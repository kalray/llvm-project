def: Pat<(int_kvx_await), (AWAIT)>;
def: Pat<(int_kvx_barrier), (BARRIER)>;
def: Pat<(int_kvx_fence AccessesMod), (FENCE accesses_all)>, Requires<[IsV1]>;
def: Pat<(int_kvx_fence AccessesMod:$m), (FENCE AccessesMod:$m)>, Requires<[IsV2]>;
def: Pat<(int_kvx_i1inval), (I1INVAL)>;
def: Pat<(int_kvx_sleep), (SLEEP)>;
def: Pat<(int_kvx_stop), (STOP)>;
def: Pat<(int_kvx_tlbdinval), (TLBDINVAL)>;
def: Pat<(int_kvx_tlbiinval), (TLBIINVAL)>;
def: Pat<(int_kvx_tlbprobe), (TLBPROBE)>;
def: Pat<(int_kvx_tlbread), (TLBREAD)>;
def: Pat<(int_kvx_tlbwrite), (TLBWRITE)>;
def: Pat<(trap), (ERROP)>;

let Constraints = "$vIn = $vOut, $qIn = $qOut" in
def XSWAP256p : KVX_PSEUDO_W_SCHEDINFO<(outs QuadReg:$qOut, VectorReg:$vOut), (ins QuadReg:$qIn, VectorReg:$vIn),[], XSWAP256>;

// Intermediary step from IR -> loopdo
let hasSideEffects = 1, isNotDuplicable=1, hasNoSchedulingInfo = 1, Defs = [LC,LE,LS] in
def LOOPDOp : KVX_PSEUDO <(outs), (ins SingleReg:$c), []>;
// Intermediary step from IR -> ENDLOOP
def LOOPDO_ENDp : KVX_PSEUDO <(outs SingleReg:$o), (ins), []>;
// Required to preserve the loop structure and void elimination of required PHIs
let isBarrier=1, isBranch = 1, isIndirectBranch = 1, isTerminator = 1, isNotDuplicable = 1, Uses = [LC,LE,LS], Defs = [LC,LE,LS], Size = 0, CodeSize = 0 in
def ENDLOOP : KVX_PSEUDO <(outs), (ins Pcrel27:$LpHead,  Pcrel27:$LpExit, Pcrel27:$LpLatch), [ ], "ENDLOOP: $LpHead, $LpExit, $LpLatch">;

// Loop pattern-matched IR intrinsics
def : Pat<(int_set_loop_iterations i64:$c), (LOOPDOp SingleReg:$c)>;
def : Pat<(int_kvx_loopdoexit), (LOOPDO_ENDp)>;

def: Pat<(int_kvx_dinvall AddrRR:$addr), (DINVALLp AddrRR:$addr)>;
def: Pat<(int_kvx_dtouchl AddrRR:$addr), (DTOUCHLp AddrRR:$addr)>;
def: Pat<(int_kvx_dzerol AddrRR:$addr), (DZEROLp AddrRR:$addr)>, Requires<[IsV1]>;
def: Pat<(int_kvx_i1invals AddrRR:$addr), (I1INVALSp AddrRR:$addr)>;

// remove unecessary sign extension
def: Pat<(int_kvx_sbmm8 (sext_inreg i64:$v, i16), (i64 0x0201020102010201)), (SBMM8ri32s SingleReg:$v, (i32 0x02010201))>;
def: Pat<(int_kvx_sbmm8 (and i64:$v, 0xffff), (i64 0x0201020102010201)), (SBMM8ri32s SingleReg:$v, (i32 0x02010201))>;
def: Pat<(int_kvx_sbmm8 (i64 (sext i32:$v)), (i64 0x0804020108040201)), (SBMM8ri32s SingleReg:$v, (i32 0x08040201))>;
def: Pat<(int_kvx_sbmm8 (i64 (zext i32:$v)), (i64 0x0804020108040201)), (SBMM8ri32s SingleReg:$v, (i32 0x08040201))>;

def: Pat<(int_kvx_sbmm8 SingleReg:$r, Signed10:$r2), (SBMM8ri10 SingleReg:$r, Signed10:$r2)>;
def: Pat<(int_kvx_sbmm8 SingleReg:$r, Signed37:$r2), (SBMM8ri37 SingleReg:$r, Signed37:$r2)>;
def: Pat<(int_kvx_sbmm8 SingleReg:$r, Wrapped64:$r2), (SBMM8ri64 SingleReg:$r, Wrapped64:$r2)>;
def: Pat<(int_kvx_sbmm8 SingleReg:$r, SingleReg:$r2), (SBMM8rr SingleReg:$r, SingleReg:$r2)>;

def: Pat<(int_kvx_sbmmt8 SingleReg:$r, Signed10:$r2), (SBMMT8ri10 SingleReg:$r, Signed10:$r2)>;
def: Pat<(int_kvx_sbmmt8 SingleReg:$r, Signed37:$r2), (SBMMT8ri37 SingleReg:$r, Signed37:$r2)>;
def: Pat<(int_kvx_sbmmt8 SingleReg:$r, Wrapped64:$r2), (SBMMT8ri64 SingleReg:$r, Wrapped64:$r2)>;
def: Pat<(int_kvx_sbmmt8 SingleReg:$r, SingleReg:$r2), (SBMMT8rr SingleReg:$r, SingleReg:$r2)>;

multiclass ACSWAP_V1_ri<Intrinsic Int, ValueType Vt, Instruction riI, Operand riO> {
  def: Pat<(Vt(Int (add i64:$addr, riO:$off), Vt:$update, Vt:$expect, boolcas_, coherency_)),
           (Vt (EXTRACT_SUBREG (v2i64
             (riI riO:$off, SingleReg:$addr,
             (v2i64 (REG_SEQUENCE PairedReg,
               SingleReg:$update, sub_d0,
               SingleReg:$expect, sub_d1)
             ))), sub_d0))>, Requires<[IsV1]>;
}

multiclass ACSWAP_V1<Intrinsic Int, ValueType Vt, Instruction ri10, Instruction ri37, Instruction ri64, Instruction rr, int scale> {
  defm  : ACSWAP_V1_ri<Int, Vt, ri10, Signed10>;
  defm : ACSWAP_V1_ri<Int, Vt, ri37, Signed37>;
  defm : ACSWAP_V1_ri<Int, Vt, ri64, Wrapped64>;
  def : Pat<(Vt(Int i64:$addr, Vt:$update, Vt:$expect, boolcas_, coherency_)),
               (Vt (EXTRACT_SUBREG (v2i64
                   (ri10 (i64 0), SingleReg:$addr,
                   (v2i64 (REG_SEQUENCE PairedReg,
                           SingleReg:$update, sub_d0,
                           SingleReg:$expect, sub_d1)
                    ))), sub_d0))>, Requires<[IsV1]>;

  def : Pat<(Vt(Int (add i64:$addr, i64:$off), Vt:$update, Vt:$expect, boolcas_, coherency_)),
              (Vt (EXTRACT_SUBREG (v2i64
                (rr SingleReg:$off, SingleReg:$addr,
                (v2i64 (REG_SEQUENCE PairedReg,
                  SingleReg:$update, sub_d0,
                  SingleReg:$expect, sub_d1)
                ), (i32 0))), sub_d0))>, Requires<[IsV1]>;

  def : Pat<(Vt(Int (add i64:$addr, (shl i64:$off, (i32 scale))), Vt:$update, Vt:$expect, boolcas_, coherency_)),
            (Vt (EXTRACT_SUBREG (v2i64
              (rr SingleReg:$off, SingleReg:$addr,
              (v2i64 (REG_SEQUENCE PairedReg,
                SingleReg:$update, sub_d0,
                SingleReg:$expect, sub_d1)
              ), (i32 1))), sub_d0))>, Requires<[IsV1]>;
}
let Predicates = [IsV1] in {
defm : ACSWAP_V1<int_kvx_acswapw, i32, ACSWAPWri10, ACSWAPWri37, ACSWAPWri64, ACSWAPWrr, 2>;
defm : ACSWAP_V1<int_kvx_acswapd, i64, ACSWAPDri10, ACSWAPDri37, ACSWAPDri64, ACSWAPDrr, 3>;
} // V1


multiclass ACSWAP_V2_ri<Intrinsic Int, ValueType Vt, Instruction riI, Operand riO, RegisterClass D, RegisterClass S, ValueType VVt, SubRegIndex i0, SubRegIndex i1> {
  def: Pat<(Vt(Int (add i64:$addr, riO:$off), Vt:$update, Vt:$expect, BoolcasMod:$bcm, CoherencyMod:$cm)),
           (Vt (riI riO:$off, SingleReg:$addr,
                (VVt (REG_SEQUENCE D,
                  S:$update, i0,
                  S:$expect, i1)
                ), BoolcasMod:$bcm, CoherencyMod:$cm))>, Requires<[IsV2]>;
}

multiclass ACSWAP_V2<Intrinsic Int, ValueType Vt, Instruction ri27, Instruction ri54, Instruction r, RegisterClass D = PairedReg, RegisterClass S = SingleReg, ValueType VVt = v2i64, SubRegIndex i0 = sub_d0, SubRegIndex i1 = sub_d1> {
  defm : ACSWAP_V2_ri<Int, Vt, ri27, Signed27, D, S, VVt, i0, i1>;
  defm : ACSWAP_V2_ri<Int, Vt, ri54, Signed54, D, S, VVt, i0, i1>;
  def: Pat<(Vt(Int i64:$addr, Vt:$update, Vt:$expect, BoolcasMod:$bcm, CoherencyMod:$cm)),
           (Vt (r SingleReg:$addr,
                (VVt (REG_SEQUENCE D,
                  S:$update, i0,
                  S:$expect, i1)
                ), BoolcasMod:$bcm, CoherencyMod:$cm))>, Requires<[IsV2]>;
}

let Predicates = [IsV2] in {
defm : ACSWAP_V2<int_kvx_acswapw, i32, ACSWAPWri27, ACSWAPWri54, ACSWAPWr>;
defm : ACSWAP_V2<int_kvx_acswapd, i64, ACSWAPDri27, ACSWAPDri54, ACSWAPDr>;
defm : ACSWAP_V2<int_kvx_acswapq, v2i64, ACSWAPQri27, ACSWAPQri54, ACSWAPQr, QuadReg, PairedReg, v4i64, sub_q0, sub_q1>;
}

def: Pat<(i32(int_kvx_alclr i64:$addr)), (ALCLRWri10 (i64 0), SingleReg:$addr)>;
def: Pat<(i64(int_kvx_alclr i64:$addr)), (ALCLRDri10 (i64 0), SingleReg:$addr)>;

foreach vt = [f16, v2f16, v4f16] in
def: Pat<(vt (int_kvx_fneg vt:$v)),
         (FNEGHQ SingleReg:$v)>;

def: Pat<(f32 (int_kvx_fneg f32:$v)),
         (FNEGW SingleReg:$v)>;

def: Pat<(f64 (int_kvx_fneg f64:$v)),
         (FNEGD SingleReg:$v)>;

def: Pat<(v2f32(int_kvx_fneg v2f32:$r)),
         (FNEGWP SingleReg:$r)>;


foreach vt = [f16, v2f16, v4f16] in {
def: Pat<(vt(int_kvx_fadd vt:$v1, vt:$v2, i32:$rounding, i32:$silent)),
         (vt(FADDHQrr SingleReg:$v1, SingleReg:$v2, RoundingMod:$rounding, SilentMod:$silent))>;

def: Pat<(vt(int_kvx_fsbf vt:$v1, vt:$v2, i32:$rounding, i32:$silent)),
         (vt(FSBFHQrr SingleReg:$v1, SingleReg:$v2, RoundingMod:$rounding, SilentMod:$silent))>;
}

def: Pat<(v4f32(int_kvx_fadd v4f32:$v1, v4f32:$v2, i32:$rounding, i32:$silent)),
          (FADDWQ PairedReg:$v1, PairedReg:$v2, RoundingMod:$rounding, SilentMod:$silent)>;

def: Pat <(v2f32 (int_kvx_faddc v2f32:$op0, v2f32:$op1, conjugate_, RoundingMod:$mod0, SilentMod:$mod1)),
          (v2f32 (FADDWPrr SingleReg:$op0, SingleReg:$op1, RoundingMod:$mod0, SilentMod:$mod1))>;

def: Pat<(v4f32 (int_kvx_faddc v4f32:$v1, v4f32:$v2, conjugate_, i32:$rounding, i32:$silent)),
         (v4f32 (FADDWQ PairedReg:$v1, PairedReg:$v2, RoundingMod:$rounding, SilentMod:$silent))>;

def: Pat<(v2f64 (int_kvx_faddc v2f64:$v1, v2f64:$v2, conjugate_, i32:$rounding, i32:$silent)),
         (v2f64 (FADDDP PairedReg:$v1, PairedReg:$v2, RoundingMod:$rounding, SilentMod:$silent))>;

def: Pat<(v2f32(int_kvx_fsbfc v2f32:$v1, v2f32:$v2, conjugate_, i32:$rounding, i32:$silent)),
          (FSBFWPrr SingleReg:$v1, SingleReg:$v2, RoundingMod:$rounding, SilentMod:$silent)>;

def: Pat<(v2f32(int_kvx_fsbfc v2f32:$v1, v2f32:$v2, conjugate_, i32:$rounding, i32:$silent)),
          (FSBFWPrr SingleReg:$v1, SingleReg:$v2, RoundingMod:$rounding, SilentMod:$silent)>;

def: Pat<(v4f32(int_kvx_fsbfc v4f32:$v1, v4f32:$v2, conjugate_, i32:$rounding, i32:$silent)),
          (FSBFWQ PairedReg:$v1, PairedReg:$v2, RoundingMod:$rounding, SilentMod:$silent)>;

def: Pat<(v2f64(int_kvx_fsbfc v2f64:$v1, v2f64:$v2, conjugate_, i32:$rounding, i32:$silent)),
          (FSBFDP PairedReg:$v1, PairedReg:$v2, RoundingMod:$rounding, SilentMod:$silent)>;

def: Pat<(v2f32(int_kvx_fmul v2f32:$v1, v2f32:$v2, i32:$rounding, i32:$silent)),
         (FMULWPrr SingleReg:$v1, SingleReg:$v2, RoundingMod:$rounding, SilentMod:$silent)>;

def: Pat<(v4f32(int_kvx_fmul v4f32:$v1, v4f32:$v2, i32:$rounding, i32:$silent)),
         (FMULWQ PairedReg:$v1, PairedReg:$v2, RoundingMod:$rounding, SilentMod:$silent)>;


