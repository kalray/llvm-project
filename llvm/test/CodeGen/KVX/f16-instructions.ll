; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -O2 -o - %s | FileCheck %s
target triple = "kvx-kalray-cos"

declare half @llvm.sqrt.f16(half %a) #0
declare half @llvm.powi.f16(half %a, i32 %b) #0
declare half @llvm.sin.f16(half %a) #0
declare half @llvm.cos.f16(half %a) #0
declare half @llvm.pow.f16(half %a, half %b) #0
declare half @llvm.exp.f16(half %a) #0
declare half @llvm.exp2.f16(half %a) #0
declare half @llvm.log.f16(half %a) #0
declare half @llvm.log10.f16(half %a) #0
declare half @llvm.log2.f16(half %a) #0
declare half @llvm.fma.f16(half %a, half %b, half %c) #0
declare half @llvm.fabs.f16(half %a) #0
declare half @llvm.minnum.f16(half %a, half %b) #0
declare half @llvm.maxnum.f16(half %a, half %b) #0
declare half @llvm.copysign.f16(half %a, half %b) #0
declare half @llvm.floor.f16(half %a) #0
declare half @llvm.ceil.f16(half %a) #0
declare half @llvm.trunc.f16(half %a) #0
declare half @llvm.rint.f16(half %a) #0
declare half @llvm.nearbyint.f16(half %a) #0
declare half @llvm.round.f16(half %a) #0
declare half @llvm.fmuladd.f16(half %a, half %b, half %c) #0

define half @test_ret_const() #0 {
; CHECK-LABEL: test_ret_const:
; CHECK:       # %bb.0:
; CHECK-NEXT:    make $r0 = 0x3c00
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  ret half 1.0
}

define half @test_fadd(half %a, half %b) #0 {
; CHECK-LABEL: test_fadd:
; CHECK:       # %bb.0:
; CHECK-NEXT:    zxhd $r1 = $r1
; CHECK-NEXT:    zxhd $r0 = $r0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    faddhq $r0 = $r0, $r1
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %r = fadd half %a, %b
  ret half %r
}

define <1 x half> @test_fadd_v1f16(<1 x half> %a, <1 x half> %b) #0 {
; CHECK-LABEL: test_fadd_v1f16:
; CHECK:       # %bb.0:
; CHECK-NEXT:    zxhd $r1 = $r1
; CHECK-NEXT:    zxhd $r0 = $r0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    faddhq $r0 = $r0, $r1
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %r = fadd <1 x half> %a, %b
  ret <1 x half> %r
}

define half @test_fadd_imm_0(half %b) #0 {
; CHECK-LABEL: test_fadd_imm_0:
; CHECK:       # %bb.0:
; CHECK-NEXT:    make $r1 = 0x3c00
; CHECK-NEXT:    zxhd $r0 = $r0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    zxhd $r1 = $r1
; CHECK-NEXT:    ;;
; CHECK-NEXT:    faddhq $r0 = $r0, $r1
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %r = fadd half 1.0, %b
  ret half %r
}

define half @test_fadd_imm_1(half %a) #0 {
; CHECK-LABEL: test_fadd_imm_1:
; CHECK:       # %bb.0:
; CHECK-NEXT:    make $r1 = 0x3c00
; CHECK-NEXT:    zxhd $r0 = $r0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    zxhd $r1 = $r1
; CHECK-NEXT:    ;;
; CHECK-NEXT:    faddhq $r0 = $r0, $r1
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %r = fadd half %a, 1.0
  ret half %r
}

define half @test_fsub(half %a, half %b) #0 {
; CHECK-LABEL: test_fsub:
; CHECK:       # %bb.0:
; CHECK-NEXT:    zxhd $r0 = $r0
; CHECK-NEXT:    zxhd $r1 = $r1
; CHECK-NEXT:    ;;
; CHECK-NEXT:    fsbfhq $r0 = $r1, $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %r = fsub half %a, %b
  ret half %r
}

define half @test_fneg(half %a) #0 {
; CHECK-LABEL: test_fneg:
; CHECK:       # %bb.0:
; CHECK-NEXT:    fneghq $r0 = $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %r = fsub half 0.0, %a
  ret half %r
}

define half @test_fmul(half %a, half %b) #0 {
; CHECK-LABEL: test_fmul:
; CHECK:       # %bb.0:
; CHECK-NEXT:    zxhd $r1 = $r1
; CHECK-NEXT:    zxhd $r0 = $r0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    fmulhq $r0 = $r0, $r1
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %r = fmul half %a, %b
  ret half %r
}

define half @test_fdiv(half %a, half %b) #0 {
; CHECK-LABEL: test_fdiv:
; CHECK:       # %bb.0:
; CHECK-NEXT:    addd $r12 = $r12, -32
; CHECK-NEXT:    get $r16 = $ra
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sd 0[$r12] = $r16
; CHECK-NEXT:    fwidenlhw $r0 = $r0
; CHECK-NEXT:    fwidenlhw $r1 = $r1
; CHECK-NEXT:    call __divsf3
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ld $r16 = 0[$r12]
; CHECK-NEXT:    fnarrowwh $r0 = $r0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    set $ra = $r16
; CHECK-NEXT:    addd $r12 = $r12, 32
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %r = fdiv half %a, %b
  ret half %r
}

