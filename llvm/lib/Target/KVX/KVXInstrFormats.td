//===-- KVXInstrFormats.td - KVX Instruction Formats -------*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

// This is a hack to get an error message as assert does not work
class KVX_Error<string s> {
  dag fail = !dag(ins, []<DAGOperand>, [s]<string>);
}

def IsV1 : Predicate<"Subtarget->isV1()">;
def IsV2 : Predicate<"Subtarget->isV2()">;

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

// List of arguments:
// <asm, itin, Ops, Mods, MemOps, CC, Out, InPlace, pattern>

// String to copy/paste on use on definition of NEWINSTRUCTION:
// defm NEWINSTRUCTION : I </*asm=*/, /*itin=*/, /*Ops=*/, /*Mods=*/, /*MemOps=*/, /*CC=*/, /*Out=*/, /*InPlace=*/, /*pattern=*/>;

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
         list<dag> pat = []> {

    // Filter out Qindex for generating the asm string from Mods and keep it in the dag
    defvar Mods = !filter(i, ModsAll, !not(!eq(i, QindexMod)));
    defvar Qindex = !filter(i, ModsAll, !eq(i, QindexMod));
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

    defvar OutStr = !cond(!empty(Out) : "",
                          true : " $r");

    defvar OpsStr = !cond(!empty(Ops): "",
                          !eq(!size(Ops), 1): " $op0",
                          !eq(!size(Ops), 2): " $op0, $op1",
                          !eq(!size(Ops), 3): " $op0, $op1, $op2");

    defvar MemOpStr = !cond(!empty(MemOps) : "",
                            !eq(!size(MemOps), 1): " [$mem]",
                            true: " $off[$mem]");

    // Check if one of the elements of Mods is SilentMode, that returns a non-empty list with !filter
    defvar mayRaiseFPE = !not(!empty(!filter(i, Mods, !eq(i, SilentMod))));

    defvar MemOperation = !and(!empty(Out), !empty(Ops));
    defvar ReadsMem = !not(!or(!empty(MemOps), !empty(Out), MemOperation));
    defvar WritesMem = !xor(!xor(ReadsMem, !not(!empty(MemOps))), MemOperation);

    defvar CanPredicate = !and(!empty(CC), !not(!empty(MemOps)));
    // Should we add an inplace register in the input dag?
    defvar AsmStr = !cond( !eq(WritesMem, 0) : !strconcat(asm, ModsStr, CC_Qindex_str, OutStr, " =", MemOpStr, OpsStr),
                           !eq(WritesMem, 1) : !strconcat(asm, ModsStr, CC_Qindex_str, OutStr, MemOpStr, " =", OpsStr));

    defvar ItirName = !cast<string>(itin);
    defvar InstSz = !cond(!ne(ItirName, !subst("_Y_", "", ItirName)): 12,
                          !ne(ItirName, !subst("_X_", "", ItirName)): 8,
                          true : 4);
// We define an "unamed" instruction, so it will be just the name of the definition it self.
  def "" : Instruction {
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
 }
}

multiclass MC_SIMPE<string OpcStr, InstrItinClass i, list<dag> pat = []>
      : I </*asm=*/OpcStr , /*itin=*/ i, /*Ops=*/[], /*Mods=*/[], /*MemOps=*/[], /*CC=*/[], /*Out=*/[], /*InPlace=*/0, /*pattern=*/pat>;

multiclass MC_LOADS<string OpcStr, RegisterClass RC> {
  defm ri10 : I <OpcStr, LSU_AUXW_LOAD, [], [VariantMod], [Signed10, SingleReg], [], [RC]>;
  defm ri37 : I <OpcStr, LSU_AUXW_X_LOAD, [], [VariantMod], [Signed37, SingleReg], [], [RC]>;
  defm ri64 : I <OpcStr, LSU_AUXW_Y_LOAD, [], [VariantMod], [Wrapped64, SingleReg], [], [RC]>;
  defm rr   : I <OpcStr, LSU_AUXW_LOAD, [], [VariantMod, DoscaleMod], [SingleReg, SingleReg], [], [RC]>;
  defm rrc  : I <OpcStr, LSU_AUXW_LOAD, [], [VariantMod], [SingleReg], [ScalarcondMod, SingleReg], [RC]>;
  defm ri27c: I <OpcStr, LSU_AUXW_X_LOAD, [], [VariantMod], [Signed27, SingleReg], [ScalarcondMod, SingleReg], [RC]>;
  defm ri54c: I <OpcStr, LSU_AUXW_Y_LOAD, [], [VariantMod], [Signed54, SingleReg], [ScalarcondMod, SingleReg], [RC]>;
}

multiclass MC_STORES<string OpcStr, RegisterClass RC> {
  defm ri10 : I <OpcStr, LSU_AUXR_STORE, [RC], [], [Signed10, SingleReg], [], []>;
  defm ri37 : I <OpcStr, LSU_AUXR_X_STORE, [RC], [], [Signed37, SingleReg], [], []>;
  defm ri64 : I <OpcStr, LSU_AUXR_Y_STORE, [RC], [], [Wrapped64, SingleReg], [], []>;
  defm rr   : I <OpcStr, LSU_AUXR_STORE, [RC], [DoscaleMod], [SingleReg, SingleReg], [], []>;
  defm rrc  : I <OpcStr, LSU_AUXR_STORE, [RC], [], [SingleReg], [ScalarcondMod, SingleReg], []>;
  defm ri27c: I <OpcStr, LSU_AUXR_X_STORE, [RC], [], [Signed27, SingleReg], [ScalarcondMod, SingleReg], []>;
  defm ri54c: I <OpcStr, LSU_AUXR_Y_STORE, [RC], [], [Signed54, SingleReg], [ScalarcondMod, SingleReg], []>;
}

