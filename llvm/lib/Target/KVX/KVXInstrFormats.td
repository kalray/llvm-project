//===-- KVXInstrFormats.td - KVX Instruction Formats -------*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

def IsV1 : Predicate<"Subtarget->isV1()">;
def IsV2 : Predicate<"Subtarget->isV2()">;

class AWType<bits<3> t> { bits<3> Value = t; }

// Access types should be such that
// AWType<i> corresponds to (1 << (i-1)) size in byte
// Must keep updated with getMemWidth in KVXInstrInfo.cpp
def NoAccess : AWType<0>;
def Byte : AWType<1>;
def Half : AWType<2>;
def Word : AWType<3>;
def Double :  AWType<4>;
def Quad : AWType<5>;
def Octuple : AWType<6>;

class InstKVX : Instruction {
  bits<1> hasNoOffset = 0; // 1 if the memory instruction has no offset
  let TSFlags{0} = hasNoOffset;

  // relative position of .xs modifier from the first memory operand
  // A value of 0 means there is no .xs modifier
  bits<2> XSModRelPos = 0;
  let TSFlags{2-1} = XSModRelPos;

  AWType MemAccessSize = NoAccess; // size of memory access
  let TSFlags{5-3} = MemAccessSize.Value;
}

// Generic KVX instruction definition.
// It uses multiclass to be able to use defvar and generate input values checking
// to automatically generate a standard dag to be matched as well the output asm.
// It also sets ReadsMem if memory operands is not empty and has
// no output values. And it sets WritesMem if it does have memory
// operands and WritesMem is not set.
// It adds an input operand equals to the output when marked as InPlace.
// or if it is a memory operation with CC. It sets constraint
// $r = $z

// It defines the instruction size depending on the occurence of _X_ or _Y_ in the
// itinenary name. (8, 12 or 4 if not present).

// It sets isPredicable to true if MemOps is not empty and it has no conditional operations

// If the instruction has the modifier SilentMode, it sets mayRaiseFPException to true

// If there is a memory operands and no in/out operands, such as
// I1INVAL, DZEROL ..., the following are set by default:
// mayLoad = 0, mayStore = 0, hasSideEffects = 1

// If the instruction is and atomic swap in memory, it has a special rule to generate
// the asm string, as well it defines that it mayLoad and mayStore

// AddedComplex increases the pattern priority, making it have higher selection chance
// against other patterns that match from the same root node.

// List of arguments:
// <asm, itin, Ops, Mods, MemOps, CC, Out, InPlace, pattern, IsAtomicSwap, AddedComplex>

// String to copy/paste on use on definition of NEWINSTRUCTION:
// defm NEWINSTRUCTION : I </*asm=*/, /*itin=*/, /*Ops=*/, /*Mods=*/, /*MemOps=*/, /*CC=*/, /*Out=*/, /*InPlace=*/, /*pattern=*/, /*IsAtomicSwap=0*/, /*AddedComplex=0*/>;

// Dag to be matched:
// (outs [Out.0:$r]),
// (ins [[MemOps.0:$offset,] MemOps.1:$mem,]
//       [Ops.0:$ops0,[...Ops.N:$opsn,]]
//       [Mods.0:$mod0,...[Mods.N:$modn,]])
//       [Out.0:$z,]
//       [CC.0:$cond, CC.1:$eval]

// Command you can use to debug this:
// ./build_llvm_Debug/bin/llvm-tblgen -I llvm-project/llvm/lib/Target/KVX -I build_llvm_Debug/include -I llvm-project/llvm/include -I llvm-project/llvm/lib/Target llvm-project/llvm/lib/Target/KVX/KVX.td --print-detailed-records