define half @test_frem(half %a, half %b) #0 {
; CHECK-LABEL: test_frem:
; CHECK:       # %bb.0:
; CHECK-NEXT:    addd $r12 = $r12, -32
; CHECK-NEXT:    get $r16 = $ra
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sd 0[$r12] = $r16
; CHECK-NEXT:    fwidenlhw $r0 = $r0
; CHECK-NEXT:    fwidenlhw $r1 = $r1
; CHECK-NEXT:    call fmodf
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ld $r16 = 0[$r12]
; CHECK-NEXT:    fnarrowwh $r0 = $r0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    set $ra = $r16
; CHECK-NEXT:    addd $r12 = $r12, 32
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %r = frem half %a, %b
  ret half %r
}

define void @test_store(half %a, half* %b) #0 {
; CHECK-LABEL: test_store:
; CHECK:       # %bb.0:
; CHECK-NEXT:    sh 0[$r1] = $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  store half %a, half* %b
  ret void
}

define half @test_load(half* %a) #0 {
; CHECK-LABEL: test_load:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lhz $r0 = 0[$r0]
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %r = load half, half* %a
  ret half %r
}

define void @test_halfp0a1(half * noalias readonly %from, half * %to) {
; CHECK-LABEL: test_halfp0a1:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lhz $r0 = 0[$r0]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sh 0[$r1] = $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %1 = load half, half * %from , align 1
  store half %1, half * %to , align 1
  ret void
}

declare half @test_callee(half %a, half %b) #0

define half @test_call(half %a, half %b) #0 {
; CHECK-LABEL: test_call:
; CHECK:       # %bb.0:
; CHECK-NEXT:    addd $r12 = $r12, -32
; CHECK-NEXT:    get $r16 = $ra
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sd 0[$r12] = $r16
; CHECK-NEXT:    call test_callee
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ld $r16 = 0[$r12]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    set $ra = $r16
; CHECK-NEXT:    addd $r12 = $r12, 32
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %r = call half @test_callee(half %a, half %b)
  ret half %r
}

define half @test_call_flipped(half %a, half %b) #0 {
; CHECK-LABEL: test_call_flipped:
; CHECK:       # %bb.0:
; CHECK-NEXT:    addd $r12 = $r12, -32
; CHECK-NEXT:    get $r16 = $ra
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sd 0[$r12] = $r16
; CHECK-NEXT:    copyd $r2 = $r0
; CHECK-NEXT:    copyd $r0 = $r1
; CHECK-NEXT:    ;;
; CHECK-NEXT:    copyd $r1 = $r2
; CHECK-NEXT:    call test_callee
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ld $r16 = 0[$r12]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    set $ra = $r16
; CHECK-NEXT:    addd $r12 = $r12, 32
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %r = call half @test_callee(half %b, half %a)
  ret half %r
}

define half @test_tailcall_flipped(half %a, half %b) #0 {
; CHECK-LABEL: test_tailcall_flipped:
; CHECK:       # %bb.0:
; CHECK-NEXT:    copyd $r2 = $r0
; CHECK-NEXT:    copyd $r0 = $r1
; CHECK-NEXT:    ;;
; CHECK-NEXT:    copyd $r1 = $r2
; CHECK-NEXT:    goto test_callee
; CHECK-NEXT:    ;;
  %r = tail call half @test_callee(half %b, half %a)
  ret half %r
}

define half @test_select(half %a, half %b, i1 zeroext %c) #0 {
; CHECK-LABEL: test_select:
; CHECK:       # %bb.0:
; CHECK-NEXT:    cmoved.wnez $r2 ? $r1 = $r0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    copyd $r0 = $r1
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %r = select i1 %c, half %a, half %b
  ret half %r
}

define half @test_select_cc(half %a, half %b, half %c, half %d) #0 {
; CHECK-LABEL: test_select_cc:
; CHECK:       # %bb.0:
; CHECK-NEXT:    fcompnhq.une $r2 = $r2, $r3
; CHECK-NEXT:    ;;
; CHECK-NEXT:    cmoved.wnez $r2 ? $r1 = $r0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    copyd $r0 = $r1
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %cc = fcmp une half %c, %d
  %r = select i1 %cc, half %a, half %b
  ret half %r
}

define float @test_select_cc_f32_f16(float %a, float %b, half %c, half %d) #0 {
; CHECK-LABEL: test_select_cc_f32_f16:
; CHECK:       # %bb.0:
; CHECK-NEXT:    fcompnhq.une $r2 = $r2, $r3
; CHECK-NEXT:    ;;
; CHECK-NEXT:    cmoved.wnez $r2 ? $r1 = $r0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    copyd $r0 = $r1
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %cc = fcmp une half %c, %d
  %r = select i1 %cc, float %a, float %b
  ret float %r
}