multiclass MC_LV<string OpcStr> {
  defm ri10  : I <OpcStr, LSU_LOAD, [], [SpeculateMod], [Signed10, SingleReg], [], [VectorReg], 0,
                  [(set v256i1:$r, (int_kvx_lv  (add SingleReg:$mem, Signed10:$off), SpeculateMod:$mod0))]>;
  defm ri37  : I <OpcStr, LSU_X_LOAD, [], [SpeculateMod], [Signed37, SingleReg], [], [VectorReg], 0,
                  [(set v256i1:$r, (int_kvx_lv  (add SingleReg:$mem, Signed37:$off), SpeculateMod:$mod0))]>;
  defm ri64  : I <OpcStr, LSU_Y_LOAD, [], [SpeculateMod], [Signed37, SingleReg], [], [VectorReg], 0,
                  [(set v256i1:$r, (int_kvx_lv  (add SingleReg:$mem, Wrapped64:$off), SpeculateMod:$mod0))]>;
  defm rr    : I <OpcStr, LSU_LOAD, [], [SpeculateMod, DoscaleMod], [SingleReg, SingleReg], [], [VectorReg]>;

  defm ri27c : I <OpcStr, LSU_X_LOAD, [], [SpeculateMod], [Signed27, SingleReg], [ScalarcondMod, SingleReg], [VectorReg], 1,
                  [(set v256i1:$r, (int_kvx_lv_cond VectorReg:$z, (add SingleReg:$mem, Signed27:$off),
                                    i64:$val, SpeculateMod:$mod0, ScalarcondMod:$cond))]>;
  defm ri54c : I <OpcStr, LSU_Y_LOAD, [], [SpeculateMod], [Signed54, SingleReg], [ScalarcondMod, SingleReg], [VectorReg], 1,
                  [(set v256i1:$r, (int_kvx_lv_cond VectorReg:$z, (add SingleReg:$mem, Signed54:$off),
                                    i64:$val, SpeculateMod:$mod0, ScalarcondMod:$cond))]>;
  defm rrc   : I <OpcStr, LSU_LOAD, [], [SpeculateMod], [SingleReg], [ScalarcondMod, SingleReg], [VectorReg], 1,
                  [(set v256i1:$r, (int_kvx_lv_cond VectorReg:$z, SingleReg:$mem,
                                    i64:$val, SpeculateMod:$mod0, ScalarcondMod:$cond))]>;

  defm ri10cs : I <OpcStr, LSU_LOAD, [], [ColumnMod, SpeculateMod], [Signed10, SingleReg], [], [MatrixReg], 1,
                  [(set v1024i1:$r, (int_kvx_lvc MatrixReg:$z, (add SingleReg:$mem, Signed10:$off),
                                    ColumnMod:$mod0, SpeculateMod:$mod1))]>;
  defm ri37cs : I <OpcStr, LSU_X_LOAD, [], [ColumnMod, SpeculateMod], [Signed37, SingleReg], [], [MatrixReg], 1,
                  [(set v1024i1:$r, (int_kvx_lvc MatrixReg:$z, (add SingleReg:$mem, Signed37:$off),
                                    ColumnMod:$mod0, SpeculateMod:$mod1))]>;
  defm ri64cs : I <OpcStr, LSU_Y_LOAD, [], [ColumnMod, SpeculateMod], [Wrapped64, SingleReg], [], [MatrixReg], 1,
                  [(set v1024i1:$r, (int_kvx_lvc MatrixReg:$z, (add SingleReg:$mem, Wrapped64:$off),
                                    ColumnMod:$mod0, SpeculateMod:$mod1))]>;
  defm rrcs : I <OpcStr, LSU_LOAD, [], [ColumnMod, SpeculateMod, DoscaleMod], [SingleReg, SingleReg], [], [MatrixReg], 1>;

  defm ri27ccs : I <OpcStr, LSU_X_LOAD, [], [ColumnMod, SpeculateMod], [Signed27, SingleReg], [ScalarcondMod, SingleReg], [MatrixReg], 1,
                  [(set v1024i1:$r, (int_kvx_lvc_cond MatrixReg:$z, (add SingleReg:$mem, Signed27:$off),
                                    i64:$val, ColumnMod:$mod0, SpeculateMod:$mod1, ScalarcondMod:$cond))]>;

  defm ri54ccs : I <OpcStr, LSU_Y_LOAD, [], [ColumnMod, SpeculateMod], [Signed54, SingleReg], [ScalarcondMod, SingleReg], [MatrixReg], 1,
                  [(set v1024i1:$r, (int_kvx_lvc_cond v1024i1:$z, (add SingleReg:$mem, Signed54:$off),
                                    i64:$val, ColumnMod:$mod0, SpeculateMod:$mod1, ScalarcondMod:$cond))]>;
  defm rrccs : I <OpcStr, LSU_LOAD, [], [ColumnMod, SpeculateMod], [SingleReg], [ScalarcondMod, SingleReg], [MatrixReg]>;
}

multiclass MC_XLO <string OpcStr = "xlo"> {
  //xlovariant registerA = signed10[registerZ]
  defm ri10 : I <OpcStr, LSU_LOAD, [], [VariantMod], [Signed10, SingleReg], [], [VectorReg], 0,
                [(set v256i1:$r, (int_kvx_xload256 (add i64:$mem, Signed10:$off), VariantMod:$mod0))]>;
  //xlovariant registerA = upper27 lower10[registerZ]
  defm ri37 : I <OpcStr, LSU_X_LOAD, [], [VariantMod], [Signed37, SingleReg], [], [VectorReg], 0,
                [(set v256i1:$r, (int_kvx_xload256 (add i64:$mem, Signed37:$off), VariantMod:$mod0))]>;
  //xlovariant registerA = extend27 upper27 lower10[registerZ]
  defm ri64 : I <OpcStr, LSU_Y_LOAD, [], [VariantMod], [Wrapped64, SingleReg], [], [VectorReg], 0,
                [(set v256i1:$r, (int_kvx_xload256 (add i64:$mem, Wrapped64:$off), VariantMod:$mod0))]>;

  //xlovariantqindex registerAq = signed10[registerZ]
  defm ri10q : I <OpcStr, LSU_LOAD, [], [VariantMod, QindexMod], [Signed10, SingleReg], [], [MatrixReg], 1,
                [(set v1024i1:$r, (int_kvx_xloads1024 v1024i1:$z, (add i64:$mem, Signed10:$off), VariantMod:$mod0, QindexMod:$mod1))]>;
  //xlovariantqindex registerAq = upper27 lower10[registerZ]
  defm ri37q : I <OpcStr, LSU_X_LOAD, [], [VariantMod, QindexMod], [Signed37, SingleReg], [], [MatrixReg], 1,
                [(set v1024i1:$r, (int_kvx_xloads1024 v1024i1:$z, (add i64:$mem, Signed37:$off), VariantMod:$mod0, QindexMod:$mod1))]>;
  //xlovariantqindex registerAq = extend27 upper27 lower10[registerZ]
  defm ri64q : I <OpcStr, LSU_Y_LOAD, [], [VariantMod, QindexMod], [Wrapped64, SingleReg], [], [MatrixReg], 1,
                [(set v1024i1:$r, (int_kvx_xloads1024 v1024i1:$z, (add i64:$mem, Wrapped64:$off), VariantMod:$mod0, QindexMod:$mod1))]>;

  //xlovariantlsumask registerY? registerA = [registerZ]
  defm rrc    : I <OpcStr, LSU_LOAD, [], [VariantMod], [SingleReg], [LsumaskMod, SingleReg], [VectorReg], 1,
                  [(set v256i1:$r, (int_kvx_xloadc256 v256i1:$z, i64:$mem, i64:$val, VariantMod:$mod0, LsumaskMod:$cond))]>;
  //xlovariantlsumask registerY? registerA = offset27[registerZ]
  defm ri27c : I <OpcStr, LSU_X_LOAD, [], [VariantMod], [Signed27, SingleReg], [LsumaskMod, SingleReg], [VectorReg], 1,
                  [(set v256i1:$r, (int_kvx_xloadc256 v256i1:$z, (add i64:$mem, Signed27:$off), i64:$val, VariantMod:$mod0, LsumaskMod:$cond))]>;
  //xlovariantlsumask registerY? registerA = extend27 offset27[registerZ]
  defm ri54c : I <OpcStr, LSU_Y_LOAD, [], [VariantMod], [Signed54, SingleReg], [LsumaskMod, SingleReg], [VectorReg], 1,
                  [(set v256i1:$r, (int_kvx_xloadc256 v256i1:$z, (add i64:$mem, Signed54:$off), i64:$val, VariantMod:$mod0, LsumaskMod:$cond))]>;

  //xlovariantlsumaskqindex registerY? registerAq = [registerZ]
  defm rrcq    : I <OpcStr, LSU_LOAD, [], [VariantMod, QindexMod], [SingleReg], [LsumaskMod, SingleReg], [MatrixReg], 1,
                  [(set v1024i1:$r, (int_kvx_xloadsc1024 v1024i1:$z, i64:$mem, i64:$val, VariantMod:$mod0, LsumaskMod:$cond, QindexMod:$mod1))]>;
  //xlovariantlsumaskqindex registerY? registerAq = offset27[registerZ]
  defm ri27cq : I <OpcStr, LSU_X_LOAD, [], [VariantMod, QindexMod], [Signed27, SingleReg], [LsumaskMod, SingleReg], [MatrixReg], 1,
                    [(set v1024i1:$r, (int_kvx_xloadsc1024 v1024i1:$z, (add i64:$mem, Signed27:$off), i64:$val, VariantMod:$mod0, LsumaskMod:$cond, QindexMod:$mod1))]>;
  //xlovariantlsumaskqindex registerY? registerAq = extend27 offset27[registerZ]
  defm ri54cq : I <OpcStr, LSU_Y_LOAD, [], [VariantMod, QindexMod], [Signed54, SingleReg], [LsumaskMod, SingleReg], [MatrixReg], 1,
                    [(set v1024i1:$r, (int_kvx_xloadsc1024 v1024i1:$z, (add i64:$mem, Signed54:$off), i64:$val, VariantMod:$mod0, LsumaskMod:$cond, QindexMod:$mod1))]>;

  // Missing 21 definitions that require the TCA buffer here
  // xlovariantdoscale registerA = registerY[registerZ]
  defm rr     : I <OpcStr, LSU_LOAD, [], [VariantMod, DoscaleMod], [SingleReg, SingleReg], [], [VectorReg]>;
  // //xlovariantdoscaleqindex registerAq = registerY[registerZ]
  defm rrq    : I <OpcStr, LSU_LOAD, [], [VariantMod, DoscaleMod, QindexMod], [SingleReg, SingleReg], [], [MatrixReg], 1>;
}

