// NOTE: Assertions have been autogenerated by utils/update_cc_test_checks.py
// RUN: %clang_cc1 -triple kvx-kalray-cos -fno-unroll-loops -emit-llvm %s -O2 -o - | FileCheck %s

// CHECK-LABEL: @addcarry(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[CMP4_NOT:%.*]] = icmp eq i32 [[N:%.*]], 0
// CHECK-NEXT:    br i1 [[CMP4_NOT]], label [[FOR_COND_CLEANUP:%.*]], label [[FOR_BODY:%.*]]
// CHECK:       for.cond.cleanup:
// CHECK-NEXT:    [[S_0_LCSSA:%.*]] = phi i64 [ 0, [[ENTRY:%.*]] ], [ [[ADD:%.*]], [[FOR_BODY]] ]
// CHECK-NEXT:    ret i64 [[S_0_LCSSA]]
// CHECK:       for.body:
// CHECK-NEXT:    [[S_06:%.*]] = phi i64 [ [[ADD]], [[FOR_BODY]] ], [ 0, [[ENTRY]] ]
// CHECK-NEXT:    [[I_05:%.*]] = phi i32 [ [[INC:%.*]], [[FOR_BODY]] ], [ 0, [[ENTRY]] ]
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.kvx.addcd(i64 [[A:%.*]], i64 [[B:%.*]], i32 0)
// CHECK-NEXT:    [[TMP1:%.*]] = tail call i64 @llvm.kvx.addcd(i64 [[TMP0]], i64 [[B]], i32 0)
// CHECK-NEXT:    [[ADD]] = add i64 [[TMP1]], [[S_06]]
// CHECK-NEXT:    [[INC]] = add nuw i32 [[I_05]], 1
// CHECK-NEXT:    [[EXITCOND_NOT:%.*]] = icmp eq i32 [[INC]], [[N]]
// CHECK-NEXT:    br i1 [[EXITCOND_NOT]], label [[FOR_COND_CLEANUP]], label [[FOR_BODY]], !llvm.loop [[LOOP2:![0-9]+]]
//
unsigned long addcarry(unsigned long a, unsigned long b, unsigned n){
  unsigned long S = 0;
  for (int i = 0; i < n; i++){
      unsigned long toto = __builtin_kvx_addcd(a, b, "");
      unsigned long titi = __builtin_kvx_addcd(toto, b, "");
      S += titi;
  }
  return S;
}
