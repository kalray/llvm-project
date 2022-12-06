def: Pat<(int_kvx_await), (AWAIT)>;
def: Pat<(int_kvx_barrier), (BARRIER)>;
def: Pat<(int_kvx_fence), (FENCE)>;
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

def: Pat<(int_kvx_syncgroup SingleReg:$r), (SYNCGROUP SingleReg:$r)>;
def: Pat<(int_kvx_waitit i64:$r), (WAITIT SingleReg:$r)>;

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

def: Pat<(int_kvx_alclrw i64:$addr), (ALCLRWri10 (i64 0), SingleReg:$addr)>;
def: Pat<(int_kvx_alclrd i64:$addr), (ALCLRDri10 (i64 0), SingleReg:$addr)>;

foreach vt = [f16, v2f16, v4f16] in
def: Pat<(vt (int_kvx_fneg vt:$v)),
         (FNEGHQ SingleReg:$v)>;

def: Pat<(f32 (int_kvx_fneg f32:$v)),
         (FNEGW SingleReg:$v)>;

def: Pat<(f64 (int_kvx_fneg f64:$v)),
         (FNEGD SingleReg:$v)>;

def: Pat<(v2f32(int_kvx_fneg v2f32:$r)),
         (FNEGWP SingleReg:$r)>;


def: Pat<(int_kvx_fmaxwp v2f32:$v1, v2f32:$v2), (FMAXWP SingleReg:$v1, SingleReg:$v2)>;
def: Pat<(int_kvx_fminwp v2f32:$v1, v2f32:$v2), (FMINWP SingleReg:$v1, SingleReg:$v2)>;

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

def: Pat<(int_kvx_fmulwp v2f32:$v1, v2f32:$v2, i32:$rounding, i32:$silent), (FMULWPrr SingleReg:$v1, SingleReg:$v2, RoundingMod:$rounding, SilentMod:$silent)>;
def: Pat<(int_kvx_fmulwq v4f32:$v1, v4f32:$v2, i32:$rounding, i32:$silent), (FMULWQ PairedReg:$v1, PairedReg:$v2, RoundingMod:$rounding, SilentMod:$silent)>;

def: Pat<(int_kvx_fmuldp v2f64:$v1, v2f64:$v2, i32:$rounding, i32:$silent),
  (v2f64 (REG_SEQUENCE PairedReg,
    (FMULDrr (f64 (EXTRACT_SUBREG PairedReg:$v1, sub_d0)), (f64 (EXTRACT_SUBREG PairedReg:$v2, sub_d0)), RoundingMod:$rounding, SilentMod:$silent), sub_d0,
    (FMULDrr (f64 (EXTRACT_SUBREG PairedReg:$v1, sub_d1)), (f64 (EXTRACT_SUBREG PairedReg:$v2, sub_d1)), RoundingMod:$rounding, SilentMod:$silent), sub_d1))>;

multiclass FFM___<Intrinsic Int, KVX_INSTRUCTION Opcode, ValueType OperandTy, ValueType DataTy> {
  def: Pat<(Int OperandTy:$v1, OperandTy:$v2, OperandTy:$v3, i32:$rounding, i32:$silent),
    (OperandTy (REG_SEQUENCE PairedReg,
      (Opcode (DataTy (EXTRACT_SUBREG PairedReg:$v3, sub_d0)),
              (DataTy (EXTRACT_SUBREG PairedReg:$v1, sub_d0)),
              (DataTy (EXTRACT_SUBREG PairedReg:$v2, sub_d0)), RoundingMod:$rounding, SilentMod:$silent), sub_d0,
      (Opcode (DataTy (EXTRACT_SUBREG PairedReg:$v3, sub_d1)),
              (DataTy (EXTRACT_SUBREG PairedReg:$v1, sub_d1)),
              (DataTy (EXTRACT_SUBREG PairedReg:$v2, sub_d1)), RoundingMod:$rounding, SilentMod:$silent), sub_d1))>;
}

defm: FFM___<int_kvx_ffmawq, FFMAWPrr, v4f32, v2f32>, Requires<[IsV1]>;
defm: FFM___<int_kvx_ffmswq, FFMSWPrr, v4f32, v2f32>, Requires<[IsV1]>;
defm: FFM___<int_kvx_ffmadp, FFMADrr, v2f64, f64>;
defm: FFM___<int_kvx_ffmsdp, FFMSDrr, v2f64, f64>;

def: Pat<(int_kvx_ffmswq v4f32:$v1, v4f32:$v2, v4f32:$v3, i32:$r, i32:$s),
         (v4f32(FFMSWQ PairedReg:$v3, PairedReg:$v2, PairedReg:$v1, RoundingMod:$r, SilentMod:$s))>, Requires<[IsV2]>;

def: Pat<(int_kvx_ffmawq v4f32:$v1, v4f32:$v2, v4f32:$v3, i32:$r, i32:$s),
         (v4f32(FFMAWQ PairedReg:$v1, PairedReg:$v2, PairedReg:$v3, RoundingMod:$r, SilentMod:$s))>, Requires<[IsV2]>;

def: Pat<(int_kvx_ffdmdaw v2f32:$v0, v2f32:$v1, f32:$v2, i32:$rounding, i32:$silent),
          (FADDWrr
            (FDOT2Wrr SingleReg:$v0, SingleReg:$v1, RoundingMod:$rounding, SilentMod:$silent)
            , SingleReg:$v2, RoundingMod:$rounding, SilentMod:$silent
          )>, Requires<[IsV1]>;

def: Pat<(int_kvx_ffdmdaw v2f32:$v0, v2f32:$v1, f32:$v2, i32:$rounding, i32:$silent),
          (FFDMDAW $v2, $v0, $v1, RoundingMod:$rounding, SilentMod:$silent)>, Requires<[IsV2]>;