multiclass MC_SV <string OpcStr> {
  defm ri10 : I <OpcStr, LSU_CRRP_STORE, [VectorReg], [], [Signed10, SingleReg], [], [], 0,
                 [(int_kvx_sv  (add i64:$mem, Signed10:$off), v256i1:$op0)]>;

  defm ri37 : I <OpcStr, LSU_CRRP_X_STORE, [VectorReg], [], [Signed10, SingleReg], [], [], 0,
                 [(int_kvx_sv  (add i64:$mem, Signed37:$off), v256i1:$op0)]>;

  defm ri64 : I <OpcStr, LSU_CRRP_Y_STORE, [VectorReg], [], [Signed10, SingleReg], [], [], 0,
                 [(int_kvx_sv  (add i64:$mem, Wrapped64:$off), v256i1:$op0)]>;

  defm rr : I <OpcStr, LSU_CRRP_STORE, [VectorReg], [DoscaleMod], [SingleReg, SingleReg]>;

  defm ri27c : I <OpcStr, LSU_CRRP_X_STORE, [VectorReg], [], [Signed27, SingleReg], [ScalarcondMod, SingleReg], [], 0,
                 [(int_kvx_sv_cond  (add i64:$mem, Signed27:$off), v256i1:$op0, i64:$val, ScalarcondMod:$cond)]>;

  defm ri54c : I <OpcStr, LSU_CRRP_Y_STORE, [VectorReg], [], [Signed54, SingleReg], [ScalarcondMod, SingleReg], [], 0,
                 [(int_kvx_sv_cond  (add i64:$mem, Signed54:$off), v256i1:$op0, i64:$val, ScalarcondMod:$cond)]>;

  defm rrc : I <OpcStr, LSU_CRRP_STORE, [VectorReg], [], [SingleReg], [ScalarcondMod, SingleReg], [], 0,
                 [(int_kvx_sv_cond  i64:$mem, v256i1:$op0, i64:$val, ScalarcondMod:$cond)]>;
}

class KVX_INSTRUCTION
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : Instruction {
    dag OutOperandList = outs;
    dag InOperandList = ins;
    let AsmString = asmstr;
    let Pattern = pattern;
    let Itinerary = itin;
    let Namespace = "KVX";
    let hasCompleteDecoder = false;
  }

class KVX_PSEUDO
  <dag outs, dag ins, list<dag> pattern, string asmstr = "pseudo">
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, NoItinerary> {
    let isPseudo = 1;
    let isCodeGenOnly = 1;
    let hasNoSchedulingInfo = 1;
  }

class KVX_PSEUDO_W_SCHEDINFO
  <dag outs, dag ins, list<dag> pattern, InstrItinClass itin, string asmstr = "pseudo">
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin> {
    let isPseudo = 1;
    let isCodeGenOnly = 1;
    let Itinerary = itin;
  }

// 16 insn(s):
// AWAIT, SLEEP, STOP, BARRIER, TLBREAD, TLBPROBE, TLBWRITE, TLBDINVAL,
// TLBIINVAL, ERROP, RET, RFE, DINVAL, I1INVAL, FENCE, NOP
let Size = 4 in
class SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 6 insn(s):
// IGOTO, ICALL, SCALL, IGET, WAITIT, SYNCGROUP
let Size = 4 in
class REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 1 insn(s):
// SCALL
let Size = 4 in
class SYSNUMBER_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, ALL>;

// 1 insn(s):
// LOOPDO
let Size = 4 in
class REGISTERZ_PCREL17_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, ALL>;

// 2 insn(s):
// WFXL, WFXM
let Size = 4 in
class SYSTEMT2_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, BCU>;

// 3 insn(s):
// WFXL, WFXM, SET
let Size = 4 in
class SYSTEMALONE_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, ALL>;

// 3 insn(s):
// WFXL, WFXM, SET
let Size = 4 in
class SYSTEMT4_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, BCU>;

// 1 insn(s):
// GET
let Size = 4 in
class REGISTERZ_SYSTEMS2_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, BCU_TINY_TINY_MAU_XNOP>;

// 2 insn(s):
// GET, RSWAP
let Size = 4 in
class REGISTERZ_SYSTEMS3_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, BCU_TINY_TINY_MAU_XNOP>;

// 1 insn(s):
// SET
let Size = 4 in
class SYSTEMT3_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, BCU>;

// 1 insn(s):
// SET
let Size = 4 in
class SYSTEMRA_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, BCU>;

// 1 insn(s):
// RSWAP
let Size = 4 in
class REGISTERZ_SYSTEMS4_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, BCU_TINY_TINY_MAU_XNOP>;

// 1 insn(s):
// RSWAP
let Size = 4 in
class REGISTERZ_SYSTEMALONE_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, ALL>;

// 2 insn(s):
// GOTO, CALL
let Size = 4 in
class PCREL27_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, BCU>;

// 1 insn(s):
// CB
let Size = 4 in
class BRANCHCOND_REGISTERZ_PCREL17_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, BCU>;