define half @test_select_cc_f16_f32(half %a, half %b, float %c, float %d) #0 {
; CHECK-LABEL: test_select_cc_f16_f32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    fcompw.une $r2 = $r2, $r3
; CHECK-NEXT:    ;;
; CHECK-NEXT:    cmoved.wnez $r2 ? $r1 = $r0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    copyd $r0 = $r1
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %cc = fcmp une float %c, %d
  %r = select i1 %cc, half %a, half %b
  ret half %r
}

define i1 @test_fcmp_une(half %a, half %b) #0 {
; CHECK-LABEL: test_fcmp_une:
; CHECK:       # %bb.0:
; CHECK-NEXT:    fcompnhq.une $r0 = $r0, $r1
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %r = fcmp une half %a, %b
  ret i1 %r
}

define i1 @test_fcmp_ueq(half %a, half %b) #0 {
; CHECK-LABEL: test_fcmp_ueq:
; CHECK:       # %bb.0:
; CHECK-NEXT:    fcompnhq.ueq $r0 = $r0, $r1
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %r = fcmp ueq half %a, %b
  ret i1 %r
}

define i1 @test_fcmp_ugt(half %a, half %b) #0 {
; CHECK-LABEL: test_fcmp_ugt:
; CHECK:       # %bb.0:
; CHECK-NEXT:    fcompnhq.ult $r0 = $r1, $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %r = fcmp ugt half %a, %b
  ret i1 %r
}

define i1 @test_fcmp_uge(half %a, half %b) #0 {
; CHECK-LABEL: test_fcmp_uge:
; CHECK:       # %bb.0:
; CHECK-NEXT:    fcompnhq.uge $r0 = $r0, $r1
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %r = fcmp uge half %a, %b
  ret i1 %r
}

define i1 @test_fcmp_ult(half %a, half %b) #0 {
; CHECK-LABEL: test_fcmp_ult:
; CHECK:       # %bb.0:
; CHECK-NEXT:    fcompnhq.ult $r0 = $r0, $r1
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %r = fcmp ult half %a, %b
  ret i1 %r
}

define i1 @test_fcmp_ule(half %a, half %b) #0 {
; CHECK-LABEL: test_fcmp_ule:
; CHECK:       # %bb.0:
; CHECK-NEXT:    fcompnhq.uge $r0 = $r1, $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %r = fcmp ule half %a, %b
  ret i1 %r
}


define i1 @test_fcmp_uno(half %a, half %b) #0 {
; CHECK-LABEL: test_fcmp_uno:
; CHECK:       # %bb.0:
; CHECK-NEXT:    fcompnhq.ult $r2 = $r0, $r1
; CHECK-NEXT:    fcompnhq.uge $r0 = $r0, $r1
; CHECK-NEXT:    ;;
; CHECK-NEXT:    andw $r0 = $r0, $r2
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %r = fcmp uno half %a, %b
  ret i1 %r
}

define i1 @test_fcmp_one(half %a, half %b) #0 {
; CHECK-LABEL: test_fcmp_one:
; CHECK:       # %bb.0:
; CHECK-NEXT:    fcompnhq.one $r0 = $r0, $r1
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %r = fcmp one half %a, %b
  ret i1 %r
}

define i1 @test_fcmp_oeq(half %a, half %b) #0 {
; CHECK-LABEL: test_fcmp_oeq:
; CHECK:       # %bb.0:
; CHECK-NEXT:    fcompnhq.oeq $r0 = $r0, $r1
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %r = fcmp oeq half %a, %b
  ret i1 %r
}

define i1 @test_fcmp_ogt(half %a, half %b) #0 {
; CHECK-LABEL: test_fcmp_ogt:
; CHECK:       # %bb.0:
; CHECK-NEXT:    fcompnhq.olt $r0 = $r1, $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %r = fcmp ogt half %a, %b
  ret i1 %r
}

define i1 @test_fcmp_oge(half %a, half %b) #0 {
; CHECK-LABEL: test_fcmp_oge:
; CHECK:       # %bb.0:
; CHECK-NEXT:    fcompnhq.oge $r0 = $r0, $r1
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %r = fcmp oge half %a, %b
  ret i1 %r
}

; XCHECK-LABEL: test_fcmp_olt(
define i1 @test_fcmp_olt(half %a, half %b) #0 {
; CHECK-LABEL: test_fcmp_olt:
; CHECK:       # %bb.0:
; CHECK-NEXT:    fcompnhq.olt $r0 = $r0, $r1
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %r = fcmp olt half %a, %b
  ret i1 %r
}

; XCHECK-LABEL: test_fcmp_ole(
define i1 @test_fcmp_ole(half %a, half %b) #0 {
; CHECK-LABEL: test_fcmp_ole:
; CHECK:       # %bb.0:
; CHECK-NEXT:    fcompnhq.oge $r0 = $r1, $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %r = fcmp ole half %a, %b
  ret i1 %r
}

define i1 @test_fcmp_ord(half %a, half %b) #0 {
; CHECK-LABEL: test_fcmp_ord:
; CHECK:       # %bb.0:
; CHECK-NEXT:    fcompnhq.olt $r2 = $r0, $r1
; CHECK-NEXT:    fcompnhq.oge $r0 = $r0, $r1
; CHECK-NEXT:    ;;
; CHECK-NEXT:    orw $r0 = $r0, $r2
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %r = fcmp ord half %a, %b
  ret i1 %r
}

