def: Pat<(int_kvx_await), (AWAIT)>;
def: Pat<(int_kvx_barrier), (BARRIER)>;
def: Pat<(int_kvx_dinval), (DINVAL)>;
def: Pat<(int_kvx_errop), (ERROP)>;
def: Pat<(int_kvx_fence), (FENCE)>;
def: Pat<(int_kvx_iinval), (IINVAL)>;
def: Pat<(int_kvx_sleep), (SLEEP)>;
def: Pat<(int_kvx_stop), (STOP)>;
def: Pat<(int_kvx_tlbdinval), (TLBDINVAL)>;
def: Pat<(int_kvx_tlbiinval), (TLBIINVAL)>;
def: Pat<(int_kvx_tlbprobe), (TLBPROBE)>;
def: Pat<(int_kvx_tlbread), (TLBREAD)>;
def: Pat<(int_kvx_tlbwrite), (TLBWRITE)>;

def GETp : KVX_PSEUDO_W_SCHEDINFO<(outs SingleReg:$dst), (ins Sysnumber:$param), [], BCU>;

let Constraints = "$vIn = $vOut, $qIn = $qOut" in
def SWAPVOp : KVX_PSEUDO_W_SCHEDINFO<(outs QuadReg:$qOut, VectorReg:$vOut), (ins QuadReg:$qIn, VectorReg:$vIn),[], SWAPVO>;

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

def: Pat<(int_kvx_get Sysnumber:$r), (GETp Sysnumber:$r)>;

def: Pat<(int_kvx_syncgroup SingleReg:$r), (SYNCGROUP SingleReg:$r)>;
def: Pat<(int_kvx_waitit i64:$r), (WAITIT SingleReg:$r)>;

def: Pat<(int_kvx_dinvall AddrRR:$addr), (DINVALLp AddrRR:$addr)>;
def: Pat<(int_kvx_dtouchl AddrRR:$addr), (DTOUCHLp AddrRR:$addr)>;
def: Pat<(int_kvx_dzerol AddrRR:$addr), (DZEROLp AddrRR:$addr)>;
def: Pat<(int_kvx_iinvals AddrRR:$addr), (IINVALSp AddrRR:$addr)>;

// remove unecessary sign extension
def: Pat<(int_kvx_sbmm8 (sext_inreg i64:$v, i16), (i64 0x0201020102010201)), (SBMM8ri64 SingleReg:$v, (i64 0x0201020102010201))>;
def: Pat<(int_kvx_sbmm8 (and i64:$v, 0xffff), (i64 0x0201020102010201)), (SBMM8ri64 SingleReg:$v, (i64 0x0201020102010201))>;
def: Pat<(int_kvx_sbmm8 (i64 (sext i32:$v)), (i64 0x0804020108040201)), (SBMM8ri64 SingleReg:$v, (i64 0x0804020108040201))>;
def: Pat<(int_kvx_sbmm8 (i64 (zext i32:$v)), (i64 0x0804020108040201)), (SBMM8ri64 SingleReg:$v, (i64 0x0804020108040201))>;

def: Pat<(int_kvx_sbmm8 SingleReg:$r, Signed10:$r2), (SBMM8ri10 SingleReg:$r, Signed10:$r2)>;
def: Pat<(int_kvx_sbmm8 SingleReg:$r, Signed37:$r2), (SBMM8ri37 SingleReg:$r, Signed37:$r2)>;
def: Pat<(int_kvx_sbmm8 SingleReg:$r, Wrapped64:$r2), (SBMM8ri64 SingleReg:$r, Wrapped64:$r2)>;
def: Pat<(int_kvx_sbmm8 SingleReg:$r, SingleReg:$r2), (SBMM8rr SingleReg:$r, SingleReg:$r2)>;

def: Pat<(int_kvx_sbmmt8 SingleReg:$r, Signed10:$r2), (SBMMT8ri10 SingleReg:$r, Signed10:$r2)>;
def: Pat<(int_kvx_sbmmt8 SingleReg:$r, Signed37:$r2), (SBMMT8ri37 SingleReg:$r, Signed37:$r2)>;
def: Pat<(int_kvx_sbmmt8 SingleReg:$r, Wrapped64:$r2), (SBMMT8ri64 SingleReg:$r, Wrapped64:$r2)>;
def: Pat<(int_kvx_sbmmt8 SingleReg:$r, SingleReg:$r2), (SBMMT8rr SingleReg:$r, SingleReg:$r2)>;

def: Pat<(int_kvx_acswapw i64:$addr, i32:$update, i32:$expect), (i32 (EXTRACT_SUBREG
  (v2i64 (ACSWAPWri10 (i64 0), SingleReg:$addr, (INSERT_SUBREG (INSERT_SUBREG (v2i64 (IMPLICIT_DEF)),
    SingleReg:$update, sub_s0), SingleReg:$expect, sub_s1))), sub_s0))>;

def: Pat<(int_kvx_acswapd i64:$addr, i64:$update, i64:$expect), (i64 (EXTRACT_SUBREG
  (v2i64 (ACSWAPDri10 (i64 0), SingleReg:$addr, (INSERT_SUBREG (INSERT_SUBREG (v2i64 (IMPLICIT_DEF)),
    SingleReg:$update, sub_s0), SingleReg:$expect, sub_s1))), sub_s0))>;

def: Pat<(int_kvx_alclrw i64:$addr), (ALCLRWri10 (i64 0), SingleReg:$addr)>;
def: Pat<(int_kvx_alclrd i64:$addr), (ALCLRDri10 (i64 0), SingleReg:$addr)>;

def: Pat<(int_kvx_fabswp v2f32:$r), (FABSWP SingleReg:$r)>;
def: Pat<(int_kvx_fnegwp v2f32:$r), (FNEGWP SingleReg:$r)>;

def: Pat<(int_kvx_fmaxwp v2f32:$v1, v2f32:$v2), (FMAXWP SingleReg:$v1, SingleReg:$v2)>;
def: Pat<(int_kvx_fminwp v2f32:$v1, v2f32:$v2), (FMINWP SingleReg:$v1, SingleReg:$v2)>;

def: Pat<(int_kvx_faddwp v2f32:$v1, v2f32:$v2, i32:$conjugate, i32:$rounding, i32:$silent),
          (FADDWPrr SingleReg:$v1, SingleReg:$v2, ConjugateMod:$conjugate, RoundingMod:$rounding, SilentMod:$silent)>;
def: Pat<(int_kvx_faddwq v4f32:$v1, v4f32:$v2, i32:$conjugate, i32:$rounding, i32:$silent),
          (FADDWQ PairedReg:$v1, PairedReg:$v2, ConjugateMod:$conjugate, RoundingMod:$rounding, SilentMod:$silent)>;
def: Pat<(int_kvx_fadddp v2f64:$v1, v2f64:$v2, i32:$conjugate, i32:$rounding, i32:$silent),
          (FADDDP PairedReg:$v1, PairedReg:$v2, ConjugateMod:$conjugate, RoundingMod:$rounding, SilentMod:$silent)>;

def: Pat<(int_kvx_fsbfwp v2f32:$v1, v2f32:$v2, i32:$conjugate, i32:$rounding, i32:$silent),
          (FSBFWPrr SingleReg:$v1, SingleReg:$v2, ConjugateMod:$conjugate, RoundingMod:$rounding, SilentMod:$silent)>;
def: Pat<(int_kvx_fsbfwq v4f32:$v1, v4f32:$v2, i32:$conjugate, i32:$rounding, i32:$silent),
          (FSBFWQ PairedReg:$v1, PairedReg:$v2, ConjugateMod:$conjugate, RoundingMod:$rounding, SilentMod:$silent)>;
def: Pat<(int_kvx_fsbfdp v2f64:$v1, v2f64:$v2, i32:$conjugate, i32:$rounding, i32:$silent),
          (FSBFDP PairedReg:$v1, PairedReg:$v2, ConjugateMod:$conjugate, RoundingMod:$rounding, SilentMod:$silent)>;

def: Pat<(int_kvx_fmulwp v2f32:$v1, v2f32:$v2, i32:$rounding, i32:$silent), (FMULWPrr SingleReg:$v1, SingleReg:$v2, RoundingMod:$rounding, SilentMod:$silent)>;
def: Pat<(int_kvx_fmulwq v4f32:$v1, v4f32:$v2, i32:$rounding, i32:$silent), (FMULWQ PairedReg:$v1, PairedReg:$v2, RoundingMod:$rounding, SilentMod:$silent)>;

def: Pat<(int_kvx_fmuldp v2f64:$v1, v2f64:$v2, i32:$rounding, i32:$silent),
  (v2f64 (REG_SEQUENCE PairedReg,
    (FMULDrr (f64 (EXTRACT_SUBREG PairedReg:$v1, sub_s0)), (f64 (EXTRACT_SUBREG PairedReg:$v2, sub_s0)), RoundingMod:$rounding, SilentMod:$silent), sub_s0,
    (FMULDrr (f64 (EXTRACT_SUBREG PairedReg:$v1, sub_s1)), (f64 (EXTRACT_SUBREG PairedReg:$v2, sub_s1)), RoundingMod:$rounding, SilentMod:$silent), sub_s1))>;

