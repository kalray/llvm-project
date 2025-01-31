; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mcpu=kv3-1 -verify-machineinstrs -o - %s | FileCheck %s --check-prefixes=CHECK,CV1
; RUN: llc -mcpu=kv3-2 -verify-machineinstrs -o - %s | FileCheck %s --check-prefixes=CHECK,CV2
; RUN: clang -c -o /dev/null %s
; RUN: clang -march=kv3-2 -c -o /dev/null %s

target triple = "kvx-kalray-cos"

%struct.atomic_flag = type { i8 }

; Function Attrs: noinline nounwind optnone
define dso_local i32 @a() {
; CHECK-LABEL: a:
; CHECK:       # %bb.0:
; CHECK-NEXT:    addd $r12 = $r12, -32
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    lwz $r0 = 28[$r12]
; CHECK-NEXT:    addd $r12 = $r12, 32
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 1)
  %1 = alloca i32, align 4
  %2 = load i32, i32* %1, align 4
  ret i32 %2
}

; Function Attrs: noinline nounwind optnone
define internal i1 @atomic_flag_test_and_set(%struct.atomic_flag* %0) {
; CHECK-LABEL: atomic_flag_test_and_set:
; CHECK:       # %bb.0:
; CHECK-NEXT:    make $r1 = 5
; CHECK-NEXT:    addd $r12 = $r12, -32
; CHECK-NEXT:    get $r16 = $ra
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    sd 24[$r12] = $r16
; CHECK-NEXT:    ;; # (end cycle 1)
; CHECK-NEXT:    sd 16[$r12] = $r0
; CHECK-NEXT:    call atomic_flag_test_and_set_explicit
; CHECK-NEXT:    ;; # (end cycle 2)
; CHECK-NEXT:    ld $r16 = 24[$r12]
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    set $ra = $r16
; CHECK-NEXT:    addd $r12 = $r12, 32
; CHECK-NEXT:    ;; # (end cycle 5)
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
  %2 = alloca %struct.atomic_flag*, align 8
  store %struct.atomic_flag* %0, %struct.atomic_flag** %2, align 8
  %3 = load %struct.atomic_flag*, %struct.atomic_flag** %2, align 8
  %4 = call i1 @atomic_flag_test_and_set_explicit(%struct.atomic_flag* %3, i32 5)
  ret i1 %4
}