define void @test_br_cc(half %a, half %b, i32* %p1, i32* %p2) #0 {
; CHECK-LABEL: test_br_cc:
; CHECK:       # %bb.0:
; CHECK-NEXT:    fcompnhq.olt $r0 = $r0, $r1
; CHECK-NEXT:    ;;
; CHECK-NEXT:    cb.wnez $r0 ? .LBB34_2
; CHECK-NEXT:    ;;
; CHECK-NEXT:  # %bb.1: # %then
; CHECK-NEXT:    make $r0 = 0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sw 0[$r2] = $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
; CHECK-NEXT:  .LBB34_2: # %else
; CHECK-NEXT:    make $r0 = 0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sw 0[$r3] = $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %c = fcmp uge half %a, %b
  br i1 %c, label %then, label %else
then:
  store i32 0, i32* %p1
  ret void
else:
  store i32 0, i32* %p2
  ret void
}

define half @test_phi(half* %p1) #0 {
; CHECK-LABEL: test_phi:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    addd $r12 = $r12, -32
; CHECK-NEXT:    get $r16 = $ra
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sd 24[$r12] = $r16
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sd 16[$r12] = $r20
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sq 0[$r12] = $r18r19
; CHECK-NEXT:    copyd $r18 = $r0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    lhz $r20 = 0[$r18]
; CHECK-NEXT:    ;;
; CHECK-NEXT:  .LBB35_1: # %loop
; CHECK-NEXT:    # =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    copyd $r19 = $r20
; CHECK-NEXT:    lhz $r20 = 0[$r18]
; CHECK-NEXT:    copyd $r0 = $r18
; CHECK-NEXT:    call test_dummy
; CHECK-NEXT:    ;;
; CHECK-NEXT:    cb.wnez $r0 ? .LBB35_1
; CHECK-NEXT:    ;;
; CHECK-NEXT:  # %bb.2: # %return
; CHECK-NEXT:    copyd $r0 = $r19
; CHECK-NEXT:    lq $r18r19 = 0[$r12]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ld $r20 = 16[$r12]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ld $r16 = 24[$r12]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    set $ra = $r16
; CHECK-NEXT:    addd $r12 = $r12, 32
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %a = load half, half* %p1
  br label %loop
loop:
  %r = phi half [%a, %entry], [%b, %loop]
  %b = load half, half* %p1
  %c = call i1 @test_dummy(half* %p1)
  br i1 %c, label %loop, label %return
return:
  ret half %r
}
declare i1 @test_dummy(half* %p1) #0

define i32 @test_fptosi_i32(half %a) #0 {
; CHECK-LABEL: test_fptosi_i32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    fwidenlhw $r0 = $r0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    fixedw.rz $r0 = $r0, 0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %r = fptosi half %a to i32
  ret i32 %r
}

define i64 @test_fptosi_i64(half %a) #0 {
; CHECK-LABEL: test_fptosi_i64:
; CHECK:       # %bb.0:
; CHECK-NEXT:    fwidenlhw $r0 = $r0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    fwidenlwd $r0 = $r0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    fixedd.rz $r0 = $r0, 0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %r = fptosi half %a to i64
  ret i64 %r
}

define i32 @test_fptoui_i32(half %a) #0 {
; CHECK-LABEL: test_fptoui_i32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    fwidenlhw $r0 = $r0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    fixeduw.rz $r0 = $r0, 0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %r = fptoui half %a to i32
  ret i32 %r
}

define i64 @test_fptoui_i64(half %a) #0 {
; CHECK-LABEL: test_fptoui_i64:
; CHECK:       # %bb.0:
; CHECK-NEXT:    fwidenlhw $r0 = $r0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    fwidenlwd $r0 = $r0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    fixedud.rz $r0 = $r0, 0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %r = fptoui half %a to i64
  ret i64 %r
}

define half @test_uitofp_i32(i32 %a) #0 {
; CHECK-LABEL: test_uitofp_i32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    floatuw.rn $r0 = $r0, 0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    fnarrowwh.rn $r0 = $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %r = uitofp i32 %a to half
  ret half %r
}

define half @test_uitofp_i64(i64 %a) #0 {
; CHECK-LABEL: test_uitofp_i64:
; CHECK:       # %bb.0:
; CHECK-NEXT:    floatud.rn $r0 = $r0, 0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    fnarrowdw.rn $r0 = $r0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    fnarrowwh.rn $r0 = $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %r = uitofp i64 %a to half
  ret half %r
}

define half @test_sitofp_i32(i32 %a) #0 {
; CHECK-LABEL: test_sitofp_i32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    floatw.rn $r0 = $r0, 0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    fnarrowwh.rn $r0 = $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %r = sitofp i32 %a to half
  ret half %r
}

define half @test_sitofp_i64(i64 %a) #0 {
; CHECK-LABEL: test_sitofp_i64:
; CHECK:       # %bb.0:
; CHECK-NEXT:    floatd.rn $r0 = $r0, 0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    fnarrowdw.rn $r0 = $r0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    fnarrowwh.rn $r0 = $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %r = sitofp i64 %a to half
  ret half %r
}