// 6 insn(s):
// ALADDW, ALADDD
let Size = 4 in
class SIGNED10_REGISTERZ_REGISTERT_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 6 insn(s):
// ALADDW, ALADDD
let Size = 8 in
class UPPER27_LOWER10_REGISTERZ_REGISTERT_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 6 insn(s):
// ALADDW, ALADDD
let Size = 12 in
class EXTEND27_UPPER27_LOWER10_REGISTERZ_REGISTERT_TRIPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 6 insn(s):
// ALADDW, ALADDD
let Size = 4 in
class DOSCALE_REGISTERY_REGISTERZ_REGISTERT_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 6 insn(s):
// ALADDW, ALADDD
let Size = 4 in
class LSUCOND_REGISTERY_REGISTERZ_REGISTERT_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 6 insn(s):
// ALADDW, ALADDD
let Size = 8 in
class LSUCOND_REGISTERY_OFFSET27_REGISTERZ_REGISTERT_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 6 insn(s):
// ALADDW, ALADDD
let Size = 12 in
class LSUCOND_REGISTERY_EXTEND27_OFFSET27_REGISTERZ_REGISTERT_TRIPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 3 insn(s):
// ACSWAPW, ACSWAPD
let Size = 4 in
class SIGNED10_REGISTERZ_REGISTERU_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 3 insn(s):
// ACSWAPW, ACSWAPD
let Size = 8 in
class UPPER27_LOWER10_REGISTERZ_REGISTERU_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 3 insn(s):
// ACSWAPW, ACSWAPD
let Size = 12 in
class EXTEND27_UPPER27_LOWER10_REGISTERZ_REGISTERU_TRIPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 3 insn(s):
// ACSWAPW, ACSWAPD
let Size = 4 in
class DOSCALE_REGISTERY_REGISTERZ_REGISTERU_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 3 insn(s):
// ACSWAPW, ACSWAPD
let Size = 4 in
class LSUCOND_REGISTERY_REGISTERZ_REGISTERU_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 3 insn(s):
// ACSWAPW, ACSWAPD
let Size = 8 in
class LSUCOND_REGISTERY_OFFSET27_REGISTERZ_REGISTERU_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 3 insn(s):
// ACSWAPW, ACSWAPD
let Size = 12 in
class LSUCOND_REGISTERY_EXTEND27_OFFSET27_REGISTERZ_REGISTERU_TRIPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 2 insn(s):
// ALCLRW, ALCLRD
let Size = 4 in
class REGISTERW_SIGNED10_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXW_ALCLR>;

// 2 insn(s):
// ALCLRW, ALCLRD
let Size = 8 in
class REGISTERW_UPPER27_LOWER10_REGISTERZ_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXW_X_ALCLR>;

// 2 insn(s):
// ALCLRW, ALCLRD
let Size = 12 in
class REGISTERW_EXTEND27_UPPER27_LOWER10_REGISTERZ_TRIPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXW_Y_ALCLR>;

// 2 insn(s):
// ALCLRW, ALCLRD
let Size = 4 in
class DOSCALE_REGISTERW_REGISTERY_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXW_ALCLR>;

// 2 insn(s):
// ALCLRW, ALCLRD
let Size = 4 in
class LSUCOND_REGISTERY_REGISTERW_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXW_ALCLR>;

// 2 insn(s):
// ALCLRW, ALCLRD
let Size = 8 in
class LSUCOND_REGISTERY_REGISTERW_OFFSET27_REGISTERZ_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXW_X_ALCLR>;

// 2 insn(s):
// ALCLRW, ALCLRD
let Size = 12 in
class LSUCOND_REGISTERY_REGISTERW_EXTEND27_OFFSET27_REGISTERZ_TRIPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXW_Y_ALCLR>;

// 4 insn(s):
// DTOUCHL, DINVALL, DZEROL, I1INVALS
let Size = 4 in
class SIGNED10_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_LOAD>;

// 4 insn(s):
// DTOUCHL, DINVALL, DZEROL, I1INVALS
let Size = 8 in
class UPPER27_LOWER10_REGISTERZ_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_X_LOAD>;

// 4 insn(s):
// DTOUCHL, DINVALL, DZEROL, I1INVALS
let Size = 12 in
class EXTEND27_UPPER27_LOWER10_REGISTERZ_TRIPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_Y_LOAD>;

// 4 insn(s):
// DTOUCHL, DINVALL, DZEROL, I1INVALS
let Size = 4 in
class REGISTERY_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_LOAD>;

// 4 insn(s):
// DTOUCHL, DINVALL, DZEROL, I1INVALS
let Size = 4 in
class LSUCOND_REGISTERY_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_LOAD>;

// 4 insn(s):
// DTOUCHL, DINVALL, DZEROL, I1INVALS
let Size = 8 in
class LSUCOND_REGISTERY_OFFSET27_REGISTERZ_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_X_LOAD>;

// 4 insn(s):
// DTOUCHL, DINVALL, DZEROL, I1INVALS
let Size = 12 in
class LSUCOND_REGISTERY_EXTEND27_OFFSET27_REGISTERZ_TRIPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_Y_LOAD>;