multiclass FFM___<Intrinsic Int, KVX_INSTRUCTION Opcode, ValueType OperandTy, ValueType DataTy> {
  def: Pat<(Int OperandTy:$v1, OperandTy:$v2, OperandTy:$v3, i32:$rounding, i32:$silent),
    (OperandTy (REG_SEQUENCE PairedReg,
      (Opcode (DataTy (EXTRACT_SUBREG PairedReg:$v3, sub_s0)),
              (DataTy (EXTRACT_SUBREG PairedReg:$v1, sub_s0)),
              (DataTy (EXTRACT_SUBREG PairedReg:$v2, sub_s0)), RoundingMod:$rounding, SilentMod:$silent), sub_s0,
      (Opcode (DataTy (EXTRACT_SUBREG PairedReg:$v3, sub_s1)),
              (DataTy (EXTRACT_SUBREG PairedReg:$v1, sub_s1)),
              (DataTy (EXTRACT_SUBREG PairedReg:$v2, sub_s1)), RoundingMod:$rounding, SilentMod:$silent), sub_s1))>;
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
              (v2f32 (EXTRACT_SUBREG PairedReg:$v0, sub_s0)),
              (v2f32 (EXTRACT_SUBREG PairedReg:$v1, sub_s0)), RoundingMod:$rounding, SilentMod:$silent),
            (v2f32 (EXTRACT_SUBREG PairedReg:$v0, sub_s1)),
            (v2f32 (EXTRACT_SUBREG PairedReg:$v1, sub_s1)),
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
     (FMULWCrr (v2f32 (EXTRACT_SUBREG PairedReg:$v1, sub_s0)),
               (v2f32 (EXTRACT_SUBREG PairedReg:$v2, sub_s0)), ConjugateMod:$conjugate, RoundingMod:$rounding, SilentMod:$silent), sub_s0,
     (FMULWCrr (v2f32 (EXTRACT_SUBREG PairedReg:$v1, sub_s1)),
               (v2f32 (EXTRACT_SUBREG PairedReg:$v2, sub_s1)), ConjugateMod:$conjugate, RoundingMod:$rounding, SilentMod:$silent), sub_s1))>;

multiclass FMUL_DC<Intrinsic int_kvx_fmul, KVX_INSTRUCTION FFMS, KVX_INSTRUCTION FFMA> {
  def: Pat<(int_kvx_fmul v2f64:$v1, v2f64:$v2, i32:$rounding, i32:$silent),
    (v2f64 (REG_SEQUENCE PairedReg,
      (FFMS (FMULDrr (f64 (EXTRACT_SUBREG PairedReg:$v1, sub_s0)), (f64 (EXTRACT_SUBREG PairedReg:$v2, sub_s0)), RoundingMod:$rounding, SilentMod:$silent),
            (f64 (EXTRACT_SUBREG PairedReg:$v1, sub_s1)),
            (f64 (EXTRACT_SUBREG PairedReg:$v2, sub_s1)), RoundingMod:$rounding, SilentMod:$silent), sub_s0,
      (FFMA (FMULDrr (f64 (EXTRACT_SUBREG PairedReg:$v1, sub_s0)), (f64 (EXTRACT_SUBREG PairedReg:$v2, sub_s1)), RoundingMod:$rounding, SilentMod:$silent),
            (f64 (EXTRACT_SUBREG PairedReg:$v1, sub_s1)),
            (f64 (EXTRACT_SUBREG PairedReg:$v2, sub_s0)), RoundingMod:$rounding, SilentMod:$silent), sub_s1))>;
}

defm: FMUL_DC<int_kvx_fmuldc, FFMSDrr, FFMADrr>;
defm: FMUL_DC<int_kvx_fmulcdc, FFMADrr, FFMSDrr>;

multiclass FFM__DC<Intrinsic int_kvx_ffmop, KVX_INSTRUCTION FOP, KVX_INSTRUCTION FFMS, KVX_INSTRUCTION FFMA> {
  def: Pat<(int_kvx_ffmop v2f64:$v1, v2f64:$v2, v2f64:$v3, i32:$rounding, i32:$silent),
    (FOP
      (v2f64 (REG_SEQUENCE PairedReg,
        (FFMS (FMULDrr (f64 (EXTRACT_SUBREG PairedReg:$v1, sub_s0)), (f64 (EXTRACT_SUBREG PairedReg:$v2, sub_s0)), RoundingMod:$rounding, SilentMod:$silent),
              (f64 (EXTRACT_SUBREG PairedReg:$v1, sub_s1)),
              (f64 (EXTRACT_SUBREG PairedReg:$v2, sub_s1)), RoundingMod:$rounding, SilentMod:$silent), sub_s0,
        (FFMA (FMULDrr (f64 (EXTRACT_SUBREG PairedReg:$v1, sub_s1)), (f64 (EXTRACT_SUBREG PairedReg:$v2, sub_s0)), RoundingMod:$rounding, SilentMod:$silent),
              (f64 (EXTRACT_SUBREG PairedReg:$v1, sub_s0)),
              (f64 (EXTRACT_SUBREG PairedReg:$v2, sub_s1)), RoundingMod:$rounding, SilentMod:$silent), sub_s1)),
      PairedReg:$v3, conjugate_, RoundingMod:$rounding, SilentMod:$silent)>;
}

multiclass FFM__CDC<Intrinsic int_kvx_ffmop, KVX_INSTRUCTION FOP, KVX_INSTRUCTION FFMS, KVX_INSTRUCTION FFMA> {
  def: Pat<(int_kvx_ffmop v2f64:$v1, v2f64:$v2, v2f64:$v3, i32:$rounding, i32:$silent),
    (FOP
      (v2f64 (REG_SEQUENCE PairedReg,
        (FFMS (FMULDrr (f64 (EXTRACT_SUBREG PairedReg:$v1, sub_s0)), (f64 (EXTRACT_SUBREG PairedReg:$v2, sub_s0)), RoundingMod:$rounding, SilentMod:$silent),
              (f64 (EXTRACT_SUBREG PairedReg:$v1, sub_s1)),
              (f64 (EXTRACT_SUBREG PairedReg:$v2, sub_s1)), RoundingMod:$rounding, SilentMod:$silent), sub_s0,
        (FFMA (FMULDrr (f64 (EXTRACT_SUBREG PairedReg:$v1, sub_s1)), (f64 (EXTRACT_SUBREG PairedReg:$v2, sub_s0)), RoundingMod:$rounding, SilentMod:$silent),
              (f64 (EXTRACT_SUBREG PairedReg:$v1, sub_s0)),
              (f64 (EXTRACT_SUBREG PairedReg:$v2, sub_s1)), RoundingMod:$rounding, SilentMod:$silent), sub_s1)),
      PairedReg:$v3, conjugate_c, RoundingMod:$rounding, SilentMod:$silent)>;
}

defm: FFM__DC<int_kvx_ffmadc, FADDDP, FFMSDrr, FFMADrr>;
defm: FFM__DC<int_kvx_ffmsdc, FSBFDP, FFMSDrr, FFMADrr>;
defm: FFM__CDC<int_kvx_ffmacdc, FADDDP, FFMADrr, FFMSDrr>;
defm: FFM__CDC<int_kvx_ffmscdc, FSBFDP, FFMADrr, FFMSDrr>;

multiclass FFM__WC<Intrinsic int_kvx_fop, KVX_INSTRUCTION FOP, KVX_INSTRUCTION FMUL> {
  def: Pat<(int_kvx_fop v2f32:$v1, v2f32:$v2, v2f32:$v3, i32:$conjugate, i32:$rounding, i32:$silent),
    (FOP (FMUL SingleReg:$v2, SingleReg:$v1, ConjugateMod:$conjugate, RoundingMod:$rounding, SilentMod:$silent),
         SingleReg:$v3, ConjugateMod:$conjugate, RoundingMod:$rounding, SilentMod:$silent)>;
}

defm: FFM__WC<int_kvx_ffmawc, FADDWPrr, FMULWCrr>;
defm: FFM__WC<int_kvx_ffmswc, FSBFWPrr, FMULWCrr>;