def: Pat<(int_kvx_ffdmdawp v4f32:$v0, v4f32:$v1, v2f32:$v2, i32:$rounding, i32:$silent),
          (FFMAWPrr
            (FFMAWPrr
              SingleReg:$v2,
              (v2f32 (EXTRACT_SUBREG PairedReg:$v0, sub_d0)),
              (v2f32 (EXTRACT_SUBREG PairedReg:$v1, sub_d0)), RoundingMod:$rounding, SilentMod:$silent),
            (v2f32 (EXTRACT_SUBREG PairedReg:$v0, sub_d1)),
            (v2f32 (EXTRACT_SUBREG PairedReg:$v1, sub_d1)),
            RoundingMod:$rounding, SilentMod:$silent
          )>, Requires<[IsV1]>;

def: Pat<(int_kvx_ffdmdawp v4f32:$v0, v4f32:$v1, v2f32:$v2, i32:$rounding, i32:$silent),
          (FFDMDAWP $v2, $v0, $v1, RoundingMod:$rounding, SilentMod:$silent)>, Requires<[IsV2]>;

def: Pat<(int_kvx_ffmawp v2f32:$v1, v2f32:$v2, v2f32:$v3, i32:$rounding, i32:$silent), (FFMAWPrr SingleReg:$v3, SingleReg:$v1, SingleReg:$v2, RoundingMod:$rounding, SilentMod:$silent)>;
def: Pat<(int_kvx_ffmswp v2f32:$v1, v2f32:$v2, v2f32:$v3, i32:$rounding, i32:$silent), (FFMSWPrr SingleReg:$v3, SingleReg:$v1, SingleReg:$v2, RoundingMod:$rounding, SilentMod:$silent)>;
def: Pat<(int_kvx_fmm212w v2f32:$v1, v2f32:$v2, i32:$rounding, i32:$silent), (FMM212W SingleReg:$v1, SingleReg:$v2, RoundingMod:$rounding, SilentMod:$silent)>;
def: Pat<(int_kvx_fmma212w v2f32:$v1, v2f32:$v2, v4f32:$v3, i32:$rounding, i32:$silent), (FMMA212W PairedReg:$v3, SingleReg:$v1, SingleReg:$v2, RoundingMod:$rounding, SilentMod:$silent)>;
def: Pat<(int_kvx_fmms212w v2f32:$v1, v2f32:$v2, v4f32:$v3, i32:$rounding, i32:$silent), (FMMS212W PairedReg:$v3, SingleReg:$v1, SingleReg:$v2, RoundingMod:$rounding, SilentMod:$silent)>;

def: Pat<(int_kvx_fmulwc v2f32:$v1, v2f32:$v2, i32:$conjugate, i32:$rounding, i32:$silent),
          (FMULWCrr SingleReg:$v1, SingleReg:$v2, ConjugateMod:$conjugate, RoundingMod:$rounding, SilentMod:$silent)>;

def: Pat<(int_kvx_fmulwcp v4f32:$v1, v4f32:$v2, i32:$conjugate, i32:$rounding, i32:$silent),
  (v4f32 (REG_SEQUENCE PairedReg,
     (FMULWCrr (v2f32 (EXTRACT_SUBREG PairedReg:$v1, sub_d0)),
               (v2f32 (EXTRACT_SUBREG PairedReg:$v2, sub_d0)), ConjugateMod:$conjugate, RoundingMod:$rounding, SilentMod:$silent), sub_d0,
     (FMULWCrr (v2f32 (EXTRACT_SUBREG PairedReg:$v1, sub_d1)),
               (v2f32 (EXTRACT_SUBREG PairedReg:$v2, sub_d1)), ConjugateMod:$conjugate, RoundingMod:$rounding, SilentMod:$silent), sub_d1))>, Requires<[IsV1]>;

def: Pat<(int_kvx_fmulwcp v4f32:$v1, v4f32:$v2, i32:$conjugate, i32:$rounding, i32:$silent),
  (v4f32 (FMULWCP PairedReg:$v1, PairedReg:$v2, ConjugateMod:$conjugate, RoundingMod:$rounding, SilentMod:$silent))>, Requires<[IsV2]>;

multiclass FMUL_DC<Intrinsic int_kvx_fmul, KVX_INSTRUCTION FFMS, KVX_INSTRUCTION FFMA> {
  def: Pat<(int_kvx_fmul v2f64:$v1, v2f64:$v2, i32:$rounding, i32:$silent),
    (v2f64 (REG_SEQUENCE PairedReg,
      (FFMS (FMULDrr (f64 (EXTRACT_SUBREG PairedReg:$v1, sub_d0)), (f64 (EXTRACT_SUBREG PairedReg:$v2, sub_d0)), RoundingMod:$rounding, SilentMod:$silent),
            (f64 (EXTRACT_SUBREG PairedReg:$v1, sub_d1)),
            (f64 (EXTRACT_SUBREG PairedReg:$v2, sub_d1)), RoundingMod:$rounding, SilentMod:$silent), sub_d0,
      (FFMA (FMULDrr (f64 (EXTRACT_SUBREG PairedReg:$v1, sub_d0)), (f64 (EXTRACT_SUBREG PairedReg:$v2, sub_d1)), RoundingMod:$rounding, SilentMod:$silent),
            (f64 (EXTRACT_SUBREG PairedReg:$v1, sub_d1)),
            (f64 (EXTRACT_SUBREG PairedReg:$v2, sub_d0)), RoundingMod:$rounding, SilentMod:$silent), sub_d1))>;
}

defm: FMUL_DC<int_kvx_fmuldc, FFMSDrr, FFMADrr>;
defm: FMUL_DC<int_kvx_fmulcdc, FFMADrr, FFMSDrr>;