multiclass I <string asm,
         InstrItinClass itin,
         list<DAGOperand> Ops = [],
         list<DAGOperand> ModsAll = [],
         list<DAGOperand> MemOps = [],
         list<DAGOperand> CC = [],
         list<DAGOperand> Out = [],
         bit InPlace = 0,
         list<dag> pat = [],
         bit IsAtomicSwap = 0,
         int AddedComplex = 0> {

    // Filter out Qindex and Splat32Mod for generating the asm string from Mods and keep it in the dag
    defvar Mods = !filter(i, ModsAll, !and(!ne(i, QindexMod),!ne(i, Splat32Mod)));
    defvar Qindex = !filter(i, ModsAll, !eq(i, QindexMod));
    defvar Splat32 = !filter(i, ModsAll, !eq(i, Splat32Mod));
    defvar EmptyList = []<string>;
    defvar EmptyOutDag = !dag(outs, []<DAGOperand>, []<string>);
    defvar EmptyInDag = !dag(ins, []<DAGOperand>, []<string>);

    // Out holds the output type, e.g. VectorReg, or none, if the instruction does not generate a value.
    defvar MemOpsTst = !gt(!size(MemOps), 2);
    if MemOpsTst then {
      def : KVX_Error<!strconcat("Can't handle instructions with ", !cast<string>(!size(MemOps)), " memory operands.")>;
    }
    defvar ModifsTst = !gt(!size(ModsAll), 3);
    if ModifsTst then {
      def : KVX_Error<!strconcat("Can't handle instructions with ", !cast<string>(!size(ModsAll)), " modifiers.")>;
    }

    defvar OutTst = !gt(!size(Out), 1);
    if OutTst then {
      def : KVX_Error<!strconcat("Can't handle instructions with ", !cast<string>(!size(Out)), " Out operands.")>;
    }

    defvar CCTst = !not(!or(!empty(CC), !eq(!size(CC), 2)));
    if CCTst then {
      def : KVX_Error<!strconcat("Can't handle instructions with ", !cast<string>(!size(CC)), " CC operands")>;
    }

    defvar OpsTst = !gt(!size(Ops), 3);
    if OpsTst then {
      def : KVX_Error<!strconcat("Can't handle instructions with ", !cast<string>(!size(Ops)), " operands.")>;
    }

    defvar AsmTst = !or(!empty(asm), !not(!isa<string>(asm)));
    if AsmTst then {
      def : KVX_Error<"Instruction should have an asm string.">;
    }

    defvar HasntItin = !and(!eq(NoItinerary, itin), !isa<InstrItinClass>(itin));
    if HasntItin then {
      def : KVX_Error<"Instruction should be given an itinerary.">;
    }

    defvar MemDag = !cond(!eq(!size(MemOps), 1): !dag(ins, MemOps, ["mem"]<string>),
                          !eq(!size(MemOps), 2): !dag(ins, MemOps, ["off", "mem"]<string>),
                          true: EmptyInDag);

    defvar OpsDag = !cond(!empty(Ops): EmptyInDag,
                          !eq(!size(Ops), 1): !dag(ins, Ops, ["op0"]),
                          !eq(!size(Ops), 2): !dag(ins, Ops, ["op0", "op1"]),
                          !eq(!size(Ops), 3): !dag(ins, Ops, ["op0", "op1", "op2"]));

    defvar ModsDag = !cond(!empty(ModsAll): EmptyInDag,
                           !eq(!size(ModsAll), 1): !dag(ins, ModsAll, ["mod0"]),
                           !eq(!size(ModsAll), 2): !dag(ins, ModsAll, ["mod0", "mod1"]),
                           !eq(!size(ModsAll), 3): !dag(ins, ModsAll, ["mod0", "mod1", "mod2"]));

    defvar InOutDag = !cond(!and(!not(!empty(Out)), !or(InPlace, !not(!empty(CC)))): !dag(ins, Out, ["z"]<string>),
                            true : EmptyInDag);

    defvar CCDag = !cond(!empty(CC): EmptyInDag,
                         true: !dag(ins, CC, ["cond", "val"]<string>));

    defvar Ins = !con(EmptyInDag, MemDag, OpsDag, ModsDag, InOutDag, CCDag);

    defvar ModsStr = !cond(!empty(Mods): "",
                      !eq(!size(Mods), 1): "$mod0",
                      !eq(!size(Mods), 2): "$mod0$mod1",
                      !eq(!size(Mods), 3): "$mod0$mod1$mod2");

    defvar QindexStr = !if(!empty(Qindex), "", "$mod" # !cast<string>(!size(Mods)));
    defvar CC_Qindex_str = !if(!empty(CC), QindexStr, "$cond" # QindexStr # " $val ?");

    if !and(!not(!empty(Splat32)), !not(!empty(Qindex))) then {
      def : KVX_Error<"There should not be Splat32 and Qindex in the same instruction">;
    }
    defvar Splat32Str = !if(!empty(Splat32), "", "$mod" # !cast<string>(!size(Mods)));

    defvar OutStr = !cond(!empty(Out) : "",
                          true : " $r");

    defvar OpsStr = !cond(!empty(Ops): "",
                          !eq(!size(Ops), 1): " $op0",
                          !eq(!size(Ops), 2): " $op0, $op1" # Splat32Str,
                          !eq(!size(Ops), 3): " $op0, $op1, $op2");

    defvar MemOpStr = !cond(!empty(MemOps) : "",
                            !eq(!size(MemOps), 1): " [$mem]",
                            true: " $off[$mem]");

    // Check if one of the elements of Mods is SilentMode, that returns a non-empty list with !filter
    defvar mayRaiseFPE = !not(!empty(!filter(i, Mods, !eq(i, SilentMod))));
    defvar isLsupack   = !not(!empty(!filter(i, Mods, !eq(i, LsupackMod))));
    defvar MemOperation = !and(!empty(Out), !empty(Ops));
    defvar ReadsMem = !or(!not(!or(!empty(MemOps), !empty(Out), MemOperation)), IsAtomicSwap);
    defvar WritesMem = !or(!xor(!xor(ReadsMem, !not(!empty(MemOps))), MemOperation), IsAtomicSwap);
    defvar CanPredicate = !and(!empty(CC), !not(!empty(MemOps)));
    // Should we add an inplace register in the input dag?
    defvar AsmStr = !cond( isLsupack : !strconcat(asm, ModsStr, OutStr, ",", OpsStr, " =", MemOpStr),
                           IsAtomicSwap : !strconcat(asm, ModsStr, CC_Qindex_str, OutStr, ", ", MemOpStr, " =", OpsStr),
                           MemOperation : !strconcat(asm, ModsStr, CC_Qindex_str, MemOpStr),
                           !eq(WritesMem, 0) : !strconcat(asm, ModsStr, CC_Qindex_str, OutStr, " =", MemOpStr, OpsStr),
                           !eq(WritesMem, 1) : !strconcat(asm, ModsStr, CC_Qindex_str, OutStr, MemOpStr, " =", OpsStr));

    defvar ItirName = !cast<string>(itin);
    defvar InstSz = !cond(!ne(ItirName, !subst("_Y_", "", ItirName)): 12,
                          !ne(ItirName, !subst("_X_", "", ItirName)): 8,
                          true : 4);

    defvar CheapAsMove = !and(!eq(InstSz, 4), !ne(ItirName, !subst("TINY", "", ItirName)));
// We define an "unamed" instruction, so it will be just the name of the definition it self.
  def "" : InstKVX {
    let isAsCheapAsAMove = CheapAsMove;
    let Pattern = pat;
    let Itinerary = itin;
    let OutOperandList = !cond(!empty(Out) : EmptyOutDag,
                               true : !dag(outs, Out, ["r"]));
    let InOperandList = Ins;
    let AsmString = AsmStr;
    let hasCompleteDecoder = false;
    let Namespace = "KVX";
    let hasSideEffects = MemOperation;
    let mayLoad = ReadsMem;
    let mayStore = WritesMem;
    let Size = InstSz;
    let Constraints = !cond(!ne(InPlace, 0): "$r = $z", true : "");
    let isPredicable = CanPredicate;
    let mayRaiseFPException = mayRaiseFPE;
    let AddedComplexity = AddedComplex;

    /* --- KVX-specific flags --- */
    let hasNoOffset = !lt(!size(MemOps), 2);

    // Position of .xs mod, relative to Mods
    defvar DoscaleModRelPos = !cond(
      !ge(!size(Mods), 3): !cond(
        !eq(Mods[0], DoscaleMod) : 0,
        !eq(Mods[1], DoscaleMod) : 1,
        !eq(Mods[2], DoscaleMod) : 2,
        true : -1),
      !ge(!size(Mods), 2): !cond(
        !eq(Mods[0], DoscaleMod) : 0,
        !eq(Mods[1], DoscaleMod) : 1,
        true : -1),
      !ge(!size(Mods), 1): !cond(
        !eq(Mods[0], DoscaleMod) : 0,
        true : -1),
      true: -1
    );

    // Position of .xs mod, relative to Memops
    let XSModRelPos = !cond(
      !gt(DoscaleModRelPos, -1) : !add(!size(MemOps), !size(Ops), DoscaleModRelPos),
      true : 0);
 }
}

multiclass MC_SIMPE<string OpcStr, InstrItinClass i, list<dag> pat = []>
      : I </*asm=*/OpcStr , /*itin=*/ i, /*Ops=*/[], /*Mods=*/[], /*MemOps=*/[], /*CC=*/[], /*Out=*/[], /*InPlace=*/0, /*pattern=*/pat>;

multiclass MC_LOADS<string OpcStr, RegisterClass RC> {
  defm ri10 : I <OpcStr, LSU_AUXW_LOAD, [], [VariantMod], [Signed10, SingleReg], [], [RC]>;
  defm ri37 : I <OpcStr, LSU_AUXW_LOAD_X_, [], [VariantMod], [Signed37, SingleReg], [], [RC]>;
  defm ri64 : I <OpcStr, LSU_AUXW_LOAD_Y_, [], [VariantMod], [Wrapped64, SingleReg], [], [RC]>;
  defm rr   : I <OpcStr, LSU_AUXW_LOAD, [], [VariantMod, DoscaleMod], [SingleReg, SingleReg], [], [RC]>;
  defm rrc  : I <OpcStr, LSU_AUXW_LOAD, [], [VariantMod], [SingleReg], [ScalarcondMod, SingleReg], [RC]>;
  defm ri27c: I <OpcStr, LSU_AUXW_LOAD_X_, [], [VariantMod], [Signed27, SingleReg], [ScalarcondMod, SingleReg], [RC]>;
  defm ri54c: I <OpcStr, LSU_AUXW_LOAD_Y_, [], [VariantMod], [Signed54, SingleReg], [ScalarcondMod, SingleReg], [RC]>;
  if !eq(RC, QuadReg) then {
    // CV2 formats
    defm rrm    : I <OpcStr, LSU_AUXW_LOAD, [], [VariantMod], [SingleReg], [LsomaskMod, SingleReg], [RC]>;
    defm ri27m : I <OpcStr, LSU_AUXW_LOAD_X_, [], [VariantMod], [Signed27, SingleReg], [LsomaskMod, SingleReg], [RC]>;
    defm ri54m : I <OpcStr, LSU_AUXW_LOAD_Y_, [], [VariantMod], [Signed54, SingleReg], [LsomaskMod, SingleReg], [RC]>;
  }
}

multiclass MC_STORES<string OpcStr, RegisterClass RC> {
  defm ri10 : I <OpcStr, LSU_AUXR_STORE_SV3, [RC], [], [Signed10, SingleReg], [], []>;
  defm ri37 : I <OpcStr, LSU_AUXR_STORE_SV3_X_, [RC], [], [Signed37, SingleReg], [], []>;
  defm ri64 : I <OpcStr, LSU_AUXR_STORE_SV3_Y_, [RC], [], [Wrapped64, SingleReg], [], []>;
  defm rr   : I <OpcStr, LSU_AUXR_STORE_SV3, [RC], [DoscaleMod], [SingleReg, SingleReg], [], []>;
  defm rrc  : I <OpcStr, LSU_AUXR_STORE_SV2, [RC], [], [SingleReg], [ScalarcondMod, SingleReg], []>;
  defm ri27c: I <OpcStr, LSU_AUXR_STORE_SV3_X_, [RC], [], [Signed27, SingleReg], [ScalarcondMod, SingleReg], []>;
  defm ri54c: I <OpcStr, LSU_AUXR_STORE_SV3_Y_, [RC], [], [Signed54, SingleReg], [ScalarcondMod, SingleReg], []>;
  if !eq(RC, QuadReg) then {
    // CV2 formats
    defm rrm  : I <OpcStr, LSU_AUXR_STORE_SV2, [RC], [], [SingleReg], [LsomaskMod, SingleReg], []>;
    defm ri27m: I <OpcStr, LSU_AUXR_STORE_SV3_X_, [RC], [], [Signed27, SingleReg], [LsomaskMod, SingleReg], []>;
    defm ri54m: I <OpcStr, LSU_AUXR_STORE_SV3_Y_, [RC], [], [Signed54, SingleReg], [LsomaskMod, SingleReg], []>;
  }
}

multiclass MC_LV<string OpcStr> {
  defm ri10  : I <OpcStr, LSU_LOAD, [], [SpeculateMod], [Signed10, SingleReg], [], [VectorReg], 0,
                  [(set v256i1:$r, (int_kvx_lv  (add SingleReg:$mem, Signed10:$off), SpeculateMod:$mod0))]>;
  defm ri37  : I <OpcStr, LSU_LOAD_X_, [], [SpeculateMod], [Signed37, SingleReg], [], [VectorReg], 0,
                  [(set v256i1:$r, (int_kvx_lv  (add SingleReg:$mem, Signed37:$off), SpeculateMod:$mod0))]>;
  defm ri64  : I <OpcStr, LSU_LOAD_Y_, [], [SpeculateMod], [Signed37, SingleReg], [], [VectorReg], 0,
                  [(set v256i1:$r, (int_kvx_lv  (add SingleReg:$mem, Wrapped64:$off), SpeculateMod:$mod0))]>;
  defm rr    : I <OpcStr, LSU_LOAD, [], [SpeculateMod, DoscaleMod], [SingleReg, SingleReg], [], [VectorReg]>;

  defm ri27c : I <OpcStr, LSU_LOAD_X_, [], [SpeculateMod], [Signed27, SingleReg], [ScalarcondMod, SingleReg], [VectorReg], 1,
                  [(set v256i1:$r, (int_kvx_lv_cond VectorReg:$z, (add SingleReg:$mem, Signed27:$off),
                                    i64:$val, SpeculateMod:$mod0, ScalarcondMod:$cond))]>;
  defm ri54c : I <OpcStr, LSU_LOAD_Y_, [], [SpeculateMod], [Signed54, SingleReg], [ScalarcondMod, SingleReg], [VectorReg], 1,
                  [(set v256i1:$r, (int_kvx_lv_cond VectorReg:$z, (add SingleReg:$mem, Signed54:$off),
                                    i64:$val, SpeculateMod:$mod0, ScalarcondMod:$cond))]>;
  defm rrc   : I <OpcStr, LSU_LOAD, [], [SpeculateMod], [SingleReg], [ScalarcondMod, SingleReg], [VectorReg], 1,
                  [(set v256i1:$r, (int_kvx_lv_cond VectorReg:$z, SingleReg:$mem,
                                    i64:$val, SpeculateMod:$mod0, ScalarcondMod:$cond))]>;

  defm ri10cs : I <OpcStr, LSU_LOAD, [], [SpeculateMod, QindexMod], [Signed10, SingleReg], [], [MatrixReg], 1,
                  [(set v1024i1:$r, (int_kvx_lvc MatrixReg:$z, (add SingleReg:$mem, Signed10:$off),
                                    SpeculateMod:$mod0, QindexMod:$mod1))]>;
  defm ri37cs : I <OpcStr, LSU_LOAD_X_, [], [SpeculateMod, QindexMod], [Signed37, SingleReg], [], [MatrixReg], 1,
                  [(set v1024i1:$r, (int_kvx_lvc MatrixReg:$z, (add SingleReg:$mem, Signed37:$off),
                                    SpeculateMod:$mod0, QindexMod:$mod1))]>;
  defm ri64cs : I <OpcStr, LSU_LOAD_Y_, [], [SpeculateMod, QindexMod], [Wrapped64, SingleReg], [], [MatrixReg], 1,
                  [(set v1024i1:$r, (int_kvx_lvc MatrixReg:$z, (add SingleReg:$mem, Wrapped64:$off),
                                    SpeculateMod:$mod0, QindexMod:$mod1))]>;
  defm rrcs : I <OpcStr, LSU_LOAD, [], [SpeculateMod, QindexMod, DoscaleMod], [SingleReg, SingleReg], [], [MatrixReg], 1>;

  defm ri27ccs : I <OpcStr, LSU_LOAD_X_, [], [SpeculateMod, QindexMod], [Signed27, SingleReg], [ScalarcondMod, SingleReg], [MatrixReg], 1,
                  [(set v1024i1:$r, (int_kvx_lvc_cond MatrixReg:$z, (add SingleReg:$mem, Signed27:$off),
                                    i64:$val, SpeculateMod:$mod0, QindexMod:$mod1, ScalarcondMod:$cond))]>;

  defm ri54ccs : I <OpcStr, LSU_LOAD_Y_, [], [SpeculateMod, QindexMod], [Signed54, SingleReg], [ScalarcondMod, SingleReg], [MatrixReg], 1,
                  [(set v1024i1:$r, (int_kvx_lvc_cond v1024i1:$z, (add SingleReg:$mem, Signed54:$off),
                                    i64:$val, SpeculateMod:$mod0, QindexMod:$mod1, ScalarcondMod:$cond))]>;
  defm rrccs : I <OpcStr, LSU_LOAD, [], [SpeculateMod, QindexMod], [SingleReg], [ScalarcondMod, SingleReg], [MatrixReg]>;
}

multiclass MC_XLO <string OpcStr = "xlo"> {
  // xlovariant registerA = signed10[registerZ]
  defm ri10 : I <OpcStr, LSU_XLOAD, [], [VariantMod], [Signed10, SingleReg], [], [VectorReg], 0,
                [(set v256i1:$r, (int_kvx_xload256 (add i64:$mem, Signed10:$off), VariantMod:$mod0))]>;
  // xlovariant registerA = upper27 lower10[registerZ]
  defm ri37 : I <OpcStr, LSU_XLOAD_X_, [], [VariantMod], [Signed37, SingleReg], [], [VectorReg], 0,
                [(set v256i1:$r, (int_kvx_xload256 (add i64:$mem, Signed37:$off), VariantMod:$mod0))]>;
  // xlovariant registerA = extend27 upper27 lower10[registerZ]
  defm ri64 : I <OpcStr, LSU_XLOAD_Y_, [], [VariantMod], [Wrapped64, SingleReg], [], [VectorReg], 0,
                [(set v256i1:$r, (int_kvx_xload256 (add i64:$mem, Wrapped64:$off), VariantMod:$mod0))]>;

  // xlovariantqindex registerAq = signed10[registerZ]
  defm ri10q : I <OpcStr, LSU_XLOAD, [], [VariantMod, QindexMod], [Signed10, SingleReg], [], [MatrixReg], 1,
                [/* no straightforward pattern */]>;
  // xlovariantqindex registerAq = upper27 lower10[registerZ]
  defm ri37q : I <OpcStr, LSU_XLOAD_X_, [], [VariantMod, QindexMod], [Signed37, SingleReg], [], [MatrixReg], 1,
                [/* no straightforward pattern */]>;
  //xlovariantqindex registerAq = extend27 upper27 lower10[registerZ]
  defm ri64q : I <OpcStr, LSU_XLOAD_Y_, [], [VariantMod, QindexMod], [Wrapped64, SingleReg], [], [MatrixReg], 1,
                [/* no straightforward pattern */]>;

  // xlovariantlsumask registerY? registerA = [registerZ]
  defm rrc    : I <OpcStr, LSU_XLOAD, [], [VariantMod], [SingleReg], [LsumaskMod, SingleReg], [VectorReg], 1,
                  [(set v256i1:$r, (int_kvx_xloadc256 v256i1:$z, i64:$mem, i64:$val, VariantMod:$mod0, LsumaskMod:$cond))]>;
  // xlovariantlsumask registerY? registerA = offset27[registerZ]
  defm ri27c : I <OpcStr, LSU_XLOAD_X_, [], [VariantMod], [Signed27, SingleReg], [LsumaskMod, SingleReg], [VectorReg], 1,
                  [(set v256i1:$r, (int_kvx_xloadc256 v256i1:$z, (add i64:$mem, Signed27:$off), i64:$val, VariantMod:$mod0, LsumaskMod:$cond))]>;
  // xlovariantlsumask registerY? registerA = extend27 offset27[registerZ]
  defm ri54c : I <OpcStr, LSU_XLOAD_Y_, [], [VariantMod], [Signed54, SingleReg], [LsumaskMod, SingleReg], [VectorReg], 1,
                  [(set v256i1:$r, (int_kvx_xloadc256 v256i1:$z, (add i64:$mem, Signed54:$off), i64:$val, VariantMod:$mod0, LsumaskMod:$cond))]>;

  // xlovariantlsumaskqindex registerY? registerAq = [registerZ]
  defm rrcq    : I <OpcStr, LSU_XLOAD, [], [VariantMod, QindexMod], [SingleReg], [LsumaskMod, SingleReg], [MatrixReg], 1,
                  [/* no straightforward pattern */]>;
  // xlovariantlsumaskqindex registerY? registerAq = offset27[registerZ]
  defm ri27cq : I <OpcStr, LSU_XLOAD_X_, [], [VariantMod, QindexMod], [Signed27, SingleReg], [LsumaskMod, SingleReg], [MatrixReg], 1,
                    [/* no straightforward pattern */]>;
  // xlovariantlsumaskqindex registerY? registerAq = extend27 offset27[registerZ]
  defm ri54cq : I <OpcStr, LSU_XLOAD_Y_, [], [VariantMod, QindexMod], [Signed54, SingleReg], [LsumaskMod, SingleReg], [MatrixReg], 1,
                    [/* no straightforward pattern */]>;

  // xlovariantlsupack registerAg, registerY = [registerZ]
  defm rvp    : I <OpcStr, LSU_XLOAD, [SingleReg], [VariantMod, LsupackMod], [SingleReg], [], [BufferReg], 1>;

  // xlovariantlsupack registerAg, registerY = offset27[registerZ]
  defm ri27vp : I <OpcStr, LSU_XLOAD_X_, [SingleReg], [VariantMod, LsupackMod], [Signed27, SingleReg], [], [BufferReg], 1>;

  // xlovariantlsupack registerAg, registerY = extend27 offset27[registerZ]
  defm ri54vp : I <OpcStr, LSU_XLOAD_Y_, [SingleReg], [VariantMod, LsupackMod], [Signed54, SingleReg], [], [BufferReg], 1>;

  // xlovariantdoscale registerA = registerY[registerZ]
  defm rr     : I <OpcStr, LSU_XLOAD, [], [VariantMod, DoscaleMod], [SingleReg, SingleReg], [], [VectorReg]>;
  // xlovariantdoscaleqindex registerAq = registerY[registerZ]
  defm rrq    : I <OpcStr, LSU_XLOAD, [], [VariantMod, DoscaleMod, QindexMod], [SingleReg, SingleReg], [], [MatrixReg], 1>;
}

multiclass MC_SV <string OpcStr> {
  defm ri10 : I <OpcStr, LSU_CRRP_STORE, [VectorReg], [], [Signed10, SingleReg], [], [], 0,
                 [(int_kvx_sv  (add i64:$mem, Signed10:$off), v256i1:$op0)]>;

  defm ri37 : I <OpcStr, LSU_CRRP_STORE_X_, [VectorReg], [], [Signed10, SingleReg], [], [], 0,
                 [(int_kvx_sv  (add i64:$mem, Signed37:$off), v256i1:$op0)]>;

  defm ri64 : I <OpcStr, LSU_CRRP_STORE_Y_, [VectorReg], [], [Signed10, SingleReg], [], [], 0,
                 [(int_kvx_sv  (add i64:$mem, Wrapped64:$off), v256i1:$op0)]>;

  defm rr : I <OpcStr, LSU_CRRP_STORE, [VectorReg], [DoscaleMod], [SingleReg, SingleReg]>;

  defm ri27c : I <OpcStr, LSU_CRRP_STORE_X_, [VectorReg], [], [Signed27, SingleReg], [ScalarcondMod, SingleReg], [], 0,
                 [(int_kvx_sv_cond  (add i64:$mem, Signed27:$off), v256i1:$op0, i64:$val, ScalarcondMod:$cond)]>;

  defm ri54c : I <OpcStr, LSU_CRRP_STORE_Y_, [VectorReg], [], [Signed54, SingleReg], [ScalarcondMod, SingleReg], [], 0,
                 [(int_kvx_sv_cond  (add i64:$mem, Signed54:$off), v256i1:$op0, i64:$val, ScalarcondMod:$cond)]>;

  defm rrc : I <OpcStr, LSU_CRRP_STORE, [VectorReg], [], [SingleReg], [ScalarcondMod, SingleReg], [], 0,
                 [(int_kvx_sv_cond  i64:$mem, v256i1:$op0, i64:$val, ScalarcondMod:$cond)]>;
}

multiclass MC_XSO <string OpcStr = "xso"> {
  // xso signed10[registerZ] = registerE
  defm ri10 : I <OpcStr, LSU_CRRP_STORE, [VectorReg], [], [Signed10, SingleReg], [], [], 0,
                [(int_kvx_xstore256 v256i1:$op0, (add i64:$mem, Signed10:$off))]>;
  // xso upper27 lower10[registerZ] = registerE
  defm ri37 : I <OpcStr, LSU_CRRP_STORE_X_, [VectorReg], [], [Signed37, SingleReg], [], [], 0,
                [(int_kvx_xstore256 v256i1:$op0, (add i64:$mem, Signed37:$off))]>;
  // xso extend27 upper27 lower10[registerZ] = registerE
  defm ri64 : I <OpcStr, LSU_CRRP_STORE_Y_, [VectorReg], [], [Wrapped64, SingleReg], [], [], 0,
                [(int_kvx_xstore256 v256i1:$op0, (add i64:$mem, Wrapped64:$off))]>;

  // xsolsumask registerY? [registerZ] = registerE
  defm rrc    : I <OpcStr, LSU_CRRP_STORE, [VectorReg], [], [SingleReg], [LsumaskMod, SingleReg], [], 0,
                  [(int_kvx_xstorec256 v256i1:$op0, i64:$mem, i64:$val, LsumaskMod:$cond)]>;
  // xsolsumask registerY? offset27[registerZ] = registerE
  defm ri27c : I <OpcStr, LSU_CRRP_STORE_X_, [VectorReg], [], [Signed27, SingleReg], [LsumaskMod, SingleReg], [], 0,
                  [(int_kvx_xstorec256 v256i1:$op0, (add i64:$mem, Signed27:$off), i64:$val, LsumaskMod:$cond)]>;
  // xsolsumask registerY? extend27 offset27[registerZ] = registerE
  defm ri54c : I <OpcStr, LSU_CRRP_STORE_Y_, [VectorReg], [], [Signed54, SingleReg], [LsumaskMod, SingleReg], [], 0,
                  [(int_kvx_xstorec256 v256i1:$op0, (add i64:$mem, Signed54:$off), i64:$val, LsumaskMod:$cond)]>;

  // xsodoscale registerY[registerZ] = registerE
  defm rr     : I <OpcStr, LSU_CRRP_STORE, [VectorReg], [DoscaleMod], [SingleReg, SingleReg], [], []>;
}

class KVX_INSTRUCTION
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin,
   int syllables=1>
  : InstKVX {
    dag OutOperandList = outs;
    dag InOperandList = ins;
    let AsmString = asmstr;
    let Pattern = pattern;
    let Itinerary = itin;
    let Namespace = "KVX";
    let hasCompleteDecoder = false;
    let Size = !mul(syllables, 4);
  }

class KVX_INSTRUCTION_X
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin, 2>;

class KVX_INSTRUCTION_Y
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin, 3>;

class KVX_PSEUDO
  <dag outs, dag ins, list<dag> pattern, string asmstr = "pseudo">
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, NoItinerary, 0> {
    let isPseudo = 1;
    let isCodeGenOnly = 1;
    let hasNoSchedulingInfo = 1;
  }

class KVX_PSEUDO_W_SCHEDINFO
  <dag outs, dag ins, list<dag> pattern, InstrItinClass itin, string asmstr = "pseudo">
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin, 0> {
    let isPseudo = 1;
    let isCodeGenOnly = 1;
    let Itinerary = itin;
  }

let Constraints = "$out = $acc" in
class ROUNDING_SILENT_TERNARY_AUXR_FP <string OpcStr, RegisterClass RC_OUT, RegisterClass RC_IN, InstrItinClass itin>
  : KVX_INSTRUCTION <
    (outs RC_OUT:$out),
    (ins RC_OUT:$acc, RC_IN:$lhs, RC_IN:$rhs, RoundingMod:$r, SilentMod:$s),
    !strconcat (OpcStr, "$r$s $out = $lhs, $rhs"),
    [],
    itin>;

let Constraints = "$o = $a" in
class TERNARY<string Opcode, RegisterClass RC_OUT, RegisterClass RC_LHS, RegisterClass RC_RHS, InstrItinClass Itin, list<dag> Patt = []>
    : KVX_INSTRUCTION <
     (outs RC_OUT:$o),
     (ins RC_OUT:$a, RC_LHS:$lhs, RC_RHS:$rhs),
     !strconcat (Opcode, " $o = $lhs, $rhs"),
     Patt,
     Itin>;

let Constraints = "$o = $a" in
class ROUNDING_SILENT_TERNARY <string Opcode, RegisterClass RC_OUT, RegisterClass RC_LHS, RegisterClass RC_RHS, InstrItinClass Itin, list<dag> Patt = []>
    : KVX_INSTRUCTION <
     (outs RC_OUT:$o),
     (ins RC_OUT:$a, RC_LHS:$lhs, RC_RHS:$rhs, RoundingMod:$r, SilentMod:$s),
     !strconcat (Opcode, "$r$s $o = $lhs, $rhs"),
     Patt,
     Itin>;

class ROUNDING_SILENT_UNARY<string Opcode, RegisterClass RC_OUT, RegisterClass RC_IN, InstrItinClass Itin, list<dag> Patt = []>
    : KVX_INSTRUCTION <
     (outs RC_OUT:$o),
     (ins RC_IN:$i, RoundingMod:$r, SilentMod:$s),
     !strconcat (Opcode, "$r$s $o = $i"),
     Patt,
     Itin>;

class UNARY <string Opcode, RegisterClass RC_OUT, RegisterClass RC_IN, InstrItinClass Itin, list<dag> Patt = []>
    : KVX_INSTRUCTION <
     (outs RC_OUT:$o),
     (ins RC_IN:$i),
     !strconcat (Opcode, " $o = $i"),
     Patt,
     Itin>;

class ROUNDING_SILENT_BINOP<string Opcode, RegisterClass RC_OUT, RegisterClass RC_LHS, RegisterClass RC_RHS, InstrItinClass Itin, list<dag> Patt = []>
    : KVX_INSTRUCTION <
     (outs RC_OUT:$o),
     (ins RC_LHS:$lhs, RC_RHS:$rhs, RoundingMod:$r, SilentMod:$s),
     !strconcat (Opcode, "$r$s $o = $lhs, $rhs"),
     Patt,
     Itin>;

class CACHE_OP<string Opcode, RegisterClass RC, InstrItinClass Itin, list<dag> Patt = []>
    : KVX_INSTRUCTION <
     (outs),
     (ins RC:$way, RC:$set, CacheLevelMod:$c),
     !strconcat (Opcode, "$c $set, $way"),
     Patt,
     Itin>;

class ROUNDING_SILENT_BINOP_FFDM<string OpcStr, RegisterClass RC_OUT, RegisterClass RC_IN, InstrItinClass itin>
    : ROUNDING_SILENT_BINOP <OpcStr, RC_OUT, RC_IN, RC_IN, itin>;


class CONJ_ROUNDING_SILENT_BINOP<string OpcStr, RegisterClass RC_OUT, RegisterClass RC_IN, InstrItinClass itin>
    : KVX_INSTRUCTION <
     (outs RC_OUT:$o),
     (ins RC_IN:$lhs, RC_IN:$rhs, ConjugateMod:$c, RoundingMod:$r, SilentMod:$s),
     !strconcat (OpcStr, "$c$r$s $o = $lhs, $rhs"),
     [/* no straightforward pattern */],
     itin>;

class KVX_INSTRUCTION_CV1_X
  <dag outs, dag ins, string asmstr, list<dag> pattern,
   InstrItinClass itin>
  : KVX_INSTRUCTION_X <outs, ins, asmstr, pattern, itin> {
    let Predicates = [IsV1];
  }

class KVX_INSTRUCTION_CV1_Y
  <dag outs, dag ins, string asmstr, list<dag> pattern,
   InstrItinClass itin>
  : KVX_INSTRUCTION_Y <outs, ins, asmstr, pattern, itin> {
    let Predicates = [IsV1];
  }

class KVX_INSTRUCTION_CV2
  <dag outs, dag ins, string asmstr, list<dag> pattern,
   InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin> {
    let Predicates = [IsV2];
  }

multiclass MC_XMOVETQ<string OpcStr, InstrItinClass L, InstrItinClass H> {
  defm rrbe : I <OpcStr, L, [SingleReg, SingleReg], [], [], [], [BlockRegE]>;
  defm rrbo : I <OpcStr, H, [SingleReg, SingleReg], [], [], [], [BlockRegO]>;
}

multiclass MC_XMOVETD<string OpcStr, InstrItinClass L, InstrItinClass H> {
  foreach i = [0, 1, 2, 3] in
    defm rc#i#m4 : I <OpcStr, !if(!lt(i, 2), L, H), [SingleReg], [], [], [], [!cast<DAGOperand>(CoproReg#i#M4)]>;
}

multiclass CV2_ATOMIC_LOAD <string Opc, Intrinsic Int, ValueType VT,  RegisterClass RC = SingleReg> {
  defm r : I</*asm=*/Opc, /*itin=*/LSU_AUXW_LOAD, /*Ops=*/[], /*Mods=*/[CoherencyMod], /*MemOps=*/[SingleReg], /*CC=*/[], /*Out=*/[RC], /*InPlace=*/0,
  /*pattern=*/ [(set VT:$r, (Int i64:$mem, CoherencyMod:$mod0))]>;
  defm ri27 : I</*asm=*/Opc, /*itin=*/LSU_AUXW_LOAD_X_, /*Ops=*/[], /*Mods=*/[CoherencyMod], /*MemOps=*/[Signed27, SingleReg], /*CC=*/[], /*Out=*/[RC], /*InPlace=*/0,
  /*pattern=*/ [(set VT:$r, (Int (add i64:$mem, Signed27:$off), CoherencyMod:$mod0))]>;
  defm ri54 : I</*asm=*/Opc, /*itin=*/LSU_AUXW_LOAD_Y_, /*Ops=*/[], /*Mods=*/[CoherencyMod], /*MemOps=*/[Signed54, SingleReg], /*CC=*/[], /*Out=*/[RC], /*InPlace=*/0,
  /*pattern=*/ [(set VT:$r, (Int (add i64:$mem, Signed54:$off), CoherencyMod:$mod0))]>;
}

multiclass CV2_ATOMIC_STORE <string Opc, Intrinsic Int, ValueType VT,  RegisterClass RC = SingleReg> {
  defm r : I</*asm=*/Opc, /*itin=*/LSU_AUXR_STORE_SV2, /*Ops=*/[RC], /*Mods=*/[CoherencyMod], /*MemOps=*/[SingleReg], /*CC=*/[], /*Out=*/[], /*InPlace=*/0,
  /*pattern=*/ [(Int i64:$mem, VT:$op0, CoherencyMod:$mod0)]>;
  defm ri27 : I</*asm=*/Opc, /*itin=*/LSU_AUXR_STORE_SV3_X_, /*Ops=*/[RC], /*Mods=*/[CoherencyMod], /*MemOps=*/[Signed27, SingleReg], /*CC=*/[], /*Out=*/[], /*InPlace=*/0,
  /*pattern=*/ [(Int (add i64:$mem, Signed27:$off), VT:$op0, CoherencyMod:$mod0)]>;
  defm ri54 : I</*asm=*/Opc, /*itin=*/LSU_AUXR_STORE_SV3_Y_, /*Ops=*/[RC], /*Mods=*/[CoherencyMod], /*MemOps=*/[Signed54, SingleReg], /*CC=*/[], /*Out=*/[], /*InPlace=*/0,
  /*pattern=*/ [(Int (add i64:$mem, Signed54:$off), VT:$op0, CoherencyMod:$mod0)]>;
}

multiclass XSPLATDO_MC <string Opc = "xsplatdo"> {
  defm i16: I</*asm=*/Opc, /*itin=*/ALU_TINY_CRWL_CRWH, /*Ops=*/[Signed16], /*Mods=*/[], /*MemOps=*/[], /*CC=*/[], /*Out=*/[VectorReg], /*InPlace=*/0,
  /*pattern=*/ [(set v256i1:$r, (int_kvx_xsplatdo Signed10:$op0))]>;
  defm i43: I</*asm=*/Opc, /*itin=*/ALU_TINY_CRWL_CRWH_X_, /*Ops=*/[Signed43], /*Mods=*/[], /*MemOps=*/[], /*CC=*/[], /*Out=*/[VectorReg], /*InPlace=*/0,
  /*pattern=*/ [(set v256i1:$r, (int_kvx_xsplatdo Signed37:$op0))]>;
  defm i64: I</*asm=*/Opc, /*itin=*/ALU_TINY_CRWL_CRWH_Y_, /*Ops=*/[Wrapped64], /*Mods=*/[], /*MemOps=*/[], /*CC=*/[], /*Out=*/[VectorReg], /*InPlace=*/0,
  /*pattern=*/ [(set v256i1:$r, (int_kvx_xsplatdo Wrapped64:$op0))]>;
}

//   defm DPURGEL
//   defm DFLUSHL
multiclass DCACHE_MC<string Opc, Intrinsic Int> {
  defm ri10 : I</*asm=*/Opc, /*itin=*/LSU_AUXW_LOAD, /*Ops=*/[], /*Mods=*/[], /*MemOps=*/[Signed10, SingleReg],
  /*CC=*/[], /*Out=*/[], /*InPlace=*/0, /*pattern=*/ [(Int (add i64:$mem, Signed10:$off))]>;

  defm ri37 : I</*asm=*/Opc, /*itin=*/LSU_AUXW_LOAD_X_, /*Ops=*/[], /*Mods=*/[], /*MemOps=*/[Signed37, SingleReg],
  /*CC=*/[], /*Out=*/[], /*InPlace=*/0, /*pattern=*/ [(Int (add i64:$mem, Signed37:$off))]>;

  defm ri64 : I</*asm=*/Opc, /*itin=*/LSU_AUXW_LOAD_Y_, /*Ops=*/[], /*Mods=*/[], /*MemOps=*/[Wrapped64, SingleReg],
  /*CC=*/[], /*Out=*/[], /*InPlace=*/0, /*pattern=*/ [(Int (add i64:$mem, Wrapped64:$off))]>;

  defm rr : I</*asm=*/Opc, /*itin=*/LSU_AUXW_LOAD, /*Ops=*/[], /*Mods=*/[DoscaleMod], /*MemOps=*/[SingleReg, SingleReg]>;
}