// STSUD, ADDD, SBFD, ABDD, MIND, MINUD, MAXD, MAXUD, ANDD, NANDD, ORD, NORD,
// XORD, NXORD, ANDND, ORND, SBMM8, SBMMT8, ADDSD, ADDUSD, ADDUSW, ADDUSWP, SBFSD, ADDX2D, ADDX4D,
// ADDX8D, ADDX16D, ADDX32D, ADDX64D, SBFX2D, SBFX4D, SBFX8D, SBFX16D, SBFX32D, SBFX64D, ADDWD, SBFWD, ADDUWD,
// SBFUWD, LANDD, LNANDD, LORD, LNORD, STSUW, ADDW, SBFW, ABDW, MINW, MINUW,
// MAXW, MAXUW, ANDW, NANDW, ORW, NORW, XORW, NXORW, ANDNW, ORNW, ADDSW,
// SBFSW, ADDX2W, ADDX4W, ADDX8W, ADDX16W, ADDX32W, ADDX64W, SBFX2W, SBFX4W, SBFX8W, SBFX16W, SBFX32W,  SBFX64W,
// AVGW, AVGUW, AVGRW, AVGRUW, LANDW, LNANDW, LORW, LNORW, ADDWP, SBFWP,
// ABDWP, MINWP, MINUWP, MAXWP, MAXUWP, ADDCWC, SBFCWC, ADDSWP, SBFSWP,
// ADDX2WP, ADDX4WP, ADDX8WP, ADDX16WP, SBFX2WP, SBFX4WP, SBFX8WP, SBFX16WP,
// AVGWP, AVGUWP, AVGRWP, AVGRUWP, LANDWP, LNANDWP, LORWP, LNORWP, ADDBO, ADDHQ,
// SBFBO, SBFHQ, ABDBO, ABDHQ, MINBO, MINHQ, MINUBO, MINUHQ, MAXBO, MAXHQ, MAXUBO,
// MAXUHQ, ADDCHCP, SBFCHCP, ADDSBO, ADDUSBO, ADDUSHQ, ADDSHQ,
// SBFSHQ, ADDX2BO, ADDX2HQ, ADDX4BO, ADDX4HQ, ADDX8BO, ADDX8HQ, ADDX16BO, ADDX16HQ,
// SBFX2BO, SBFX2HQ, SBFX4BO, SBFX4HQ, SBFX8BO, SBFX8HQ, SBFX16BO, SBFX16HQ,
// SBFX16HQ, AVGHQ, AVGUHQ, AVGRHQ, AVGRUHQ, LANDHQ, LNANDHQ, LORHQ, LNORHQ,
// ADDX2WD, ADDX4WD, ADDX8WD, ADDX16WD, ADDX32WD, ADDX64WD, SBFX2WD, SBFX4WD, SBFX8WD, SBFX16WD, SBFX32WD, SBFX64WD,
// ADDX2UWD, ADDX4UWD, ADDX8UWD, ADDX16UWD, ADDX32UWD, ADDX64UWD, SBFX2UWD, SBFX4UWD, SBFX8UWD,
// SBFX16UWD, SBFX32UWD, SBFX64UWD, ADDCD, SBFCD, ADDCDI, SBFCDI, SATD, SRSD, SLLD, SRAD, SRLD,
// SLSD, SRSW, SLLW, SRAW, SRLW, SLSW, ROLW, RORW, SRSWPS, SLLWPS, SRAWPS,
// SRLWPS, SLSWPS, ROLWPS, RORWPS, SRSHQS, SLLBOS, SLLHQS, SRABOS, SRAHQS, SRLBOS, SRLHQS, SLSHQS,
// FMIND, FMAXD, FMINW, FMAXW, FMINWP, FMAXWP, FMINHQ, FMAXHQ, MADDD, MSBFD,
// MADDWP, MSBFWP, MADDHQ, MSBFHQ, MULD, CRCBELMW, CRCBELLW, CRCLELMW,
// CRCLELLW, DOT2WD, DOT2UWD, DOT2SUWD, DOT2W, MULWP, MULHQ, MULWC, MULCWC,
// MADDWD, MADDUWD, MADDSUWD, MADDW, MSBFWD, MSBFUWD, MSBFSUWD, MSBFW, MULWD,
// MULUWD, MULSUWD, MULW, ABDSW, SBFUSBO, SBFUSD, SBFUSHQ, SBFUSW, SBFUSWP, SBFSBO,
// AVGBO, AVGUBO, AVGRBO, AVGRUBO, SLSBOS, SLUSBOS, SLUSD, SLUSW, SLUSWPS, SLUSHQS,
// ABDSWP, ABDSBO, ABDSD, ABDSHQ, SRSBOS
let Size = 4 in
class REGISTERW_REGISTERZ_REGISTERY_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 45 insn(s):
// ADDD, SBFD, ABDD, MIND, MINUD, MAXD, MAXUD, ANDD, NANDD, ORD, NORD, XORD,
// NXORD, ANDND, ORND, SBMM8, SBMMT8, ADDSD, SBFSD, ADDW, SBFW, ABDW, MINW,
// MINUW, MAXW, MAXUW, ANDW, NANDW, ORW, NORW, XORW, NXORW, ANDNW, ORNW,
// MADDD, MADDWP, MADDHQ, MULD, DOT2WD, DOT2UWD, DOT2SUWD, DOT2W, MULWP,
// MULHQ, MULWC
let Size = 4 in
class REGISTERW_REGISTERZ_SIGNED10_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 45 insn(s):
// ADDD, SBFD, ABDD, MIND, MINUD, MAXD, MAXUD, ANDD, NANDD, ORD, NORD, XORD,
// NXORD, ANDND, ORND, SBMM8, SBMMT8, ADDSD, SBFSD, ADDW, SBFW, ABDW, MINW,
// MINUW, MAXW, MAXUW, ANDW, NANDW, ORW, NORW, XORW, NXORW, ANDNW, ORNW,
// MADDD, MADDWP, MADDHQ, MULD, DOT2WD, DOT2UWD, DOT2SUWD, DOT2W, MULWP,
// MULHQ, MULWC
let Size = 8 in
class REGISTERW_REGISTERZ_UPPER27_LOWER10_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 30 insn(s):
// ADDD, SBFD, ABDD, MIND, MINUD, MAXD, MAXUD, ANDD, NANDD, ORD, NORD, XORD,
// NXORD, ANDND, ORND, SBMM8, SBMMT8, ADDSD, SBFSD, MADDD, MADDWP, MADDHQ,
// MULD, DOT2WD, DOT2UWD, DOT2SUWD, DOT2W, MULWP, MULHQ, MULWC
let Size = 12 in
class REGISTERW_REGISTERZ_EXTEND27_UPPER27_LOWER10_TRIPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// ADDX2D, ADDX4D, ADDX8D, ADDX16D, ADDX32D, ADDX64D, SBFX2D, SBFX4D, SBFX8D, SBFX16D, SBFX32D, SBFX64D, ADDWD,
// SBFWD, ADDUWD, SBFUWD, LANDD, LNANDD, LORD, LNORD, ADDSW, SBFSW, ADDX2W,
// ADDX4W, ADDX8W, ADDX16W, ADDX32W, ADDX64W, SBFX2W, SBFX4W, SBFX8W, SBFX16W, SBFX32W, SBFX64W, AVGW, AVGUW,
// AVGRW, AVGRUW, LANDW, LNANDW, LORW, LNORW, ADDX2WD, ADDX4WD, ADDX8WD,
// ADDX16WD, ADDX32WD, ADDX64WD, SBFX2WD, SBFX4WD, SBFX8WD, SBFX16WD, SBFX32WD, SBFX64WD, ADDX2UWD, ADDX4UWD,
// ADDX8UWD, ADDX16UWD, ADDX32UWD, ADDX64UWD, SBFX2UWD, SBFX4UWD, SBFX8UWD, SBFX16UWD, SBFX32UWD, SBFX64UWD, CRCBELMW,
// CRCBELLW, CRCLELMW, CRCLELLW, MADDWD, MADDUWD, MADDSUWD, MADDW, MSBFWD,
// MSBFUWD, MSBFSUWD, MSBFW, MULWD, MULUWD, MULSUWD, MULW, ABDSBO, ABDSW, ABDSWP, ABDSHQ
let Size = 8 in
class REGISTERW_REGISTERZ_UPPER27_LOWER5_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// ADDWP, SBFWP, ABDWP, MINWP, MINUWP, MAXWP, MAXUWP, ADDCWC, SBFCWC, ADDSWP,
// SBFSWP, ADDX2WP, ADDX4WP, ADDX8WP, ADDX16WP, SBFX2WP, SBFX4WP, SBFX8WP,
// SBFX16WP, AVGWP, AVGUWP, AVGRWP, AVGRUWP, LANDWP, LNANDWP, LORWP, LNORWP,
// ADDBO, ADDHQ, SBFBO, SBFHQ, ABDBO, ABDHQ, MINBO, MINHQ, MINUBO, MINUHQ, MAXBO, MAXHQ, MAXUBO, MAXUHQ, ADDCHCP, SBFCHCP,
// ADDSBO, ADDUSBO, ADDUSHQ, ADDSHQ, SBFSHQ, ADDX2BO, ADDX2HQ, ADDX4BO, ADDX4HQ, ADDX8BO, ADDX8HQ, ADDX16BO, ADDX16HQ,
// SBFX2BO, SBFX2HQ, SBFX4BO, SBFX4HQ, SBFX8BO, SBFX8HQ, SBFX16BO, SBFX16HQ,
// AVGHQ, AVGUHQ, AVGRHQ, AVGRUHQ, LANDHQ, LNANDHQ, LORHQ,
// LNORHQ, ADDUSD, ADDUSW, ADDUSWP, SBFUSBO, SBFUSD, SBFUSHQ, SBFUSW, SBFUSWP, SBFSBO,
// ABDSBO, AVGBO, AVGUBO, AVGRBO, AVGRUBO, ABDSD, ABDSHQ
let Size = 8 in
class SPLAT32_REGISTERW_REGISTERZ_UPPER27_LOWER5_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 43 insn(s):
// FNEGD, FABSD, FSRSRD, FNEGW, FABSW, FSRSRW, FNEGWP, FABSWP, FSRSRWP,
// FNEGHQ, FABSHQ, CLZW, CLSW, CBSW, CTZW, CLZD, CLSD, CBSD, CTZD, CLZWP,
// CLSWP, CBSWP, CTZWP, SXLHWP, SXMHWP, SXLBHQ, SXMBHQ, COPYD, NOTD, NEGD,
// ABSD, ZXBD, SXBD, ZXHD, SXHD, ZXWD, SXWD, SATDH, SATDW, COPYW, NOTW, NEGW,
// ABSW
let Size = 4 in
class REGISTERW_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 9 insn(s):
// FSRECD, FWIDENLWD, FWIDENMWD, FSRECW, FWIDENLHW, FWIDENMHW, FSRECWP,
// FWIDENLHWP, FWIDENMHWP
let Size = 4 in
class SILENT2_REGISTERW_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, ALU_LITE>;