define half @test_uitofp_i32_fadd(i32 %a, half %b) #0 {
; CHECK-LABEL: test_uitofp_i32_fadd:
; CHECK:       # %bb.0:
; CHECK-NEXT:    floatuw.rn $r0 = $r0, 0
; CHECK-NEXT:    zxhd $r1 = $r1
; CHECK-NEXT:    ;;
; CHECK-NEXT:    fnarrowwh.rn $r0 = $r0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    zxhd $r0 = $r0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    faddhq $r0 = $r1, $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %c = uitofp i32 %a to half
  %r = fadd half %b, %c
  ret half %r
}

; XCHECK-NOF16-DAG:  cvt.f32.f16    [[B32:%f[0-9]+]], [[B]]
; XCHECK-NOF16-DAG:  cvt.f32.f16    [[C32:%f[0-9]+]], [[C]]
; XCHECK-NOF16-NEXT: add.rn.f32     [[R32:%f[0-9]+]], [[B32]], [[C32]];
; XCHECK-NOF16-NEXT: cvt.rn.f16.f32 [[R:%h[0-9]+]], [[R32]]
define half @test_sitofp_i32_fadd(i32 %a, half %b) #0 {
; CHECK-LABEL: test_sitofp_i32_fadd:
; CHECK:       # %bb.0:
; CHECK-NEXT:    floatw.rn $r0 = $r0, 0
; CHECK-NEXT:    zxhd $r1 = $r1
; CHECK-NEXT:    ;;
; CHECK-NEXT:    fnarrowwh.rn $r0 = $r0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    zxhd $r0 = $r0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    faddhq $r0 = $r1, $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %c = sitofp i32 %a to half
  %r = fadd half %b, %c
  ret half %r
}

define half @test_fptrunc_float(float %a) #0 {
; CHECK-LABEL: test_fptrunc_float:
; CHECK:       # %bb.0:
; CHECK-NEXT:    fnarrowwh $r0 = $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %r = fptrunc float %a to half
  ret half %r
}

define half @test_fptrunc_double(double %a) #0 {
; CHECK-LABEL: test_fptrunc_double:
; CHECK:       # %bb.0:
; CHECK-NEXT:    fnarrowdw $r0 = $r0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    fnarrowwh $r0 = $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %r = fptrunc double %a to half
  ret half %r
}

define float @test_fpext_float(half %a) #0 {
; CHECK-LABEL: test_fpext_float:
; CHECK:       # %bb.0:
; CHECK-NEXT:    fwidenlhw $r0 = $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %r = fpext half %a to float
  ret float %r
}

define double @test_fpext_double(half %a) #0 {
; CHECK-LABEL: test_fpext_double:
; CHECK:       # %bb.0:
; CHECK-NEXT:    fwidenlhw $r0 = $r0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    fwidenlwd $r0 = $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %r = fpext half %a to double
  ret double %r
}


define i16 @test_bitcast_halftoi16(half %a) #0 {
; CHECK-LABEL: test_bitcast_halftoi16:
; CHECK:       # %bb.0:
; CHECK-NEXT:    addd $r12 = $r12, -32
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sh 0[$r12] = $r0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    lhz $r0 = 0[$r12]
; CHECK-NEXT:    addd $r12 = $r12, 32
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %r = bitcast half %a to i16
  ret i16 %r
}

define half @test_bitcast_i16tohalf(i16 %a) #0 {
; CHECK-LABEL: test_bitcast_i16tohalf:
; CHECK:       # %bb.0:
; CHECK-NEXT:    addd $r12 = $r12, -32
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sh 0[$r12] = $r0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    lhz $r0 = 0[$r12]
; CHECK-NEXT:    addd $r12 = $r12, 32
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %r = bitcast i16 %a to half
  ret half %r
}

define half @test_sqrt(half %a) #0 {
; CHECK-LABEL: test_sqrt:
; CHECK:       # %bb.0:
; CHECK-NEXT:    addd $r12 = $r12, -32
; CHECK-NEXT:    get $r16 = $ra
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sd 0[$r12] = $r16
; CHECK-NEXT:    fwidenlhw $r0 = $r0
; CHECK-NEXT:    call sqrtf
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ld $r16 = 0[$r12]
; CHECK-NEXT:    fnarrowwh $r0 = $r0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    set $ra = $r16
; CHECK-NEXT:    addd $r12 = $r12, 32
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %r = call half @llvm.sqrt.f16(half %a)
  ret half %r
}

define half @test_powi(half %a, i32 %b) #0 {
; CHECK-LABEL: test_powi:
; CHECK:       # %bb.0:
; CHECK-NEXT:    addd $r12 = $r12, -32
; CHECK-NEXT:    get $r16 = $ra
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sd 0[$r12] = $r16
; CHECK-NEXT:    fwidenlhw $r0 = $r0
; CHECK-NEXT:    call __powisf2
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ld $r16 = 0[$r12]
; CHECK-NEXT:    fnarrowwh $r0 = $r0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    set $ra = $r16
; CHECK-NEXT:    addd $r12 = $r12, 32
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
 %r = call half @llvm.powi.f16(half %a, i32 %b)
 ret half %r
}