multiclass FFM__DC<Intrinsic int_kvx_ffmop, KVX_INSTRUCTION FOP, KVX_INSTRUCTION FFMS, KVX_INSTRUCTION FFMA> {
  def: Pat<(int_kvx_ffmop v2f64:$v1, v2f64:$v2, v2f64:$v3, i32:$rounding, i32:$silent),
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

multiclass FFM__CDC<Intrinsic int_kvx_ffmop, KVX_INSTRUCTION FOP, KVX_INSTRUCTION FFMS, KVX_INSTRUCTION FFMA> {
  def: Pat<(int_kvx_ffmop v2f64:$v1, v2f64:$v2, v2f64:$v3, i32:$rounding, i32:$silent),
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

defm: FFM__DC<int_kvx_ffmadc, FADDDP, FFMSDrr, FFMADrr>;
defm: FFM__DC<int_kvx_ffmsdc, FSBFDP, FFMSDrr, FFMADrr>;
defm: FFM__CDC<int_kvx_ffmacdc, FADDDC, FFMADrr, FFMSDrr>;
defm: FFM__CDC<int_kvx_ffmscdc, FSBFDC, FFMADrr, FFMSDrr>;

multiclass FFM__WC<Intrinsic int_kvx_fop, KVX_INSTRUCTION FOP, KVX_INSTRUCTION CFOP, KVX_INSTRUCTION FMUL> {
  def: Pat<(int_kvx_fop v2f32:$v1, v2f32:$v2, v2f32:$v3, conjugate_, i32:$rounding, i32:$silent),
    (FOP (FMUL SingleReg:$v2, SingleReg:$v1, conjugate_, RoundingMod:$rounding, SilentMod:$silent),
         SingleReg:$v3, RoundingMod:$rounding, SilentMod:$silent)>;

  def: Pat<(int_kvx_fop v2f32:$v1, v2f32:$v2, v2f32:$v3, conjugate_c, i32:$rounding, i32:$silent),
    (CFOP (FMUL SingleReg:$v2, SingleReg:$v1, conjugate_c, RoundingMod:$rounding, SilentMod:$silent),
         SingleReg:$v3, RoundingMod:$rounding, SilentMod:$silent)>;
}

defm: FFM__WC<int_kvx_ffmawc, FADDWPrr, FADDWCrr, FMULWCrr>;
defm: FFM__WC<int_kvx_ffmswc, FSBFWPrr, FSBFWCrr, FMULWCrr>;

multiclass FFM__WCP<Intrinsic int_kvx_fop, KVX_INSTRUCTION FOP, KVX_INSTRUCTION CFOP, KVX_INSTRUCTION FMUL> {
  def: Pat<(int_kvx_fop v4f32:$v1, v4f32:$v2, v4f32:$v3, conjugate_, i32:$rounding, i32:$silent),
    (v4f32 (REG_SEQUENCE PairedReg,
       (FOP (FMUL (v2f32 (EXTRACT_SUBREG PairedReg:$v2, sub_d0)),
                  (v2f32 (EXTRACT_SUBREG PairedReg:$v1, sub_d0)), conjugate_, RoundingMod:$rounding, SilentMod:$silent),
            (v2f32 (EXTRACT_SUBREG PairedReg:$v3, sub_d0)), RoundingMod:$rounding, SilentMod:$silent), sub_d0,
       (FOP (FMUL (v2f32 (EXTRACT_SUBREG PairedReg:$v2, sub_d1)),
                  (v2f32 (EXTRACT_SUBREG PairedReg:$v1, sub_d1)), conjugate_, RoundingMod:$rounding, SilentMod:$silent),
            (v2f32 (EXTRACT_SUBREG PairedReg:$v3, sub_d1)), RoundingMod:$rounding, SilentMod:$silent), sub_d1))>, Requires<[IsV1]>;

  def: Pat<(int_kvx_fop v4f32:$v1, v4f32:$v2, v4f32:$v3, conjugate_c, i32:$rounding, i32:$silent),
    (v4f32 (REG_SEQUENCE PairedReg,
       (FOP (FMUL (v2f32 (EXTRACT_SUBREG PairedReg:$v2, sub_d0)),
                  (v2f32 (EXTRACT_SUBREG PairedReg:$v1, sub_d0)), conjugate_c, RoundingMod:$rounding, SilentMod:$silent),
            (v2f32 (EXTRACT_SUBREG PairedReg:$v3, sub_d0)), RoundingMod:$rounding, SilentMod:$silent), sub_d0,
       (FOP (FMUL (v2f32 (EXTRACT_SUBREG PairedReg:$v2, sub_d1)),
                  (v2f32 (EXTRACT_SUBREG PairedReg:$v1, sub_d1)), conjugate_c, RoundingMod:$rounding, SilentMod:$silent),
            (v2f32 (EXTRACT_SUBREG PairedReg:$v3, sub_d1)), RoundingMod:$rounding, SilentMod:$silent), sub_d1))>, Requires<[IsV1]>;
}

defm: FFM__WCP<int_kvx_ffmawcp, FADDWPrr, FADDWCrr, FMULWCrr>;
defm: FFM__WCP<int_kvx_ffmswcp, FSBFWPrr, FSBFWCrr, FMULWCrr>;

def: Pat<(int_kvx_fconjwc v2f32:$v), (FNEGD SingleReg:$v)>;
def: Pat<(int_kvx_fconjwcp v4f32:$v),
  (v4f32 (REG_SEQUENCE PairedReg,
    (FNEGD (v2f32 (EXTRACT_SUBREG PairedReg:$v, sub_d0))), sub_d0,
    (FNEGD (v2f32 (EXTRACT_SUBREG PairedReg:$v, sub_d1))), sub_d1))>;
def: Pat<(int_kvx_fconjdc v2f64:$v),
  (v2f64 (REG_SEQUENCE PairedReg,
    (f64 (EXTRACT_SUBREG PairedReg:$v, sub_d0)), sub_d0,
    (FNEGD (f64 (EXTRACT_SUBREG PairedReg:$v, sub_d1))), sub_d1))>;

def: Pat<(int_kvx_ctzd i64:$r), (CTZD SingleReg:$r)>;
def: Pat<(int_kvx_ctzw i32:$r), (CTZW SingleReg:$r)>;
def: Pat<(int_kvx_ctzwp v2i32:$r), (CTZWP SingleReg:$r)>;
def: Pat<(int_kvx_clzd i64:$r), (CLZD SingleReg:$r)>;
def: Pat<(int_kvx_clzw i32:$r), (CLZW SingleReg:$r)>;
def: Pat<(int_kvx_clzwp v2i32:$r), (CLZWP SingleReg:$r)>;
def: Pat<(int_kvx_clsd i64:$r), (CLSD SingleReg:$r)>;
def: Pat<(int_kvx_clsw i32:$r), (CLSW SingleReg:$r)>;
def: Pat<(int_kvx_clswp v2i32:$r), (CLSWP SingleReg:$r)>;
def: Pat<(int_kvx_cbsd i64:$r), (CBSD SingleReg:$r)>;
def: Pat<(int_kvx_cbsw i32:$r), (CBSW SingleReg:$r)>;
def: Pat<(int_kvx_cbswp v2i32:$r), (CBSWP SingleReg:$r)>;

def: Pat<(int_kvx_fixedw f32:$f, i64:$shift, i32:$rounding, i32:$silent), (FIXEDW SingleReg:$f, Unsigned6:$shift, RoundingMod:$rounding, SilentMod:$silent)>;
def: Pat<(int_kvx_fixeduw f32:$f, i64:$shift, i32:$rounding, i32:$silent), (FIXEDUW SingleReg:$f, Unsigned6:$shift, RoundingMod:$rounding, SilentMod:$silent)>;
def: Pat<(int_kvx_fixedwp v2f32:$f, i64:$shift, i32:$rounding, i32:$silent), (FIXEDWP SingleReg:$f, Unsigned6:$shift, RoundingMod:$rounding, SilentMod:$silent)>;
def: Pat<(int_kvx_fixeduwp v2f32:$f, i64:$shift, i32:$rounding, i32:$silent), (FIXEDUWP SingleReg:$f, Unsigned6:$shift, RoundingMod:$rounding, SilentMod:$silent)>;
def: Pat<(int_kvx_fixedd f64:$f, i64:$shift, i32:$rounding, i32:$silent), (FIXEDD SingleReg:$f, Unsigned6:$shift, RoundingMod:$rounding, SilentMod:$silent)>;
def: Pat<(int_kvx_fixedud f64:$f, i64:$shift, i32:$rounding, i32:$silent), (FIXEDUD SingleReg:$f, Unsigned6:$shift, RoundingMod:$rounding, SilentMod:$silent)>;
def: Pat<(int_kvx_floatw i32:$i, i64:$shift, i32:$rounding, i32:$silent), (FLOATW SingleReg:$i, Unsigned6:$shift, RoundingMod:$rounding, SilentMod:$silent)>;
def: Pat<(int_kvx_floatwp v2i32:$i, i64:$shift, i32:$rounding, i32:$silent), (FLOATWP SingleReg:$i, Unsigned6:$shift, RoundingMod:$rounding, SilentMod:$silent)>;
def: Pat<(int_kvx_floatuw i32:$i, i64:$shift, i32:$rounding, i32:$silent), (FLOATUW SingleReg:$i, Unsigned6:$shift, RoundingMod:$rounding, SilentMod:$silent)>;
def: Pat<(int_kvx_floatuwp v2i32:$i, i64:$shift, i32:$rounding, i32:$silent), (FLOATUWP SingleReg:$i, Unsigned6:$shift, RoundingMod:$rounding, SilentMod:$silent)>;
def: Pat<(int_kvx_floatd i64:$i, i64:$shift, i32:$rounding, i32:$silent), (FLOATD SingleReg:$i, Unsigned6:$shift, RoundingMod:$rounding, SilentMod:$silent)>;
def: Pat<(int_kvx_floatud i64:$i, i64:$shift, i32:$rounding, i32:$silent), (FLOATUD SingleReg:$i, Unsigned6:$shift, RoundingMod:$rounding, SilentMod:$silent)>;

def: Pat<(int_kvx_fnarrowwh f32:$v, i32:$rounding, i32:$silent), (FNARROWWH SingleReg:$v, RoundingMod:$rounding, SilentMod:$silent)>;
def: Pat<(int_kvx_fnarrowwhq v4f32:$v, i32:$rounding, i32:$silent), (FNARROWWHQ PairedReg:$v, RoundingMod:$rounding, SilentMod:$silent)>;
def: Pat<(int_kvx_fnarrowdw f64:$v, i32:$rounding, i32:$silent), (FNARROWDW SingleReg:$v, RoundingMod:$rounding, SilentMod:$silent)>;
def: Pat<(int_kvx_fnarrowdwp v2f64:$v, i32:$rounding, i32:$silent), (FNARROWDWP PairedReg:$v, RoundingMod:$rounding, SilentMod:$silent)>;

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

def: Pat<(int_kvx_avghq v4i16:$v1, v4i16:$v2), (AVGHQrr SingleReg:$v1, SingleReg:$v2)>;
def: Pat<(int_kvx_avgw i32:$v1, i32:$v2), (AVGWrr SingleReg:$v1, SingleReg:$v2)>;
def: Pat<(int_kvx_avgwp v2i32:$v1, v2i32:$v2), (AVGWPrr SingleReg:$v1, SingleReg:$v2)>;
def: Pat<(int_kvx_avguhq v4i16:$v1, v4i16:$v2), (AVGUHQrr SingleReg:$v1, SingleReg:$v2)>;
def: Pat<(int_kvx_avguw i32:$v1, i32:$v2), (AVGUWrr SingleReg:$v1, SingleReg:$v2)>;
def: Pat<(int_kvx_avguwp v2i32:$v1, v2i32:$v2), (AVGUWPrr SingleReg:$v1, SingleReg:$v2)>;

def: Pat<(int_kvx_avgrhq v4i16:$v1, v4i16:$v2), (AVGRHQrr SingleReg:$v1, SingleReg:$v2)>;
def: Pat<(int_kvx_avgruhq v4i16:$v1, v4i16:$v2), (AVGRUHQrr SingleReg:$v1, SingleReg:$v2)>;
def: Pat<(int_kvx_avgrw i32:$v1, i32:$v2), (AVGRWrr SingleReg:$v1, SingleReg:$v2)>;
def: Pat<(int_kvx_avgrwp v2i32:$v1, v2i32:$v2), (AVGRWPrr SingleReg:$v1, SingleReg:$v2)>;
def: Pat<(int_kvx_avgruw i32:$v1, i32:$v2), (AVGRUWrr SingleReg:$v1, SingleReg:$v2)>;
def: Pat<(int_kvx_avgruwp v2i32:$v1, v2i32:$v2), (AVGRUWPrr SingleReg:$v1, SingleReg:$v2)>;

def: Pat<(f32(int_fabs f32:$v)),
         (FABSW SingleReg:$v)>;

def: Pat<(f64(int_fabs f64:$v)),
         (FABSD SingleReg:$v)>;

def: Pat<(int_kvx_fmaxw f32:$v1, f32:$v2), (FMAXW SingleReg:$v1, SingleReg:$v2)>;
def: Pat<(int_kvx_fmaxd f64:$v1, f64:$v2), (FMAXD SingleReg:$v1, SingleReg:$v2)>;
def: Pat<(int_kvx_fminw f32:$v1, f32:$v2), (FMINW SingleReg:$v1, SingleReg:$v2)>;
def: Pat<(int_kvx_fmind f64:$v1, f64:$v2), (FMIND SingleReg:$v1, SingleReg:$v2)>;
def: Pat<(int_kvx_frecw f32:$f, i32:$rounding, i32:$silent), (FRECW SingleReg:$f, RoundingMod:$rounding, SilentMod:$silent)>;
def: Pat<(int_kvx_frsrw f32:$f, i32:$rounding, i32:$silent), (FRSRW SingleReg:$f, RoundingMod:$rounding, SilentMod:$silent)>;
def: Pat<(f32(int_kvx_fadd f32:$v1, f32:$v2, i32:$rounding, i32:$silent)), (FADDWrr SingleReg:$v1, SingleReg:$v2, RoundingMod:$rounding, SilentMod:$silent)>;
def: Pat<(f64(int_kvx_fadd f64:$v1, f64:$v2, i32:$rounding, i32:$silent)), (FADDDrr SingleReg:$v1, SingleReg:$v2, RoundingMod:$rounding, SilentMod:$silent)>;
def: Pat<(f32(int_kvx_fsbf f32:$v1, f32:$v2, i32:$rounding, i32:$silent)), (FSBFWrr SingleReg:$v1, SingleReg:$v2, RoundingMod:$rounding, SilentMod:$silent)>;
def: Pat<(f64(int_kvx_fsbf f64:$v1, f64:$v2, i32:$rounding, i32:$silent)), (FSBFDrr SingleReg:$v1, SingleReg:$v2, RoundingMod:$rounding, SilentMod:$silent)>;
def: Pat<(int_kvx_fmulw f32:$v1, f32:$v2, i32:$rounding, i32:$silent), (FMULWrr SingleReg:$v1, SingleReg:$v2, RoundingMod:$rounding, SilentMod:$silent)>;
def: Pat<(int_kvx_fmuld f64:$v1, f64:$v2, i32:$rounding, i32:$silent), (FMULDrr SingleReg:$v1, SingleReg:$v2, RoundingMod:$rounding, SilentMod:$silent)>;
def: Pat<(int_kvx_fmulwd f32:$v1, f32:$v2, i32:$rounding, i32:$silent), (FMULWDrr SingleReg:$v1, SingleReg:$v2, RoundingMod:$rounding, SilentMod:$silent)>;
def: Pat<(int_kvx_ffmaw f32:$v1, f32:$v2, f32:$v3, i32:$rounding, i32:$silent), (FFMAWrr SingleReg:$v3, SingleReg:$v1, SingleReg:$v2, RoundingMod:$rounding, SilentMod:$silent)>;
def: Pat<(int_kvx_ffmad f64:$v1, f64:$v2, f64:$v3, i32:$rounding, i32:$silent), (FFMADrr SingleReg:$v3, SingleReg:$v1, SingleReg:$v2, RoundingMod:$rounding, SilentMod:$silent)>;
def: Pat<(int_kvx_ffmawd f32:$v1, f32:$v2, f64:$v3, i32:$rounding, i32:$silent), (FFMAWDrr SingleReg:$v3, SingleReg:$v1, SingleReg:$v2, RoundingMod:$rounding, SilentMod:$silent)>;
def: Pat<(int_kvx_ffmsw f32:$v1, f32:$v2, f32:$v3, i32:$rounding, i32:$silent), (FFMSWrr SingleReg:$v3, SingleReg:$v1, SingleReg:$v2, RoundingMod:$rounding, SilentMod:$silent)>;
def: Pat<(int_kvx_ffmsd f64:$v1, f64:$v2, f64:$v3, i32:$rounding, i32:$silent), (FFMSDrr SingleReg:$v3, SingleReg:$v1, SingleReg:$v2, RoundingMod:$rounding, SilentMod:$silent)>;
def: Pat<(int_kvx_ffmswd f32:$v1, f32:$v2, f64:$v3, i32:$rounding, i32:$silent), (FFMSWDrr SingleReg:$v3, SingleReg:$v1, SingleReg:$v2, RoundingMod:$rounding, SilentMod:$silent)>;
def: Pat<(int_kvx_fcdivw f32:$v1, f32:$v2, i32:$silent), (FCDIVW (INSERT_SUBREG (INSERT_SUBREG (v2i64 (IMPLICIT_DEF)),
    SingleReg:$v1, sub_d0), SingleReg:$v2, sub_d1), SilentMod:$silent)>;
def: Pat<(int_kvx_fcdivd f64:$v1, f64:$v2, i32:$silent), (FCDIVD (INSERT_SUBREG (INSERT_SUBREG (v2i64 (IMPLICIT_DEF)),
    SingleReg:$v1, sub_d0), SingleReg:$v2, sub_d1), SilentMod:$silent)>;
def: Pat<(int_kvx_fsdivw f32:$v1, f32:$v2, i32:$silent), (FSDIVW (INSERT_SUBREG (INSERT_SUBREG (v2i64 (IMPLICIT_DEF)),
    SingleReg:$v1, sub_d0), SingleReg:$v2, sub_d1), SilentMod:$silent)>;
def: Pat<(int_kvx_fsdivd f64:$v1, f64:$v2, i32:$silent), (FSDIVD (INSERT_SUBREG (INSERT_SUBREG (v2i64 (IMPLICIT_DEF)),
    SingleReg:$v1, sub_d0), SingleReg:$v2, sub_d1), SilentMod:$silent)>;
def: Pat<(int_kvx_fsrecw f32:$v, i32:$silent), (FSRECW SingleReg:$v, SilentMod:$silent)>;
def: Pat<(int_kvx_fsrecd f64:$v, i32:$silent), (FSRECD SingleReg:$v, SilentMod:$silent)>;
def: Pat<(int_kvx_fsrsrw f32:$v), (FSRSRW SingleReg:$v)>;
def: Pat<(int_kvx_fsrsrd f64:$v), (FSRSRD SingleReg:$v)>;

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

def: Pat<(i32(int_kvx_select Signed37W:$t, i32:$f, i64:$c, i32:$sc)),
         (CMOVEDri37 SingleReg:$c, SingleReg:$f, (imm32_to_imm64 $t), ScalarcondMod:$sc)>;

foreach vt = [f32, i32, f64, i64] in
def: Pat<(vt(int_kvx_select vt:$t, vt:$f, i64:$c, i32:$sc)),
         (CMOVEDrr SingleReg:$c, SingleReg:$f, SingleReg:$t, ScalarcondMod:$sc)>;

// widen patterns
def: Pat<(int_kvx_fwidenmwd v2f32:$v, i32:$silent), (FWIDENMWD SingleReg:$v, SilentMod:$silent)>;
def: Pat<(int_kvx_fwidenlhwp v4f16:$v, i32:$silent), (FWIDENLHWP SingleReg:$v, SilentMod:$silent)>;
def: Pat<(int_kvx_fwidenmhwp v4f16:$v, i32:$silent), (FWIDENMHWP SingleReg:$v, SilentMod:$silent)>;

def: Pat<(int_kvx_fwidenlhw v4f16:$v, i32:$silent), (FWIDENLHW SingleReg:$v, SilentMod:$silent)>;
def: Pat<(int_kvx_fwidenlhw (build_vector f16:$f1, (f16 undef), (f16 undef), (f16 undef)), i32:$silent), (FWIDENLHW SingleReg:$f1, SilentMod:$silent)>;

def: Pat<(int_kvx_fwidenlwd v2f32:$v, i32:$silent), (FWIDENLWD SingleReg:$v, SilentMod:$silent)>;
def: Pat<(int_kvx_fwidenlwd (build_vector f32:$f1, (f32 undef)), i32:$silent), (FWIDENLWD SingleReg:$f1, SilentMod:$silent)>;

// f16 patterns
def: Pat<(int_kvx_fmulhq v4f16:$v1, v4f16:$v2, i32:$rounding, i32:$silent), (FMULHQrr SingleReg:$v1, SingleReg:$v2, RoundingMod:$rounding, SilentMod:$silent)>;
def: Pat<(int_kvx_fmulhq (build_vector f16:$f1, (f16 undef), (f16 undef), (f16 undef)),
                         (build_vector f16:$f2, (f16 undef), (f16 undef), (f16 undef)), i32:$rounding, (i32 1)),
         (FMULHQrr SingleReg:$f1, SingleReg:$f2, RoundingMod:$rounding, silent_s)>;
def: Pat<(int_kvx_fmulhq (build_vector f16:$f1, (f16 undef), (f16 undef), (f16 undef)),
                         (build_vector f16:$f2, (f16 undef), (f16 undef), (f16 undef)), i32:$rounding, (i32 0)),
         (FMULHQrr (ZXHD SingleReg:$f1), (ZXHD SingleReg:$f2), RoundingMod:$rounding, silent_)>;

def: Pat<(int_kvx_fmaxhq v4f16:$v1, v4f16:$v2), (FMAXHQ SingleReg:$v1, SingleReg:$v2)>;
def: Pat<(int_kvx_fmaxhq (build_vector f16:$f1, (f16 undef), (f16 undef), (f16 undef)),
                         (build_vector f16:$f2, (f16 undef), (f16 undef), (f16 undef))),
         (FMAXHQ SingleReg:$f1, SingleReg:$f2)>;

def: Pat<(int_kvx_fminhq v4f16:$v1, v4f16:$v2), (FMINHQ SingleReg:$v1, SingleReg:$v2)>;
def: Pat<(int_kvx_fminhq (build_vector f16:$f1, (f16 undef), (f16 undef), (f16 undef)),
                         (build_vector f16:$f2, (f16 undef), (f16 undef), (f16 undef))),
         (FMINHQ SingleReg:$f1, SingleReg:$f2)>;

def: Pat<(int_kvx_ffmahq v4f16:$v1, v4f16:$v2, v4f16:$v3, i32:$rounding, i32:$silent),
  (v4f16 (FFMAHQrr SingleReg:$v1, SingleReg:$v2, SingleReg:$v3, RoundingMod:$rounding, SilentMod:$silent))>;
def: Pat<(int_kvx_ffmahq (build_vector f16:$f1, (f16 undef), (f16 undef), (f16 undef)),
                         (build_vector f16:$f2, (f16 undef), (f16 undef), (f16 undef)),
                         (build_vector f16:$f3, (f16 undef), (f16 undef), (f16 undef)), i32:$rounding, (i32 1)),
  (v4f16 (FFMAHQrr SingleReg:$f1, SingleReg:$f2, SingleReg:$f3, RoundingMod:$rounding, silent_s))>;
def: Pat<(int_kvx_ffmahq (build_vector f16:$f1, (f16 undef), (f16 undef), (f16 undef)),
                         (build_vector f16:$f2, (f16 undef), (f16 undef), (f16 undef)),
                         (build_vector f16:$f3, (f16 undef), (f16 undef), (f16 undef)), i32:$rounding, (i32 0)),
  (v4f16 (FFMAHQrr (ZXHD SingleReg:$f1), (ZXHD SingleReg:$f2), (ZXHD SingleReg:$f3), RoundingMod:$rounding, silent_))>;

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

def: Pat<(int_kvx_xmoveoto QuadReg:$r), (COPY_TO_REGCLASS QuadReg:$r, VectorReg)>;

// Copy from TCA to GPR registers
def: Pat<(int_kvx_xmovefo VectorReg:$v), (COPY_TO_REGCLASS $v, QuadReg)>;

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

def: Pat<(int_kvx_xcat1024 v512i1:$w0, v512i1:$w1),
            (REG_SEQUENCE MatrixReg,
                (v512i1 WideReg:$w0), (i32 sub_w0),
                (v512i1 WideReg:$w1), (i32 sub_w1))>;

def: Pat<(int_kvx_xcat512 v256i1:$v0, v256i1:$v1),
            (REG_SEQUENCE WideReg,
                (v256i1 VectorReg:$v0), (i32 sub_v0),
                (v256i1 VectorReg:$v1), (i32 sub_v1))>;
let Predicates = [IsV1] in {
def : Pat<(v256i1(int_kvx_lv (add i64:$mem, (shl i64:$off, (i32 5))), SpeculateMod:$mod0)),
          (LVrr SingleReg:$off, SingleReg:$mem, SpeculateMod:$mod0, scaling_xs)>;

def : Pat<(v256i1(int_kvx_lv (add i64:$mem, i64:$off), SpeculateMod:$mod0)),
          (LVrr SingleReg:$off, SingleReg:$mem, SpeculateMod:$mod0, scaling_)>;

def : Pat<(v256i1(int_kvx_lv i64:$mem, SpeculateMod:$mod0)),
          (LVri10 0, SingleReg:$mem, SpeculateMod:$mod0)>;

def : Pat<(v1024i1(int_kvx_lvc MatrixReg:$z, (add i64:$mem, (shl i64:$off, (i32 5))), QindexMod:$mod0, SpeculateMod:$mod1)),
          (LVrrcs SingleReg:$off, SingleReg:$mem, QindexMod:$mod0, SpeculateMod:$mod1, scaling_xs, MatrixReg:$z)>;

def : Pat<(v1024i1(int_kvx_lvc MatrixReg:$z, (add i64:$mem, i64:$off), QindexMod:$mod0, SpeculateMod:$mod1)),
          (LVrrcs SingleReg:$off, SingleReg:$mem, QindexMod:$mod0, SpeculateMod:$mod1, scaling_, MatrixReg:$z)>;

def : Pat<(v1024i1(int_kvx_lvc MatrixReg:$z, i64:$mem, QindexMod:$mod0, SpeculateMod:$mod1)),
          (LVri10cs 0, SingleReg:$mem, QindexMod:$mod0, SpeculateMod:$mod1, MatrixReg:$z)>;

def : Pat<(int_kvx_sv  i64:$mem, v256i1:$op0),
          (SVri10 0, SingleReg:$mem, VectorReg:$op0)>;
}

// atomic register copy/shift operations
def: Pat<(int_kvx_xswap256 QuadReg:$r, VectorReg:$v),
         (XSWAP256p QuadReg:$r, VectorReg:$v)>;

def: Pat<(int_kvx_xaccess512o WideReg:$a2a3, Unsigned6:$a4), (ALIGNOreroi (EXTRACT_SUBREG WideReg:$a2a3, sub_v0), (EXTRACT_SUBREG WideReg:$a2a3, sub_v1), Unsigned6:$a4)>, Requires<[IsV1]>;
def: Pat<(int_kvx_xaccess512o WideReg:$a2a3, Unsigned6:$a4), (ALIGNOrorei (EXTRACT_SUBREG WideReg:$a2a3, sub_v0), (EXTRACT_SUBREG WideReg:$a2a3, sub_v1), Unsigned6:$a4)>, Requires<[IsV1]>;
def: Pat<(int_kvx_xaccess512o WideReg:$a2a3, SingleReg:$a4), (ALIGNOreror (EXTRACT_SUBREG WideReg:$a2a3, sub_v0), (EXTRACT_SUBREG WideReg:$a2a3, sub_v1), $a4)>, Requires<[IsV1]>;
def: Pat<(int_kvx_xaccess512o WideReg:$a2a3, SingleReg:$a4), (ALIGNOrorer (EXTRACT_SUBREG WideReg:$a2a3, sub_v0), (EXTRACT_SUBREG WideReg:$a2a3, sub_v1), $a4)>, Requires<[IsV1]>;

def: Pat<(int_kvx_xalign512o WideReg:$a2a3, Unsigned6:$a4), (ALIGNVreroi (EXTRACT_SUBREG WideReg:$a2a3, sub_v0), (EXTRACT_SUBREG WideReg:$a2a3, sub_v1), Unsigned6:$a4)>, Requires<[IsV1]>;
def: Pat<(int_kvx_xalign512o WideReg:$a2a3, Unsigned6:$a4), (ALIGNVrorei (EXTRACT_SUBREG WideReg:$a2a3, sub_v0), (EXTRACT_SUBREG WideReg:$a2a3, sub_v1), Unsigned6:$a4)>, Requires<[IsV1]>;
def: Pat<(int_kvx_xalign512o WideReg:$a2a3, SingleReg:$a4), (ALIGNVreror (EXTRACT_SUBREG WideReg:$a2a3, sub_v0), (EXTRACT_SUBREG WideReg:$a2a3, sub_v1), $a4)>, Requires<[IsV1]>;
def: Pat<(int_kvx_xalign512o WideReg:$a2a3, SingleReg:$a4), (ALIGNVrorer (EXTRACT_SUBREG WideReg:$a2a3, sub_v0), (EXTRACT_SUBREG WideReg:$a2a3, sub_v1), $a4)>, Requires<[IsV1]>;

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
multiclass FMMAS222W <PatFrag Node, KVX_INSTRUCTION Op, Intrinsic KVX_Int> {
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
multiclass FMMAS222W_CV1 <PatFrag Node, KVX_INSTRUCTION Op, Intrinsic KVX_Int> {
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
def: Pat<(int_kvx_xload256 (add i64:$mem, (shl i64:$off, (i32 5))), VariantMod:$mod0),
         (XLOrr SingleReg:$off, SingleReg:$mem, VariantMod:$mod0,  scaling_xs)>;

def: Pat<(int_kvx_xload256 (add i64:$mem, i64:$off), VariantMod:$mod0),
         (XLOrr SingleReg:$off, SingleReg:$mem, VariantMod:$mod0,  scaling_)>;

def: Pat<(int_kvx_xload256 i64:$mem, VariantMod:$mod0),
         (XLOri10 0, SingleReg:$mem, VariantMod:$mod0)>;

def: Pat<(int_kvx_xloads1024 v1024i1:$z, (add i64:$mem, (shl i64:$off, (i32 5))), VariantMod:$mod0, QindexMod:$mod1),
         (XLOrrq SingleReg:$off, SingleReg:$mem, VariantMod:$mod0, scaling_xs, QindexMod:$mod1, MatrixReg:$z)>;

def: Pat<(int_kvx_xloads1024 v1024i1:$z, (add i64:$mem, i64:$off), VariantMod:$mod0, QindexMod:$mod1),
         (XLOrrq SingleReg:$off, SingleReg:$mem, VariantMod:$mod0, scaling_, QindexMod:$mod1, MatrixReg:$z)>;

def: Pat<(int_kvx_xloads1024 v1024i1:$z, i64:$mem, VariantMod:$mod0, QindexMod:$mod1),
         (XLOri10q 0, SingleReg:$mem, VariantMod:$mod0, QindexMod:$mod1, MatrixReg:$z)>;

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

def: Pat<(int_kvx_xstore256 v256i1:$op0, (add i64:$mem, (shl i64:$off, (i32 5)))),
         (XSOrr SingleReg:$off, SingleReg:$mem, VectorReg:$op0, scaling_xs)>;

def: Pat<(int_kvx_xstore256 v256i1:$op0, (add i64:$mem, i64:$off)),
         (XSOrr SingleReg:$off, SingleReg:$mem, VectorReg:$op0, scaling_)>;

def: Pat<(int_kvx_dpurgel i64:$mem),
         (DPURGELri10 0, SingleReg:$mem)>;

def: Pat<(int_kvx_dpurgel (add i64:$mem, i64:$off)),
         (DPURGELrr SingleReg:$off, SingleReg:$mem, scaling_)>;

def: Pat<(int_kvx_dpurgel (add i64:$mem, (shl i64:$off, (i32 6)))),
         (DPURGELrr SingleReg:$off, SingleReg:$mem, scaling_xs)>;

def: Pat<(int_kvx_dflushl i64:$mem),
         (DFLUSHLri10 0, SingleReg:$mem)>;

def: Pat<(int_kvx_dflushl (add i64:$mem, i64:$off)),
         (DFLUSHLrr SingleReg:$off, SingleReg:$mem, scaling_)>;

def: Pat<(int_kvx_dflushl (add i64:$mem, (shl i64:$off, (i32 6)))),
         (DFLUSHLrr SingleReg:$off, SingleReg:$mem, scaling_xs)>;

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

def : Pat <(int_kvx_xloadbuff1024 i64:$mem, i64:$op0, v1024i1:$z, VariantMod:$mod0, LsupackMod:$mod1),
           (v1024i1(XLOrvp i64:$mem, i64:$op0, VariantMod:$mod0, LsupackMod:$mod1, v1024i1:$z))>;

def : Pat <(int_kvx_xloadbuff1024 (add i64:$mem, Signed27:$off), i64:$op0, v1024i1:$z, VariantMod:$mod0, LsupackMod:$mod1),
           (v1024i1(XLOri27vp Signed27:$off, i64:$mem, i64:$op0, VariantMod:$mod0, LsupackMod:$mod1, v1024i1:$z))>;

def : Pat <(int_kvx_xloadbuff1024 (add i64:$mem, Signed54:$off), i64:$op0, v1024i1:$z, VariantMod:$mod0, LsupackMod:$mod1),
           (v1024i1(XLOri54vp Signed54:$off, i64:$mem, i64:$op0, VariantMod:$mod0, LsupackMod:$mod1, v1024i1:$z))>;