multiclass FFM__WCP<Intrinsic int_kvx_fop, KVX_INSTRUCTION FOP, KVX_INSTRUCTION FMUL> {
  def: Pat<(int_kvx_fop v4f32:$v1, v4f32:$v2, v4f32:$v3, i32:$conjugate, i32:$rounding, i32:$silent),
    (v4f32 (REG_SEQUENCE PairedReg,
       (FOP (FMUL (v2f32 (EXTRACT_SUBREG PairedReg:$v2, sub_s0)),
                  (v2f32 (EXTRACT_SUBREG PairedReg:$v1, sub_s0)), ConjugateMod:$conjugate, RoundingMod:$rounding, SilentMod:$silent),
            (v2f32 (EXTRACT_SUBREG PairedReg:$v3, sub_s0)), ConjugateMod:$conjugate, RoundingMod:$rounding, SilentMod:$silent), sub_s0,
       (FOP (FMUL (v2f32 (EXTRACT_SUBREG PairedReg:$v2, sub_s1)),
                  (v2f32 (EXTRACT_SUBREG PairedReg:$v1, sub_s1)), ConjugateMod:$conjugate, RoundingMod:$rounding, SilentMod:$silent),
            (v2f32 (EXTRACT_SUBREG PairedReg:$v3, sub_s1)), ConjugateMod:$conjugate, RoundingMod:$rounding, SilentMod:$silent), sub_s1))>;
}

defm: FFM__WCP<int_kvx_ffmawcp, FADDWPrr, FMULWCrr>;
defm: FFM__WCP<int_kvx_ffmswcp, FSBFWPrr, FMULWCrr>;

def: Pat<(int_kvx_fconjwc v2f32:$v), (FNEGD SingleReg:$v)>;
def: Pat<(int_kvx_fconjwcp v4f32:$v),
  (v4f32 (REG_SEQUENCE PairedReg,
    (FNEGD (v2f32 (EXTRACT_SUBREG PairedReg:$v, sub_s0))), sub_s0,
    (FNEGD (v2f32 (EXTRACT_SUBREG PairedReg:$v, sub_s1))), sub_s1))>;
def: Pat<(int_kvx_fconjdc v2f64:$v),
  (v2f64 (REG_SEQUENCE PairedReg,
    (f64 (EXTRACT_SUBREG PairedReg:$v, sub_s0)), sub_s0,
    (FNEGD (f64 (EXTRACT_SUBREG PairedReg:$v, sub_s1))), sub_s1))>;

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
def: Pat<(int_kvx_stsuw i32:$x, i32:$y), (STSUW SingleReg:$x, SingleReg:$y)>;
def: Pat<(int_kvx_stsud i64:$x, i64:$y), (STSUD SingleReg:$x, SingleReg:$y)>;

def: Pat<(int_kvx_aladdd i64:$addr, i64:$val), (ALADDDri10 (i64 0), SingleReg:$addr, SingleReg:$val)>;
def: Pat<(int_kvx_aladdd AddrFI:$addr, i64:$val), (ALADDDri64 (i64 0), SingleReg:$addr, SingleReg:$val)>;
def: Pat<(int_kvx_aladdw i64:$addr, i32:$val), (ALADDWri10 (i64 0), SingleReg:$addr, SingleReg:$val)>;
def: Pat<(int_kvx_aladdw AddrFI:$addr, i32:$val), (ALADDWri64 (i64 0), SingleReg:$addr, SingleReg:$val)>;

def: Pat<(int_kvx_abdw i32:$v1, i32:$v2), (ABDWrr SingleReg:$v1, SingleReg:$v2)>;
def: Pat<(int_kvx_abdwp v2i32:$v1, v2i32:$v2), (ABDWPrr SingleReg:$v1, SingleReg:$v2)>;
def: Pat<(int_kvx_abdhq v4i16:$v1, v4i16:$v2), (ABDHQrr SingleReg:$v1, SingleReg:$v2)>;
def: Pat<(int_kvx_abdd i64:$v1, i64:$v2), (ABDDrr SingleReg:$v1, SingleReg:$v2)>;
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

def: Pat<(int_kvx_fabsw f32:$v), (FABSW SingleReg:$v)>;
def: Pat<(int_kvx_fabsd f64:$v), (FABSD SingleReg:$v)>;
def: Pat<(int_kvx_fnegw f32:$v), (FNEGW SingleReg:$v)>;
def: Pat<(int_kvx_fnegd f64:$v), (FNEGD SingleReg:$v)>;
def: Pat<(int_kvx_fmaxw f32:$v1, f32:$v2), (FMAXW SingleReg:$v1, SingleReg:$v2)>;
def: Pat<(int_kvx_fmaxd f64:$v1, f64:$v2), (FMAXD SingleReg:$v1, SingleReg:$v2)>;
def: Pat<(int_kvx_fminw f32:$v1, f32:$v2), (FMINW SingleReg:$v1, SingleReg:$v2)>;
def: Pat<(int_kvx_fmind f64:$v1, f64:$v2), (FMIND SingleReg:$v1, SingleReg:$v2)>;
def: Pat<(int_kvx_frecw f32:$f, i32:$rounding, i32:$silent), (FRECW SingleReg:$f, RoundingMod:$rounding, SilentMod:$silent)>;
def: Pat<(int_kvx_frsrw f32:$f, i32:$rounding, i32:$silent), (FRSRW SingleReg:$f, RoundingMod:$rounding, SilentMod:$silent)>;
def: Pat<(int_kvx_faddw f32:$v1, f32:$v2, i32:$rounding, i32:$silent), (FADDWrr SingleReg:$v1, SingleReg:$v2, RoundingMod:$rounding, SilentMod:$silent)>;
def: Pat<(int_kvx_faddd f64:$v1, f64:$v2, i32:$rounding, i32:$silent), (FADDDrr SingleReg:$v1, SingleReg:$v2, RoundingMod:$rounding, SilentMod:$silent)>;
def: Pat<(int_kvx_fsbfw f32:$v1, f32:$v2, i32:$rounding, i32:$silent), (FSBFWrr SingleReg:$v1, SingleReg:$v2, RoundingMod:$rounding, SilentMod:$silent)>;
def: Pat<(int_kvx_fsbfd f64:$v1, f64:$v2, i32:$rounding, i32:$silent), (FSBFDrr SingleReg:$v1, SingleReg:$v2, RoundingMod:$rounding, SilentMod:$silent)>;
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
    SingleReg:$v1, sub_s0), SingleReg:$v2, sub_s1), SilentMod:$silent)>;
def: Pat<(int_kvx_fcdivd f64:$v1, f64:$v2, i32:$silent), (FCDIVD (INSERT_SUBREG (INSERT_SUBREG (v2i64 (IMPLICIT_DEF)),
    SingleReg:$v1, sub_s0), SingleReg:$v2, sub_s1), SilentMod:$silent)>;
def: Pat<(int_kvx_fsdivw f32:$v1, f32:$v2, i32:$silent), (FSDIVW (INSERT_SUBREG (INSERT_SUBREG (v2i64 (IMPLICIT_DEF)),
    SingleReg:$v1, sub_s0), SingleReg:$v2, sub_s1), SilentMod:$silent)>;
def: Pat<(int_kvx_fsdivd f64:$v1, f64:$v2, i32:$silent), (FSDIVD (INSERT_SUBREG (INSERT_SUBREG (v2i64 (IMPLICIT_DEF)),
    SingleReg:$v1, sub_s0), SingleReg:$v2, sub_s1), SilentMod:$silent)>;
def: Pat<(int_kvx_fsrecw f32:$v, i32:$silent), (FSRECW SingleReg:$v, SilentMod:$silent)>;
def: Pat<(int_kvx_fsrecd f64:$v, i32:$silent), (FSRECD SingleReg:$v, SilentMod:$silent)>;
def: Pat<(int_kvx_fsrsrw f32:$v), (FSRSRW SingleReg:$v)>;
def: Pat<(int_kvx_fsrsrd f64:$v), (FSRSRD SingleReg:$v)>;

def: Pat<(int_kvx_maxhq v4i16:$v1, v4i16:$v2), (MAXHQrr SingleReg:$v1, SingleReg:$v2)>;
def: Pat<(int_kvx_maxw i32:$v1, i32:$v2), (MAXWrr SingleReg:$v1, SingleReg:$v2)>;
def: Pat<(int_kvx_maxw i32:$v1, Signed10W:$v2), (MAXWri10 SingleReg:$v1, Signed10W:$v2)>;
def: Pat<(int_kvx_maxw i32:$v1, Signed37W:$v2), (MAXWri10 SingleReg:$v1, Signed37W:$v2)>;
def: Pat<(int_kvx_maxwp v2i32:$v1, v2i32:$v2), (MAXWPrr SingleReg:$v1, SingleReg:$v2)>;
def: Pat<(int_kvx_maxd i64:$v1, i64:$v2) ,(MAXDrr SingleReg:$v1, SingleReg:$v2)>;
def: Pat<(int_kvx_maxd i64:$v1, Signed10:$v2) ,(MAXDri10 SingleReg:$v1, Signed10:$v2)>;
def: Pat<(int_kvx_maxd i64:$v1, Signed37:$v2) ,(MAXDri37 SingleReg:$v1, Signed37:$v2)>;
def: Pat<(int_kvx_maxd i64:$v1, Wrapped64:$v2) ,(MAXDri64 SingleReg:$v1, Wrapped64:$v2)>;