define half @test_sin(half %a) #0 #1 {
; CHECK-LABEL: test_sin:
; CHECK:       # %bb.0:
; CHECK-NEXT:    addd $r12 = $r12, -32
; CHECK-NEXT:    get $r16 = $ra
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sd 0[$r12] = $r16
; CHECK-NEXT:    fwidenlhw $r0 = $r0
; CHECK-NEXT:    call sinf
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ld $r16 = 0[$r12]
; CHECK-NEXT:    fnarrowwh $r0 = $r0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    set $ra = $r16
; CHECK-NEXT:    addd $r12 = $r12, 32
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %r = call half @llvm.sin.f16(half %a)
  ret half %r
}

define half @test_cos(half %a) #0 #1 {
; CHECK-LABEL: test_cos:
; CHECK:       # %bb.0:
; CHECK-NEXT:    addd $r12 = $r12, -32
; CHECK-NEXT:    get $r16 = $ra
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sd 0[$r12] = $r16
; CHECK-NEXT:    fwidenlhw $r0 = $r0
; CHECK-NEXT:    call cosf
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ld $r16 = 0[$r12]
; CHECK-NEXT:    fnarrowwh $r0 = $r0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    set $ra = $r16
; CHECK-NEXT:    addd $r12 = $r12, 32
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %r = call half @llvm.cos.f16(half %a)
  ret half %r
}

define half @test_pow(half %a, half %b) #0 {
; CHECK-LABEL: test_pow:
; CHECK:       # %bb.0:
; CHECK-NEXT:    addd $r12 = $r12, -32
; CHECK-NEXT:    get $r16 = $ra
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sd 0[$r12] = $r16
; CHECK-NEXT:    fwidenlhw $r0 = $r0
; CHECK-NEXT:    fwidenlhw $r1 = $r1
; CHECK-NEXT:    call powf
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ld $r16 = 0[$r12]
; CHECK-NEXT:    fnarrowwh $r0 = $r0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    set $ra = $r16
; CHECK-NEXT:    addd $r12 = $r12, 32
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
 %r = call half @llvm.pow.f16(half %a, half %b)
 ret half %r
}

define half @test_exp(half %a) #0 {
; CHECK-LABEL: test_exp:
; CHECK:       # %bb.0:
; CHECK-NEXT:    addd $r12 = $r12, -32
; CHECK-NEXT:    get $r16 = $ra
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sd 0[$r12] = $r16
; CHECK-NEXT:    fwidenlhw $r0 = $r0
; CHECK-NEXT:    call expf
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ld $r16 = 0[$r12]
; CHECK-NEXT:    fnarrowwh $r0 = $r0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    set $ra = $r16
; CHECK-NEXT:    addd $r12 = $r12, 32
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
 %r = call half @llvm.exp.f16(half %a)
 ret half %r
}

define half @test_exp2(half %a) #0 {
; CHECK-LABEL: test_exp2:
; CHECK:       # %bb.0:
; CHECK-NEXT:    addd $r12 = $r12, -32
; CHECK-NEXT:    get $r16 = $ra
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sd 0[$r12] = $r16
; CHECK-NEXT:    fwidenlhw $r0 = $r0
; CHECK-NEXT:    call exp2f
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ld $r16 = 0[$r12]
; CHECK-NEXT:    fnarrowwh $r0 = $r0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    set $ra = $r16
; CHECK-NEXT:    addd $r12 = $r12, 32
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
 %r = call half @llvm.exp2.f16(half %a)
 ret half %r
}

define half @test_log(half %a) #0 {
; CHECK-LABEL: test_log:
; CHECK:       # %bb.0:
; CHECK-NEXT:    addd $r12 = $r12, -32
; CHECK-NEXT:    get $r16 = $ra
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sd 0[$r12] = $r16
; CHECK-NEXT:    fwidenlhw $r0 = $r0
; CHECK-NEXT:    call logf
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ld $r16 = 0[$r12]
; CHECK-NEXT:    fnarrowwh $r0 = $r0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    set $ra = $r16
; CHECK-NEXT:    addd $r12 = $r12, 32
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
 %r = call half @llvm.log.f16(half %a)
 ret half %r
}

define half @test_log10(half %a) #0 {
; CHECK-LABEL: test_log10:
; CHECK:       # %bb.0:
; CHECK-NEXT:    addd $r12 = $r12, -32
; CHECK-NEXT:    get $r16 = $ra
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sd 0[$r12] = $r16
; CHECK-NEXT:    fwidenlhw $r0 = $r0
; CHECK-NEXT:    call log10f
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ld $r16 = 0[$r12]
; CHECK-NEXT:    fnarrowwh $r0 = $r0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    set $ra = $r16
; CHECK-NEXT:    addd $r12 = $r12, 32
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
 %r = call half @llvm.log10.f16(half %a)
 ret half %r
}