multiclass FFM___<Intrinsic Int, Instruction Opcode, ValueType OperandTy, ValueType DataTy> {
  def: Pat<(Int OperandTy:$v1, OperandTy:$v2, OperandTy:$v3, i32:$rounding, i32:$silent),
    (OperandTy (REG_SEQUENCE PairedReg,
      (Opcode (DataTy (EXTRACT_SUBREG PairedReg:$v3, sub_d0)),
              (DataTy (EXTRACT_SUBREG PairedReg:$v1, sub_d0)),
              (DataTy (EXTRACT_SUBREG PairedReg:$v2, sub_d0)), RoundingMod:$rounding, SilentMod:$silent), sub_d0,
      (Opcode (DataTy (EXTRACT_SUBREG PairedReg:$v3, sub_d1)),
              (DataTy (EXTRACT_SUBREG PairedReg:$v1, sub_d1)),
              (DataTy (EXTRACT_SUBREG PairedReg:$v2, sub_d1)), RoundingMod:$rounding, SilentMod:$silent), sub_d1))>;
}

defm: FFM___<int_kvx_ffma, FFMAWPrr, v4f32, v2f32>, Requires<[IsV1]>;
defm: FFM___<int_kvx_ffms, FFMSWPrr, v4f32, v2f32>, Requires<[IsV1]>;
defm: FFM___<int_kvx_ffma, FFMADrr, v2f64, f64>;
defm: FFM___<int_kvx_ffms, FFMSDrr, v2f64, f64>;

def: Pat<(v4f32(int_kvx_ffms v4f32:$v1, v4f32:$v2, v4f32:$v3, i32:$r, i32:$s)),
         (v4f32(FFMSWQ PairedReg:$v3, PairedReg:$v2, PairedReg:$v1, RoundingMod:$r, SilentMod:$s))>, Requires<[IsV2]>;

def: Pat<(v4f32(int_kvx_ffma v4f32:$v2, v4f32:$v3, v4f32:$v1, i32:$r, i32:$s)),
         (v4f32(FFMAWQ PairedReg:$v1, PairedReg:$v2, PairedReg:$v3, RoundingMod:$r, SilentMod:$s))>, Requires<[IsV2]>;

def: Pat<(f32 (int_kvx_ffdma v2f32:$lhs, v2f32:$rhs, RoundingMod:$r, SilentMod:$s)),
         (FFDMAW SingleReg:$lhs, SingleReg:$rhs, RoundingMod:$r, SilentMod:$s)>, Requires<[IsV2]>;

def: Pat<(f32 (int_kvx_ffdma v2f32:$lhs, v2f32:$rhs, RoundingMod:$r, SilentMod:$s)),
         (FDOT2Wrr SingleReg:$lhs, SingleReg:$rhs, RoundingMod:$r, SilentMod:$s)>, Requires<[IsV1]>;

def: Pat<(v2f32 (int_kvx_ffdma v4f32:$lhs, v4f32:$rhs, RoundingMod:$r, SilentMod:$s)),
         (FFDMAWP PairedReg:$lhs, PairedReg:$rhs, RoundingMod:$r, SilentMod:$s)>, Requires<[IsV2]>;

def: Pat<(v2f32 (int_kvx_ffdma v4f32:$lhs, v4f32:$rhs, RoundingMod:$r, SilentMod:$s)),
         (FADDWPrr (v2f32 (EXTRACT_SUBREG (FADDWQ $lhs, $rhs, RoundingMod:$r, SilentMod:$s), sub_d0)),
                (v2f32 (EXTRACT_SUBREG (FADDWQ $lhs, $rhs, RoundingMod:$r, SilentMod:$s), sub_d1)),
                RoundingMod:$r, SilentMod:$s)>, Requires<[IsV1]>;

def: Pat<(f32 (int_kvx_ffdmda v2f32:$v0, v2f32:$v1, f32:$v2, i32:$rounding, i32:$silent)),
          (FADDWrr
            (FDOT2Wrr SingleReg:$v0, SingleReg:$v1, RoundingMod:$rounding, SilentMod:$silent)
            , SingleReg:$v2, RoundingMod:$rounding, SilentMod:$silent
          )>, Requires<[IsV1]>;

def: Pat<(v2f32(int_kvx_ffdmda v4f32:$v0, v4f32:$v1, v2f32:$v2, i32:$rounding, i32:$silent)),
          (FFMAWPrr
            (FFMAWPrr
              SingleReg:$v2,
              (v2f32 (EXTRACT_SUBREG PairedReg:$v0, sub_d0)),
              (v2f32 (EXTRACT_SUBREG PairedReg:$v1, sub_d0)), RoundingMod:$rounding, SilentMod:$silent),
            (v2f32 (EXTRACT_SUBREG PairedReg:$v0, sub_d1)),
            (v2f32 (EXTRACT_SUBREG PairedReg:$v1, sub_d1)),
            RoundingMod:$rounding, SilentMod:$silent
          )>, Requires<[IsV1]>;

def: Pat<(f32 (int_kvx_ffdms v2f32:$lhs, v2f32:$rhs, RoundingMod:$r, SilentMod:$s)),
         (FFDMSW SingleReg:$lhs, SingleReg:$rhs, RoundingMod:$r, SilentMod:$s)>, Requires<[IsV2]>;

def: Pat<(v2f32 (int_kvx_ffdms v4f32:$lhs, v4f32:$rhs, RoundingMod:$r, SilentMod:$s)),
         (FFDMSWP PairedReg:$lhs, PairedReg:$rhs, RoundingMod:$r, SilentMod:$s)>, Requires<[IsV2]>;

def: Pat<(v2f32(int_kvx_ffma v2f32:$v1, v2f32:$v2, v2f32:$v3, i32:$rounding, i32:$silent)), (FFMAWPrr SingleReg:$v3, SingleReg:$v1, SingleReg:$v2, RoundingMod:$rounding, SilentMod:$silent)>;
def: Pat<(v2f32(int_kvx_ffms v2f32:$v1, v2f32:$v2, v2f32:$v3, i32:$rounding, i32:$silent)), (FFMSWPrr SingleReg:$v3, SingleReg:$v1, SingleReg:$v2, RoundingMod:$rounding, SilentMod:$silent)>;
def: Pat<(int_kvx_fmm212w v2f32:$v1, v2f32:$v2, i32:$rounding, i32:$silent), (FMM212W SingleReg:$v1, SingleReg:$v2, RoundingMod:$rounding, SilentMod:$silent)>;
def: Pat<(int_kvx_fmma212w v2f32:$v1, v2f32:$v2, v4f32:$v3, i32:$rounding, i32:$silent), (FMMA212W PairedReg:$v3, SingleReg:$v1, SingleReg:$v2, RoundingMod:$rounding, SilentMod:$silent)>;
def: Pat<(int_kvx_fmms212w v2f32:$v1, v2f32:$v2, v4f32:$v3, i32:$rounding, i32:$silent), (FMMS212W PairedReg:$v3, SingleReg:$v1, SingleReg:$v2, RoundingMod:$rounding, SilentMod:$silent)>;

def: Pat<(v2f32(int_kvx_fcmul v2f32:$v1, v2f32:$v2, i32:$conjugate, i32:$rounding, i32:$silent)),
         (FMULWCrr SingleReg:$v1, SingleReg:$v2, ConjugateMod:$conjugate, RoundingMod:$rounding, SilentMod:$silent)>;

def: Pat<(v4f32(int_kvx_fcmul v4f32:$v1, v4f32:$v2, i32:$conjugate, i32:$rounding, i32:$silent)),
  (v4f32 (REG_SEQUENCE PairedReg,
     (FMULWCrr (v2f32 (EXTRACT_SUBREG PairedReg:$v1, sub_d0)),
               (v2f32 (EXTRACT_SUBREG PairedReg:$v2, sub_d0)), ConjugateMod:$conjugate, RoundingMod:$rounding, SilentMod:$silent), sub_d0,
     (FMULWCrr (v2f32 (EXTRACT_SUBREG PairedReg:$v1, sub_d1)),
               (v2f32 (EXTRACT_SUBREG PairedReg:$v2, sub_d1)), ConjugateMod:$conjugate, RoundingMod:$rounding, SilentMod:$silent), sub_d1))>, Requires<[IsV1]>;

def: Pat<(v4f32 (int_kvx_fcmul v4f32:$v1, v4f32:$v2, i32:$conjugate, i32:$rounding, i32:$silent)),
  (v4f32 (FMULWCP PairedReg:$v1, PairedReg:$v2, ConjugateMod:$conjugate, RoundingMod:$rounding, SilentMod:$silent))>, Requires<[IsV2]>;

multiclass FMUL_DC<Instruction FFMS, Instruction FFMA, Conjugate CM> {
  def: Pat<(int_kvx_fcmul v2f64:$v1, v2f64:$v2, CM, i32:$rounding, i32:$silent),
    (v2f64 (REG_SEQUENCE PairedReg,
      (FFMS (FMULDrr (f64 (EXTRACT_SUBREG PairedReg:$v1, sub_d0)), (f64 (EXTRACT_SUBREG PairedReg:$v2, sub_d0)), RoundingMod:$rounding, SilentMod:$silent),
            (f64 (EXTRACT_SUBREG PairedReg:$v1, sub_d1)),
            (f64 (EXTRACT_SUBREG PairedReg:$v2, sub_d1)), RoundingMod:$rounding, SilentMod:$silent), sub_d0,
      (FFMA (FMULDrr (f64 (EXTRACT_SUBREG PairedReg:$v1, sub_d0)), (f64 (EXTRACT_SUBREG PairedReg:$v2, sub_d1)), RoundingMod:$rounding, SilentMod:$silent),
            (f64 (EXTRACT_SUBREG PairedReg:$v1, sub_d1)),
            (f64 (EXTRACT_SUBREG PairedReg:$v2, sub_d0)), RoundingMod:$rounding, SilentMod:$silent), sub_d1))>;
}

defm: FMUL_DC<FFMSDrr, FFMADrr, conjugate_>;
defm: FMUL_DC<FFMADrr, FFMSDrr, conjugate_c>;

multiclass FFM__DC<Intrinsic int_kvx_ffmop, Instruction FOP, Instruction FFMS, Instruction FFMA, Conjugate C> {
  def: Pat<(v2f64(int_kvx_ffmop v2f64:$v1, v2f64:$v2, v2f64:$v3, C, i32:$rounding, i32:$silent)),
    (FOP
      (v2f64 (REG_SEQUENCE PairedReg,
        (FFMS (FMULDrr (f64 (EXTRACT_SUBREG PairedReg:$v1, sub_d0)), (f64 (EXTRACT_SUBREG PairedReg:$v2, sub_d0)), RoundingMod:$rounding, SilentMod:$silent),
              (f64 (EXTRACT_SUBREG PairedReg:$v1, sub_d1)),
              (f64 (EXTRACT_SUBREG PairedReg:$v2, sub_d1)), RoundingMod:$rounding, SilentMod:$silent), sub_d0,
        (FFMA (FMULDrr (f64 (EXTRACT_SUBREG PairedReg:$v1, sub_d1)), (f64 (EXTRACT_SUBREG PairedReg:$v2, sub_d0)), RoundingMod:$rounding, SilentMod:$silent),
              (f64 (EXTRACT_SUBREG PairedReg:$v1, sub_d0)),
              (f64 (EXTRACT_SUBREG PairedReg:$v2, sub_d1)), RoundingMod:$rounding, SilentMod:$silent), sub_d1)),
      PairedReg:$v3, RoundingMod:$rounding, SilentMod:$silent)>;
}

defm: FFM__DC<int_kvx_fcfma, FADDDP, FFMSDrr, FFMADrr, conjugate_>;
defm: FFM__DC<int_kvx_fcfms, FSBFDP, FFMSDrr, FFMADrr, conjugate_>;
defm: FFM__DC<int_kvx_fcfma, FADDDC, FFMADrr, FFMSDrr, conjugate_c>;
defm: FFM__DC<int_kvx_fcfms, FSBFDC, FFMADrr, FFMSDrr, conjugate_c>;

multiclass FFM__WC<Intrinsic int_kvx_fop, Instruction FOP, Conjugate C> {
  def: Pat<(v2f32(int_kvx_fop v2f32:$v1, v2f32:$v2, v2f32:$v3, C, i32:$rounding, i32:$silent)),
    (FOP (FMULWCrr SingleReg:$v2, SingleReg:$v1, C, RoundingMod:$rounding, SilentMod:$silent),
         SingleReg:$v3, RoundingMod:$rounding, SilentMod:$silent)>;
}

defm: FFM__WC<int_kvx_fcfma, FADDWPrr, conjugate_>;
defm: FFM__WC<int_kvx_fcfms, FSBFWPrr, conjugate_>;
defm: FFM__WC<int_kvx_fcfma, FADDWCrr, conjugate_c>;
defm: FFM__WC<int_kvx_fcfms, FSBFWCrr, conjugate_c>;

multiclass FFM__WCP<Intrinsic int_kvx_fop, Instruction FOP, Conjugate C> {
  def: Pat<(v4f32(int_kvx_fop v4f32:$v1, v4f32:$v2, v4f32:$v3, C, i32:$rounding, i32:$silent)),
    (v4f32 (REG_SEQUENCE PairedReg,
       (FOP (FMULWCrr (v2f32 (EXTRACT_SUBREG PairedReg:$v2, sub_d0)),
                  (v2f32 (EXTRACT_SUBREG PairedReg:$v1, sub_d0)), C, RoundingMod:$rounding, SilentMod:$silent),
            (v2f32 (EXTRACT_SUBREG PairedReg:$v3, sub_d0)), RoundingMod:$rounding, SilentMod:$silent), sub_d0,
       (FOP (FMULWCrr (v2f32 (EXTRACT_SUBREG PairedReg:$v2, sub_d1)),
                  (v2f32 (EXTRACT_SUBREG PairedReg:$v1, sub_d1)), C, RoundingMod:$rounding, SilentMod:$silent),
            (v2f32 (EXTRACT_SUBREG PairedReg:$v3, sub_d1)), RoundingMod:$rounding, SilentMod:$silent), sub_d1))>, Requires<[IsV1]>;
}

defm: FFM__WCP<int_kvx_fcfma, FADDWPrr, conjugate_>;
defm: FFM__WCP<int_kvx_fcfms, FSBFWCrr, conjugate_>;
defm: FFM__WCP<int_kvx_fcfma, FADDWCrr, conjugate_c>;
defm: FFM__WCP<int_kvx_fcfms, FSBFWCrr, conjugate_c>;

def: Pat<(v2f32(int_kvx_fcconj v2f32:$v)), (FNEGD SingleReg:$v)>;
def: Pat<(int_kvx_fcconj v2f64:$v),
  (v2f64 (REG_SEQUENCE PairedReg,
    (f64 (EXTRACT_SUBREG PairedReg:$v, sub_d0)), sub_d0,
    (FNEGD (f64 (EXTRACT_SUBREG PairedReg:$v, sub_d1))), sub_d1))>;