def: Pat<(int_kvx_minhq v4i16:$v1, v4i16:$v2), (MINHQrr SingleReg:$v1, SingleReg:$v2)>;
def: Pat<(int_kvx_minw i32:$v1, i32:$v2), (MINWrr SingleReg:$v1, SingleReg:$v2)>;
def: Pat<(int_kvx_minw i32:$v1, Signed10W:$v2), (MINWri10 SingleReg:$v1, Signed10W:$v2)>;
def: Pat<(int_kvx_minw i32:$v1, Signed37W:$v2), (MINWri10 SingleReg:$v1, Signed37W:$v2)>;
def: Pat<(int_kvx_minwp v2i32:$v1, v2i32:$v2), (MINWPrr SingleReg:$v1, SingleReg:$v2)>;
def: Pat<(int_kvx_mind i64:$v1, i64:$v2) ,(MINDrr SingleReg:$v1, SingleReg:$v2)>;
def: Pat<(int_kvx_mind i64:$v1, Signed10:$v2) ,(MINDri10 SingleReg:$v1, Signed10:$v2)>;
def: Pat<(int_kvx_mind i64:$v1, Signed37:$v2) ,(MINDri37 SingleReg:$v1, Signed37:$v2)>;
def: Pat<(int_kvx_mind i64:$v1, Wrapped64:$v2) ,(MINDri64 SingleReg:$v1, Wrapped64:$v2)>;

def: Pat<(int_kvx_maxuhq v4i16:$v1, v4i16:$v2), (MAXUHQrr SingleReg:$v1, SingleReg:$v2)>;
def: Pat<(int_kvx_maxuw i32:$v1, i32:$v2), (MAXUWrr SingleReg:$v1, SingleReg:$v2)>;
def: Pat<(int_kvx_maxuw i32:$v1, Signed10W:$v2), (MAXUWri10 SingleReg:$v1, Signed10W:$v2)>;
def: Pat<(int_kvx_maxuw i32:$v1, Signed37W:$v2), (MAXUWri10 SingleReg:$v1, Signed37W:$v2)>;
def: Pat<(int_kvx_maxuwp v2i32:$v1, v2i32:$v2), (MAXUWPrr SingleReg:$v1, SingleReg:$v2)>;
def: Pat<(int_kvx_maxud i64:$v1, i64:$v2) ,(MAXUDrr SingleReg:$v1, SingleReg:$v2)>;
def: Pat<(int_kvx_maxud i64:$v1, Signed10:$v2) ,(MAXUDri10 SingleReg:$v1, Signed10:$v2)>;
def: Pat<(int_kvx_maxud i64:$v1, Signed37:$v2) ,(MAXUDri37 SingleReg:$v1, Signed37:$v2)>;
def: Pat<(int_kvx_maxud i64:$v1, Wrapped64:$v2) ,(MAXUDri64 SingleReg:$v1, Wrapped64:$v2)>;

def: Pat<(int_kvx_minuhq v4i16:$v1, v4i16:$v2), (MINUHQrr SingleReg:$v1, SingleReg:$v2)>;
def: Pat<(int_kvx_minuw i32:$v1, i32:$v2), (MINUWrr SingleReg:$v1, SingleReg:$v2)>;
def: Pat<(int_kvx_minuw i32:$v1, Signed10W:$v2), (MINUWri10 SingleReg:$v1, Signed10W:$v2)>;
def: Pat<(int_kvx_minuw i32:$v1, Signed37W:$v2), (MINUWri10 SingleReg:$v1, Signed37W:$v2)>;
def: Pat<(int_kvx_minuwp v2i32:$v1, v2i32:$v2), (MINUWPrr SingleReg:$v1, SingleReg:$v2)>;
def: Pat<(int_kvx_minud i64:$v1, i64:$v2) ,(MINUDrr SingleReg:$v1, SingleReg:$v2)>;
def: Pat<(int_kvx_minud i64:$v1, Signed10:$v2) ,(MINUDri10 SingleReg:$v1, Signed10:$v2)>;
def: Pat<(int_kvx_minud i64:$v1, Signed37:$v2) ,(MINUDri37 SingleReg:$v1, Signed37:$v2)>;
def: Pat<(int_kvx_minud i64:$v1, Wrapped64:$v2) ,(MINUDri64 SingleReg:$v1, Wrapped64:$v2)>;

def: Pat<(int_kvx_slld i64:$v, i64:$s), (SLLDrr SingleReg:$v, SingleReg:$s)>;
def: Pat<(int_kvx_slld i64:$v, Unsigned6:$s), (SLLDri SingleReg:$v, Unsigned6:$s)>;
def: Pat<(int_kvx_sllhqs v4i16:$v, i64:$s), (SLLHQSrr SingleReg:$v, SingleReg:$s)>;
def: Pat<(int_kvx_sllhqs v4i16:$v, Unsigned6:$s), (SLLHQSri SingleReg:$v, Unsigned6:$s)>;
def: Pat<(int_kvx_sllwps v2i32:$v, i64:$s), (SLLWPSrr SingleReg:$v, SingleReg:$s)>;
def: Pat<(int_kvx_sllwps v2i32:$v, Unsigned6:$s), (SLLWPSri SingleReg:$v, Unsigned6:$s)>;

def: Pat<(int_kvx_slsd i64:$v, i64:$s), (SLSDrr SingleReg:$v, SingleReg:$s)>;
def: Pat<(int_kvx_slsd i64:$v, Unsigned6:$s), (SLSDri SingleReg:$v, Unsigned6:$s)>;
def: Pat<(int_kvx_slshqs v4i16:$v, i64:$s), (SLSHQSrr SingleReg:$v, SingleReg:$s)>;
def: Pat<(int_kvx_slshqs v4i16:$v, Unsigned6:$s), (SLSHQSri SingleReg:$v, Unsigned6:$s)>;
def: Pat<(int_kvx_slswps v2i32:$v, i64:$s), (SLSWPSrr SingleReg:$v, SingleReg:$s)>;
def: Pat<(int_kvx_slswps v2i32:$v, Unsigned6:$s), (SLSWPSri SingleReg:$v, Unsigned6:$s)>;

def: Pat<(int_kvx_srad i64:$v, i64:$s), (SRADrr SingleReg:$v, SingleReg:$s)>;
def: Pat<(int_kvx_srad i64:$v, Unsigned6:$s), (SRADri SingleReg:$v, Unsigned6:$s)>;
def: Pat<(int_kvx_srahqs v4i16:$v, i64:$s), (SRAHQSrr SingleReg:$v, SingleReg:$s)>;
def: Pat<(int_kvx_srahqs v4i16:$v, Unsigned6:$s), (SRAHQSri SingleReg:$v, Unsigned6:$s)>;
def: Pat<(int_kvx_srawps v2i32:$v, i64:$s), (SRAWPSrr SingleReg:$v, SingleReg:$s)>;
def: Pat<(int_kvx_srawps v2i32:$v, Unsigned6:$s), (SRAWPSri SingleReg:$v, Unsigned6:$s)>;

def: Pat<(int_kvx_srld i64:$v, i64:$s), (SRLDrr SingleReg:$v, SingleReg:$s)>;
def: Pat<(int_kvx_srld i64:$v, Unsigned6:$s), (SRLDri SingleReg:$v, Unsigned6:$s)>;
def: Pat<(int_kvx_srlhqs v4i16:$v, i64:$s), (SRLHQSrr SingleReg:$v, SingleReg:$s)>;
def: Pat<(int_kvx_srlhqs v4i16:$v, Unsigned6:$s), (SRLHQSri SingleReg:$v, Unsigned6:$s)>;
def: Pat<(int_kvx_srlwps v2i32:$v, i64:$s), (SRLWPSrr SingleReg:$v, SingleReg:$s)>;
def: Pat<(int_kvx_srlwps v2i32:$v, Unsigned6:$s), (SRLWPSri SingleReg:$v, Unsigned6:$s)>;

def: Pat<(int_kvx_srsd i64:$v, i64:$s), (SRSDrr SingleReg:$v, SingleReg:$s)>;
def: Pat<(int_kvx_srsd i64:$v, Unsigned6:$s), (SRSDri SingleReg:$v, Unsigned6:$s)>;
def: Pat<(int_kvx_srshqs v4i16:$v, i64:$s), (SRSHQSrr SingleReg:$v, SingleReg:$s)>;
def: Pat<(int_kvx_srshqs v4i16:$v, Unsigned6:$s), (SRSHQSri SingleReg:$v, Unsigned6:$s)>;
def: Pat<(int_kvx_srswps v2i32:$v, i64:$s), (SRSWPSrr SingleReg:$v, SingleReg:$s)>;
def: Pat<(int_kvx_srswps v2i32:$v, Unsigned6:$s), (SRSWPSri SingleReg:$v, Unsigned6:$s)>;