// 4 insn(s):
// FNARROWDW, FRECW, FRSRW, FNARROWWH
let Size = 4 in
class ROUNDING2_SILENT2_REGISTERW_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 2 insn(s):
// FNARROWDWP, FNARROWWHQ
let Size = 4 in
class ROUNDING2_SILENT2_REGISTERW_REGISTERP_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 4 insn(s):
// INSF, EXTFZ, EXTFS, CLRF
let Size = 4 in
class REGISTERW_REGISTERZ_STOPBIT2_STOPBIT4_STARTBIT_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, ALU_LITE>;

// 25 insn(s):
// SATD, SRSD, SLLD, SRAD, SRLD, SLSD, SRSW, SLLW, SRAW, SRLW, SLSW, ROLW,
// RORW, SRSWPS, SLLWPS, SRAWPS, SRLWPS, SLSWPS, ROLWPS, RORWPS, SRSBOS, SRSHQS,
// SLLBOS, SLLHQS, SRABOS, SRAHQS, SRLBOS, SRLHQS, SLSHQS,
// SLSBOS, SLUSBOS, SLUSD, SLUSW, SLUSWPS, SLUSHQS, SRSBOS
let Size = 4 in
class REGISTERW_REGISTERZ_UNSIGNED6_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 1 insn(s):
// COMPD
let Size = 4 in
class COMPARISON_REGISTERW_REGISTERZ_SIGNED10_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, ALU_TINY>;

// 1 insn(s):
// COMPD
let Size = 8 in
class COMPARISON_REGISTERW_REGISTERZ_UPPER27_LOWER10_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, ALU_TINY_X>;

// 1 insn(s):
// COMPD
let Size = 12 in
class COMPARISON_REGISTERW_REGISTERZ_EXTEND27_UPPER27_LOWER10_TRIPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, ALU_TINY_Y>;

// COMPD, COMPW, COMPWD, COMPUWD, COMPNWP, COMPNBO, COMPNHQ, COMPNW
let Size = 4 in
class COMPARISON_REGISTERW_REGISTERZ_REGISTERY_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// COMPW, COMPNW, COMPND
let Size = 8 in
class COMPARISON_REGISTERW_REGISTERZ_UPPER27_LOWER5_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, ALU_TINY_X>;

// 1 insn(s):
// CMOVED
let Size = 4 in
class SCALARCOND_REGISTERZ_REGISTERW_SIGNED10_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, ALU_LITE>;

// 1 insn(s):
// CMOVED
let Size = 8 in
class SCALARCOND_REGISTERZ_REGISTERW_UPPER27_LOWER10_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, ALU_LITE_X>;

// 1 insn(s):
// CMOVED
let Size = 12 in
class SCALARCOND_REGISTERZ_REGISTERW_EXTEND27_UPPER27_LOWER10_TRIPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, ALU_LITE_Y>;

// 1 insn(s):
// CMOVED
let Size = 4 in
class SCALARCOND_REGISTERZ_REGISTERW_REGISTERY_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, ALU_LITE>;

// CMOVEWP, CMOVEHQ, CMOVEBO
let Size = 4 in
class SIMDCOND_REGISTERZ_REGISTERW_REGISTERY_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, ALU_LITE>;

// 2 insn(s):
// MAKE, PCREL
let Size = 4 in
class REGISTERW_SIGNED16_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 2 insn(s):
// MAKE, PCREL
let Size = 8 in
class REGISTERW_EXTEND6_UPPER27_LOWER10_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 2 insn(s):
// MAKE, PCREL
let Size = 12 in
class REGISTERW_EXTEND27_UPPER27_LOWER10_TRIPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// FCOMPW, FCOMPNW
let Size = 4 in
class FLOATCOMP_REGISTERW_REGISTERZ_REGISTERY_SIMPLE_BINARY32
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, ALU_LITE>;

// FCOMPW, FCOMPNW
let Size = 8 in
class FLOATCOMP_REGISTERW_REGISTERZ_UPPER27_LOWER5_DOUBLE_BINARY32
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, ALU_LITE_X>;

// 1 insn(s):
// FCOMPD
let Size = 4 in
class FLOATCOMP_REGISTERW_REGISTERZ_REGISTERY_SIMPLE_BINARY64
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, ALU_LITE>;

// 1 insn(s):
// FCOMPNWP
let Size = 4 in
class FLOATCOMP_REGISTERW_REGISTERZ_REGISTERY_SIMPLE_BINARY32X2
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, ALU_LITE>;

// 1 insn(s):
// FCOMPNHQ
let Size = 4 in
class FLOATCOMP_REGISTERW_REGISTERZ_REGISTERY_SIMPLE_BINARY16X4
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, ALU_LITE>;

// 6 insn(s):
// FSDIVD, FCDIVD, FSDIVW, FCDIVW, FSDIVWP, FCDIVWP
let Size = 4 in
class SILENT2_REGISTERW_REGISTERP_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, ALU_LITE>;

// 4 insn(s):
// FLOATD, FLOATUD, FIXEDD, FIXEDUD
let Size = 4 in
class ROUNDING_SILENT_REGISTERW_REGISTERZ_UNSIGNED6_SIMPLE_BINARY64
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, MAU_FP>;

// 4 insn(s):
// FLOATWP, FLOATUWP, FIXEDWP, FIXEDUWP
let Size = 4 in
class ROUNDING_SILENT_REGISTERW_REGISTERZ_UNSIGNED6_SIMPLE_BINARY32X2
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, MAU_FP>;

// 4 insn(s):
// FLOATW, FLOATUW, FIXEDW, FIXEDUW
let Size = 4 in
class ROUNDING_SILENT_REGISTERW_REGISTERZ_UNSIGNED6_SIMPLE_BINARY32
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, MAU_FP>;

// 40 insn(s):
// MADDHWQ, MSBFHWQ, MADDUHWQ, MSBFUHWQ, MADDSUHWQ, MSBFSUHWQ, MADDDT,
// MADDUDT, MADDSUDT, MADDUZDT, MSBFDT, MSBFUDT, MSBFSUDT, MSBFUZDT, MULDT,
// MULUDT, MULSUDT, CMULDT, CMULXDT, CMULGLXDT, CMULGMXDT, CMULGHXDT, MULWDC,
// MULCWDC, MULHWQ, MULUHWQ, MULSUHWQ, MADDWDP, MADDUWDP, MADDSUWDP, MMA212W,
// MSBFWDP, MSBFUWDP, MSBFSUWDP, MMS212W, MULWDP, MULUWDP, MULSUWDP, MM212W,
// COPYQ
let Size = 4 in
class REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 8 insn(s):
// MADDDT, MADDUDT, MADDSUDT, MADDUZDT, MULDT, MULUDT, MULSUDT, CMULDT
let Size = 4 in
class REGISTERM_REGISTERZ_SIGNED10_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 8 insn(s):
// MADDDT, MADDUDT, MADDSUDT, MADDUZDT, MULDT, MULUDT, MULSUDT, CMULDT
let Size = 8 in
class REGISTERM_REGISTERZ_UPPER27_LOWER10_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 8 insn(s):
// MADDDT, MADDUDT, MADDSUDT, MADDUZDT, MULDT, MULUDT, MULSUDT, CMULDT
let Size = 12 in
class REGISTERM_REGISTERZ_EXTEND27_UPPER27_LOWER10_TRIPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 5 insn(s):
// DOT2WDP, DOT2UWDP, DOT2SUWDP, MULWQ, DOT2WZP
let Size = 4 in
class REGISTERM_REGISTERP_REGISTERO_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, MAU_AUXR>;