def: Pat<(i64(int_kvx_bitcnt i64:$r, (i32 3))), (CTZD SingleReg:$r)>;
def: Pat<(i32(int_kvx_bitcnt i32:$r, (i32 3))), (CTZW SingleReg:$r)>;
def: Pat<(v2i32(int_kvx_bitcnt v2i32:$r, (i32 3))), (CTZWP SingleReg:$r)>;
def: Pat<(i64(int_kvx_bitcnt i64:$r, (i32 1))), (CLZD SingleReg:$r)>;
def: Pat<(i32(int_kvx_bitcnt i32:$r, (i32 1))), (CLZW SingleReg:$r)>;
def: Pat<(v2i32(int_kvx_bitcnt v2i32:$r, (i32 1))), (CLZWP SingleReg:$r)>;
def: Pat<(i64(int_kvx_bitcnt i64:$r, (i32 2))), (CLSD SingleReg:$r)>;
def: Pat<(i32(int_kvx_bitcnt i32:$r, (i32 2))), (CLSW SingleReg:$r)>;
def: Pat<(v2i32(int_kvx_bitcnt v2i32:$r, (i32 2))), (CLSWP SingleReg:$r)>;
def: Pat<(i64(int_kvx_bitcnt i64:$r, (i32 0))), (CBSD SingleReg:$r)>;
def: Pat<(i32(int_kvx_bitcnt i32:$r, (i32 0))), (CBSW SingleReg:$r)>;
def: Pat<(v2i32(int_kvx_bitcnt v2i32:$r, (i32 0))), (CBSWP SingleReg:$r)>;

def: Pat<(v2f16(int_kvx_fnarrow v2f32:$v, i32:$rounding, silent_s)),
         (v2f16 (FNARROWWHQ (v4f32 (REG_SEQUENCE PairedReg, (v2f32(IMPLICIT_DEF)), sub_d1, $v, sub_d0)), RoundingMod:$rounding, silent_s))>;

def: Pat<(v2f16(int_kvx_fnarrow v2f32:$v, i32:$rounding, silent_)),
         (FNARROWWHQ (v4f32 (REG_SEQUENCE PairedReg, (v2f32 (MAKEi16 0)), sub_d1, $v, sub_d0)), RoundingMod:$rounding, silent_)>;

def: Pat<(v2f32(int_kvx_fmulx v2f16:$lhs, v2f16:$rhs, RoundingMod:$r, SilentMod:$s)),
         (v2f32 (EXTRACT_SUBREG (v4f32 (FMULHWQrr SingleReg:$lhs, SingleReg:$rhs, RoundingMod:$r, SilentMod:$s)), sub_d0))>;

def: Pat<(int_kvx_satd i64:$v, i32:$b), (SATDrr SingleReg:$v, SingleReg:$b)>;

def: Pat<(i32 (int_kvx_stsu i32:$x, i32:$y)),
         (STSUWrr SingleReg:$x, SingleReg:$y)>;

let Predicates = [IsV2] in {
def: Pat<(i32 (int_kvx_stsu i32:$x, Wrapped32:$y)),
         (STSUWri SingleReg:$x, Wrapped32:$y)>;

def: Pat<(i64 (int_kvx_stsu i64:$x, Wrapped64W:$y)),
         (STSUDri SingleReg:$x, (trunc_imm_32 $y), splat32_)>;

def: Pat<(i64 (int_kvx_stsu i64:$x, UnsignedSplat32Imm:$y)),
         (STSUDri SingleReg:$x, (trunc_imm_32 $y), splat32_at)>;
} // IsV2

def: Pat<(i64 (int_kvx_stsu i64:$x, i64:$y)),
         (STSUDrr SingleReg:$x, SingleReg:$y)>;

def: Pat<(int_kvx_aladdd i64:$addr, i64:$val), (ALADDDri10 (i64 0), SingleReg:$addr, SingleReg:$val)>;
def: Pat<(int_kvx_aladdd AddrFI:$addr, i64:$val), (ALADDDri64 (i64 0), SingleReg:$addr, SingleReg:$val)>;
def: Pat<(int_kvx_aladdw i64:$addr, i32:$val), (ALADDWri10 (i64 0), SingleReg:$addr, SingleReg:$val)>;
def: Pat<(int_kvx_aladdw AddrFI:$addr, i32:$val), (ALADDWri64 (i64 0), SingleReg:$addr, SingleReg:$val)>;

def: Pat<(int_kvx_addsw i32:$v1, i32:$v2), (ADDSWrr SingleReg:$v1, SingleReg:$v2)>;
def: Pat<(int_kvx_addsd i64:$v1, i64:$v2), (ADDSDrr SingleReg:$v1, SingleReg:$v2)>;
def: Pat<(int_kvx_addshq v4i16:$v1, v4i16:$v2), (ADDSHQrr SingleReg:$v1, SingleReg:$v2)>;
def: Pat<(int_kvx_addswp v2i32:$v1, v2i32:$v2), (ADDSWPrr SingleReg:$v1, SingleReg:$v2)>;

def: Pat<(int_kvx_sbfshq v4i16:$v1, v4i16:$v2), (SBFSHQrr SingleReg:$v1, SingleReg:$v2)>;
def: Pat<(int_kvx_sbfswp v2i32:$v1, v2i32:$v2), (SBFSWPrr SingleReg:$v1, SingleReg:$v2)>;
def: Pat<(int_kvx_sbfsw i32:$v1, i32:$v2), (SBFSWrr SingleReg:$v1, SingleReg:$v2)>;
def: Pat<(int_kvx_sbfsd i64:$v1, i64:$v2), (SBFSDrr SingleReg:$v1, SingleReg:$v2)>;

def: Pat<(int_kvx_addcd i64:$v1, i64:$v2, (i32 0)), (ADDCD SingleReg:$v1, SingleReg:$v2)>;
def: Pat<(int_kvx_addcd i64:$v1, i64:$v2, (i32 1)), (ADDCDI SingleReg:$v1, SingleReg:$v2)>;

def: Pat<(int_kvx_sbfcd i64:$v1, i64:$v2, (i32 0)), (SBFCD SingleReg:$v1, SingleReg:$v2)>;
def: Pat<(int_kvx_sbfcd i64:$v1, i64:$v2, (i32 1)), (SBFCDI SingleReg:$v1, SingleReg:$v2)>;

def: Pat<(f32(int_fabs f32:$v)),
         (FABSW SingleReg:$v)>;

def: Pat<(f64(int_fabs f64:$v)),
         (FABSD SingleReg:$v)>;

def: Pat<(int_kvx_frecw f32:$f, i32:$rounding, i32:$silent), (FRECW SingleReg:$f, RoundingMod:$rounding, SilentMod:$silent)>;
def: Pat<(int_kvx_frsrw f32:$f, i32:$rounding, i32:$silent), (FRSRW SingleReg:$f, RoundingMod:$rounding, SilentMod:$silent)>;
def: Pat<(f32(int_kvx_fadd f32:$v1, f32:$v2, i32:$rounding, i32:$silent)), (FADDWrr SingleReg:$v1, SingleReg:$v2, RoundingMod:$rounding, SilentMod:$silent)>;
def: Pat<(f64(int_kvx_fadd f64:$v1, f64:$v2, i32:$rounding, i32:$silent)), (FADDDrr SingleReg:$v1, SingleReg:$v2, RoundingMod:$rounding, SilentMod:$silent)>;
def: Pat<(f32(int_kvx_fsbf f32:$v1, f32:$v2, i32:$rounding, i32:$silent)), (FSBFWrr SingleReg:$v1, SingleReg:$v2, RoundingMod:$rounding, SilentMod:$silent)>;
def: Pat<(f64(int_kvx_fsbf f64:$v1, f64:$v2, i32:$rounding, i32:$silent)), (FSBFDrr SingleReg:$v1, SingleReg:$v2, RoundingMod:$rounding, SilentMod:$silent)>;
def: Pat<(f32(int_kvx_fmul f32:$v1, f32:$v2, i32:$rounding, i32:$silent)), (FMULWrr SingleReg:$v1, SingleReg:$v2, RoundingMod:$rounding, SilentMod:$silent)>;
def: Pat<(f64(int_kvx_fmul f64:$v1, f64:$v2, i32:$rounding, i32:$silent)), (FMULDrr SingleReg:$v1, SingleReg:$v2, RoundingMod:$rounding, SilentMod:$silent)>;
def: Pat<(f64(int_kvx_fmulx f32:$v1, f32:$v2, i32:$rounding, i32:$silent)), (FMULWDrr SingleReg:$v1, SingleReg:$v2, RoundingMod:$rounding, SilentMod:$silent)>;
def: Pat<(v2f64(int_kvx_fmulx v2f32:$v1, v2f32:$v2, i32:$rounding, i32:$silent)), (FMULWDPrr SingleReg:$v1, SingleReg:$v2, RoundingMod:$rounding, SilentMod:$silent)>;
def: Pat<(f32(int_kvx_ffma f32:$v1, f32:$v2, f32:$v3, i32:$rounding, i32:$silent)), (FFMAWrr SingleReg:$v3, SingleReg:$v1, SingleReg:$v2, RoundingMod:$rounding, SilentMod:$silent)>;
def: Pat<(f32(int_kvx_ffma f32:$v1, f32:$v2, f64:$v3, i32:$rounding, i32:$silent)), (FFMAWDrr SingleReg:$v3, SingleReg:$v1, SingleReg:$v2, RoundingMod:$rounding, SilentMod:$silent)>;
def: Pat<(f32(int_kvx_ffms f32:$v1, f32:$v2, f32:$v3, i32:$rounding, i32:$silent)), (FFMSWrr SingleReg:$v3, SingleReg:$v1, SingleReg:$v2, RoundingMod:$rounding, SilentMod:$silent)>;
def: Pat<(f64(int_kvx_ffms f64:$v1, f64:$v2, f64:$v3, i32:$rounding, i32:$silent)), (FFMSDrr SingleReg:$v3, SingleReg:$v1, SingleReg:$v2, RoundingMod:$rounding, SilentMod:$silent)>;
def: Pat<(f32(int_kvx_ffms f32:$v1, f32:$v2, f64:$v3, i32:$rounding, i32:$silent)), (FFMSWDrr SingleReg:$v3, SingleReg:$v1, SingleReg:$v2, RoundingMod:$rounding, SilentMod:$silent)>;
def: Pat<(f32 (int_kvx_fcdiv f32:$v1, f32:$v2, i32:$silent)), (f32(FCDIVW (v4f32(REG_SEQUENCE PairedReg, SingleReg:$v1, sub_d0, SingleReg:$v2, sub_d1)), SilentMod:$silent))>;
def: Pat<(v2f32 (int_kvx_fcdiv v2f32:$v1, v2f32:$v2, i32:$silent)), (v2f32(FCDIVWP (v4f32(REG_SEQUENCE PairedReg, SingleReg:$v1, sub_d0, SingleReg:$v2, sub_d1)), SilentMod:$silent))>;
def: Pat<(f64(int_kvx_fcdiv f64:$v1, f64:$v2, i32:$silent)), (f64(FCDIVD (v2f64(REG_SEQUENCE PairedReg, SingleReg:$v1, sub_d0, SingleReg:$v2, sub_d1)), SilentMod:$silent))>;
def: Pat<(f32(int_kvx_fsdiv f32:$v1, f32:$v2, i32:$silent)), (f32(FSDIVW (v4f32 (REG_SEQUENCE PairedReg, SingleReg:$v1, sub_d0, SingleReg:$v2, sub_d1)), SilentMod:$silent))>;
def: Pat<(v2f32(int_kvx_fsdiv v2f32:$v1, v2f32:$v2, i32:$silent)), (v2f32 (FSDIVWP (v4f32(REG_SEQUENCE PairedReg, SingleReg:$v1, sub_d0, SingleReg:$v2, sub_d1)), SilentMod:$silent))>;
def: Pat<(f64(int_kvx_fsdiv f64:$v1, f64:$v2, i32:$silent)), (f64 (FSDIVD (v2f64 (REG_SEQUENCE PairedReg, SingleReg:$v1, sub_d0, SingleReg:$v2, sub_d1)), SilentMod:$silent))>;