def: Pat<(int_kvx_cmovehq v4i16:$v1, v4i16:$v2, v4i16:$c, i32:$sc), (CMOVEHQ SingleReg:$c, SingleReg:$v1, SingleReg:$v2, SimplecondMod: $sc)>;
def: Pat<(int_kvx_cmovewp v2i32:$v1, v2i32:$v2, v2i32:$c, i32:$sc), (CMOVEWP SingleReg:$c, SingleReg:$v1, SingleReg:$v2, SimplecondMod: $sc)>;
def: Pat<(int_kvx_cmoved i64:$v1, Signed10:$v2, i64:$c, i32:$sc), (CMOVEDri10 SingleReg:$c, SingleReg:$v1, Signed10:$v2, ScalarcondMod: $sc)>;
def: Pat<(int_kvx_cmoved i64:$v1, Signed37:$v2, i64:$c, i32:$sc), (CMOVEDri37 SingleReg:$c, SingleReg:$v1, Signed37:$v2, ScalarcondMod: $sc)>;
def: Pat<(int_kvx_cmoved i64:$v1, Wrapped64:$v2, i64:$c, i32:$sc), (CMOVEDri37 SingleReg:$c, SingleReg:$v1, Wrapped64:$v2, ScalarcondMod: $sc)>;
def: Pat<(int_kvx_cmoved i64:$v1, i64:$v2, i64:$c, i32:$sc), (CMOVEDrr SingleReg:$c, SingleReg:$v1, SingleReg:$v2, ScalarcondMod: $sc)>;

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
         (FMULHQrr SingleReg:$f1, SingleReg:$f2, RoundingMod:$rounding, 1)>;
def: Pat<(int_kvx_fmulhq (build_vector f16:$f1, (f16 undef), (f16 undef), (f16 undef)),
                         (build_vector f16:$f2, (f16 undef), (f16 undef), (f16 undef)), i32:$rounding, (i32 0)),
         (FMULHQrr (ZXHD SingleReg:$f1), (ZXHD SingleReg:$f2), RoundingMod:$rounding, 0)>;

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
  (v4f16 (FFMAHQrr SingleReg:$f1, SingleReg:$f2, SingleReg:$f3, RoundingMod:$rounding, 1))>;
def: Pat<(int_kvx_ffmahq (build_vector f16:$f1, (f16 undef), (f16 undef), (f16 undef)),
                         (build_vector f16:$f2, (f16 undef), (f16 undef), (f16 undef)),
                         (build_vector f16:$f3, (f16 undef), (f16 undef), (f16 undef)), i32:$rounding, (i32 0)),
  (v4f16 (FFMAHQrr (ZXHD SingleReg:$f1), (ZXHD SingleReg:$f2), (ZXHD SingleReg:$f3), RoundingMod:$rounding, 0))>;

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

def: Pat<(int_kvx_xmovetohi v256i1:$o, i64:$z, i64:$y),
            (MOVETOHIp VectorReg:$o, SingleReg:$z, SingleReg:$y)>;

def: Pat<(int_kvx_xmovetolo v256i1:$o, i64:$z, i64:$y),
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

def: Pat<(int_kvx_xbuildfvm v256i1:$v0, v256i1:$v1, v256i1:$v2, v256i1:$v3),
            (REG_SEQUENCE MatrixReg,
                (v256i1 VectorReg:$v0), (i32 sub_v0),
                (v256i1 VectorReg:$v1), (i32 sub_v1),
                (v256i1 VectorReg:$v2), (i32 sub_v2),
                (v256i1 VectorReg:$v3), (i32 sub_v3))>;

def: Pat<(int_kvx_xbuildfwm v512i1:$w0, v512i1:$w1),
            (REG_SEQUENCE MatrixReg,
                (v512i1 WideReg:$w0), (i32 sub_w0),
                (v512i1 WideReg:$w1), (i32 sub_w1))>;

def: Pat<(int_kvx_xbuildfvw v256i1:$v0, v256i1:$v1),
            (REG_SEQUENCE WideReg,
                (v256i1 VectorReg:$v0), (i32 sub_v0),
                (v256i1 VectorReg:$v1), (i32 sub_v1))>;

// Vector conditional load
// TODO: Allow all addressing modes.
def : Pat<(v256i1(int_kvx_xloadc256 VectorReg:$io, SingleReg:$base, SingleReg:$cond, SpeculateMod:$spec, ScalarcondMod:$scac)),
         (LVrrc SingleReg:$base, VectorReg:$io, SpeculateMod:$spec, ScalarcondMod:$scac, SingleReg:$cond)>;

def : Pat<(v1024i1(int_kvx_xload1024q v1024i1:$io, SingleReg:$base, ColumnMod:$a1, SpeculateMod:$spec)),
         (LVmri10cs MatrixReg:$io, (i64 0), SingleReg:$base, ColumnMod:$a1, SpeculateMod:$spec)>;

def : Pat<(v1024i1(int_kvx_xloadc1024q MatrixReg:$io, SingleReg:$base, SingleReg:$cond, ColumnMod:$a1, SpeculateMod:$spec, ScalarcondMod:$scac)),
         (LVmrrccs MatrixReg:$io, SingleReg:$cond, SingleReg:$base, ColumnMod:$a1, SpeculateMod:$spec, ScalarcondMod:$scac)>;

def : Pat<(int_kvx_xstorec256 VectorReg:$val, i64:$base, i64:$cond, ScalarcondMod:$scac),
          (SVrrc SingleReg:$base, VectorReg:$val, ScalarcondMod:$scac, SingleReg:$cond)>;

// atomic register copy/shift operations
def: Pat<(int_kvx_xswapvo QuadReg:$r, VectorReg:$v),
         (SWAPVOp QuadReg:$r, VectorReg:$v)>;

def: Pat<(int_kvx_xaccess512o WideReg:$a2a3, Unsigned6:$a4), (ALIGNOreroi (EXTRACT_SUBREG WideReg:$a2a3, sub_v0), (EXTRACT_SUBREG WideReg:$a2a3, sub_v1), Unsigned6:$a4)>;
def: Pat<(int_kvx_xaccess512o WideReg:$a2a3, Unsigned6:$a4), (ALIGNOrorei (EXTRACT_SUBREG WideReg:$a2a3, sub_v0), (EXTRACT_SUBREG WideReg:$a2a3, sub_v1), Unsigned6:$a4)>;
def: Pat<(int_kvx_xaccess512o WideReg:$a2a3, SingleReg:$a4), (ALIGNOreror (EXTRACT_SUBREG WideReg:$a2a3, sub_v0), (EXTRACT_SUBREG WideReg:$a2a3, sub_v1), $a4)>;
def: Pat<(int_kvx_xaccess512o WideReg:$a2a3, SingleReg:$a4), (ALIGNOrorer (EXTRACT_SUBREG WideReg:$a2a3, sub_v0), (EXTRACT_SUBREG WideReg:$a2a3, sub_v1), $a4)>;

def: Pat<(int_kvx_xalign512o WideReg:$a2a3, Unsigned6:$a4), (ALIGNVreroi (EXTRACT_SUBREG WideReg:$a2a3, sub_v0), (EXTRACT_SUBREG WideReg:$a2a3, sub_v1), Unsigned6:$a4)>;
def: Pat<(int_kvx_xalign512o WideReg:$a2a3, Unsigned6:$a4), (ALIGNVrorei (EXTRACT_SUBREG WideReg:$a2a3, sub_v0), (EXTRACT_SUBREG WideReg:$a2a3, sub_v1), Unsigned6:$a4)>;
def: Pat<(int_kvx_xalign512o WideReg:$a2a3, SingleReg:$a4), (ALIGNVreror (EXTRACT_SUBREG WideReg:$a2a3, sub_v0), (EXTRACT_SUBREG WideReg:$a2a3, sub_v1), $a4)>;
def: Pat<(int_kvx_xalign512o WideReg:$a2a3, SingleReg:$a4), (ALIGNVrorer (EXTRACT_SUBREG WideReg:$a2a3, sub_v0), (EXTRACT_SUBREG WideReg:$a2a3, sub_v1), $a4)>;