// 9 insn(s):
// FFMAD, FFMSD, FMULD, FADDD, FSBFD, FFMAWD, FFMSWD, FMULWD, FDOT2WD
let Size = 12, Predicates = [IsV1] in
class REGISTERW_REGISTERZ_EXTEND27_UPPER27_LOWER10_TRIPLE_BINARY64
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 9 insn(s):
// FFMAD, FFMSD, FMULD, FADDD, FSBFD, FFMAWD, FFMSWD, FMULWD, FDOT2WD
let Size = 4 in
class ROUNDING_SILENT_REGISTERW_REGISTERZ_REGISTERY_SIMPLE_BINARY64
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 6 insn(s):
// FFMAWP, FFMSWP, FMULWP, FMULWC, FADDWP, FSBFWP
let Size = 12, Predicates = [IsV1] in
class REGISTERW_REGISTERZ_EXTEND27_UPPER27_LOWER10_TRIPLE_BINARY32X2
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// FFMAWP, FFMSWP, FMULWP, FMULWC, FADDWP, FSBFWP
let Size = 4 in
class ROUNDING_SILENT_REGISTERW_REGISTERZ_REGISTERY_SIMPLE_BINARY32X2
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 5 insn(s):
// FFMAHQ, FFMSHQ, FMULHQ, FADDHQ, FSBFHQ
let Size = 12, Predicates = [IsV1] in
class REGISTERW_REGISTERZ_EXTEND27_UPPER27_LOWER10_TRIPLE_BINARY16X4
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 5 insn(s):
// FFMAHQ, FFMSHQ, FMULHQ, FADDHQ, FSBFHQ
let Size = 4 in
class ROUNDING_SILENT_REGISTERW_REGISTERZ_REGISTERY_SIMPLE_BINARY16X4
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 5 insn(s):
// FMULWDP, FMULWDC, FMULCWDC, FFMAWDP, FFMSWDP
let Size = 12, Predicates = [IsV1] in
class REGISTERM_REGISTERZ_EXTEND27_UPPER27_LOWER10_TRIPLE_BINARY32X2
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 5 insn(s):
// FMULWDP, FMULWDC, FMULCWDC, FFMAWDP, FFMSWDP
let Size = 4 in
class ROUNDING_SILENT_REGISTERM_REGISTERZ_REGISTERY_SIMPLE_BINARY32X2
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 3 insn(s):
// FMULHWQ, FFMAHWQ, FFMSHWQ
let Size = 12, Predicates = [IsV1] in
class REGISTERM_REGISTERZ_EXTEND27_UPPER27_LOWER10_TRIPLE_BINARY16X4
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 3 insn(s):
// FMULHWQ, FFMAHWQ, FFMSHWQ
let Size = 4 in
class ROUNDING_SILENT_REGISTERM_REGISTERZ_REGISTERY_SIMPLE_BINARY16X4
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// FIXME: Some of these intructions do not use AUXR in cv2
// FMULWQ, FADDDP, FADDWQ, FSBFDP, FSBFWQ, FDOT2WZP, FDOT2WDP
let Size = 4 in
class ROUNDING_SILENT_REGISTERM_REGISTERP_REGISTERO_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, MAU_AUXR_FP>;

let Size = 4, Constraints = "$out = $acc" in
class ROUNDING_SILENT_TERNARY_AUXR_FP <string OpcStr, RegisterClass RC_OUT, RegisterClass RC_IN>
  : KVX_INSTRUCTION <
    (outs RC_OUT:$out),
    (ins RC_OUT:$acc, RC_IN:$lhs, RC_IN:$rhs, RoundingMod:$r, SilentMod:$s),
    !strconcat (OpcStr, "$r$s $out = $lhs, $rhs"),
    [],
    MAU_AUXR_FP>;

let Size = 4, Constraints = "$o = $a" in
class TERNARY<string Opcode, RegisterClass RC_OUT, RegisterClass RC_LHS, RegisterClass RC_RHS, InstrItinClass Itin, list<dag> Patt = []>
    : KVX_INSTRUCTION <
     (outs RC_OUT:$o),
     (ins RC_OUT:$a, RC_LHS:$lhs, RC_RHS:$rhs),
     !strconcat (Opcode, " $o = $lhs, $rhs"),
     Patt,
     Itin>;

let Size = 4, Constraints = "$o = $a" in
class ROUNDING_SILENT_TERNARY <string Opcode, RegisterClass RC_OUT, RegisterClass RC_LHS, RegisterClass RC_RHS, InstrItinClass Itin, list<dag> Patt = []>
    : KVX_INSTRUCTION <
     (outs RC_OUT:$o),
     (ins RC_OUT:$a, RC_LHS:$lhs, RC_RHS:$rhs, RoundingMod:$r, SilentMod:$s),
     !strconcat (Opcode, "$r$s $o = $lhs, $rhs"),
     Patt,
     Itin>;

let Size = 4 in
class ROUNDING_SILENT_UNARY<string Opcode, RegisterClass RC_OUT, RegisterClass RC_IN, InstrItinClass Itin, list<dag> Patt = []>
    : KVX_INSTRUCTION <
     (outs RC_OUT:$o),
     (ins RC_IN:$i, RoundingMod:$r, SilentMod:$s),
     !strconcat (Opcode, "$r$s $o = $i"),
     Patt,
     Itin>;

let Size = 4 in
class UNARY <string Opcode, RegisterClass RC_OUT, RegisterClass RC_IN, InstrItinClass Itin, list<dag> Patt = []>
    : KVX_INSTRUCTION <
     (outs RC_OUT:$o),
     (ins RC_IN:$i),
     !strconcat (Opcode, " $o = $i"),
     Patt,
     Itin>;

let Size = 4 in
class ROUNDING_SILENT_BINOP<string Opcode, RegisterClass RC_OUT, RegisterClass RC_LHS, RegisterClass RC_RHS, InstrItinClass Itin, list<dag> Patt = []>
    : KVX_INSTRUCTION <
     (outs RC_OUT:$o),
     (ins RC_LHS:$lhs, RC_RHS:$rhs, RoundingMod:$r, SilentMod:$s),
     !strconcat (Opcode, "$r$s $o = $lhs, $rhs"),
     Patt,
     Itin>;

let Size = 4 in
class CACHE_OP<string Opcode, RegisterClass RC, InstrItinClass Itin, list<dag> Patt = []>
    : KVX_INSTRUCTION <
     (outs),
     (ins RC:$way, RC:$set, CacheLevelMod:$c),
     !strconcat (Opcode, "$c $set, $way"),
     Patt,
     Itin>;

class ROUNDING_SILENT_BINOP_MAU_FP<string OpcStr, RegisterClass RC_OUT, RegisterClass RC_IN>
    : ROUNDING_SILENT_BINOP <OpcStr, RC_OUT, RC_IN, RC_IN, MAU_FP>;