multiclass INT_MADDDT_FAMILY <Intrinsic int_madddt, bit isSub=0> {
  defvar rr = !cond(isSub:!cast<Instruction>(NAME),
                    !not(isSub):!cast<Instruction>(NAME # rr));
  def: Pat<(int_madddt v2i64:$acc, i64:$a, i64:$b), (rr PairedReg:$acc, SingleReg:$a, SingleReg:$b)>;
  if !not(isSub) then {
    defvar ri10 = !cast<Instruction>(NAME # ri10);
    defvar ri37 = !cast<Instruction>(NAME # ri37);
    defvar ri64 = !cast<Instruction>(NAME # ri64);
    let Predicates = [IsV1] in {
      def: Pat<(int_madddt v2i64:$acc, i64:$a, Signed10:$b), (ri10 PairedReg:$acc, SingleReg:$a, Signed10:$b)>;
      def: Pat<(int_madddt v2i64:$acc, i64:$a, Signed37:$b), (ri37 PairedReg:$acc, SingleReg:$a, Signed37:$b)>;
      def: Pat<(int_madddt v2i64:$acc, i64:$a, Wrapped64:$b), (ri64 PairedReg:$acc, SingleReg:$a, Wrapped64:$b)>;
    }
  }
}

defm MADDDT: INT_MADDDT_FAMILY<int_kvx_madddt>;
defm MADDSUDT: INT_MADDDT_FAMILY<int_kvx_maddsudt>;
defm MADDUDT: INT_MADDDT_FAMILY<int_kvx_maddudt>;
defm MADDUZDT: INT_MADDDT_FAMILY<int_kvx_madduzdt>;
defm MSBFDT: INT_MADDDT_FAMILY<int_kvx_msbfdt, /*isSub*/ 1>;
defm MSBFSUDT: INT_MADDDT_FAMILY<int_kvx_msbfsudt, /*isSub*/ 1>;
defm MSBFUDT: INT_MADDDT_FAMILY<int_kvx_msbfudt, /*isSub*/ 1>;
defm MSBFUZDT: INT_MADDDT_FAMILY<int_kvx_msbfuzdt, /*isSub*/ 1>;

multiclass INTR_SELECT_VEC<ValueType VT, ValueType CVT, Instruction I> {
  def: Pat<(VT (int_kvx_select_vec VT:$t, VT:$f, CVT:$c, SimplecondMod:$sc)),
           (VT (I SingleReg:$c, SingleReg:$f, VT:$t, SimplecondMod:$sc))>;
}

foreach vt = [v2i8, v4i8] in
defm : INTR_SELECT_VEC<vt, vt, CMOVEBO>, Requires<[IsV2]>;

foreach vt = [v2i16, v2f16] in
defm : INTR_SELECT_VEC<vt, v2i16, CMOVEHQ>;

foreach vt = [v4i16, v4f16] in
defm : INTR_SELECT_VEC<vt, v4i16, CMOVEHQ>;

foreach vt = [v2i32, v2f32] in
defm : INTR_SELECT_VEC<vt, v2i32, CMOVEWP>;

def: Pat<(i64(int_kvx_select Signed10:$t, i64:$f, i64:$c, i32:$sc)),
         (CMOVEDri10 SingleReg:$c, SingleReg:$f, Signed10:$t, ScalarcondMod:$sc)>;

def: Pat<(i64(int_kvx_select Signed37:$t, i64:$f, i64:$c, i32:$sc)),
         (CMOVEDri37 SingleReg:$c, SingleReg:$f, Signed37:$t, ScalarcondMod:$sc)>;

def: Pat<(i64(int_kvx_select Wrapped64:$t, i64:$f, i64:$c, i32:$sc)),
         (CMOVEDri64 SingleReg:$c, SingleReg:$f, Wrapped64:$t, ScalarcondMod:$sc)>;

def: Pat<(i32(int_kvx_select Signed10W:$t, i32:$f, i64:$c, i32:$sc)),
         (CMOVEDri10 SingleReg:$c, SingleReg:$f, (imm32_to_imm64 $t), ScalarcondMod:$sc)>;

def: Pat<(i32(int_kvx_select Wrapped32:$t, i32:$f, i64:$c, i32:$sc)),
         (CMOVEDri37 SingleReg:$c, SingleReg:$f, (imm32_to_imm64 $t), ScalarcondMod:$sc)>;

foreach vt = [f32, i32, f64, i64] in
def: Pat<(vt(int_kvx_select vt:$t, vt:$f, i64:$c, i32:$sc)),
         (CMOVEDrr SingleReg:$c, SingleReg:$f, SingleReg:$t, ScalarcondMod:$sc)>;

// widen patterns
def: Pat<(v2f64 (int_kvx_fwiden v2f32:$v, SilentMod:$silent)),
         (REG_SEQUENCE PairedReg,
            (FWIDENLWD SingleReg:$v, SilentMod:$silent), sub_d0,
            (FWIDENMWD SingleReg:$v, SilentMod:$silent), sub_d1)>;

def: Pat<(v4f32 (int_kvx_fwiden v4f16:$v, SilentMod:$silent)),
         (REG_SEQUENCE PairedReg,
            (FWIDENLHWP SingleReg:$v, SilentMod:$silent), sub_d0,
            (FWIDENMHWP SingleReg:$v, SilentMod:$silent), sub_d1)>;

// f16 patterns
multiclass F16_SUBVECTOR__BINOP<Intrinsic I, Instruction RR> {
def: Pat<(v2f16 (I v2f16:$f1, v2f16:$f2, i32:$rounding, silent_)),
         (RR (ZXWD SingleReg:$f1), (ZXWD SingleReg:$f2), RoundingMod:$rounding, silent_)>;

def: Pat<(v2f16 (I v2f16:$f1, v2f16:$f2, i32:$rounding, silent_s)),
         (RR SingleReg:$f1, SingleReg:$f2, RoundingMod:$rounding, silent_s)>;

def: Pat<(f16 (I f16:$f1, f16:$f2, i32:$rounding, silent_)),
         (RR (ZXHD SingleReg:$f1), (ZXHD SingleReg:$f2), RoundingMod:$rounding, silent_)>;

def: Pat<(f16 (I f16:$f1, f16:$f2, i32:$rounding, silent_s)),
         (RR SingleReg:$f1, SingleReg:$f2, RoundingMod:$rounding, silent_s)>;
}

def: Pat<(v4f16 (int_kvx_fmul v4f16:$v1, v4f16:$v2, i32:$rounding, i32:$silent)),
         (FMULHQrr SingleReg:$v1, SingleReg:$v2, RoundingMod:$rounding, SilentMod:$silent)>;

defm : F16_SUBVECTOR__BINOP<int_kvx_fmul, FMULHQrr>;

def: Pat<(v8f16(int_kvx_ffma v8f16:$L, v8f16:$R, v8f16:$acc, i32:$rounding, i32:$silent)),
  (v8f16 (REG_SEQUENCE PairedReg,
          (v4f16 (FFMAHQrr (v4f16 (EXTRACT_SUBREG PairedReg:$acc, sub_d0)),
                           (v4f16 (EXTRACT_SUBREG PairedReg:$L, sub_d0)),
                           (v4f16 (EXTRACT_SUBREG PairedReg:$R, sub_d0)),
                           RoundingMod:$rounding, SilentMod:$silent)),
          sub_d0,
          (v4f16 (FFMAHQrr (v4f16 (EXTRACT_SUBREG PairedReg:$acc, sub_d1)),
                           (v4f16 (EXTRACT_SUBREG PairedReg:$L, sub_d1)),
                           (v4f16 (EXTRACT_SUBREG PairedReg:$R, sub_d1)),
                           RoundingMod:$rounding, SilentMod:$silent)),
          sub_d1))>, Requires<[IsV1]>;

def: Pat<(v4f16(int_kvx_ffma v4f16:$L, v4f16:$R, v4f16:$acc, i32:$rounding, i32:$silent)),
  (v4f16 (FFMAHQrr SingleReg:$acc, SingleReg:$L, SingleReg:$R, RoundingMod:$rounding, SilentMod:$silent))>;

def: Pat<(v2f16(int_kvx_ffma v2f16:$L, v2f16:$R, v2f16:$acc, i32:$rounding, silent_s)),
  (v2f16 (FFMAHQrr SingleReg:$acc, SingleReg:$L, SingleReg:$R, RoundingMod:$rounding, silent_s))>;

def: Pat<(v2f16(int_kvx_ffma v2f16:$L, v2f16:$R, v2f16:$acc, i32:$rounding, silent_)),
  (v2f16 (FFMAHQrr (ZXWD SingleReg:$acc), (ZXWD SingleReg:$L), (ZXWD SingleReg:$R), RoundingMod:$rounding, silent_))>;

def: Pat<(f16(int_kvx_ffma f16:$L, f16:$R, f16:$acc, i32:$rounding, silent_s)),
  (f16 (FFMAHQrr SingleReg:$acc, SingleReg:$L, SingleReg:$R, RoundingMod:$rounding, silent_s))>;

def: Pat<(f16(int_kvx_ffma f16:$L, f16:$R, f16:$acc, i32:$rounding, silent_)),
  (f16 (FFMAHQrr (ZXHD SingleReg:$acc), (ZXHD SingleReg:$L), (ZXHD SingleReg:$R), RoundingMod:$rounding, silent_))>;

//===----------------------------------------------------------------------===//
// TCA - tightly-coupled accelerator
//===----------------------------------------------------------------------===//
// Move from GRP to TCA registers
// We use pseudo-instruction to hide from the compiler that these instructions
// generate sub-vector values, avoiding the compiler from ever generating copy
// instructions that can't be handled.
let Constraints = "$vIn = $vOut" in {
def MOVETOHIp : KVX_PSEUDO<(outs VectorReg:$vOut), (ins VectorReg:$vIn, SingleReg:$z, SingleReg:$y), []>;
def MOVETOLOp : KVX_PSEUDO<(outs VectorReg:$vOut), (ins VectorReg:$vIn, SingleReg:$z, SingleReg:$y), []>;
}

def: Pat<(int_kvx_xmovetq v256i1:$o, i64:$z, i64:$y, (i32 1)),
            (MOVETOHIp VectorReg:$o, SingleReg:$z, SingleReg:$y)>;

def: Pat<(int_kvx_xmovetq v256i1:$o, i64:$z, i64:$y, (i32 0)),
            (MOVETOLOp VectorReg:$o, SingleReg:$z, SingleReg:$y)>;

def: Pat<(int_kvx_xmoveto i64:$z, i64:$y, i64:$x, i64:$w),
            (MOVETOHIp (MOVETOLOp (v256i1(IMPLICIT_DEF)), SingleReg:$x, SingleReg:$w), SingleReg:$z, SingleReg:$y)>;

def: Pat<(int_kvx_xmoveto256 QuadReg:$r), (COPY_TO_REGCLASS QuadReg:$r, VectorReg)>;
let Predicates = [IsV2] in {
  def: Pat<(int_kvx_xmovetq256 VectorReg:$a, PairedReg:$p, hindex_h0),
    (INSERT_SUBREG $a, (XMOVETQrrbe (i64 (EXTRACT_SUBREG $p, sub_d0)), (i64 (EXTRACT_SUBREG $p, sub_d1))), sub_q0)>;
  def: Pat<(int_kvx_xmovetq256 VectorReg:$a, PairedReg:$p, hindex_h1),
    (INSERT_SUBREG $a, (XMOVETQrrbo (i64 (EXTRACT_SUBREG $p, sub_d0)), (i64 (EXTRACT_SUBREG $p, sub_d1))), sub_q1)>;

  def: Pat<(int_kvx_xmovetd256 VectorReg:$a, SingleReg:$r, qindex_q0),
    (INSERT_SUBREG $a, (XMOVETDrc0m4 $r), sub_d0)>;
  def: Pat<(int_kvx_xmovetd256 VectorReg:$a, SingleReg:$r, qindex_q1),
    (INSERT_SUBREG $a, (XMOVETDrc1m4 $r), sub_d1)>;
  def: Pat<(int_kvx_xmovetd256 VectorReg:$a, SingleReg:$r, qindex_q2),
    (INSERT_SUBREG $a, (XMOVETDrc2m4 $r), sub_d2)>;
  def: Pat<(int_kvx_xmovetd256 VectorReg:$a, SingleReg:$r, qindex_q3),
    (INSERT_SUBREG $a, (XMOVETDrc3m4 $r), sub_d3)>;
}

// Copy from TCA to GPR registers
def: Pat<(int_kvx_xmovefo256 VectorReg:$v), (COPY_TO_REGCLASS $v, QuadReg)>;
let Predicates = [IsV2] in {
  def: Pat<(int_kvx_xmovefq256 VectorReg:$v, hindex_h0),
    (XMOVEFQ (v128i1 (EXTRACT_SUBREG VectorReg:$v, sub_q0)))>;
  def: Pat<(int_kvx_xmovefq256 VectorReg:$v, hindex_h1),
    (XMOVEFQ (v128i1 (EXTRACT_SUBREG VectorReg:$v, sub_q1)))>;

  def: Pat<(int_kvx_xmovefd256 VectorReg:$v, qindex_q0),
    (XMOVEFD (v64i1 (EXTRACT_SUBREG VectorReg:$v, sub_d0)))>;
  def: Pat<(int_kvx_xmovefd256 VectorReg:$v, qindex_q1),
    (XMOVEFD (v64i1 (EXTRACT_SUBREG VectorReg:$v, sub_d1)))>;
  def: Pat<(int_kvx_xmovefd256 VectorReg:$v, qindex_q2),
    (XMOVEFD (v64i1 (EXTRACT_SUBREG VectorReg:$v, sub_d2)))>;
  def: Pat<(int_kvx_xmovefd256 VectorReg:$v, qindex_q3),
    (XMOVEFD (v64i1 (EXTRACT_SUBREG VectorReg:$v, sub_d3)))>;
}

// Copy TCA Sub-types (insert/extract sub-registers)
// Operands:
def sub_w_imm_check : Operand<i32>, ImmLeaf<i32, [{return (0 <= Imm) && (Imm <= 1);}]>;
def sub_w_imm_value : SDNodeXForm<imm, [{
  return CurDAG->getTargetConstant(N->getZExtValue() + KVX::sub_w0, SDLoc(N), MVT::i32);
}]>;

def m_sub_v_imm_check : Operand<i32>, ImmLeaf<i32, [{return (0 <= Imm) && (Imm <= 4);}]>;
def m_sub_v_imm_value : Operand<i32>, SDNodeXForm<imm, [{
  return CurDAG->getTargetConstant(N->getSExtValue() + KVX::sub_v0, SDLoc(N), MVT::i32);
}]>;

def w_sub_v_imm_check : Operand<i32>, ImmLeaf<i32, [{return (0 <= Imm) && (Imm <= 1);}]>;
def w_sub_v_imm_value : Operand<i32>, SDNodeXForm<imm, [{
  return CurDAG->getTargetConstant(N->getSExtValue() + KVX::sub_v0, SDLoc(N), MVT::i32);
}]>;

// Builtins -> intrinsics patterns:
def: Pat<(int_kvx_xinsertwm v1024i1:$a0, v512i1:$a1, sub_w_imm_check:$pos),
    (INSERT_SUBREG MatrixReg:$a0, WideReg:$a1, (sub_w_imm_value imm:$pos))>;
def: Pat<(int_kvx_xinsertvm v1024i1:$a0, v256i1:$a1, m_sub_v_imm_check:$pos),
    (INSERT_SUBREG MatrixReg:$a0, VectorReg:$a1, (m_sub_v_imm_value imm:$pos))>;
def: Pat<(int_kvx_xinsertvw v512i1:$a0, v256i1:$a1, w_sub_v_imm_check:$pos),
    (INSERT_SUBREG WideReg:$a0, VectorReg:$a1, (w_sub_v_imm_value imm:$pos))>;
def: Pat<(int_kvx_xmovefmw v1024i1:$a0, sub_w_imm_check:$pos),
    (v512i1(EXTRACT_SUBREG MatrixReg:$a0, (sub_w_imm_value imm:$pos)))>;
def: Pat<(int_kvx_xmovefmv v1024i1:$a0, m_sub_v_imm_check:$pos),
    (v256i1(EXTRACT_SUBREG MatrixReg:$a0, (m_sub_v_imm_value imm:$pos)))>;
def: Pat<(int_kvx_xmovefwv v512i1:$a0, w_sub_v_imm_check:$pos),
    (v256i1(EXTRACT_SUBREG WideReg:$a0, (w_sub_v_imm_value imm:$pos)))>;

def: Pat<(int_kvx_xbuild1024 v256i1:$v0, v256i1:$v1, v256i1:$v2, v256i1:$v3),
            (REG_SEQUENCE MatrixReg,
                (v256i1 VectorReg:$v0), (i32 sub_v0),
                (v256i1 VectorReg:$v1), (i32 sub_v1),
                (v256i1 VectorReg:$v2), (i32 sub_v2),
                (v256i1 VectorReg:$v3), (i32 sub_v3))>;

let Predicates = [IsV1] in {
def : Pat<(v256i1(int_kvx_lv (add i64:$mem, (shiftMulPats <5, i64> i64:$off)), SpeculateMod:$mod0)),
          (LVrr SingleReg:$off, SingleReg:$mem, SpeculateMod:$mod0, scale_xs)>;

def : Pat<(v256i1(int_kvx_lv (add i64:$mem, i64:$off), SpeculateMod:$mod0)),
          (LVrr SingleReg:$off, SingleReg:$mem, SpeculateMod:$mod0, scale_)>;

def : Pat<(v256i1(int_kvx_lv i64:$mem, SpeculateMod:$mod0)),
          (LVri10 0, SingleReg:$mem, SpeculateMod:$mod0)>;

def : Pat<(v1024i1(int_kvx_lvc MatrixReg:$z, (add i64:$mem, (shiftMulPats <5, i64> i64:$off)), QindexMod:$mod0, SpeculateMod:$mod1)),
          (LVrrcs SingleReg:$off, SingleReg:$mem, QindexMod:$mod0, SpeculateMod:$mod1, scale_xs, MatrixReg:$z)>;

def : Pat<(v1024i1(int_kvx_lvc MatrixReg:$z, (add i64:$mem, i64:$off), QindexMod:$mod0, SpeculateMod:$mod1)),
          (LVrrcs SingleReg:$off, SingleReg:$mem, QindexMod:$mod0, SpeculateMod:$mod1, scale_, MatrixReg:$z)>;

def : Pat<(v1024i1(int_kvx_lvc MatrixReg:$z, i64:$mem, QindexMod:$mod0, SpeculateMod:$mod1)),
          (LVri10cs 0, SingleReg:$mem, QindexMod:$mod0, SpeculateMod:$mod1, MatrixReg:$z)>;

def : Pat<(int_kvx_sv  i64:$mem, v256i1:$op0),
          (SVri10 0, SingleReg:$mem, VectorReg:$op0)>;
}

// atomic register copy/shift operations
def: Pat<(int_kvx_xswapo256 QuadReg:$r, VectorReg:$v),
         (XSWAP256p QuadReg:$r, VectorReg:$v)>;

def: Pat<(int_kvx_xaccesso WideReg:$a2a3, Unsigned6:$a4), (ALIGNOreroi (EXTRACT_SUBREG WideReg:$a2a3, sub_v0), (EXTRACT_SUBREG WideReg:$a2a3, sub_v1), Unsigned6:$a4)>, Requires<[IsV1]>;
def: Pat<(int_kvx_xaccesso WideReg:$a2a3, Unsigned6:$a4), (ALIGNOrorei (EXTRACT_SUBREG WideReg:$a2a3, sub_v0), (EXTRACT_SUBREG WideReg:$a2a3, sub_v1), Unsigned6:$a4)>, Requires<[IsV1]>;
def: Pat<(int_kvx_xaccesso WideReg:$a2a3, SingleReg:$a4), (ALIGNOreror (EXTRACT_SUBREG WideReg:$a2a3, sub_v0), (EXTRACT_SUBREG WideReg:$a2a3, sub_v1), $a4)>, Requires<[IsV1]>;
def: Pat<(int_kvx_xaccesso WideReg:$a2a3, SingleReg:$a4), (ALIGNOrorer (EXTRACT_SUBREG WideReg:$a2a3, sub_v0), (EXTRACT_SUBREG WideReg:$a2a3, sub_v1), $a4)>, Requires<[IsV1]>;

def: Pat<(int_kvx_xaligno WideReg:$a2a3, Unsigned6:$a4), (ALIGNVreroi (EXTRACT_SUBREG WideReg:$a2a3, sub_v0), (EXTRACT_SUBREG WideReg:$a2a3, sub_v1), Unsigned6:$a4)>, Requires<[IsV1]>;
def: Pat<(int_kvx_xaligno WideReg:$a2a3, Unsigned6:$a4), (ALIGNVrorei (EXTRACT_SUBREG WideReg:$a2a3, sub_v0), (EXTRACT_SUBREG WideReg:$a2a3, sub_v1), Unsigned6:$a4)>, Requires<[IsV1]>;
def: Pat<(int_kvx_xaligno WideReg:$a2a3, SingleReg:$a4), (ALIGNVreror (EXTRACT_SUBREG WideReg:$a2a3, sub_v0), (EXTRACT_SUBREG WideReg:$a2a3, sub_v1), $a4)>, Requires<[IsV1]>;
def: Pat<(int_kvx_xaligno WideReg:$a2a3, SingleReg:$a4), (ALIGNVrorer (EXTRACT_SUBREG WideReg:$a2a3, sub_v0), (EXTRACT_SUBREG WideReg:$a2a3, sub_v1), $a4)>, Requires<[IsV1]>;

// TCA arithmetic/conversion intrinsics that generate sub-vector register values
// We use pseudo-instruction to hide from the compiler that these instructions
// generate sub-vector values, avoiding the compiler from ever generating copy
// instructions that can't be handled.
let Constraints = "$vIn = $vOut" in {
def CONVDHV0p : KVX_PSEUDO<(outs VectorReg:$vOut), (ins VectorReg:$vIn,
                                 MatrixReg:$a4, RoundintMod:$a1, SaturateMod:$a2), []>, Requires<[IsV1]>;

def CONVDHV1p : KVX_PSEUDO<(outs VectorReg:$vOut), (ins VectorReg:$vIn,
                                 MatrixReg:$a4, RoundintMod:$a1, SaturateMod:$a2), []>, Requires<[IsV1]>;


def CONVWBV0p : KVX_PSEUDO<(outs VectorReg:$vOut), (ins VectorReg:$vIn,
                                 MatrixReg:$a4, RoundintMod:$a1, SaturateMod:$a2), []>, Requires<[IsV1]>;

def CONVWBV1p : KVX_PSEUDO<(outs VectorReg:$vOut), (ins VectorReg:$vIn,
                                 MatrixReg:$a4, RoundintMod:$a1, SaturateMod:$a2), []>, Requires<[IsV1]>;

def CONVWBV2p : KVX_PSEUDO<(outs VectorReg:$vOut), (ins VectorReg:$vIn,
                                 MatrixReg:$a4, RoundintMod:$a1, SaturateMod:$a2), []>, Requires<[IsV1]>;

def CONVWBV3p : KVX_PSEUDO<(outs VectorReg:$vOut), (ins VectorReg:$vIn,
                                 MatrixReg:$a4, RoundintMod:$a1, SaturateMod:$a2), []>, Requires<[IsV1]>;

def FMMA242HW0p : KVX_PSEUDO<(outs VectorRegE:$vOut), (ins VectorRegE:$vIn,
                                 WideReg:$a2, VectorReg:$a3, VectorReg:$a4), []>, Requires<[IsV1]>;

def FMMA242HW1p : KVX_PSEUDO<(outs VectorRegE:$vOut), (ins VectorRegE:$vIn,
                                 WideReg:$a2, VectorReg:$a3, VectorReg:$a4), []>, Requires<[IsV1]>;

def FMMA242HW2p : KVX_PSEUDO<(outs VectorRegO:$vOut), (ins VectorRegO:$vIn,
                                 WideReg:$a2, VectorReg:$a3, VectorReg:$a4), []>, Requires<[IsV1]>;

def FMMA242HW3p : KVX_PSEUDO<(outs VectorRegO:$vOut), (ins VectorRegO:$vIn,
                                 WideReg:$a2, VectorReg:$a3, VectorReg:$a4), []>, Requires<[IsV1]>;
}

def: Pat<(int_kvx_xconvdhv0 VectorReg:$o, MatrixReg:$a4, i32:$a1, i32:$a2),
            (CONVDHV0p $o, $a4, RoundintMod:$a1, SaturateMod:$a2)>, Requires<[IsV1]>;
def: Pat<(int_kvx_xconvdhv1 VectorReg:$o, MatrixReg:$a4, i32:$a1, i32:$a2),
            (CONVDHV1p $o, $a4, RoundintMod:$a1, SaturateMod:$a2)>, Requires<[IsV1]>;

def: Pat<(int_kvx_xconvdhv MatrixReg:$a4, i32:$a1, i32:$a2),
         (CONVDHV1p (CONVDHV0p (v256i1(IMPLICIT_DEF)), $a4, RoundintMod:$a1, SaturateMod:$a2),
                    $a4, RoundintMod:$a1, SaturateMod:$a2)>, Requires<[IsV1]>;

def: Pat<(int_kvx_xconvwbv0 VectorReg:$o, MatrixReg:$a4, i32:$a1, i32:$a2),
         (CONVWBV0p $o, $a4, RoundintMod:$a1, SaturateMod:$a2)>, Requires<[IsV1]>;
def: Pat<(int_kvx_xconvwbv1 VectorReg:$o, MatrixReg:$a4, i32:$a1, i32:$a2),
         (CONVWBV1p $o, $a4, RoundintMod:$a1, SaturateMod:$a2)>, Requires<[IsV1]>;
def: Pat<(int_kvx_xconvwbv2 VectorReg:$o, MatrixReg:$a4, i32:$a1, i32:$a2),
         (CONVWBV2p $o, $a4, RoundintMod:$a1, SaturateMod:$a2)>, Requires<[IsV1]>;
def: Pat<(int_kvx_xconvwbv3 VectorReg:$o, MatrixReg:$a4, i32:$a1, i32:$a2),
         (CONVWBV3p $o, $a4, RoundintMod:$a1, SaturateMod:$a2)>, Requires<[IsV1]>;

def: Pat<(int_kvx_xconvwbv MatrixReg:$a4, i32:$a1, i32:$a2),
         (CONVWBV3p (CONVWBV2p (CONVWBV1p
                    (CONVWBV0p (v256i1(IMPLICIT_DEF)), $a4, RoundintMod:$a1, SaturateMod:$a2),
                $a4, RoundintMod:$a1, SaturateMod:$a2),
            $a4, RoundintMod:$a1, SaturateMod:$a2),
          $a4, RoundintMod:$a1, SaturateMod:$a2)>, Requires<[IsV1]>;

def: Pat<(int_kvx_xfmma242hw0 VectorRegE:$o, WideReg:$a2, VectorReg:$a3, VectorReg:$a4),
         (FMMA242HW0p VectorRegE:$o, $a2, $a3, $a4)>, Requires<[IsV1]>;
def: Pat<(int_kvx_xfmma242hw1 VectorRegE:$o, WideReg:$a2, VectorReg:$a3, VectorReg:$a4),
         (FMMA242HW1p VectorRegE:$o, $a2, $a3, $a4)>, Requires<[IsV1]>;
def: Pat<(int_kvx_xfmma242hw2 VectorRegO:$o, WideReg:$a2, VectorReg:$a3, VectorReg:$a4),
         (FMMA242HW2p VectorRegO:$o, $a2, $a3, $a4)>, Requires<[IsV1]>;
def: Pat<(int_kvx_xfmma242hw3 VectorRegO:$o, WideReg:$a2, VectorReg:$a3, VectorReg:$a4),
         (FMMA242HW3p VectorRegO:$o, $a2, $a3, $a4)>, Requires<[IsV1]>;
def: Pat<(int_kvx_xfmma444hw VectorReg:$a3, VectorReg:$a4, WideReg:$a2),
         (REG_SEQUENCE WideReg,
            (FMMA242HW1p (FMMA242HW0p (v256i1(IMPLICIT_DEF)), $a2, $a3, $a4), $a2, $a3, $a4),
            sub_v0,
            (FMMA242HW3p (FMMA242HW2p (v256i1(IMPLICIT_DEF)), $a2, $a3, $a4), $a2, $a3, $a4),
            sub_v1)>, Requires<[IsV1]>;

// TCA arithmetic intrinsics
def: Pat<(int_kvx_xmma444hbd0 VectorReg:$a3, VectorReg:$a4, MatrixReg:$a2, UnSignMod_S),
         (MMA444HBD0 $a2, $a3, $a4)>, Requires<[IsV1]>;

def: Pat<(int_kvx_xmma444hbd1 VectorReg:$a3, VectorReg:$a4, MatrixReg:$a2, UnSignMod_S),
         (MMA444HBD1 $a2, $a3, $a4)>, Requires<[IsV1]>;

def: Pat<(int_kvx_xmma484hbd WideReg:$a3, VectorReg:$a4, MatrixReg:$a2, UnSignMod_S),
         (MMA444HBD1
            (MMA444HBD0 $a2,
              (v256i1(EXTRACT_SUBREG $a3, sub_v0)),
              $a4),
            (v256i1(EXTRACT_SUBREG $a3, sub_v1)),
            $a4)>, Requires<[IsV1]>;

def: Pat<(int_kvx_xmma444hd VectorReg:$a3, VectorReg:$a4, MatrixReg:$a2, UnSignMod_S),
         (MMA444HD $a2, $a3, $a4)>, Requires<[IsV1]>;
def: Pat<(int_kvx_xmma444hbd0 VectorReg:$a3, VectorReg:$a4, MatrixReg:$a2, UnSignMod_SU),
         (MMA444SUHBD0 $a2, $a3, $a4)>, Requires<[IsV1]>;
def: Pat<(int_kvx_xmma444hbd1 VectorReg:$a3, VectorReg:$a4, MatrixReg:$a2, UnSignMod_SU),
         (MMA444SUHBD1 $a2, $a3, $a4)>, Requires<[IsV1]>;
def: Pat<(int_kvx_xmma484hbd WideReg:$a3, VectorReg:$a4, MatrixReg:$a2, UnSignMod_SU),
         (MMA444SUHBD1
            (MMA444SUHBD0 $a2,
              (v256i1(EXTRACT_SUBREG $a3, sub_v0)),
              $a4),
            (v256i1(EXTRACT_SUBREG $a3, sub_v1)),
            $a4)>, Requires<[IsV1]>;

def: Pat<(int_kvx_xmma444hd VectorReg:$a3, VectorReg:$a4, MatrixReg:$a2, UnSignMod_SU),
         (MMA444SUHD $a2, $a3, $a4)>, Requires<[IsV1]>;

def: Pat<(int_kvx_xmma444hbd0 VectorReg:$a3, VectorReg:$a4, MatrixReg:$a2, UnSignMod_U),
         (MMA444UHBD0 $a2, $a3, $a4)>, Requires<[IsV1]>;

def: Pat<(int_kvx_xmma444hbd1 VectorReg:$a3, VectorReg:$a4, MatrixReg:$a2, UnSignMod_U),
         (MMA444UHBD1 $a2, $a3, $a4)>, Requires<[IsV1]>;

def: Pat<(int_kvx_xmma484hbd WideReg:$a3, VectorReg:$a4, MatrixReg:$a2, UnSignMod_U),
         (MMA444UHBD1
            (MMA444UHBD0 $a2,
              (v256i1(EXTRACT_SUBREG $a3, sub_v0)),
              $a4),
            (v256i1(EXTRACT_SUBREG $a3, sub_v1)),
            $a4)>, Requires<[IsV1]>;

def: Pat<(int_kvx_xmma444hd VectorReg:$a3, VectorReg:$a4, MatrixReg:$a2, UnSignMod_U), (MMA444UHD $a2, $a3, $a4)>;
def: Pat<(int_kvx_xmma444hbd0 VectorReg:$a3, VectorReg:$a4, MatrixReg:$a2, UnSignMod_US),
         (MMA444USHBD0 $a2, $a3, $a4)>, Requires<[IsV1]>;
def: Pat<(int_kvx_xmma444hbd1 VectorReg:$a3, VectorReg:$a4, MatrixReg:$a2, UnSignMod_US),
         (MMA444USHBD1 $a2, $a3, $a4)>, Requires<[IsV1]>;
def: Pat<(int_kvx_xmma484hbd WideReg:$a3, VectorReg:$a4, MatrixReg:$a2, UnSignMod_US),
         (MMA444USHBD1
            (MMA444USHBD0 $a2,
              (v256i1(EXTRACT_SUBREG $a3, sub_v0)),
              $a4),
            (v256i1(EXTRACT_SUBREG $a3, sub_v1)),
            $a4)>, Requires<[IsV1]>;

def: Pat<(int_kvx_xmma444hd VectorReg:$a3, VectorReg:$a4, MatrixReg:$a2, UnSignMod_US), (MMA444USHD $a2, $a3, $a4)>, Requires<[IsV1]>;

def: Pat<(int_kvx_xmt44d MatrixReg:$a1), (XMT44D $a1)>, Requires<[IsV1]>;

// TCA conversion intrinsics
def: Pat<(int_kvx_xfscalewv VectorReg:$a5, i32:$a1, i32:$a2, i32:$a3),
         (FSCALEWV $a5, RoundingMod:$a1, SilentMod:$a2, RectifyMod:$a3)>, Requires<[IsV1]>;

// TODO: T18719 We could have generic C code patterns, but that requires changing how we lower
// vector_shuffle/build_vector for v4f32 vectors.
// FMM222
def : Pat<(v4f32 (int_matrix_multiply v4f32:$LHS, v4f32:$RHS, 2, 2, 2)),
          (v4f32 (FMM222W PairedReg:$LHS, PairedReg:$RHS, transpose_nn, rounding_, silent_))>, Requires<[IsV2]>;

def : Pat<(v4f32 (int_matrix_multiply (v4f32 (int_matrix_transpose v4f32:$LHS, 2, 2)), v4f32:$RHS, 2, 2, 2)),
          (v4f32 (FMM222W PairedReg:$LHS, PairedReg:$RHS, transpose_tn, rounding_, silent_))>, Requires<[IsV2]>;

def : Pat<(v4f32 (int_matrix_multiply v4f32:$LHS, (v4f32 (int_matrix_transpose v4f32:$RHS, 2, 2)), 2, 2, 2)),
          (v4f32 (FMM222W PairedReg:$LHS, PairedReg:$RHS, transpose_nt, rounding_, silent_))>, Requires<[IsV2]>;

def : Pat<(v4f32 (int_matrix_multiply (v4f32 (int_matrix_transpose v4f32:$LHS, 2, 2)), (v4f32 (int_matrix_transpose v4f32:$RHS, 2, 2)), 2, 2, 2)),
          (v4f32 (FMM222W PairedReg:$LHS, PairedReg:$RHS, transpose_tt, rounding_, silent_))>, Requires<[IsV2]>;

def : Pat<(int_kvx_fmm222w v4f32:$LHS, v4f32:$RHS, i32:$t, i32:$r, i32:$s),
          (FMM222W PairedReg:$LHS, PairedReg:$RHS, TransposeMod:$t, RoundingMod:$r, SilentMod:$s)>, Requires<[IsV2]>;

// FMMA222, FMMS222
multiclass FMMAS222W <PatFrag Node, Instruction Op, Intrinsic KVX_Int> {
def : Pat<(Node v4f32:$ACC, (int_matrix_multiply v4f32:$LHS, v4f32:$RHS, 2, 2, 2)),
          (Op PairedReg:$LHS, PairedReg:$RHS, PairedReg:$ACC, transpose_nn, rounding_, silent_)>;

def : Pat<(Node v4f32:$ACC, (int_matrix_multiply (v4f32 (int_matrix_transpose v4f32:$LHS, 2, 2)), v4f32:$RHS, 2, 2, 2)),
          (Op PairedReg:$LHS, PairedReg:$RHS, PairedReg:$ACC, transpose_tn, rounding_, silent_)>;

def : Pat<(Node v4f32:$ACC, (int_matrix_multiply (v4f32 (int_matrix_transpose v4f32:$LHS, 2, 2)), (v4f32 (int_matrix_transpose v4f32:$RHS, 2, 2)), 2, 2, 2)),
          (Op PairedReg:$LHS, PairedReg:$RHS, PairedReg:$ACC, transpose_tt, rounding_, silent_)>;

def : Pat<(Node v4f32:$ACC, (int_matrix_multiply v4f32:$LHS, (v4f32 (int_matrix_transpose v4f32:$RHS, 2, 2)), 2, 2, 2)),
          (Op PairedReg:$LHS, PairedReg:$RHS, PairedReg:$ACC, transpose_nt, rounding_, silent_)>;

def : Pat<(KVX_Int v4f32:$LHS, v4f32:$RHS, v4f32:$ACC, i32:$t, i32:$r, i32:$s),
          (Op PairedReg:$LHS, PairedReg:$RHS, PairedReg:$ACC, TransposeMod:$t, RoundingMod:$r, SilentMod:$s)>;
}

defm : FMMAS222W<faddcont, FMMA222W, int_kvx_fmma222w>, Requires<[IsV2]>;
defm : FMMAS222W<fsubcont, FMMS222W, int_kvx_fmms222w>, Requires<[IsV2]>;

// ----------------------- To fix START  -----------------------
// FIXME: These patterns below should not exits, the front-end should be able
//        to detect march version and generate the correct code from there.
//        However or front-end sub-arch selection is not implemented somehow
//        that we can detect it.
// FMM222_CV1
// nn
def : Pat<(v4f32 (int_matrix_multiply v4f32:$LHS, v4f32:$RHS, 2, 2, 2)),
          (FMMA212W
            (FMM212W
              (INSF (v2f32(EXTRACT_SUBREG $LHS, sub_d0)), (v2f32(EXTRACT_SUBREG $LHS, sub_d1)), 63, 32),
              (v2f32(EXTRACT_SUBREG $RHS, sub_d0)),
              rounding_, silent_
            ),
            (ORDrr (SRLDri (v2f32(EXTRACT_SUBREG $LHS, sub_d0)), 32), (ANDDri37 (v2f32(EXTRACT_SUBREG $LHS, sub_d1)), -4294967296)),
            (v2f32(EXTRACT_SUBREG $RHS, sub_d1)),
            rounding_, silent_)>, Requires<[IsV1]>;
def : Pat<(int_kvx_fmm222w v4f32:$LHS, v4f32:$RHS, 0, i32:$r, i32:$s),
          (FMMA212W
            (FMM212W
              (INSF (v2f32(EXTRACT_SUBREG $LHS, sub_d0)), (v2f32(EXTRACT_SUBREG $LHS, sub_d1)), 63, 32),
              (v2f32(EXTRACT_SUBREG $RHS, sub_d0)),
              RoundingMod:$r, SilentMod:$s
            ),
            (ORDrr (SRLDri (v2f32(EXTRACT_SUBREG $LHS, sub_d0)), 32), (ANDDri37 (v2f32(EXTRACT_SUBREG $LHS, sub_d1)), -4294967296)),
            (v2f32(EXTRACT_SUBREG $RHS, sub_d1)),
            RoundingMod:$r, SilentMod:$s)>, Requires<[IsV1]>;


// tn
def : Pat<(v4f32 (int_matrix_multiply (v4f32 (int_matrix_transpose v4f32:$LHS, 2, 2)), v4f32:$RHS, 2, 2, 2)),
          (FMMA212W
            (FMM212W
              (v2f32(EXTRACT_SUBREG $LHS, sub_d0)),
              (v2f32(EXTRACT_SUBREG $RHS, sub_d0)),
              rounding_, silent_
            ),
            (v2f32(EXTRACT_SUBREG $LHS, sub_d1)),
            (v2f32(EXTRACT_SUBREG $RHS, sub_d1)),
            rounding_, silent_)>, Requires<[IsV1]>;
def : Pat<(int_kvx_fmm222w v4f32:$LHS, v4f32:$RHS, 1, i32:$r, i32:$s),
          (FMMA212W
            (FMM212W
              (v2f32(EXTRACT_SUBREG $LHS, sub_d0)),
              (v2f32(EXTRACT_SUBREG $RHS, sub_d0)),
              RoundingMod:$r, SilentMod:$s
            ),
            (v2f32(EXTRACT_SUBREG $LHS, sub_d1)),
            (v2f32(EXTRACT_SUBREG $RHS, sub_d1)),
            RoundingMod:$r, SilentMod:$s)>, Requires<[IsV1]>;
// nt
def : Pat<(v4f32 (int_matrix_multiply v4f32:$LHS, (v4f32 (int_matrix_transpose v4f32:$RHS, 2, 2)), 2, 2, 2)),
          (FMMA212W
            (FMM212W
              (INSF (v2f32(EXTRACT_SUBREG $LHS, sub_d0)), (v2f32(EXTRACT_SUBREG $LHS, sub_d1)), 63, 32),
              (INSF (v2f32(EXTRACT_SUBREG $RHS, sub_d0)), (v2f32(EXTRACT_SUBREG $RHS, sub_d1)), 63, 32),
              rounding_, silent_
            ),
            (ORDrr (SRLDri (v2f32(EXTRACT_SUBREG $LHS, sub_d0)), 32), (ANDDri37 (v2f32(EXTRACT_SUBREG $LHS, sub_d1)), -4294967296)),
            (ORDrr (SRLDri (v2f32(EXTRACT_SUBREG $RHS, sub_d0)), 32), (ANDDri37 (v2f32(EXTRACT_SUBREG $RHS, sub_d1)), -4294967296)),
            rounding_, silent_)>, Requires<[IsV1]>;
def : Pat<(int_kvx_fmm222w v4f32:$LHS, v4f32:$RHS, 2, i32:$r, i32:$s),
          (FMMA212W
            (FMM212W
              (INSF (v2f32(EXTRACT_SUBREG $LHS, sub_d0)), (v2f32(EXTRACT_SUBREG $LHS, sub_d1)), 63, 32),
              (INSF (v2f32(EXTRACT_SUBREG $RHS, sub_d0)), (v2f32(EXTRACT_SUBREG $RHS, sub_d1)), 63, 32),
              RoundingMod:$r, SilentMod:$s
            ),
            (ORDrr (SRLDri (v2f32(EXTRACT_SUBREG $LHS, sub_d0)), 32), (ANDDri37 (v2f32(EXTRACT_SUBREG $LHS, sub_d1)), -4294967296)),
            (ORDrr (SRLDri (v2f32(EXTRACT_SUBREG $RHS, sub_d0)), 32), (ANDDri37 (v2f32(EXTRACT_SUBREG $RHS, sub_d1)), -4294967296)),
            RoundingMod:$r, SilentMod:$s)>, Requires<[IsV1]>;
// tt
def : Pat<(v4f32 (int_matrix_multiply (v4f32 (int_matrix_transpose v4f32:$LHS, 2, 2)), (v4f32 (int_matrix_transpose v4f32:$RHS, 2, 2)), 2, 2, 2)),
          (FMMA212W
            (FMM212W
              (v2f32(EXTRACT_SUBREG $LHS, sub_d0)),
              (INSF (v2f32(EXTRACT_SUBREG $RHS, sub_d0)), (v2f32(EXTRACT_SUBREG $RHS, sub_d1)), 63, 32),
              rounding_, silent_
            ),
            (v2f32(EXTRACT_SUBREG $LHS, sub_d1)),
            (ORDrr (SRLDri (v2f32(EXTRACT_SUBREG $RHS, sub_d0)), 32), (ANDDri37 (v2f32(EXTRACT_SUBREG $RHS, sub_d1)), -4294967296)),
            rounding_, silent_)>, Requires<[IsV1]>;
def : Pat<(int_kvx_fmm222w v4f32:$LHS, v4f32:$RHS, 3, i32:$r, i32:$s),
          (FMMA212W
            (FMM212W
              (v2f32(EXTRACT_SUBREG $LHS, sub_d0)),
              (INSF (v2f32(EXTRACT_SUBREG $RHS, sub_d0)), (v2f32(EXTRACT_SUBREG $RHS, sub_d1)), 63, 32),
              RoundingMod:$r, SilentMod:$s
            ),
            (v2f32(EXTRACT_SUBREG $LHS, sub_d1)),
            (ORDrr (SRLDri (v2f32(EXTRACT_SUBREG $RHS, sub_d0)), 32), (ANDDri37 (v2f32(EXTRACT_SUBREG $RHS, sub_d1)), -4294967296)),
            RoundingMod:$r, SilentMod:$s)>, Requires<[IsV1]>;

// FMMA222_CV1, FMMS222_CV1
multiclass FMMAS222W_CV1 <PatFrag Node, Instruction Op, Intrinsic KVX_Int> {
def : Pat<(Node v4f32:$ACC, (int_matrix_multiply v4f32:$LHS, v4f32:$RHS, 2, 2, 2)),
          (Op
            (Op
              PairedReg:$ACC,
              (INSF (v2f32(EXTRACT_SUBREG $LHS, sub_d0)), (v2f32(EXTRACT_SUBREG $LHS, sub_d1)), 63, 32),
              (v2f32(EXTRACT_SUBREG $RHS, sub_d0)),
              rounding_, silent_
            ),
            (ORDrr (SRLDri (v2f32(EXTRACT_SUBREG $LHS, sub_d0)), 32), (ANDDri37 (v2f32(EXTRACT_SUBREG $LHS, sub_d1)), -4294967296)),
            (v2f32(EXTRACT_SUBREG $RHS, sub_d1)),
            rounding_, silent_)>;

def : Pat<(KVX_Int v4f32:$LHS, v4f32:$RHS, v4f32:$ACC, 0, i32:$r, i32:$s),
          (Op
            (Op
              PairedReg:$ACC,
              (INSF (v2f32(EXTRACT_SUBREG $LHS, sub_d0)), (v2f32(EXTRACT_SUBREG $LHS, sub_d1)), 63, 32),
              (v2f32(EXTRACT_SUBREG $RHS, sub_d0)),
              RoundingMod:$r, SilentMod:$s
            ),
            (ORDrr (SRLDri (v2f32(EXTRACT_SUBREG $LHS, sub_d0)), 32), (ANDDri37 (v2f32(EXTRACT_SUBREG $LHS, sub_d1)), -4294967296)),
            (v2f32(EXTRACT_SUBREG $RHS, sub_d1)),
            RoundingMod:$r, SilentMod:$s)>;

def : Pat<(Node v4f32:$ACC, (int_matrix_multiply (v4f32 (int_matrix_transpose v4f32:$LHS, 2, 2)), v4f32:$RHS, 2, 2, 2)),
          (Op
            (Op
              PairedReg:$ACC,
              (v2f32(EXTRACT_SUBREG $LHS, sub_d0)),
              (v2f32(EXTRACT_SUBREG $RHS, sub_d0)),
              rounding_, silent_
            ),
            (v2f32(EXTRACT_SUBREG $LHS, sub_d1)),
            (v2f32(EXTRACT_SUBREG $RHS, sub_d1)),
            rounding_, silent_)>;

def : Pat<(KVX_Int v4f32:$LHS, v4f32:$RHS, v4f32:$ACC, 1, i32:$r, i32:$s),
          (Op
            (Op
              PairedReg:$ACC,
              (v2f32(EXTRACT_SUBREG $LHS, sub_d0)),
              (v2f32(EXTRACT_SUBREG $RHS, sub_d0)),
              RoundingMod:$r, SilentMod:$s
            ),
            (v2f32(EXTRACT_SUBREG $LHS, sub_d1)),
            (v2f32(EXTRACT_SUBREG $RHS, sub_d1)),
            RoundingMod:$r, SilentMod:$s)>;

def : Pat<(Node v4f32:$ACC, (int_matrix_multiply v4f32:$LHS, (v4f32 (int_matrix_transpose v4f32:$RHS, 2, 2)), 2, 2, 2)),
          (Op
            (Op
              PairedReg:$ACC,
              (INSF (v2f32(EXTRACT_SUBREG $LHS, sub_d0)), (v2f32(EXTRACT_SUBREG $LHS, sub_d1)), 63, 32),
              (INSF (v2f32(EXTRACT_SUBREG $RHS, sub_d0)), (v2f32(EXTRACT_SUBREG $RHS, sub_d1)), 63, 32),
              rounding_, silent_
            ),
            (ORDrr (SRLDri (v2f32(EXTRACT_SUBREG $LHS, sub_d0)), 32), (ANDDri37 (v2f32(EXTRACT_SUBREG $LHS, sub_d1)), -4294967296)),
            (ORDrr (SRLDri (v2f32(EXTRACT_SUBREG $RHS, sub_d0)), 32), (ANDDri37 (v2f32(EXTRACT_SUBREG $RHS, sub_d1)), -4294967296)),
            rounding_, silent_)>;

def : Pat<(KVX_Int v4f32:$LHS, v4f32:$RHS, v4f32:$ACC, 2, i32:$r, i32:$s),
          (Op
            (Op
              PairedReg:$ACC,
              (INSF (v2f32(EXTRACT_SUBREG $LHS, sub_d0)), (v2f32(EXTRACT_SUBREG $LHS, sub_d1)), 63, 32),
              (INSF (v2f32(EXTRACT_SUBREG $RHS, sub_d0)), (v2f32(EXTRACT_SUBREG $RHS, sub_d1)), 63, 32),
              RoundingMod:$r, SilentMod:$s
            ),
            (ORDrr (SRLDri (v2f32(EXTRACT_SUBREG $LHS, sub_d0)), 32), (ANDDri37 (v2f32(EXTRACT_SUBREG $LHS, sub_d1)), -4294967296)),
            (ORDrr (SRLDri (v2f32(EXTRACT_SUBREG $RHS, sub_d0)), 32), (ANDDri37 (v2f32(EXTRACT_SUBREG $RHS, sub_d1)), -4294967296)),
            RoundingMod:$r, SilentMod:$s)>;

def : Pat<(Node v4f32:$ACC, (int_matrix_multiply (v4f32 (int_matrix_transpose v4f32:$LHS, 2, 2)), (v4f32 (int_matrix_transpose v4f32:$RHS, 2, 2)), 2, 2, 2)),
          (Op
            (Op
              PairedReg:$ACC,
              (v2f32(EXTRACT_SUBREG $LHS, sub_d0)),
              (INSF (v2f32(EXTRACT_SUBREG $RHS, sub_d0)), (v2f32(EXTRACT_SUBREG $RHS, sub_d1)), 63, 32),
              rounding_, silent_
            ),
            (v2f32(EXTRACT_SUBREG $LHS, sub_d1)),
            (ORDrr (SRLDri (v2f32(EXTRACT_SUBREG $RHS, sub_d0)), 32), (ANDDri37 (v2f32(EXTRACT_SUBREG $RHS, sub_d1)), -4294967296)),
            rounding_, silent_)>;

def : Pat<(KVX_Int v4f32:$LHS, v4f32:$RHS, v4f32:$ACC, 3, i32:$r, i32:$s),
          (Op
            (Op
              PairedReg:$ACC,
              (v2f32(EXTRACT_SUBREG $LHS, sub_d0)),
              (INSF (v2f32(EXTRACT_SUBREG $RHS, sub_d0)), (v2f32(EXTRACT_SUBREG $RHS, sub_d1)), 63, 32),
              RoundingMod:$r, SilentMod:$s
            ),
            (v2f32(EXTRACT_SUBREG $LHS, sub_d1)),
            (ORDrr (SRLDri (v2f32(EXTRACT_SUBREG $RHS, sub_d0)), 32), (ANDDri37 (v2f32(EXTRACT_SUBREG $RHS, sub_d1)), -4294967296)),
            RoundingMod:$r, SilentMod:$s)>;
}

defm : FMMAS222W_CV1<faddcont, FMMA212W, int_kvx_fmma222w>, Requires<[IsV1]>;
defm : FMMAS222W_CV1<fsubcont, FMMS212W, int_kvx_fmms222w>, Requires<[IsV1]>;
// ----------------------- To fix END  -----------------------

def: Pat<(int_kvx_alignov VectorRegE:$a2, VectorRegO:$a3, Unsigned6:$a4), (ALIGNOreroi $a2, $a3, Unsigned6:$a4)>, Requires<[IsV1]>;
def: Pat<(int_kvx_alignov VectorRegO:$a2, VectorRegE:$a3, Unsigned6:$a4), (ALIGNOrorei $a2, $a3, Unsigned6:$a4)>, Requires<[IsV1]>;
def: Pat<(int_kvx_alignov VectorRegE:$a2, VectorRegO:$a3, SingleReg:$a4), (ALIGNOreror $a2, $a3, $a4)>, Requires<[IsV1]>;
def: Pat<(int_kvx_alignov VectorRegO:$a2, VectorRegE:$a3, SingleReg:$a4), (ALIGNOrorer $a2, $a3, $a4)>, Requires<[IsV1]>;

def: Pat<(int_kvx_alignv VectorRegE:$a2, VectorRegO:$a3, Unsigned6:$a4), (ALIGNVreroi $a2, $a3, Unsigned6:$a4)>, Requires<[IsV1]>;
def: Pat<(int_kvx_alignv VectorRegO:$a2, VectorRegE:$a3, Unsigned6:$a4), (ALIGNVrorei $a2, $a3, Unsigned6:$a4)>, Requires<[IsV1]>;
def: Pat<(int_kvx_alignv VectorRegE:$a2, VectorRegO:$a3, SingleReg:$a4), (ALIGNVreror $a2, $a3, $a4)>, Requires<[IsV1]>;
def: Pat<(int_kvx_alignv VectorRegO:$a2, VectorRegE:$a3, SingleReg:$a4), (ALIGNVrorer $a2, $a3, $a4)>, Requires<[IsV1]>;

let Predicates = [IsV2] in {
def: Pat<(int_kvx_xload256 (add i64:$mem, (shiftMulPats <5, i64> i64:$off)), VariantMod:$mod0),
         (XLOrr SingleReg:$off, SingleReg:$mem, VariantMod:$mod0,  scale_xs)>;

def: Pat<(int_kvx_xload256 (add i64:$mem, i64:$off), VariantMod:$mod0),
         (XLOrr SingleReg:$off, SingleReg:$mem, VariantMod:$mod0,  scale_)>;

def: Pat<(int_kvx_xload256 i64:$mem, VariantMod:$mod0),
         (XLOri10 0, SingleReg:$mem, VariantMod:$mod0)>;

foreach i = [0, 1, 2, 3] in {
  defvar xload1024q = !cast<Intrinsic>(!strconcat("int_kvx_xload1024q", !cast<string>(i)));
  defvar qindex = i;

  def: Pat<(xload1024q v1024i1:$z, (add i64:$mem, Signed10:$off), VariantMod:$mod0),
           (XLOri10q Signed10:$off, SingleReg:$mem, VariantMod:$mod0, qindex, MatrixReg:$z)>;
  def: Pat<(xload1024q v1024i1:$z, (add i64:$mem, Signed37:$off), VariantMod:$mod0),
           (XLOri37q Signed37:$off, SingleReg:$mem, VariantMod:$mod0, qindex, MatrixReg:$z)>;
  def: Pat<(xload1024q v1024i1:$z, (add i64:$mem, Wrapped64:$off), VariantMod:$mod0),
           (XLOri64q Wrapped64:$off, SingleReg:$mem, VariantMod:$mod0, qindex, MatrixReg:$z)>;

  def: Pat<(xload1024q v1024i1:$z, (add i64:$mem, (shiftMulPats <5, i64> i64:$off)), VariantMod:$mod0),
           (XLOrrq SingleReg:$off, SingleReg:$mem, VariantMod:$mod0, scale_xs, qindex, MatrixReg:$z)>;
  def: Pat<(xload1024q v1024i1:$z, (add i64:$mem, i64:$off), VariantMod:$mod0),
           (XLOrrq SingleReg:$off, SingleReg:$mem, VariantMod:$mod0, scale_, qindex, MatrixReg:$z)>;
  def: Pat<(xload1024q v1024i1:$z, i64:$mem, VariantMod:$mod0),
           (XLOri10q 0, SingleReg:$mem, VariantMod:$mod0, qindex, MatrixReg:$z)>;
}

foreach i = [0, 1, 2, 3] in {
  defvar xloadc1024q = !cast<Intrinsic>(!strconcat("int_kvx_xloadc1024q", !cast<string>(i)));
  defvar qindex = i;
  def: Pat<(xloadc1024q v1024i1:$z, i64:$mem, i64:$val, VariantMod:$mod0, LsumaskMod:$cond),
           (XLOrrcq SingleReg:$mem, VariantMod:$mod0, qindex, MatrixReg:$z, LsumaskMod:$cond, i64:$val)>;
  def: Pat<(xloadc1024q v1024i1:$z, (add i64:$mem, Signed27:$off), i64:$val, VariantMod:$mod0, LsumaskMod:$cond),
           (XLOri27cq Signed27:$off, SingleReg:$mem, VariantMod:$mod0, qindex, MatrixReg:$z, LsumaskMod:$cond, i64:$val)>;
  def: Pat<(xloadc1024q v1024i1:$z, (add i64:$mem, Signed54:$off), i64:$val, VariantMod:$mod0, LsumaskMod:$cond),
           (XLOri54cq Signed54:$off, SingleReg:$mem, VariantMod:$mod0, qindex, MatrixReg:$z, LsumaskMod:$cond, i64:$val)>;
}

def: Pat<(int_kvx_xload512 i64:$mem, VariantMod:$mod0),
         (REG_SEQUENCE WideReg,
            (XLOri10 0, SingleReg:$mem, VariantMod:$mod0),
            sub_v0,
            (XLOri10 32, SingleReg:$mem, VariantMod:$mod0),
            sub_v1)>;

def: Pat<(int_kvx_xload1024 i64:$mem, VariantMod:$mod0),
         (REG_SEQUENCE MatrixReg,
            (XLOri10 0, SingleReg:$mem, VariantMod:$mod0),
            sub_v0,
            (XLOri10 32, SingleReg:$mem, VariantMod:$mod0),
            sub_v1,
            (XLOri10 64, SingleReg:$mem, VariantMod:$mod0),
            sub_v2,
            (XLOri10 96, SingleReg:$mem, VariantMod:$mod0),
            sub_v3)>;

def: Pat<(int_kvx_xloadc512 v512i1:$z, i64:$mem, i64:$val, i32:$mod0, LsumaskScalarMod:$cond),
         (REG_SEQUENCE WideReg,
            (XLOrrc SingleReg:$mem, VariantMod:$mod0, (v256i1 (EXTRACT_SUBREG WideReg:$z, sub_v0)), LsumaskScalarMod:$cond, SingleReg:$val),
            sub_v0,
            (XLOri27c 32, SingleReg:$mem, VariantMod:$mod0, (v256i1 (EXTRACT_SUBREG WideReg:$z, sub_v1)), LsumaskScalarMod:$cond, SingleReg:$val),
            sub_v1)>;

def: Pat<(int_kvx_xloadc512 v512i1:$z, i64:$mem, i64:$val, i32:$mod0, LsumaskMaskMod:$cond),
         (REG_SEQUENCE WideReg,
            (XLOrrc SingleReg:$mem, VariantMod:$mod0, (v256i1 (EXTRACT_SUBREG WideReg:$z, sub_v0)), LsumaskMaskMod:$cond, SingleReg:$val),
            sub_v0,
            (XLOri27c 32, SingleReg:$mem, VariantMod:$mod0, (v256i1 (EXTRACT_SUBREG WideReg:$z, sub_v1)), LsumaskMaskMod:$cond, (SRLDri SingleReg:$val, (i32 32))),
            sub_v1)>;

def: Pat<(int_kvx_xloadc1024 v1024i1:$z, i64:$mem, v4i32:$val, i32:$mod0, LsumaskScalarMod:$cond),
         (REG_SEQUENCE MatrixReg,
            (XLOrrc SingleReg:$mem, VariantMod:$mod0, (v256i1 (EXTRACT_SUBREG MatrixReg:$z, sub_v0)), LsumaskScalarMod:$cond, (i64 (EXTRACT_SUBREG PairedReg:$val, sub_d0))),
            sub_v0,
            (XLOri27c 32, SingleReg:$mem, VariantMod:$mod0, (v256i1 (EXTRACT_SUBREG MatrixReg:$z, sub_v1)), LsumaskScalarMod:$cond, (i64 (EXTRACT_SUBREG PairedReg:$val, sub_d0))),
            sub_v1,
            (XLOri27c 64, SingleReg:$mem, VariantMod:$mod0, (v256i1 (EXTRACT_SUBREG MatrixReg:$z, sub_v1)), LsumaskScalarMod:$cond, (i64 (EXTRACT_SUBREG PairedReg:$val, sub_d0))),
            sub_v2,
            (XLOri27c 96, SingleReg:$mem, VariantMod:$mod0, (v256i1 (EXTRACT_SUBREG MatrixReg:$z, sub_v1)), LsumaskScalarMod:$cond, (i64 (EXTRACT_SUBREG PairedReg:$val, sub_d0))),
            sub_v3)>;

def: Pat<(int_kvx_xloadc1024 v1024i1:$z, i64:$mem, v4i32:$val, i32:$mod0, LsumaskMaskMod:$cond),
         (REG_SEQUENCE MatrixReg,
            (XLOrrc SingleReg:$mem, VariantMod:$mod0, (v256i1 (EXTRACT_SUBREG MatrixReg:$z, sub_v0)), LsumaskMaskMod:$cond, (i64 (EXTRACT_SUBREG PairedReg:$val, sub_d0))),
            sub_v0,
            (XLOri27c 32, SingleReg:$mem, VariantMod:$mod0, (v256i1 (EXTRACT_SUBREG MatrixReg:$z, sub_v1)), LsumaskMaskMod:$cond, (SRLDri (i64 (EXTRACT_SUBREG PairedReg:$val, sub_d0)), 32)),
            sub_v1,
            (XLOri27c 64, SingleReg:$mem, VariantMod:$mod0, (v256i1 (EXTRACT_SUBREG MatrixReg:$z, sub_v1)), LsumaskMaskMod:$cond, (i64 (EXTRACT_SUBREG PairedReg:$val, sub_d1))),
            sub_v2,
            (XLOri27c 96, SingleReg:$mem, VariantMod:$mod0, (v256i1 (EXTRACT_SUBREG MatrixReg:$z, sub_v1)), LsumaskMaskMod:$cond, (SRLDri (i64 (EXTRACT_SUBREG PairedReg:$val, sub_d1)), 32)),
            sub_v3)>;

def : Pat<(int_kvx_xstore256  v256i1:$op0, i64:$mem),
          (XSOri10 0, SingleReg:$mem, VectorReg:$op0)>;

def: Pat<(int_kvx_xstore256 v256i1:$op0, (add i64:$mem, (shiftMulPats <5, i64> i64:$off))),
         (XSOrr SingleReg:$off, SingleReg:$mem, VectorReg:$op0, scale_xs)>;

def: Pat<(int_kvx_xstore256 v256i1:$op0, (add i64:$mem, i64:$off)),
         (XSOrr SingleReg:$off, SingleReg:$mem, VectorReg:$op0, scale_)>;

def: Pat<(int_kvx_dpurgel i64:$mem),
         (DPURGELri10 0, SingleReg:$mem)>;

def: Pat<(int_kvx_dpurgel (add i64:$mem, i64:$off)),
         (DPURGELrr SingleReg:$off, SingleReg:$mem, scale_)>;

def: Pat<(int_kvx_dpurgel (add i64:$mem, (shiftMulPats <6, i64> i64:$off))),
         (DPURGELrr SingleReg:$off, SingleReg:$mem, scale_xs)>;

def: Pat<(int_kvx_dflushl i64:$mem),
         (DFLUSHLri10 0, SingleReg:$mem)>;

def: Pat<(int_kvx_dflushl (add i64:$mem, i64:$off)),
         (DFLUSHLrr SingleReg:$off, SingleReg:$mem, scale_)>;

def: Pat<(int_kvx_dflushl (add i64:$mem, (shiftMulPats <6, i64> i64:$off))),
         (DFLUSHLrr SingleReg:$off, SingleReg:$mem, scale_xs)>;

def: Pat<(v4i16 (int_kvx_zxlbhq v8i8:$v)),
         (ZXLBHQ SingleReg:$v)>;

def: Pat<(v4i16 (int_kvx_zxmbhq v8i8:$v)),
         (ZXMBHQ SingleReg:$v)>;


def: Pat<(v2i32 (int_kvx_zxlhwp v4i16:$v)),
         (ZXLHWP SingleReg:$v)>;

def: Pat<(v2i32 (int_kvx_zxmhwp v4i16:$v)),
         (ZXMHWP SingleReg:$v)>;

def : Pat<(v2i16 (int_kvx_stsu v2i16:$op0, (v2i16(is_imm_vec:$IMM)))),
          (STSUHQri SingleReg:$op0, (build_imm_vec $IMM), splat32_)>;

def : Pat<(v2i16 (int_kvx_stsu v2i16:$op0, v2i16:$op1)),
          (STSUHQrr SingleReg:$op0, SingleReg:$op1)>;

def : Pat<(v4i16 (int_kvx_stsu v4i16:$op0, (v4i16(is_imm_vec_kvx_splat32_:$IMM)))),
          (STSUHQri SingleReg:$op0, (build_imm_vec $IMM), splat32_)>;

def : Pat<(v4i16 (int_kvx_stsu v4i16:$op0, (v4i16 (is_imm_vec_kvx_splat32_at:$IMM)))),
          (STSUHQri SingleReg:$op0, (build_imm_vec $IMM), splat32_at)>;

def : Pat<(v4i16 (int_kvx_stsu v4i16:$op0, (v4i16 (is_imm_vec_kvx_splat32_at:$IMM)))),
          (STSUHQri SingleReg:$op0, (build_imm_vec $IMM), splat32_at)>;

def : Pat<(v2i32 (int_kvx_stsu v2i32:$op0, (v2i32 (is_imm_vec_kvx_splat32_:$IMM)))),
          (STSUWPri SingleReg:$op0, (build_imm_vec $IMM), splat32_)>;

def : Pat<(v2i32 (int_kvx_stsu v2i32:$op0, (v2i32 (is_imm_vec_kvx_splat32_at:$IMM)))),
          (STSUWPri SingleReg:$op0, (build_imm_vec $IMM), splat32_at)>;
} // let Predicates = [IsV2]

def: Pat<(v4i16 (int_kvx_sxlbhq v8i8:$v)),
         (SXLBHQ SingleReg:$v)>;

def: Pat<(v4i16 (int_kvx_sxmbhq v8i8:$v)),
         (SXMBHQ SingleReg:$v)>;


def: Pat<(v2i32 (int_kvx_sxlhwp v4i16:$v)),
         (SXLHWP SingleReg:$v)>;

def: Pat<(v2i32 (int_kvx_sxmhwp v4i16:$v)),
         (SXMHWP SingleReg:$v)>;

def : Pat <(v2f32 (int_kvx_ffmax v2f16:$lhs, v2f16:$rhs, v2f32:$acc, RoundingMod:$r, silent_)),
           (v2f32 (EXTRACT_SUBREG (v4f32(FFMAHWQrr (v4f32 (REG_SEQUENCE PairedReg, SingleReg:$acc, sub_d0, (v2f32(MAKEi16 0)), sub_d1)),
                                                   (ZXWD SingleReg:$lhs), (ZXWD SingleReg:$rhs), RoundingMod:$r, silent_)), sub_d0))>;

def : Pat <(v2f32 (int_kvx_ffmax v2f16:$lhs, v2f16:$rhs, v2f32:$acc, RoundingMod:$r, silent_s)),
           (v2f32 (EXTRACT_SUBREG (v4f32(FFMAHWQrr (v4f32 (REG_SEQUENCE PairedReg, SingleReg:$acc, sub_d0, (v2f32(IMPLICIT_DEF)), sub_d1)),
                                                   SingleReg:$lhs, SingleReg:$rhs, RoundingMod:$r, silent_s)), sub_d0))>;

def : Pat <(v2f32 (int_kvx_ffmsx v2f16:$lhs, v2f16:$rhs, v2f32:$acc, RoundingMod:$r, silent_)),
           (v2f32 (EXTRACT_SUBREG (v4f32(FFMSHWQrr (v4f32 (REG_SEQUENCE PairedReg, SingleReg:$acc, sub_d0, (v2f32(MAKEi16 0)), sub_d1)),
                                                   (ZXWD SingleReg:$lhs), (ZXWD SingleReg:$rhs), RoundingMod:$r, silent_)), sub_d0))>;

def : Pat <(v2f32 (int_kvx_ffmsx v2f16:$lhs, v2f16:$rhs, v2f32:$acc, RoundingMod:$r, silent_s)),
           (v2f32 (EXTRACT_SUBREG (v4f32(FFMSHWQrr (v4f32 (REG_SEQUENCE PairedReg, SingleReg:$acc, sub_d0, (v2f32(IMPLICIT_DEF)), sub_d1)),
                                                   SingleReg:$lhs, SingleReg:$rhs, RoundingMod:$r, silent_s)), sub_d0))>;

def: Pat<(v4f16(int_kvx_ffms v4f16:$v1, v4f16:$v2, v4f16:$v3, i32:$rounding, i32:$silent)),
  (v4f16 (FFMSHQrr SingleReg:$v1, SingleReg:$v2, SingleReg:$v3, RoundingMod:$rounding, SilentMod:$silent))>;

def: Pat<(v2f16(int_kvx_ffms v2f16:$f1, v2f16:$f2, v2f16:$f3, i32:$rounding, silent_s)),
  (v2f16 (FFMSHQrr SingleReg:$f1, SingleReg:$f2, SingleReg:$f3, RoundingMod:$rounding, silent_s))>;

def: Pat<(v2f16(int_kvx_ffms v2f16:$f1, v2f16:$f2, v2f16:$f3, i32:$rounding, silent_)),
  (v2f16 (FFMSHQrr (ZXWD SingleReg:$f1), (ZXWD SingleReg:$f2), (ZXWD SingleReg:$f3), RoundingMod:$rounding, silent_))>;

def: Pat<(f16(int_kvx_ffms f16:$f1, f16:$f2, f16:$f3, i32:$rounding, silent_s)),
  (f16 (FFMSHQrr SingleReg:$f1, SingleReg:$f2, SingleReg:$f3, RoundingMod:$rounding, silent_s))>;

def: Pat<(f16(int_kvx_ffms f16:$f1, f16:$f2, f16:$f3, i32:$rounding, silent_)),
  (f16 (FFMSHQrr (ZXHD SingleReg:$f1), (ZXHD SingleReg:$f2), (ZXHD SingleReg:$f3), RoundingMod:$rounding, silent_))>;

def kvx_any_frags : PatFrags<(ops node:$a, node:$b),
                [(int_kvx_any node:$a, node:$b),
                 (int_kvx_any (abs node:$a), node:$b)]>;

foreach vt = [v8i8, v4i16, v2i32] in
def: Pat<(kvx_any_frags vt:$v, any_nez),
         (COMPDri10 $v, 0, comparison_ne)>;

foreach vt = [v8i8, v4i16, v2i32, i64] in {
def: Pat<(int_kvx_any2 vt:$v0, vt:$v1, any_nez),
         (LORDrr $v0, $v1)>;

def: Pat<(int_kvx_any4 vt:$v0, vt:$v1, vt:$v2, vt:$v3, any_nez),
         (ORWrr (LORDrr $v0, $v1), (LORDrr $v2, $v3))>;
}
// TODO: select (kvx_any_frags) can also profit from avoiding useless compd
foreach vt = [v8i8, v4f16, v4i16, v2f32, v2i32] in {
foreach pos = [scalarcond_dnez, scalarcond_wnez, scalarcond_odd] in
def : Pat<(KVXBRCond (i64 (int_kvx_any vt:$cond, any_nez)), bb:$dst, pos),
            (CB SingleReg:$cond, Pcrel17Imm:$dst, scalarcond_dnez)>;

foreach neg = [scalarcond_deqz, scalarcond_weqz, scalarcond_even] in
def : Pat<(KVXBRCond (i64 (int_kvx_any vt:$cond, any_nez)), bb:$dst, neg),
            (CB SingleReg:$cond, Pcrel17Imm:$dst, scalarcond_deqz)>;
}

multiclass ANYEQZ<ValueType vt, OutPatFrag LEAF, Instruction I = LORDrr> {
    foreach pos = [scalarcond_dnez, scalarcond_wnez, scalarcond_odd] in
    def : Pat<(KVXBRCond (i64 (kvx_any_frags vt:$cond, any_eqz)), bb:$dst, pos),
            (CB (LEAF $cond), Pcrel17Imm:$dst, scalarcond_dnez)>;

    foreach neg = [scalarcond_deqz, scalarcond_weqz, scalarcond_even] in
    def : Pat<(KVXBRCond (i64 (kvx_any_frags vt:$cond, any_eqz)), bb:$dst, neg),
            (CB (LEAF $cond), Pcrel17Imm:$dst, scalarcond_deqz)>;

    def: Pat<(kvx_any_frags vt:$v, any_eqz),
         (COMPDri10 (LEAF $v), (i64 0), comparison_ne)>;

    def: Pat<(int_kvx_any2 vt:$v0, vt:$v1, any_eqz),
             (I (LEAF $v0), (LEAF $v1))>;

    def: Pat<(int_kvx_any4 vt:$v0, vt:$v1, vt:$v2, vt:$v3, any_eqz),
               (ORWrr
                  (I (LEAF $v0), (LEAF $v1)),
                  (I (LEAF $v2), (LEAF $v3)))>;
}

class ANY_VECLEAF<Instruction I> :
  OutPatFrag<(ops node:$v),
             (i64(I $v, (i64 0), comparison_eq))>;

def ANYi64LEAF :
  OutPatFrag<(ops node:$v),
             (i64(COPY $v))>;

def ANYcv1i8LEAF :
  OutPatFrag<(ops node:$v),
             (ANDDrr (ADDDri64 $v, 0xfefefefefefefeff), (ANDNDri32s $v, 0x80808080))>;

defm : ANYEQZ<v8i8, ANYcv1i8LEAF>, Requires<[IsV1]>;
defm : ANYEQZ<v8i8, ANY_VECLEAF<COMPNBO>>, Requires<[IsV2]>;
defm : ANYEQZ<v2i32, ANY_VECLEAF<COMPNWP>>;
defm : ANYEQZ<v4i16, ANY_VECLEAF<COMPNHQ>>;
defm : ANYEQZ<i64, ANYi64LEAF, LNANDDrr>;

let Predicates = [IsV2] in {
foreach vt = [v512i1, v1024i1, v2048i1, v4096i1] in {
def : Pat <(vt (int_kvx_xpreload vt:$z, i64:$mem, i64:$op0, VariantMod:$mod0, LsupackMod:$mod1)),
           (vt (XLOrvp i64:$mem, i64:$op0, VariantMod:$mod0, LsupackMod:$mod1, vt:$z))>;

def : Pat <(int_kvx_xpreload vt:$z, (add i64:$mem, Signed27:$off), i64:$op0, VariantMod:$mod0, LsupackMod:$mod1),
           (vt(XLOri27vp Signed27:$off, i64:$mem, i64:$op0, VariantMod:$mod0, LsupackMod:$mod1, vt:$z))>;

def : Pat <(int_kvx_xpreload vt:$z, (add i64:$mem, Signed54:$off), i64:$op0, VariantMod:$mod0, LsupackMod:$mod1),
           (vt(XLOri54vp Signed54:$off, i64:$mem, i64:$op0, VariantMod:$mod0, LsupackMod:$mod1, vt:$z))>;
}
} // IsV2