// TCA arithmetic/conversion intrinsics that generate sub-vector register values
// We use pseudo-instruction to hide from the compiler that these instructions
// generate sub-vector values, avoiding the compiler from ever generating copy
// instructions that can't be handled.
let Constraints = "$vIn = $vOut" in {
def CONVDHV0p : KVX_PSEUDO<(outs VectorReg:$vOut), (ins VectorReg:$vIn,
                                 MatrixReg:$a4, RoundintMod:$a1, SaturateMod:$a2), []>;

def CONVDHV1p : KVX_PSEUDO<(outs VectorReg:$vOut), (ins VectorReg:$vIn,
                                 MatrixReg:$a4, RoundintMod:$a1, SaturateMod:$a2), []>;


def CONVWBV0p : KVX_PSEUDO<(outs VectorReg:$vOut), (ins VectorReg:$vIn,
                                 MatrixReg:$a4, RoundintMod:$a1, SaturateMod:$a2), []>;

def CONVWBV1p : KVX_PSEUDO<(outs VectorReg:$vOut), (ins VectorReg:$vIn,
                                 MatrixReg:$a4, RoundintMod:$a1, SaturateMod:$a2), []>;

def CONVWBV2p : KVX_PSEUDO<(outs VectorReg:$vOut), (ins VectorReg:$vIn,
                                 MatrixReg:$a4, RoundintMod:$a1, SaturateMod:$a2), []>;

def CONVWBV3p : KVX_PSEUDO<(outs VectorReg:$vOut), (ins VectorReg:$vIn,
                                 MatrixReg:$a4, RoundintMod:$a1, SaturateMod:$a2), []>;

def FMMA242HW0p : KVX_PSEUDO<(outs VectorReg:$vOut), (ins VectorReg:$vIn,
                                 WideReg:$a2, VectorReg:$a3, VectorReg:$a4), []>;

def FMMA242HW1p : KVX_PSEUDO<(outs VectorReg:$vOut), (ins VectorReg:$vIn,
                                 WideReg:$a2, VectorReg:$a3, VectorReg:$a4), []>;

def FMMA242HW2p : KVX_PSEUDO<(outs VectorReg:$vOut), (ins VectorReg:$vIn,
                                 WideReg:$a2, VectorReg:$a3, VectorReg:$a4), []>;

def FMMA242HW3p : KVX_PSEUDO<(outs VectorReg:$vOut), (ins VectorReg:$vIn,
                                 WideReg:$a2, VectorReg:$a3, VectorReg:$a4), []>;
}

def: Pat<(int_kvx_xconvdhv0 VectorReg:$o, MatrixReg:$a4, i32:$a1, i32:$a2),
            (CONVDHV0p $o, $a4, RoundintMod:$a1, SaturateMod:$a2)>;
def: Pat<(int_kvx_xconvdhv1 VectorReg:$o, MatrixReg:$a4, i32:$a1, i32:$a2),
            (CONVDHV1p $o, $a4, RoundintMod:$a1, SaturateMod:$a2)>;

def: Pat<(int_kvx_xconvdhv MatrixReg:$a4, i32:$a1, i32:$a2),
         (CONVDHV1p (CONVDHV0p (v256i1(IMPLICIT_DEF)), $a4, RoundintMod:$a1, SaturateMod:$a2),
                    $a4, RoundintMod:$a1, SaturateMod:$a2)>;

def: Pat<(int_kvx_xconvwbv0 VectorReg:$o, MatrixReg:$a4, i32:$a1, i32:$a2),
         (CONVWBV0p $o, $a4, RoundintMod:$a1, SaturateMod:$a2)>;
def: Pat<(int_kvx_xconvwbv1 VectorReg:$o, MatrixReg:$a4, i32:$a1, i32:$a2),
         (CONVWBV1p $o, $a4, RoundintMod:$a1, SaturateMod:$a2)>;
def: Pat<(int_kvx_xconvwbv2 VectorReg:$o, MatrixReg:$a4, i32:$a1, i32:$a2),
         (CONVWBV2p $o, $a4, RoundintMod:$a1, SaturateMod:$a2)>;
def: Pat<(int_kvx_xconvwbv3 VectorReg:$o, MatrixReg:$a4, i32:$a1, i32:$a2),
         (CONVWBV3p $o, $a4, RoundintMod:$a1, SaturateMod:$a2)>;

def: Pat<(int_kvx_xconvwbv MatrixReg:$a4, i32:$a1, i32:$a2),
         (CONVWBV3p (CONVWBV2p (CONVWBV1p
                    (CONVWBV0p (v256i1(IMPLICIT_DEF)), $a4, RoundintMod:$a1, SaturateMod:$a2),
                $a4, RoundintMod:$a1, SaturateMod:$a2),
            $a4, RoundintMod:$a1, SaturateMod:$a2),
          $a4, RoundintMod:$a1, SaturateMod:$a2)>;

def: Pat<(int_kvx_xfmma242hw0 VectorRegE:$o, WideReg:$a2, VectorReg:$a3, VectorReg:$a4),
         (FMMA242HW0p VectorRegE:$o, $a2, $a3, $a4)>;
def: Pat<(int_kvx_xfmma242hw1 VectorRegE:$o, WideReg:$a2, VectorReg:$a3, VectorReg:$a4),
         (FMMA242HW1p VectorRegE:$o, $a2, $a3, $a4)>;
def: Pat<(int_kvx_xfmma242hw2 VectorRegO:$o, WideReg:$a2, VectorReg:$a3, VectorReg:$a4),
         (FMMA242HW2p VectorRegO:$o, $a2, $a3, $a4)>;
def: Pat<(int_kvx_xfmma242hw3 VectorRegO:$o, WideReg:$a2, VectorReg:$a3, VectorReg:$a4),
         (FMMA242HW3p VectorRegO:$o, $a2, $a3, $a4)>;
def: Pat<(int_kvx_xfmma444hw WideReg:$a2, VectorReg:$a3, VectorReg:$a4),
         (REG_SEQUENCE WideReg,
            (FMMA242HW1p (FMMA242HW0p (v256i1(IMPLICIT_DEF)), $a2, $a3, $a4), $a2, $a3, $a4),
            sub_v0,
            (FMMA242HW3p (FMMA242HW2p (v256i1(IMPLICIT_DEF)), $a2, $a3, $a4), $a2, $a3, $a4),
            sub_v1)>;

// TCA arithmetic intrinsics
def: Pat<(int_kvx_xmma444hbd0 MatrixReg:$a2, VectorReg:$a3, VectorReg:$a4), (MMA444HBD0 $a2, $a3, $a4)>;
def: Pat<(int_kvx_xmma444hbd1 MatrixReg:$a2, VectorReg:$a3, VectorReg:$a4), (MMA444HBD1 $a2, $a3, $a4)>;
def: Pat<(int_kvx_xmma484hbd MatrixReg:$a2, WideReg:$a3, VectorReg:$a4),
         (MMA444HBD1
            (MMA444HBD0 $a2,
              (v256i1(EXTRACT_SUBREG $a3, sub_v0)),
              $a4),
            (v256i1(EXTRACT_SUBREG $a3, sub_v1)),
            $a4)>;

def: Pat<(int_kvx_xmma444hd MatrixReg:$a2, VectorReg:$a3, VectorReg:$a4), (MMA444HD $a2, $a3, $a4)>;
def: Pat<(int_kvx_xmma444suhbd0 MatrixReg:$a2, VectorReg:$a3, VectorReg:$a4), (MMA444SUHBD0 $a2, $a3, $a4)>;
def: Pat<(int_kvx_xmma444suhbd1 MatrixReg:$a2, VectorReg:$a3, VectorReg:$a4), (MMA444SUHBD1 $a2, $a3, $a4)>;
def: Pat<(int_kvx_xmma484suhbd MatrixReg:$a2, WideReg:$a3, VectorReg:$a4),
         (MMA444SUHBD1
            (MMA444SUHBD0 $a2,
              (v256i1(EXTRACT_SUBREG $a3, sub_v0)),
              $a4),
            (v256i1(EXTRACT_SUBREG $a3, sub_v1)),
            $a4)>;

def: Pat<(int_kvx_xmma444suhd MatrixReg:$a2, VectorReg:$a3, VectorReg:$a4), (MMA444SUHD $a2, $a3, $a4)>;
def: Pat<(int_kvx_xmma444uhbd0 MatrixReg:$a2, VectorReg:$a3, VectorReg:$a4), (MMA444UHBD0 $a2, $a3, $a4)>;
def: Pat<(int_kvx_xmma444uhbd1 MatrixReg:$a2, VectorReg:$a3, VectorReg:$a4), (MMA444UHBD1 $a2, $a3, $a4)>;
def: Pat<(int_kvx_xmma484uhbd MatrixReg:$a2, WideReg:$a3, VectorReg:$a4),
         (MMA444UHBD1
            (MMA444UHBD0 $a2,
              (v256i1(EXTRACT_SUBREG $a3, sub_v0)),
              $a4),
            (v256i1(EXTRACT_SUBREG $a3, sub_v1)),
            $a4)>;

def: Pat<(int_kvx_xmma444uhd MatrixReg:$a2, VectorReg:$a3, VectorReg:$a4), (MMA444UHD $a2, $a3, $a4)>;
def: Pat<(int_kvx_xmma444ushbd0 MatrixReg:$a2, VectorReg:$a3, VectorReg:$a4), (MMA444USHBD0 $a2, $a3, $a4)>;
def: Pat<(int_kvx_xmma444ushbd1 MatrixReg:$a2, VectorReg:$a3, VectorReg:$a4), (MMA444USHBD1 $a2, $a3, $a4)>;
def: Pat<(int_kvx_xmma484ushbd MatrixReg:$a2, WideReg:$a3, VectorReg:$a4),
         (MMA444USHBD1
            (MMA444USHBD0 $a2,
              (v256i1(EXTRACT_SUBREG $a3, sub_v0)),
              $a4),
            (v256i1(EXTRACT_SUBREG $a3, sub_v1)),
            $a4)>;