class CONJ_ROUNDING_SILENT_BINOP_MAU_FP<string OpcStr, RegisterClass RC_OUT, RegisterClass RC_IN>
    : KVX_INSTRUCTION <
     (outs RC_OUT:$o),
     (ins RC_IN:$lhs, RC_IN:$rhs, ConjugateMod:$c, RoundingMod:$r, SilentMod:$s),
     !strconcat (OpcStr, "$c$r$s $o = $lhs, $rhs"),
     [/* no straightforward pattern */],
     MAU_FP>;

// 9 insn(s):
// FFMAHW, FFMAW, FFMSHW, FFMSW, FADDW, FSBFW, FMULHW, FMULW, FDOT2W
let Size = 8, Predicates = [IsV1] in
class REGISTERW_REGISTERZ_UPPER27_LOWER10_DOUBLE_BINARY32
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 9 insn(s):
// FFMAHW, FFMAW, FFMSHW, FFMSW, FADDW, FSBFW, FMULHW, FMULW, FDOT2W
let Size = 4 in
class ROUNDING_SILENT_REGISTERW_REGISTERZ_REGISTERY_SIMPLE_BINARY32
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 3 insn(s):
// FMMA212W, FMMS212W, FMM212W
let Size = 4 in
class ROUNDING_SILENT_REGISTERM_REGISTERZ_REGISTERY_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// FMM222W, FMMA222W, FMMS222W
let Size = 4 in
class ROUNDING_SILENT_TRANSPOSE_REGISTERM_REGISTERO_REGISTERP
  <dag outs, dag ins, string asmstr, InstrItinClass itin, list<dag> pattern = []>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>, Requires<[IsV2]>;

// 1 insn(s):
// COPYO
let Size = 4 in
class REGISTERN_REGISTERQ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, LSU_AUXR_AUXW_LOAD>;

// 1 insn(s):
// MOVETQ
let Size = 4 in
class REGISTERAL_REGISTERZ_REGISTERY_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, ALU_LITE_CRWL>;

// 1 insn(s):
// MOVETQ
let Size = 4 in
class REGISTERAH_REGISTERZ_REGISTERY_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, ALU_LITE_CRWH>;

// 1 insn(s):
// ALIGNO
let Size = 4 in
class REGISTERN_REGISTERBE_REGISTERCO_BYTESHIFT_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, BCU_TINY_AUXW_CRRP>;

// 1 insn(s):
// ALIGNO
let Size = 4 in
class REGISTERN_REGISTERBO_REGISTERCE_BYTESHIFT_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, BCU_TINY_AUXW_CRRP>;

// 1 insn(s):
// ALIGNO
let Size = 4 in
class REGISTERN_REGISTERBE_REGISTERCO_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, BCU_TINY_AUXW_CRRP>;

// 1 insn(s):
// ALIGNO
let Size = 4 in
class REGISTERN_REGISTERBO_REGISTERCE_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, BCU_TINY_AUXW_CRRP>;

// 1 insn(s):
// ALIGNV
let Size = 4 in
class REGISTERA_REGISTERBE_REGISTERCO_BYTESHIFT_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, BCU_CRRP_CRWL_CRWH>;

// 1 insn(s):
// ALIGNV
let Size = 4 in
class REGISTERA_REGISTERBO_REGISTERCE_BYTESHIFT_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, BCU_CRRP_CRWL_CRWH>;

// 1 insn(s):
// ALIGNV
let Size = 4 in
class REGISTERA_REGISTERBE_REGISTERCO_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, BCU_CRRP_CRWL_CRWH>;

// 1 insn(s):
// ALIGNV
let Size = 4 in
class REGISTERA_REGISTERBO_REGISTERCE_REGISTERZ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, BCU_CRRP_CRWL_CRWH>;

// 1 insn(s):
// MT44D
let Size = 4 in
class REGISTERAQ_REGISTERBQ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, TCA>;

// 4 insn(s):
// MMA484BW, MMA484UBW, MMA484SUBW, MMA484USBW
let Size = 4 in
class REGISTERAP_REGISTERBP_REGISTERC_REGISTERD_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, TCA>;

// 12 insn(s):
// MMA444HBD0, MMA444UHBD0, MMA444SUHBD0, MMA444USHBD0, MMA444HBD1,
// MMA444UHBD1, MMA444SUHBD1, MMA444USHBD1, MMA444HD, MMA444UHD, MMA444SUHD,
// MMA444USHD
let Size = 4 in
class REGISTERAQ_REGISTERBQ_REGISTERC_REGISTERD_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, TCA>;

// 1 insn(s):
// FMMA242HW0
let Size = 4 in
class REGISTERA0_REGISTERBP_REGISTERC_REGISTERD_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, TCA_FP16>;

// 1 insn(s):
// FMMA242HW1
let Size = 4 in
class REGISTERA1_REGISTERBP_REGISTERC_REGISTERD_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, TCA_FP16>;

// 1 insn(s):
// FMMA242HW2
let Size = 4 in
class REGISTERA2_REGISTERBP_REGISTERC_REGISTERD_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, TCA_FP16>;

// 1 insn(s):
// FMMA242HW3
let Size = 4 in
class REGISTERA3_REGISTERBP_REGISTERC_REGISTERD_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, TCA_FP16>;

// 1 insn(s):
// CONVDHV0
let Size = 4 in
class ROUNDINT_SATURATE_REGISTERAL_REGISTERBQ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, TCA>;

// 1 insn(s):
// CONVDHV1
let Size = 4 in
class ROUNDINT_SATURATE_REGISTERAH_REGISTERBQ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, TCA>;

// 1 insn(s):
// CONVWBV0
let Size = 4 in
class ROUNDINT_SATURATE_REGISTERAX_REGISTERBQ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, TCA>;

// 1 insn(s):
// CONVWBV1
let Size = 4 in
class ROUNDINT_SATURATE_REGISTERAY_REGISTERBQ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, TCA>;

// 1 insn(s):
// CONVWBV2
let Size = 4 in
class ROUNDINT_SATURATE_REGISTERAZ_REGISTERBQ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, TCA>;

// 1 insn(s):
// CONVWBV3
let Size = 4 in
class ROUNDINT_SATURATE_REGISTERAT_REGISTERBQ_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, TCA>;

// 1 insn(s):
// FSCALEWV
let Size = 4 in
class XROUNDING_SILENT2_RECTIFY_REGISTERA_REGISTERB_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, TCA>;

// 1 insn(s):
// FNARROWWHV
let Size = 4 in
class XROUNDING_SILENT2_REGISTERA_REGISTERBP_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, TCA>;

// 4 insn(s):
// NEGWP, ABSWP, NEGHQ, ABSBO, ABSHQ
let Size = 8 in
class REGISTERW_REGISTERZ_DOUBLE
  <dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, itin>;

// 1 insn(s):
// COPYV
let Size = 4 in
class REGISTERA_REGISTERBE_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, BCU_CRRP_CRWL_CRWH>;

// 1 insn(s):
// COPYV
let Size = 4 in
class REGISTERA_REGISTERBO_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, BCU_CRRP_CRWL_CRWH>;

// 1 insn(s):
// MOVEFO
let Size = 4 in
class REGISTERN_REGISTERBE_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, BCU_TINY_AUXW_CRRP>;

// 1 insn(s):
// MOVEFO
let Size = 4 in
class REGISTERN_REGISTERBO_SIMPLE
  <dag outs, dag ins, string asmstr, list<dag> pattern>
  : KVX_INSTRUCTION <outs, ins, asmstr, pattern, BCU_TINY_AUXW_CRRP>;