; Function Attrs: noinline nounwind optnone
define internal i1 @atomic_flag_test_and_set_explicit(%struct.atomic_flag* %0, i32 %1) {
; CV1-LABEL: atomic_flag_test_and_set_explicit:
; CV1:       # %bb.0:
; CV1-NEXT:    make $r2 = 1
; CV1-NEXT:    addd $r12 = $r12, -32
; CV1-NEXT:    ;; # (end cycle 0)
; CV1-NEXT:    sb 19[$r12] = $r2
; CV1-NEXT:    compw.gt $r2 = $r1, 3
; CV1-NEXT:    ;; # (end cycle 1)
; CV1-NEXT:    sd 24[$r12] = $r0
; CV1-NEXT:    ;; # (end cycle 2)
; CV1-NEXT:    sw 20[$r12] = $r1
; CV1-NEXT:    cb.odd $r2 ? .LBB2_3
; CV1-NEXT:    ;; # (end cycle 3)
; CV1-NEXT:  # %bb.1:
; CV1-NEXT:    addw $r2 = $r1, -1
; CV1-NEXT:    ;; # (end cycle 0)
; CV1-NEXT:    compw.ltu $r2 = $r2, 2
; CV1-NEXT:    ;; # (end cycle 1)
; CV1-NEXT:    cb.even $r2 ? .LBB2_11
; CV1-NEXT:    ;;
; CV1-NEXT:  # %bb.2:
; CV1-NEXT:    lbz $r1 = 19[$r12]
; CV1-NEXT:    goto .LBB2_6
; CV1-NEXT:    ;; # (end cycle 0)
; CV1-NEXT:  .LBB2_3:
; CV1-NEXT:    compw.eq $r2 = $r1, 4
; CV1-NEXT:    ;; # (end cycle 0)
; CV1-NEXT:    cb.odd $r2 ? .LBB2_5
; CV1-NEXT:    ;;
; CV1-NEXT:  # %bb.4:
; CV1-NEXT:    compw.eq $r1 = $r1, 5
; CV1-NEXT:    ;; # (end cycle 0)
; CV1-NEXT:    cb.even $r1 ? .LBB2_15
; CV1-NEXT:    ;;
; CV1-NEXT:  .LBB2_5:
; CV1-NEXT:    lbz $r1 = 19[$r12]
; CV1-NEXT:    ;; # (end cycle 0)
; CV1-NEXT:    fence
; CV1-NEXT:    ;; # (end cycle 1)
; CV1-NEXT:  .LBB2_6:
; CV1-NEXT:    andd $r3 = $r0, 3
; CV1-NEXT:    ;; # (end cycle 0)
; CV1-NEXT:    slld $r3 = $r3, 3
; CV1-NEXT:    sbfd $r7 = $r3, 0
; CV1-NEXT:    ;; # (end cycle 1)
; CV1-NEXT:  .LBB2_7: # =>This Inner Loop Header: Depth=1
; CV1-NEXT:    lwz.u $r5 = $r7[$r0]
; CV1-NEXT:    sllw $r6 = $r1, $r3
; CV1-NEXT:    ;; # (end cycle 0)
; CV1-NEXT:    srlw $r2 = $r5, $r3
; CV1-NEXT:    iorw $r4 = $r5, $r6
; CV1-NEXT:    ;; # (end cycle 3)
; CV1-NEXT:    andw $r2 = $r2, 255
; CV1-NEXT:    ;; # (end cycle 4)
; CV1-NEXT:    cb.wnez $r2 ? .LBB2_9
; CV1-NEXT:    ;;
; CV1-NEXT:  # %bb.8: # in Loop: Header=BB2_7 Depth=1
; CV1-NEXT:    acswapw $r7[$r0] = $r4r5
; CV1-NEXT:    ;; # (end cycle 0)
; CV1-NEXT:    cb.even $r4 ? .LBB2_7
; CV1-NEXT:    ;;
; CV1-NEXT:  .LBB2_9: # Label of block must be emitted
; CV1-NEXT:    fence
; CV1-NEXT:    ;; # (end cycle 0)
; CV1-NEXT:  .LBB2_10:
; CV1-NEXT:    sb 18[$r12] = $r2
; CV1-NEXT:    ;; # (end cycle 0)
; CV1-NEXT:    lbz $r0 = 18[$r12]
; CV1-NEXT:    addd $r12 = $r12, 32
; CV1-NEXT:    ret
; CV1-NEXT:    ;; # (end cycle 1)
; CV1-NEXT:  .LBB2_11:
; CV1-NEXT:    compw.eq $r1 = $r1, 3
; CV1-NEXT:    ;; # (end cycle 0)
; CV1-NEXT:    cb.even $r1 ? .LBB2_15
; CV1-NEXT:    ;;
; CV1-NEXT:  # %bb.12:
; CV1-NEXT:    lbz $r1 = 19[$r12]
; CV1-NEXT:    andd $r3 = $r0, 3
; CV1-NEXT:    ;; # (end cycle 0)
; CV1-NEXT:    fence
; CV1-NEXT:    slld $r3 = $r3, 3
; CV1-NEXT:    sbfd $r7 = $r3, 0
; CV1-NEXT:    ;; # (end cycle 1)
; CV1-NEXT:  .LBB2_13: # =>This Inner Loop Header: Depth=1
; CV1-NEXT:    lwz.u $r5 = $r7[$r0]
; CV1-NEXT:    sllw $r6 = $r1, $r3
; CV1-NEXT:    ;; # (end cycle 0)
; CV1-NEXT:    srlw $r2 = $r5, $r3
; CV1-NEXT:    iorw $r4 = $r5, $r6
; CV1-NEXT:    ;; # (end cycle 3)
; CV1-NEXT:    andw $r2 = $r2, 255
; CV1-NEXT:    ;; # (end cycle 4)
; CV1-NEXT:    cb.wnez $r2 ? .LBB2_10
; CV1-NEXT:    ;;
; CV1-NEXT:  # %bb.14: # in Loop: Header=BB2_13 Depth=1
; CV1-NEXT:    acswapw $r7[$r0] = $r4r5
; CV1-NEXT:    ;; # (end cycle 0)
; CV1-NEXT:    cb.even $r4 ? .LBB2_13
; CV1-NEXT:    ;;
; CV1-NEXT:    goto .LBB2_10
; CV1-NEXT:    ;;
; CV1-NEXT:  .LBB2_15:
; CV1-NEXT:    lbz $r1 = 19[$r12]
; CV1-NEXT:    andd $r3 = $r0, 3
; CV1-NEXT:    ;; # (end cycle 0)
; CV1-NEXT:    slld $r3 = $r3, 3
; CV1-NEXT:    sbfd $r7 = $r3, 0
; CV1-NEXT:    ;; # (end cycle 1)
; CV1-NEXT:  .LBB2_16: # =>This Inner Loop Header: Depth=1
; CV1-NEXT:    lwz.u $r5 = $r7[$r0]
; CV1-NEXT:    sllw $r6 = $r1, $r3
; CV1-NEXT:    ;; # (end cycle 0)
; CV1-NEXT:    srlw $r2 = $r5, $r3
; CV1-NEXT:    iorw $r4 = $r5, $r6
; CV1-NEXT:    ;; # (end cycle 3)
; CV1-NEXT:    andw $r2 = $r2, 255
; CV1-NEXT:    ;; # (end cycle 4)
; CV1-NEXT:    cb.wnez $r2 ? .LBB2_10
; CV1-NEXT:    ;;
; CV1-NEXT:  # %bb.17: # in Loop: Header=BB2_16 Depth=1
; CV1-NEXT:    acswapw $r7[$r0] = $r4r5
; CV1-NEXT:    ;; # (end cycle 0)
; CV1-NEXT:    cb.even $r4 ? .LBB2_16
; CV1-NEXT:    ;;
; CV1-NEXT:    goto .LBB2_10
; CV1-NEXT:    ;;
;
; CV2-LABEL: atomic_flag_test_and_set_explicit:
; CV2:       # %bb.0:
; CV2-NEXT:    make $r2 = 1
; CV2-NEXT:    addd $r12 = $r12, -32
; CV2-NEXT:    ;; # (end cycle 0)
; CV2-NEXT:    sb 19[$r12] = $r2
; CV2-NEXT:    compw.gt $r2 = $r1, 3
; CV2-NEXT:    ;; # (end cycle 1)
; CV2-NEXT:    sd 24[$r12] = $r0
; CV2-NEXT:    ;; # (end cycle 2)
; CV2-NEXT:    sw 20[$r12] = $r1
; CV2-NEXT:    cb.odd $r2 ? .LBB2_3
; CV2-NEXT:    ;; # (end cycle 3)
; CV2-NEXT:  # %bb.1:
; CV2-NEXT:    addw $r2 = $r1, -1
; CV2-NEXT:    ;; # (end cycle 0)
; CV2-NEXT:    compw.ltu $r2 = $r2, 2
; CV2-NEXT:    ;; # (end cycle 1)
; CV2-NEXT:    cb.even $r2 ? .LBB2_11
; CV2-NEXT:    ;;
; CV2-NEXT:  # %bb.2:
; CV2-NEXT:    lbz $r1 = 19[$r12]
; CV2-NEXT:    goto .LBB2_6
; CV2-NEXT:    ;; # (end cycle 0)
; CV2-NEXT:  .LBB2_3:
; CV2-NEXT:    compw.eq $r2 = $r1, 4
; CV2-NEXT:    ;; # (end cycle 0)
; CV2-NEXT:    cb.odd $r2 ? .LBB2_5
; CV2-NEXT:    ;;
; CV2-NEXT:  # %bb.4:
; CV2-NEXT:    compw.eq $r1 = $r1, 5
; CV2-NEXT:    ;; # (end cycle 0)
; CV2-NEXT:    cb.even $r1 ? .LBB2_15
; CV2-NEXT:    ;;
; CV2-NEXT:  .LBB2_5:
; CV2-NEXT:    lbz $r1 = 19[$r12]
; CV2-NEXT:    ;; # (end cycle 0)
; CV2-NEXT:    fence
; CV2-NEXT:    ;; # (end cycle 1)
; CV2-NEXT:  .LBB2_6:
; CV2-NEXT:    andd $r3 = $r0, 3
; CV2-NEXT:    ;; # (end cycle 0)
; CV2-NEXT:    slld $r3 = $r3, 3
; CV2-NEXT:    sbfd $r7 = $r3, 0
; CV2-NEXT:    ;; # (end cycle 1)
; CV2-NEXT:    addd $r0 = $r0, $r7
; CV2-NEXT:    ;; # (end cycle 2)
; CV2-NEXT:  .LBB2_7: # =>This Inner Loop Header: Depth=1
; CV2-NEXT:    lwz.u $r5 = 0[$r0]
; CV2-NEXT:    sllw $r6 = $r1, $r3
; CV2-NEXT:    ;; # (end cycle 0)
; CV2-NEXT:    srlw $r2 = $r5, $r3
; CV2-NEXT:    iorw $r4 = $r5, $r6
; CV2-NEXT:    ;; # (end cycle 3)
; CV2-NEXT:    andw $r2 = $r2, 255
; CV2-NEXT:    ;; # (end cycle 4)
; CV2-NEXT:    cb.wnez $r2 ? .LBB2_9
; CV2-NEXT:    ;;
; CV2-NEXT:  # %bb.8: # in Loop: Header=BB2_7 Depth=1
; CV2-NEXT:    acswapw $r4, [$r0] = $r4r5
; CV2-NEXT:    ;; # (end cycle 0)
; CV2-NEXT:    cb.even $r4 ? .LBB2_7
; CV2-NEXT:    ;;
; CV2-NEXT:  .LBB2_9: # Label of block must be emitted
; CV2-NEXT:    fence
; CV2-NEXT:    ;; # (end cycle 0)
; CV2-NEXT:  .LBB2_10:
; CV2-NEXT:    sb 18[$r12] = $r2
; CV2-NEXT:    ;; # (end cycle 0)
; CV2-NEXT:    lbz $r0 = 18[$r12]
; CV2-NEXT:    addd $r12 = $r12, 32
; CV2-NEXT:    ret
; CV2-NEXT:    ;; # (end cycle 1)
; CV2-NEXT:  .LBB2_11:
; CV2-NEXT:    compw.eq $r1 = $r1, 3
; CV2-NEXT:    ;; # (end cycle 0)
; CV2-NEXT:    cb.even $r1 ? .LBB2_15
; CV2-NEXT:    ;;
; CV2-NEXT:  # %bb.12:
; CV2-NEXT:    lbz $r1 = 19[$r12]
; CV2-NEXT:    andd $r3 = $r0, 3
; CV2-NEXT:    ;; # (end cycle 0)
; CV2-NEXT:    fence
; CV2-NEXT:    slld $r3 = $r3, 3
; CV2-NEXT:    sbfd $r7 = $r3, 0
; CV2-NEXT:    ;; # (end cycle 1)
; CV2-NEXT:    addd $r0 = $r0, $r7
; CV2-NEXT:    ;; # (end cycle 2)
; CV2-NEXT:  .LBB2_13: # =>This Inner Loop Header: Depth=1
; CV2-NEXT:    lwz.u $r5 = 0[$r0]
; CV2-NEXT:    sllw $r6 = $r1, $r3
; CV2-NEXT:    ;; # (end cycle 0)
; CV2-NEXT:    srlw $r2 = $r5, $r3
; CV2-NEXT:    iorw $r4 = $r5, $r6
; CV2-NEXT:    ;; # (end cycle 3)
; CV2-NEXT:    andw $r2 = $r2, 255
; CV2-NEXT:    ;; # (end cycle 4)
; CV2-NEXT:    cb.wnez $r2 ? .LBB2_10
; CV2-NEXT:    ;;
; CV2-NEXT:  # %bb.14: # in Loop: Header=BB2_13 Depth=1
; CV2-NEXT:    acswapw $r4, [$r0] = $r4r5
; CV2-NEXT:    ;; # (end cycle 0)
; CV2-NEXT:    cb.even $r4 ? .LBB2_13
; CV2-NEXT:    ;;
; CV2-NEXT:    goto .LBB2_10
; CV2-NEXT:    ;;
; CV2-NEXT:  .LBB2_15:
; CV2-NEXT:    lbz $r1 = 19[$r12]
; CV2-NEXT:    andd $r3 = $r0, 3
; CV2-NEXT:    ;; # (end cycle 0)
; CV2-NEXT:    slld $r3 = $r3, 3
; CV2-NEXT:    sbfd $r7 = $r3, 0
; CV2-NEXT:    ;; # (end cycle 1)
; CV2-NEXT:    addd $r0 = $r0, $r7
; CV2-NEXT:    ;; # (end cycle 2)
; CV2-NEXT:  .LBB2_16: # =>This Inner Loop Header: Depth=1
; CV2-NEXT:    lwz.u $r5 = 0[$r0]
; CV2-NEXT:    sllw $r6 = $r1, $r3
; CV2-NEXT:    ;; # (end cycle 0)
; CV2-NEXT:    srlw $r2 = $r5, $r3
; CV2-NEXT:    iorw $r4 = $r5, $r6
; CV2-NEXT:    ;; # (end cycle 3)
; CV2-NEXT:    andw $r2 = $r2, 255
; CV2-NEXT:    ;; # (end cycle 4)
; CV2-NEXT:    cb.wnez $r2 ? .LBB2_10
; CV2-NEXT:    ;;
; CV2-NEXT:  # %bb.17: # in Loop: Header=BB2_16 Depth=1
; CV2-NEXT:    acswapw $r4, [$r0] = $r4r5
; CV2-NEXT:    ;; # (end cycle 0)
; CV2-NEXT:    cb.even $r4 ? .LBB2_16
; CV2-NEXT:    ;;
; CV2-NEXT:    goto .LBB2_10
; CV2-NEXT:    ;;
  %3 = alloca %struct.atomic_flag*, align 8
  %4 = alloca i32, align 4
  %5 = alloca i8, align 1
  %6 = alloca i8, align 1
  store %struct.atomic_flag* %0, %struct.atomic_flag** %3, align 8
  store i32 %1, i32* %4, align 4
  %7 = load %struct.atomic_flag*, %struct.atomic_flag** %3, align 8
  %8 = getelementptr inbounds %struct.atomic_flag, %struct.atomic_flag* %7, i32 0, i32 0
  %9 = load i32, i32* %4, align 4
  store i8 1, i8* %5, align 1
  switch i32 %9, label %10 [
    i32 1, label %13
    i32 2, label %13
    i32 3, label %16
    i32 4, label %19
    i32 5, label %22
  ]

10:                                               ; preds = %2
  %11 = load i8, i8* %5, align 1
  %12 = atomicrmw volatile xchg i8* %8, i8 %11 monotonic
  store i8 %12, i8* %6, align 1
  br label %25

13:                                               ; preds = %2, %2
  %14 = load i8, i8* %5, align 1
  %15 = atomicrmw volatile xchg i8* %8, i8 %14 acquire
  store i8 %15, i8* %6, align 1
  br label %25

16:                                               ; preds = %2
  %17 = load i8, i8* %5, align 1
  %18 = atomicrmw volatile xchg i8* %8, i8 %17 release
  store i8 %18, i8* %6, align 1
  br label %25

19:                                               ; preds = %2
  %20 = load i8, i8* %5, align 1
  %21 = atomicrmw volatile xchg i8* %8, i8 %20 acq_rel
  store i8 %21, i8* %6, align 1
  br label %25

22:                                               ; preds = %2
  %23 = load i8, i8* %5, align 1
  %24 = atomicrmw volatile xchg i8* %8, i8 %23 seq_cst
  store i8 %24, i8* %6, align 1
  br label %25

25:                                               ; preds = %22, %19, %16, %13, %10
  %26 = load i8, i8* %6, align 1
  %27 = trunc i8 %26 to i1
  ret i1 %27
}