def: Pat<(int_kvx_xmma444ushd MatrixReg:$a2, VectorReg:$a3, VectorReg:$a4), (MMA444USHD $a2, $a3, $a4)>;
def: Pat<(int_kvx_xmma484bw WideReg:$a2, VectorReg:$a3, VectorReg:$a4), (MMA484BW $a2, $a3, $a4)>;
def: Pat<(int_kvx_xmma484subw WideReg:$a2, VectorReg:$a3, VectorReg:$a4), (MMA484SUBW $a2, $a3, $a4)>;
def: Pat<(int_kvx_xmma484ubw WideReg:$a2, VectorReg:$a3, VectorReg:$a4), (MMA484UBW $a2, $a3, $a4)>;
def: Pat<(int_kvx_xmma484usbw WideReg:$a2, VectorReg:$a3, VectorReg:$a4), (MMA484USBW $a2, $a3, $a4)>;

def: Pat<(int_kvx_xmt44d MatrixReg:$a1), (MT44D $a1)>;

// TCA conversion intrinsics
def: Pat<(int_kvx_xfscalewv VectorReg:$a5, i32:$a1, i32:$a2, i32:$a3), (FSCALEWV $a5, RoundingMod:$a1, SilentMod:$a2, RectifyMod:$a3)>;
def: Pat<(int_kvx_xfnarrowwhv WideReg:$a4, i32:$a1, i32:$a2), (FNARROWWHV $a4, RoundingMod:$a1, SilentMod:$a2)>;

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
              (INSF (v2f32(EXTRACT_SUBREG $LHS, sub_s0)), (v2f32(EXTRACT_SUBREG $LHS, sub_s1)), 63, 32),
              (v2f32(EXTRACT_SUBREG $RHS, sub_s0)),
              rounding_, silent_
            ),
            (ORDrr (SRLDri (v2f32(EXTRACT_SUBREG $LHS, sub_s0)), 32), (ANDDri37 (v2f32(EXTRACT_SUBREG $LHS, sub_s1)), -4294967296)),
            (v2f32(EXTRACT_SUBREG $RHS, sub_s1)),
            rounding_, silent_)>, Requires<[IsV1]>;
def : Pat<(int_kvx_fmm222w v4f32:$LHS, v4f32:$RHS, 0, i32:$r, i32:$s),
          (FMMA212W
            (FMM212W
              (INSF (v2f32(EXTRACT_SUBREG $LHS, sub_s0)), (v2f32(EXTRACT_SUBREG $LHS, sub_s1)), 63, 32),
              (v2f32(EXTRACT_SUBREG $RHS, sub_s0)),
              RoundingMod:$r, SilentMod:$s
            ),
            (ORDrr (SRLDri (v2f32(EXTRACT_SUBREG $LHS, sub_s0)), 32), (ANDDri37 (v2f32(EXTRACT_SUBREG $LHS, sub_s1)), -4294967296)),
            (v2f32(EXTRACT_SUBREG $RHS, sub_s1)),
            RoundingMod:$r, SilentMod:$s)>, Requires<[IsV1]>;


// tn
def : Pat<(v4f32 (int_matrix_multiply (v4f32 (int_matrix_transpose v4f32:$LHS, 2, 2)), v4f32:$RHS, 2, 2, 2)),
          (FMMA212W
            (FMM212W
              (v2f32(EXTRACT_SUBREG $LHS, sub_s0)),
              (v2f32(EXTRACT_SUBREG $RHS, sub_s0)),
              rounding_, silent_
            ),
            (v2f32(EXTRACT_SUBREG $LHS, sub_s1)),
            (v2f32(EXTRACT_SUBREG $RHS, sub_s1)),
            rounding_, silent_)>, Requires<[IsV1]>;
def : Pat<(int_kvx_fmm222w v4f32:$LHS, v4f32:$RHS, 1, i32:$r, i32:$s),
          (FMMA212W
            (FMM212W
              (v2f32(EXTRACT_SUBREG $LHS, sub_s0)),
              (v2f32(EXTRACT_SUBREG $RHS, sub_s0)),
              RoundingMod:$r, SilentMod:$s
            ),
            (v2f32(EXTRACT_SUBREG $LHS, sub_s1)),
            (v2f32(EXTRACT_SUBREG $RHS, sub_s1)),
            RoundingMod:$r, SilentMod:$s)>, Requires<[IsV1]>;
// nt
def : Pat<(v4f32 (int_matrix_multiply v4f32:$LHS, (v4f32 (int_matrix_transpose v4f32:$RHS, 2, 2)), 2, 2, 2)),
          (FMMA212W
            (FMM212W
              (INSF (v2f32(EXTRACT_SUBREG $LHS, sub_s0)), (v2f32(EXTRACT_SUBREG $LHS, sub_s1)), 63, 32),
              (INSF (v2f32(EXTRACT_SUBREG $RHS, sub_s0)), (v2f32(EXTRACT_SUBREG $RHS, sub_s1)), 63, 32),
              rounding_, silent_
            ),
            (ORDrr (SRLDri (v2f32(EXTRACT_SUBREG $LHS, sub_s0)), 32), (ANDDri37 (v2f32(EXTRACT_SUBREG $LHS, sub_s1)), -4294967296)),
            (ORDrr (SRLDri (v2f32(EXTRACT_SUBREG $RHS, sub_s0)), 32), (ANDDri37 (v2f32(EXTRACT_SUBREG $RHS, sub_s1)), -4294967296)),
            rounding_, silent_)>, Requires<[IsV1]>;
def : Pat<(int_kvx_fmm222w v4f32:$LHS, v4f32:$RHS, 2, i32:$r, i32:$s),
          (FMMA212W
            (FMM212W
              (INSF (v2f32(EXTRACT_SUBREG $LHS, sub_s0)), (v2f32(EXTRACT_SUBREG $LHS, sub_s1)), 63, 32),
              (INSF (v2f32(EXTRACT_SUBREG $RHS, sub_s0)), (v2f32(EXTRACT_SUBREG $RHS, sub_s1)), 63, 32),
              RoundingMod:$r, SilentMod:$s
            ),
            (ORDrr (SRLDri (v2f32(EXTRACT_SUBREG $LHS, sub_s0)), 32), (ANDDri37 (v2f32(EXTRACT_SUBREG $LHS, sub_s1)), -4294967296)),
            (ORDrr (SRLDri (v2f32(EXTRACT_SUBREG $RHS, sub_s0)), 32), (ANDDri37 (v2f32(EXTRACT_SUBREG $RHS, sub_s1)), -4294967296)),
            RoundingMod:$r, SilentMod:$s)>, Requires<[IsV1]>;
// tt
def : Pat<(v4f32 (int_matrix_multiply (v4f32 (int_matrix_transpose v4f32:$LHS, 2, 2)), (v4f32 (int_matrix_transpose v4f32:$RHS, 2, 2)), 2, 2, 2)),
          (FMMA212W
            (FMM212W
              (v2f32(EXTRACT_SUBREG $LHS, sub_s0)),
              (INSF (v2f32(EXTRACT_SUBREG $RHS, sub_s0)), (v2f32(EXTRACT_SUBREG $RHS, sub_s1)), 63, 32),
              rounding_, silent_
            ),
            (v2f32(EXTRACT_SUBREG $LHS, sub_s1)),
            (ORDrr (SRLDri (v2f32(EXTRACT_SUBREG $RHS, sub_s0)), 32), (ANDDri37 (v2f32(EXTRACT_SUBREG $RHS, sub_s1)), -4294967296)),
            rounding_, silent_)>, Requires<[IsV1]>;
def : Pat<(int_kvx_fmm222w v4f32:$LHS, v4f32:$RHS, 3, i32:$r, i32:$s),
          (FMMA212W
            (FMM212W
              (v2f32(EXTRACT_SUBREG $LHS, sub_s0)),
              (INSF (v2f32(EXTRACT_SUBREG $RHS, sub_s0)), (v2f32(EXTRACT_SUBREG $RHS, sub_s1)), 63, 32),
              RoundingMod:$r, SilentMod:$s
            ),
            (v2f32(EXTRACT_SUBREG $LHS, sub_s1)),
            (ORDrr (SRLDri (v2f32(EXTRACT_SUBREG $RHS, sub_s0)), 32), (ANDDri37 (v2f32(EXTRACT_SUBREG $RHS, sub_s1)), -4294967296)),
            RoundingMod:$r, SilentMod:$s)>, Requires<[IsV1]>;