define half @test_log2(half %a) #0 {
; CHECK-LABEL: test_log2:
; CHECK:       # %bb.0:
; CHECK-NEXT:    addd $r12 = $r12, -32
; CHECK-NEXT:    get $r16 = $ra
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sd 0[$r12] = $r16
; CHECK-NEXT:    fwidenlhw $r0 = $r0
; CHECK-NEXT:    call log2f
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ld $r16 = 0[$r12]
; CHECK-NEXT:    fnarrowwh $r0 = $r0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    set $ra = $r16
; CHECK-NEXT:    addd $r12 = $r12, 32
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
 %r = call half @llvm.log2.f16(half %a)
 ret half %r
}

define half @test_fma(half %a, half %b, half %c) #0 {
; CHECK-LABEL: test_fma:
; CHECK:       # %bb.0:
; CHECK-NEXT:    zxhd $r3 = $r0
; CHECK-NEXT:    zxhd $r1 = $r1
; CHECK-NEXT:    ;;
; CHECK-NEXT:    zxhd $r0 = $r2
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ffmahq $r0 = $r3, $r1
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %r = call half @llvm.fma.f16(half %a, half %b, half %c)
  ret half %r
}

define half @test_fabs(half %a) #0 {
; CHECK-LABEL: test_fabs:
; CHECK:       # %bb.0:
; CHECK-NEXT:    fabshq $r0 = $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %r = call half @llvm.fabs.f16(half %a)
  ret half %r
}

define half @test_minnum(half %a, half %b) #0 {
; CHECK-LABEL: test_minnum:
; CHECK:       # %bb.0:
; CHECK-NEXT:    addd $r12 = $r12, -32
; CHECK-NEXT:    get $r16 = $ra
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sd 0[$r12] = $r16
; CHECK-NEXT:    fwidenlhw $r0 = $r0
; CHECK-NEXT:    fwidenlhw $r1 = $r1
; CHECK-NEXT:    call fminf
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ld $r16 = 0[$r12]
; CHECK-NEXT:    fnarrowwh $r0 = $r0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    set $ra = $r16
; CHECK-NEXT:    addd $r12 = $r12, 32
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %r = call half @llvm.minnum.f16(half %a, half %b)
  ret half %r
}

define half @test_minnum_fast(half %a, half %b) #0 {
; CHECK-LABEL: test_minnum_fast:
; CHECK:       # %bb.0:
; CHECK-NEXT:    fminhq $r0 = $r0, $r1
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %r = call fast half @llvm.minnum.f16(half %a, half %b)
  ret half %r
}

define half @test_maxnum(half %a, half %b) #0 {
; CHECK-LABEL: test_maxnum:
; CHECK:       # %bb.0:
; CHECK-NEXT:    addd $r12 = $r12, -32
; CHECK-NEXT:    get $r16 = $ra
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sd 0[$r12] = $r16
; CHECK-NEXT:    fwidenlhw $r0 = $r0
; CHECK-NEXT:    fwidenlhw $r1 = $r1
; CHECK-NEXT:    call fmaxf
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ld $r16 = 0[$r12]
; CHECK-NEXT:    fnarrowwh $r0 = $r0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    set $ra = $r16
; CHECK-NEXT:    addd $r12 = $r12, 32
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %r = call half @llvm.maxnum.f16(half %a, half %b)
  ret half %r
}

define half @test_maxnum_fast(half %a, half %b) #0 {
; CHECK-LABEL: test_maxnum_fast:
; CHECK:       # %bb.0:
; CHECK-NEXT:    fmaxhq $r0 = $r0, $r1
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %r = call fast half @llvm.maxnum.f16(half %a, half %b)
  ret half %r
}

define half @test_copysign(half %a, half %b) #0 {
; CHECK-LABEL: test_copysign:
; CHECK:       # %bb.0:
; CHECK-NEXT:    sraw $r1 = $r1, 15
; CHECK-NEXT:    ;;
; CHECK-NEXT:    insf $r0 = $r1, 15, 15
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %r = call half @llvm.copysign.f16(half %a, half %b)
  ret half %r
}

define half @test_copysign_f32(half %a, float %b) #0 {
; CHECK-LABEL: test_copysign_f32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    sraw $r1 = $r1, 31
; CHECK-NEXT:    ;;
; CHECK-NEXT:    insf $r0 = $r1, 15, 15
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %tb = fptrunc float %b to half
  %r = call half @llvm.copysign.f16(half %a, half %tb)
  ret half %r
}

define half @test_copysign_f64(half %a, double %b) #0 {
; CHECK-LABEL: test_copysign_f64:
; CHECK:       # %bb.0:
; CHECK-NEXT:    srad $r1 = $r1, 63
; CHECK-NEXT:    ;;
; CHECK-NEXT:    insf $r0 = $r1, 15, 15
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %tb = fptrunc double %b to half
  %r = call half @llvm.copysign.f16(half %a, half %tb)
  ret half %r
}

define float @test_copysign_extended(half %a, half %b) #0 {
; CHECK-LABEL: test_copysign_extended:
; CHECK:       # %bb.0:
; CHECK-NEXT:    sraw $r1 = $r1, 15
; CHECK-NEXT:    ;;
; CHECK-NEXT:    insf $r0 = $r1, 15, 15
; CHECK-NEXT:    ;;
; CHECK-NEXT:    fwidenlhw $r0 = $r0
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %r = call half @llvm.copysign.f16(half %a, half %b)
  %xr = fpext half %r to float
  ret float %xr
}

