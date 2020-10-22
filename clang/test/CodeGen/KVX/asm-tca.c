// NOTE: Assertions have been autogenerated by utils/update_cc_test_checks.py
// RUN: %clang_cc1 -triple kvx-kalray-cos -emit-llvm %s -O2 -o - | FileCheck %s

// CHECK-LABEL: @asm_tca(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[ADD:%.*]] = add nsw i64 [[A:%.*]], 1
// CHECK-NEXT:    [[TMP0:%.*]] = tail call { <256 x i1>, <256 x i1> } asm sideeffect "lv $0 = $3[$2]\0A\09
// CHECK-NEXT:    [[ASMRESULT:%.*]] = extractvalue { <256 x i1>, <256 x i1> } [[TMP0]], 0
// CHECK-NEXT:    [[ASMRESULT1:%.*]] = extractvalue { <256 x i1>, <256 x i1> } [[TMP0]], 1
// CHECK-NEXT:    [[TMP1:%.*]] = tail call <256 x i1> asm sideeffect "copyv $0 = $1\0A\09
// CHECK-NEXT:    ret void
//
void asm_tca(void *v, long A) {
  long B = A + 1;
  __tca256 out1, out2, out3;
  __asm__ volatile("lv %0 = %3[%2]\n\t;;\n\t"
                   "lv.s %1 = %4[%2]\n\t;;"
                   : "=w"(out1), "=w"(out2)
                   : "r"(v), "r"(A), "r"(B)
                   : "$r0");
  __asm__ volatile("copyv %0 = %1\n\t;;\n\t"
                   "sv 0[%3] = %2"
                   : "=w"(out3)
                   : "w"(out1), "w"(out2), "r"(v)
                   :);
}

// CHECK-LABEL: @asm_clobber_vec_vec(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call <256 x i1> asm sideeffect "copyv $0 = $1", "=w,w,~{$a0}"(<256 x i1> undef) #3, !srcloc !4
// CHECK-NEXT:    ret void
//
void asm_clobber_vec_vec(long A) {
  __tca256 v4i64;
  __tca256 tcav4i64;
  __asm__ volatile("copyv %0 = %1"
                   : "=w"(v4i64)
                   : "w"(tcav4i64)
                   : "$a0");
}

// CHECK-LABEL: @asm_clobber_vec_block(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call <256 x i1> asm sideeffect "copyv $0 = $1", "=w,w,~{$a0.hi}"(<256 x i1> undef) #3, !srcloc !5
// CHECK-NEXT:    ret void
//
void asm_clobber_vec_block(long A) {
  __tca256 v4i64;
  __tca256 tcav4i64;
  __asm__ volatile("copyv %0 = %1"
                   : "=w"(v4i64)
                   : "w"(tcav4i64)
                   : "$a0.hi");
}

// CHECK-LABEL: @asm_clobber_wide_vec(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = load <256 x i1>, <256 x i1>* [[A:%.*]], align 32, !tbaa !6
// CHECK-NEXT:    tail call void asm sideeffect "copyv $0 = $0", "w,~{$r0r1r2r3},~{$a0a1}"(<256 x i1> [[TMP0]]) #3, !srcloc !10
// CHECK-NEXT:    ret void
//
void asm_clobber_wide_vec(__tca256 *a) {
  __asm__ volatile("copyv %0 = %0"
                   :
                   : "w"(a[0])
                   : "$r0r1r2r3", "$a0a1");
}

// CHECK-LABEL: @asm_clobber_multiple_quad(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = load <256 x i1>, <256 x i1>* [[C:%.*]], align 32, !tbaa !6
// CHECK-NEXT:    [[TMP1:%.*]] = tail call { <256 x i1>, <256 x i1> } asm sideeffect "copyv $0 = $1\0A\09
// CHECK-NEXT:    [[ASMRESULT:%.*]] = extractvalue { <256 x i1>, <256 x i1> } [[TMP1]], 0
// CHECK-NEXT:    [[ASMRESULT3:%.*]] = extractvalue { <256 x i1>, <256 x i1> } [[TMP1]], 1
// CHECK-NEXT:    store <256 x i1> [[ASMRESULT]], <256 x i1>* [[C]], align 32, !tbaa !6
// CHECK-NEXT:    store <256 x i1> [[ASMRESULT3]], <256 x i1>* [[B:%.*]], align 32, !tbaa !6
// CHECK-NEXT:    ret void
//
void asm_clobber_multiple_quad(__tca256 *c, __tca256 *b) {
  __asm__ volatile("copyv %0 = %1\n\t;;\n\tcopyv %1 = %0"
                   : "=w"(c[0]), "=w"(b[0])
                   : "w"(c[0])
                   : "$r0r1r2r3", "$a0a1a2a3");
}

// CHECK-LABEL: @asm_clobber_quad_matrix(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = load <256 x i1>, <256 x i1>* [[A:%.*]], align 32, !tbaa !6
// CHECK-NEXT:    tail call void asm sideeffect "sv 0[$$r3] = $0", "w,~{$r0r1r2r3},~{$a0a1a2a3}"(<256 x i1> [[TMP0]]) #3, !srcloc !12
// CHECK-NEXT:    ret <256 x i1>* [[A]]
//
__tca256 *asm_clobber_quad_matrix(__tca256 *a) {
  __asm__ volatile("sv 0[$r3] = %0"
                   :
                   : "w"(a[0])
                   : "$r0r1r2r3", "$a0a1a2a3");
  return a;
}

// CHECK-LABEL: @use_wide_reg(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = load <512 x i1>, <512 x i1>* [[W:%.*]], align 64, !tbaa !13
// CHECK-NEXT:    [[TMP1:%.*]] = load <256 x i1>, <256 x i1>* [[V:%.*]], align 32, !tbaa !6
// CHECK-NEXT:    [[TMP2:%.*]] = tail call <512 x i1> asm sideeffect "mma484bw $0 = $0, $1, $1", "=w,w,0,~{$r0r1r2r3},~{$a0a1a2a3}"(<256 x i1> [[TMP1]], <512 x i1> [[TMP0]]) #3, !srcloc !15
// CHECK-NEXT:    store <512 x i1> [[TMP2]], <512 x i1>* [[W]], align 64, !tbaa !13
// CHECK-NEXT:    ret void
//
void use_wide_reg(__tca512 *w, __tca256 *v) {
  __asm__ volatile("mma484bw %0 = %0, %1, %1"
                   : "+w"(w[0])
                   : "w"(v[0])
                   : "$r0r1r2r3", "$a0a1a2a3");
}

// CHECK-LABEL: @use_matrix_reg(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = load <1024 x i1>, <1024 x i1>* [[X:%.*]], align 128, !tbaa !16
// CHECK-NEXT:    [[TMP1:%.*]] = tail call <1024 x i1> asm sideeffect "mt44d $0 = $0", "=w,0,~{$r0r1r2r3},~{$a0a1a2a3}"(<1024 x i1> [[TMP0]]) #3, !srcloc !18
// CHECK-NEXT:    store <1024 x i1> [[TMP1]], <1024 x i1>* [[X]], align 128, !tbaa !16
// CHECK-NEXT:    ret void
//
void use_matrix_reg(__tca1024 *x) {
  __asm__ volatile("mt44d %0 = %0"
                   : "+w"(x[0])
                   :
                   : "$r0r1r2r3", "$a0a1a2a3");
}
