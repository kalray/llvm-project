; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -O0 < %s | FileCheck %s
target triple = "kvx-kalray-cos"

define void @zeroinit256() {
; CHECK-LABEL: zeroinit256:
; CHECK:       # %bb.0:
; CHECK-NEXT:    addd $r12 = $r12, -64
; CHECK-NEXT:    ;;
; CHECK-NEXT:    .cfi_def_cfa_offset 64
; CHECK-NEXT:    # implicit-def: $a0
; CHECK-NEXT:    sv 32[$r12] = $a0
; CHECK-NEXT:    ;;
; CHECK-NEXT:  .LBB0_1: # =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    lv $a0 = 32[$r12]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    copyv $a1 = $a48
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sv 32[$r12] = $a1
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sv 0[$r12] = $a0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    goto .LBB0_1
; CHECK-NEXT:    ;;
  br label %1

1:
  %2 = phi <256 x i1> [ %3, %1 ], [ undef, %0 ]
  %3 = select i1 undef, <256 x i1> %2, <256 x i1> zeroinitializer
  br label %1
}

define void @zeroinit512() {
; CHECK-LABEL: zeroinit512:
; CHECK:       # %bb.0:
; CHECK-NEXT:    addd $r12 = $r12, -256
; CHECK-NEXT:    ;;
; CHECK-NEXT:    .cfi_def_cfa_offset 256
; CHECK-NEXT:    get $r16 = $ra
; CHECK-NEXT:    ;;
; CHECK-NEXT:    .cfi_register 67, 16
; CHECK-NEXT:    sd 248[$r12] = $r16
; CHECK-NEXT:    ;;
; CHECK-NEXT:    .cfi_offset 67, -8
; CHECK-NEXT:    sd 240[$r12] = $r14
; CHECK-NEXT:    ;;
; CHECK-NEXT:    .cfi_offset 14, -16
; CHECK-NEXT:    addd $r14 = $r12, 240
; CHECK-NEXT:    ;;
; CHECK-NEXT:    .cfi_def_cfa 14, 16
; CHECK-NEXT:    sd 232[$r12] = $r31
; CHECK-NEXT:    ;;
; CHECK-NEXT:    .cfi_offset 31, -24
; CHECK-NEXT:    andd $r31 = $r12, -64
; CHECK-NEXT:    ;;
; CHECK-NEXT:    # implicit-def: $w0
; CHECK-NEXT:    sv 128[$r31] = $a0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sv 160[$r31] = $a1
; CHECK-NEXT:    ;;
; CHECK-NEXT:  .LBB1_1: # =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    lv $a0 = 128[$r31]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    lv $a1 = 160[$r31]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    copyv $a2 = $a50
; CHECK-NEXT:    ;;
; CHECK-NEXT:    copyv $a3 = $a51
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sv 128[$r31] = $a2
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sv 160[$r31] = $a3
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sv 64[$r31] = $a0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sv 96[$r31] = $a1
; CHECK-NEXT:    ;;
; CHECK-NEXT:    goto .LBB1_1
; CHECK-NEXT:    ;;
  br label %1

1:
  %2 = phi <512 x i1> [ %3, %1 ], [ undef, %0 ]
  %3 = select i1 undef, <512 x i1> %2, <512 x i1> zeroinitializer
  br label %1
}

define void @zeroinit1024() {
; CHECK-LABEL: zeroinit1024:
; CHECK:       # %bb.0:
; CHECK-NEXT:    addd $r12 = $r12, -512
; CHECK-NEXT:    ;;
; CHECK-NEXT:    .cfi_def_cfa_offset 512
; CHECK-NEXT:    get $r16 = $ra
; CHECK-NEXT:    ;;
; CHECK-NEXT:    .cfi_register 67, 16
; CHECK-NEXT:    sd 504[$r12] = $r16
; CHECK-NEXT:    ;;
; CHECK-NEXT:    .cfi_offset 67, -8
; CHECK-NEXT:    sd 496[$r12] = $r14
; CHECK-NEXT:    ;;
; CHECK-NEXT:    .cfi_offset 14, -16
; CHECK-NEXT:    addd $r14 = $r12, 496
; CHECK-NEXT:    ;;
; CHECK-NEXT:    .cfi_def_cfa 14, 16
; CHECK-NEXT:    sd 488[$r12] = $r31
; CHECK-NEXT:    ;;
; CHECK-NEXT:    .cfi_offset 31, -24
; CHECK-NEXT:    andd $r31 = $r12, -128
; CHECK-NEXT:    ;;
; CHECK-NEXT:    # implicit-def: $x0
; CHECK-NEXT:    sv 256[$r31] = $a0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sv 288[$r31] = $a1
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sv 320[$r31] = $a2
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sv 352[$r31] = $a3
; CHECK-NEXT:    ;;
; CHECK-NEXT:  .LBB2_1: # =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    lv $a0 = 256[$r31]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    lv $a1 = 288[$r31]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    lv $a2 = 320[$r31]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    lv $a3 = 352[$r31]
; CHECK-NEXT:    ;;
; CHECK-NEXT:    copyv $a4 = $a48
; CHECK-NEXT:    ;;
; CHECK-NEXT:    copyv $a5 = $a49
; CHECK-NEXT:    ;;
; CHECK-NEXT:    copyv $a6 = $a50
; CHECK-NEXT:    ;;
; CHECK-NEXT:    copyv $a7 = $a51
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sv 256[$r31] = $a4
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sv 288[$r31] = $a5
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sv 320[$r31] = $a6
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sv 352[$r31] = $a7
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sv 128[$r31] = $a0
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sv 160[$r31] = $a1
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sv 192[$r31] = $a2
; CHECK-NEXT:    ;;
; CHECK-NEXT:    sv 224[$r31] = $a3
; CHECK-NEXT:    ;;
; CHECK-NEXT:    goto .LBB2_1
; CHECK-NEXT:    ;;
  br label %1

1:
  %2 = phi <1024 x i1> [ %3, %1 ], [ undef, %0 ]
  %3 = select i1 undef, <1024 x i1> %2, <1024 x i1> zeroinitializer
  br label %1
}