// FMMA222_CV1, FMMS222_CV1
multiclass FMMAS222W_CV1 <PatFrag Node, KVX_INSTRUCTION Op, Intrinsic KVX_Int> {
def : Pat<(Node v4f32:$ACC, (int_matrix_multiply v4f32:$LHS, v4f32:$RHS, 2, 2, 2)),
          (Op
            (Op
              PairedReg:$ACC,
              (INSF (v2f32(EXTRACT_SUBREG $LHS, sub_s0)), (v2f32(EXTRACT_SUBREG $LHS, sub_s1)), 63, 32),
              (v2f32(EXTRACT_SUBREG $RHS, sub_s0)),
              rounding_, silent_
            ),
            (ORDrr (SRLDri (v2f32(EXTRACT_SUBREG $LHS, sub_s0)), 32), (ANDDri37 (v2f32(EXTRACT_SUBREG $LHS, sub_s1)), -4294967296)),
            (v2f32(EXTRACT_SUBREG $RHS, sub_s1)),
            rounding_, silent_)>;

def : Pat<(KVX_Int v4f32:$LHS, v4f32:$RHS, v4f32:$ACC, 0, i32:$r, i32:$s),
          (Op
            (Op
              PairedReg:$ACC,
              (INSF (v2f32(EXTRACT_SUBREG $LHS, sub_s0)), (v2f32(EXTRACT_SUBREG $LHS, sub_s1)), 63, 32),
              (v2f32(EXTRACT_SUBREG $RHS, sub_s0)),
              RoundingMod:$r, SilentMod:$s
            ),
            (ORDrr (SRLDri (v2f32(EXTRACT_SUBREG $LHS, sub_s0)), 32), (ANDDri37 (v2f32(EXTRACT_SUBREG $LHS, sub_s1)), -4294967296)),
            (v2f32(EXTRACT_SUBREG $RHS, sub_s1)),
            RoundingMod:$r, SilentMod:$s)>;

def : Pat<(Node v4f32:$ACC, (int_matrix_multiply (v4f32 (int_matrix_transpose v4f32:$LHS, 2, 2)), v4f32:$RHS, 2, 2, 2)),
          (Op
            (Op
              PairedReg:$ACC,
              (v2f32(EXTRACT_SUBREG $LHS, sub_s0)),
              (v2f32(EXTRACT_SUBREG $RHS, sub_s0)),
              rounding_, silent_
            ),
            (v2f32(EXTRACT_SUBREG $LHS, sub_s1)),
            (v2f32(EXTRACT_SUBREG $RHS, sub_s1)),
            rounding_, silent_)>;

def : Pat<(KVX_Int v4f32:$LHS, v4f32:$RHS, v4f32:$ACC, 1, i32:$r, i32:$s),
          (Op
            (Op
              PairedReg:$ACC,
              (v2f32(EXTRACT_SUBREG $LHS, sub_s0)),
              (v2f32(EXTRACT_SUBREG $RHS, sub_s0)),
              RoundingMod:$r, SilentMod:$s
            ),
            (v2f32(EXTRACT_SUBREG $LHS, sub_s1)),
            (v2f32(EXTRACT_SUBREG $RHS, sub_s1)),
            RoundingMod:$r, SilentMod:$s)>;

def : Pat<(Node v4f32:$ACC, (int_matrix_multiply v4f32:$LHS, (v4f32 (int_matrix_transpose v4f32:$RHS, 2, 2)), 2, 2, 2)),
          (Op
            (Op
              PairedReg:$ACC,
              (INSF (v2f32(EXTRACT_SUBREG $LHS, sub_s0)), (v2f32(EXTRACT_SUBREG $LHS, sub_s1)), 63, 32),
              (INSF (v2f32(EXTRACT_SUBREG $RHS, sub_s0)), (v2f32(EXTRACT_SUBREG $RHS, sub_s1)), 63, 32),
              rounding_, silent_
            ),
            (ORDrr (SRLDri (v2f32(EXTRACT_SUBREG $LHS, sub_s0)), 32), (ANDDri37 (v2f32(EXTRACT_SUBREG $LHS, sub_s1)), -4294967296)),
            (ORDrr (SRLDri (v2f32(EXTRACT_SUBREG $RHS, sub_s0)), 32), (ANDDri37 (v2f32(EXTRACT_SUBREG $RHS, sub_s1)), -4294967296)),
            rounding_, silent_)>;

def : Pat<(KVX_Int v4f32:$LHS, v4f32:$RHS, v4f32:$ACC, 2, i32:$r, i32:$s),
          (Op
            (Op
              PairedReg:$ACC,
              (INSF (v2f32(EXTRACT_SUBREG $LHS, sub_s0)), (v2f32(EXTRACT_SUBREG $LHS, sub_s1)), 63, 32),
              (INSF (v2f32(EXTRACT_SUBREG $RHS, sub_s0)), (v2f32(EXTRACT_SUBREG $RHS, sub_s1)), 63, 32),
              RoundingMod:$r, SilentMod:$s
            ),
            (ORDrr (SRLDri (v2f32(EXTRACT_SUBREG $LHS, sub_s0)), 32), (ANDDri37 (v2f32(EXTRACT_SUBREG $LHS, sub_s1)), -4294967296)),
            (ORDrr (SRLDri (v2f32(EXTRACT_SUBREG $RHS, sub_s0)), 32), (ANDDri37 (v2f32(EXTRACT_SUBREG $RHS, sub_s1)), -4294967296)),
            RoundingMod:$r, SilentMod:$s)>;

def : Pat<(Node v4f32:$ACC, (int_matrix_multiply (v4f32 (int_matrix_transpose v4f32:$LHS, 2, 2)), (v4f32 (int_matrix_transpose v4f32:$RHS, 2, 2)), 2, 2, 2)),
          (Op
            (Op
              PairedReg:$ACC,
              (v2f32(EXTRACT_SUBREG $LHS, sub_s0)),
              (INSF (v2f32(EXTRACT_SUBREG $RHS, sub_s0)), (v2f32(EXTRACT_SUBREG $RHS, sub_s1)), 63, 32),
              rounding_, silent_
            ),
            (v2f32(EXTRACT_SUBREG $LHS, sub_s1)),
            (ORDrr (SRLDri (v2f32(EXTRACT_SUBREG $RHS, sub_s0)), 32), (ANDDri37 (v2f32(EXTRACT_SUBREG $RHS, sub_s1)), -4294967296)),
            rounding_, silent_)>;

def : Pat<(KVX_Int v4f32:$LHS, v4f32:$RHS, v4f32:$ACC, 3, i32:$r, i32:$s),
          (Op
            (Op
              PairedReg:$ACC,
              (v2f32(EXTRACT_SUBREG $LHS, sub_s0)),
              (INSF (v2f32(EXTRACT_SUBREG $RHS, sub_s0)), (v2f32(EXTRACT_SUBREG $RHS, sub_s1)), 63, 32),
              RoundingMod:$r, SilentMod:$s
            ),
            (v2f32(EXTRACT_SUBREG $LHS, sub_s1)),
            (ORDrr (SRLDri (v2f32(EXTRACT_SUBREG $RHS, sub_s0)), 32), (ANDDri37 (v2f32(EXTRACT_SUBREG $RHS, sub_s1)), -4294967296)),
            RoundingMod:$r, SilentMod:$s)>;
}

defm : FMMAS222W_CV1<faddcont, FMMA212W, int_kvx_fmma222w>, Requires<[IsV1]>;
defm : FMMAS222W_CV1<fsubcont, FMMS212W, int_kvx_fmms222w>, Requires<[IsV1]>;
// ----------------------- To fix END  -----------------------

//===----------------------------------------------------------------------===//
// ACB 4.8 TCA intrinsics. Should remove them in ACB 4.10
//===----------------------------------------------------------------------===//
def: Pat<(int_kvx_alignov VectorRegE:$a2, VectorRegO:$a3, Unsigned6:$a4), (ALIGNOreroi $a2, $a3, Unsigned6:$a4)>;
def: Pat<(int_kvx_alignov VectorRegO:$a2, VectorRegE:$a3, Unsigned6:$a4), (ALIGNOrorei $a2, $a3, Unsigned6:$a4)>;
def: Pat<(int_kvx_alignov VectorRegE:$a2, VectorRegO:$a3, SingleReg:$a4), (ALIGNOreror $a2, $a3, $a4)>;
def: Pat<(int_kvx_alignov VectorRegO:$a2, VectorRegE:$a3, SingleReg:$a4), (ALIGNOrorer $a2, $a3, $a4)>;

def: Pat<(int_kvx_alignv VectorRegE:$a2, VectorRegO:$a3, Unsigned6:$a4), (ALIGNVreroi $a2, $a3, Unsigned6:$a4)>;
def: Pat<(int_kvx_alignv VectorRegO:$a2, VectorRegE:$a3, Unsigned6:$a4), (ALIGNVrorei $a2, $a3, Unsigned6:$a4)>;
def: Pat<(int_kvx_alignv VectorRegE:$a2, VectorRegO:$a3, SingleReg:$a4), (ALIGNVreror $a2, $a3, $a4)>;
def: Pat<(int_kvx_alignv VectorRegO:$a2, VectorRegE:$a3, SingleReg:$a4), (ALIGNVrorer $a2, $a3, $a4)>;

def : Pat<(int_kvx_sv_cond i64:$base, VectorReg:$val, i64:$cond, ScalarcondMod:$scac),
          (SVrrc SingleReg:$base, VectorReg:$val, ScalarcondMod:$scac, SingleReg:$cond)>;