define half @test_floor(half %a) #0 {
; CHECK-LABEL: test_floor:
; CHECK:       # %bb.0:
; CHECK-NEXT:    addd $r12 = $r12, -32
; CHECK-NEXT:    get $r16 = $ra
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sd 0[$r12] = $r16
; CHECK-NEXT:    fwidenlhw $r0 = $r0
; CHECK-NEXT:    call floorf
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ld $r16 = 0[$r12]
; CHECK-NEXT:    fnarrowwh $r0 = $r0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    set $ra = $r16
; CHECK-NEXT:    addd $r12 = $r12, 32
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %r = call half @llvm.floor.f16(half %a)
  ret half %r
}

define half @test_ceil(half %a) #0 {
; CHECK-LABEL: test_ceil:
; CHECK:       # %bb.0:
; CHECK-NEXT:    addd $r12 = $r12, -32
; CHECK-NEXT:    get $r16 = $ra
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sd 0[$r12] = $r16
; CHECK-NEXT:    fwidenlhw $r0 = $r0
; CHECK-NEXT:    call ceilf
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ld $r16 = 0[$r12]
; CHECK-NEXT:    fnarrowwh $r0 = $r0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    set $ra = $r16
; CHECK-NEXT:    addd $r12 = $r12, 32
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %r = call half @llvm.ceil.f16(half %a)
  ret half %r
}

define half @test_trunc(half %a) #0 {
; CHECK-LABEL: test_trunc:
; CHECK:       # %bb.0:
; CHECK-NEXT:    addd $r12 = $r12, -32
; CHECK-NEXT:    get $r16 = $ra
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sd 0[$r12] = $r16
; CHECK-NEXT:    fwidenlhw $r0 = $r0
; CHECK-NEXT:    call truncf
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ld $r16 = 0[$r12]
; CHECK-NEXT:    fnarrowwh $r0 = $r0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    set $ra = $r16
; CHECK-NEXT:    addd $r12 = $r12, 32
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %r = call half @llvm.trunc.f16(half %a)
  ret half %r
}

define half @test_rint(half %a) #0 {
; CHECK-LABEL: test_rint:
; CHECK:       # %bb.0:
; CHECK-NEXT:    addd $r12 = $r12, -32
; CHECK-NEXT:    get $r16 = $ra
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sd 0[$r12] = $r16
; CHECK-NEXT:    fwidenlhw $r0 = $r0
; CHECK-NEXT:    call rintf
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ld $r16 = 0[$r12]
; CHECK-NEXT:    fnarrowwh $r0 = $r0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    set $ra = $r16
; CHECK-NEXT:    addd $r12 = $r12, 32
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %r = call half @llvm.rint.f16(half %a)
  ret half %r
}

define half @test_nearbyint(half %a) #0 {
; CHECK-LABEL: test_nearbyint:
; CHECK:       # %bb.0:
; CHECK-NEXT:    addd $r12 = $r12, -32
; CHECK-NEXT:    get $r16 = $ra
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sd 0[$r12] = $r16
; CHECK-NEXT:    fwidenlhw $r0 = $r0
; CHECK-NEXT:    call nearbyintf
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ld $r16 = 0[$r12]
; CHECK-NEXT:    fnarrowwh $r0 = $r0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    set $ra = $r16
; CHECK-NEXT:    addd $r12 = $r12, 32
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %r = call half @llvm.nearbyint.f16(half %a)
  ret half %r
}

define half @test_round(half %a) #0 {
; CHECK-LABEL: test_round:
; CHECK:       # %bb.0:
; CHECK-NEXT:    addd $r12 = $r12, -32
; CHECK-NEXT:    get $r16 = $ra
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sd 0[$r12] = $r16
; CHECK-NEXT:    fwidenlhw $r0 = $r0
; CHECK-NEXT:    call roundf
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ld $r16 = 0[$r12]
; CHECK-NEXT:    fnarrowwh $r0 = $r0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    set $ra = $r16
; CHECK-NEXT:    addd $r12 = $r12, 32
; CHECK-NEXT:    ;;
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %r = call half @llvm.round.f16(half %a)
  ret half %r
}

define half @test_fmuladd(half %a, half %b, half %c) #0 {
; CHECK-LABEL: test_fmuladd:
; CHECK:       # %bb.0:
; CHECK-NEXT:    zxhd $r1 = $r1
; CHECK-NEXT:    zxhd $r0 = $r0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    fmulhq $r0 = $r0, $r1
; CHECK-NEXT:    zxhd $r1 = $r2
; CHECK-NEXT:    ;;
; CHECK-NEXT:    zxhd $r0 = $r0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    faddhq $r0 = $r0, $r1
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %r = call half @llvm.fmuladd.f16(half %a, half %b, half %c)
  ret half %r
}

attributes #0 = { nounwind }
attributes #1 = { "unsafe-fp-math" = "true" }
