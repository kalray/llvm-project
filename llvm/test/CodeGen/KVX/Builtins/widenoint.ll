; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mcpu=kv3-1 -O2 -o - %s | FileCheck %s --check-prefixes=ALL,CV1
; RUN: llc -mcpu=kv3-2 -O2 -o - %s | FileCheck %s --check-prefixes=ALL,CV2
; RUN: clang -O2 -c -o /dev/null %s
; RUN: clang -O2 -march=kv3-2 -c -o /dev/null %s

target triple = "kvx-kalray-cos"

define <8 x i16> @widenobho_(<16 x i8> %0) {
; ALL-LABEL: widenobho_:
; ALL:       # %bb.0:
; ALL-NEXT:    srahqs $r0 = $r0, 8
; ALL-NEXT:    srahqs $r1 = $r1, 8
; ALL-NEXT:    ret
; ALL-NEXT:    ;; # (end cycle 0)
  %2 = shufflevector <16 x i8> %0, <16 x i8> undef, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %3 = tail call <4 x i16> @llvm.kvx.wideninto.v4i16(<8 x i8> %2, i32 0)
  %4 = shufflevector <16 x i8> %0, <16 x i8> undef, <8 x i32> <i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  %5 = tail call <4 x i16> @llvm.kvx.wideninto.v4i16(<8 x i8> %4, i32 0)
  %6 = shufflevector <4 x i16> %3, <4 x i16> %5, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  ret <8 x i16> %6
}

declare <4 x i16> @llvm.kvx.wideninto.v4i16(<8 x i8>, i32)

define <8 x i16> @widenobho_z(<16 x i8> %0) {
; ALL-LABEL: widenobho_z:
; ALL:       # %bb.0:
; ALL-NEXT:    srlhqs $r0 = $r0, 8
; ALL-NEXT:    srlhqs $r1 = $r1, 8
; ALL-NEXT:    ret
; ALL-NEXT:    ;; # (end cycle 0)
  %2 = shufflevector <16 x i8> %0, <16 x i8> undef, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %3 = tail call <4 x i16> @llvm.kvx.wideninto.v4i16(<8 x i8> %2, i32 1)
  %4 = shufflevector <16 x i8> %0, <16 x i8> undef, <8 x i32> <i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  %5 = tail call <4 x i16> @llvm.kvx.wideninto.v4i16(<8 x i8> %4, i32 1)
  %6 = shufflevector <4 x i16> %3, <4 x i16> %5, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  ret <8 x i16> %6
}

define <8 x i16> @widenobho_q(<16 x i8> %0) {
; ALL-LABEL: widenobho_q:
; ALL:       # %bb.0:
; ALL-NEXT:    andd $r0 = $r0, 0xff00ff00.@
; ALL-NEXT:    andd $r1 = $r1, 0xff00ff00.@
; ALL-NEXT:    ret
; ALL-NEXT:    ;; # (end cycle 0)
  %2 = shufflevector <16 x i8> %0, <16 x i8> undef, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %3 = tail call <4 x i16> @llvm.kvx.wideninto.v4i16(<8 x i8> %2, i32 2)
  %4 = shufflevector <16 x i8> %0, <16 x i8> undef, <8 x i32> <i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  %5 = tail call <4 x i16> @llvm.kvx.wideninto.v4i16(<8 x i8> %4, i32 2)
  %6 = shufflevector <4 x i16> %3, <4 x i16> %5, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  ret <8 x i16> %6
}

define <2 x i16> @widenobhp_(<4 x i8> %0) {
; ALL-LABEL: widenobhp_:
; ALL:       # %bb.0:
; ALL-NEXT:    srahqs $r0 = $r0, 8
; ALL-NEXT:    ret
; ALL-NEXT:    ;; # (end cycle 0)
  %2 = tail call <2 x i16> @llvm.kvx.wideninto.v2i16(<4 x i8> %0, i32 0)
  ret <2 x i16> %2
}

declare <2 x i16> @llvm.kvx.wideninto.v2i16(<4 x i8>, i32)

define <2 x i16> @widenobhp_z(<4 x i8> %0) {
; ALL-LABEL: widenobhp_z:
; ALL:       # %bb.0:
; ALL-NEXT:    srlhqs $r0 = $r0, 8
; ALL-NEXT:    ret
; ALL-NEXT:    ;; # (end cycle 0)
  %2 = tail call <2 x i16> @llvm.kvx.wideninto.v2i16(<4 x i8> %0, i32 1)
  ret <2 x i16> %2
}

define <2 x i16> @widenobhp_q(<4 x i8> %0) {
; ALL-LABEL: widenobhp_q:
; ALL:       # %bb.0:
; ALL-NEXT:    andw $r0 = $r0, 0xff00ff00
; ALL-NEXT:    ret
; ALL-NEXT:    ;; # (end cycle 0)
  %2 = tail call <2 x i16> @llvm.kvx.wideninto.v2i16(<4 x i8> %0, i32 2)
  ret <2 x i16> %2
}

define <4 x i16> @widenobhq_(<8 x i8> %0) {
; ALL-LABEL: widenobhq_:
; ALL:       # %bb.0:
; ALL-NEXT:    srahqs $r0 = $r0, 8
; ALL-NEXT:    ret
; ALL-NEXT:    ;; # (end cycle 0)
  %2 = tail call <4 x i16> @llvm.kvx.wideninto.v4i16(<8 x i8> %0, i32 0)
  ret <4 x i16> %2
}

define <4 x i16> @widenobhq_z(<8 x i8> %0) {
; ALL-LABEL: widenobhq_z:
; ALL:       # %bb.0:
; ALL-NEXT:    srlhqs $r0 = $r0, 8
; ALL-NEXT:    ret
; ALL-NEXT:    ;; # (end cycle 0)
  %2 = tail call <4 x i16> @llvm.kvx.wideninto.v4i16(<8 x i8> %0, i32 1)
  ret <4 x i16> %2
}

define <4 x i16> @widenobhq_q(<8 x i8> %0) {
; ALL-LABEL: widenobhq_q:
; ALL:       # %bb.0:
; ALL-NEXT:    andd $r0 = $r0, 0xff00ff00.@
; ALL-NEXT:    ret
; ALL-NEXT:    ;; # (end cycle 0)
  %2 = tail call <4 x i16> @llvm.kvx.wideninto.v4i16(<8 x i8> %0, i32 2)
  ret <4 x i16> %2
}

define <16 x i16> @widenobhx_(<32 x i8> %0) {
; CV1-LABEL: widenobhx_:
; CV1:       # %bb.0:
; CV1-NEXT:    srahqs $r0 = $r0, 8
; CV1-NEXT:    srahqs $r1 = $r1, 8
; CV1-NEXT:    ;; # (end cycle 0)
; CV1-NEXT:    srahqs $r2 = $r2, 8
; CV1-NEXT:    srahqs $r3 = $r3, 8
; CV1-NEXT:    ret
; CV1-NEXT:    ;; # (end cycle 1)
;
; CV2-LABEL: widenobhx_:
; CV2:       # %bb.0:
; CV2-NEXT:    srahqs $r0 = $r0, 8
; CV2-NEXT:    srahqs $r1 = $r1, 8
; CV2-NEXT:    srahqs $r2 = $r2, 8
; CV2-NEXT:    srahqs $r3 = $r3, 8
; CV2-NEXT:    ret
; CV2-NEXT:    ;; # (end cycle 0)
  %2 = shufflevector <32 x i8> %0, <32 x i8> undef, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %3 = tail call <4 x i16> @llvm.kvx.wideninto.v4i16(<8 x i8> %2, i32 0)
  %4 = shufflevector <32 x i8> %0, <32 x i8> undef, <8 x i32> <i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  %5 = tail call <4 x i16> @llvm.kvx.wideninto.v4i16(<8 x i8> %4, i32 0)
  %6 = shufflevector <32 x i8> %0, <32 x i8> undef, <8 x i32> <i32 16, i32 17, i32 18, i32 19, i32 20, i32 21, i32 22, i32 23>
  %7 = tail call <4 x i16> @llvm.kvx.wideninto.v4i16(<8 x i8> %6, i32 0)
  %8 = shufflevector <32 x i8> %0, <32 x i8> undef, <8 x i32> <i32 24, i32 25, i32 26, i32 27, i32 28, i32 29, i32 30, i32 31>
  %9 = tail call <4 x i16> @llvm.kvx.wideninto.v4i16(<8 x i8> %8, i32 0)
  %10 = shufflevector <4 x i16> %3, <4 x i16> %5, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %11 = shufflevector <4 x i16> %7, <4 x i16> %9, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %12 = shufflevector <8 x i16> %10, <8 x i16> %11, <16 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  ret <16 x i16> %12
}

define <16 x i16> @widenobhx_z(<32 x i8> %0) {
; CV1-LABEL: widenobhx_z:
; CV1:       # %bb.0:
; CV1-NEXT:    srlhqs $r0 = $r0, 8
; CV1-NEXT:    srlhqs $r1 = $r1, 8
; CV1-NEXT:    ;; # (end cycle 0)
; CV1-NEXT:    srlhqs $r2 = $r2, 8
; CV1-NEXT:    srlhqs $r3 = $r3, 8
; CV1-NEXT:    ret
; CV1-NEXT:    ;; # (end cycle 1)
;
; CV2-LABEL: widenobhx_z:
; CV2:       # %bb.0:
; CV2-NEXT:    srlhqs $r0 = $r0, 8
; CV2-NEXT:    srlhqs $r1 = $r1, 8
; CV2-NEXT:    srlhqs $r2 = $r2, 8
; CV2-NEXT:    srlhqs $r3 = $r3, 8
; CV2-NEXT:    ret
; CV2-NEXT:    ;; # (end cycle 0)
  %2 = shufflevector <32 x i8> %0, <32 x i8> undef, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %3 = tail call <4 x i16> @llvm.kvx.wideninto.v4i16(<8 x i8> %2, i32 1)
  %4 = shufflevector <32 x i8> %0, <32 x i8> undef, <8 x i32> <i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  %5 = tail call <4 x i16> @llvm.kvx.wideninto.v4i16(<8 x i8> %4, i32 1)
  %6 = shufflevector <32 x i8> %0, <32 x i8> undef, <8 x i32> <i32 16, i32 17, i32 18, i32 19, i32 20, i32 21, i32 22, i32 23>
  %7 = tail call <4 x i16> @llvm.kvx.wideninto.v4i16(<8 x i8> %6, i32 1)
  %8 = shufflevector <32 x i8> %0, <32 x i8> undef, <8 x i32> <i32 24, i32 25, i32 26, i32 27, i32 28, i32 29, i32 30, i32 31>
  %9 = tail call <4 x i16> @llvm.kvx.wideninto.v4i16(<8 x i8> %8, i32 1)
  %10 = shufflevector <4 x i16> %3, <4 x i16> %5, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %11 = shufflevector <4 x i16> %7, <4 x i16> %9, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %12 = shufflevector <8 x i16> %10, <8 x i16> %11, <16 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  ret <16 x i16> %12
}

define <16 x i16> @widenobhx_q(<32 x i8> %0) {
; ALL-LABEL: widenobhx_q:
; ALL:       # %bb.0:
; ALL-NEXT:    andd $r0 = $r0, 0xff00ff00.@
; ALL-NEXT:    andd $r1 = $r1, 0xff00ff00.@
; ALL-NEXT:    andd $r2 = $r2, 0xff00ff00.@
; ALL-NEXT:    andd $r3 = $r3, 0xff00ff00.@
; ALL-NEXT:    ;; # (end cycle 0)
; ALL-NEXT:    ret
; ALL-NEXT:    ;;
  %2 = shufflevector <32 x i8> %0, <32 x i8> undef, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %3 = tail call <4 x i16> @llvm.kvx.wideninto.v4i16(<8 x i8> %2, i32 2)
  %4 = shufflevector <32 x i8> %0, <32 x i8> undef, <8 x i32> <i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  %5 = tail call <4 x i16> @llvm.kvx.wideninto.v4i16(<8 x i8> %4, i32 2)
  %6 = shufflevector <32 x i8> %0, <32 x i8> undef, <8 x i32> <i32 16, i32 17, i32 18, i32 19, i32 20, i32 21, i32 22, i32 23>
  %7 = tail call <4 x i16> @llvm.kvx.wideninto.v4i16(<8 x i8> %6, i32 2)
  %8 = shufflevector <32 x i8> %0, <32 x i8> undef, <8 x i32> <i32 24, i32 25, i32 26, i32 27, i32 28, i32 29, i32 30, i32 31>
  %9 = tail call <4 x i16> @llvm.kvx.wideninto.v4i16(<8 x i8> %8, i32 2)
  %10 = shufflevector <4 x i16> %3, <4 x i16> %5, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %11 = shufflevector <4 x i16> %7, <4 x i16> %9, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %12 = shufflevector <8 x i16> %10, <8 x i16> %11, <16 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  ret <16 x i16> %12
}

define <8 x i32> @widenohwo_(<16 x i16> %0) {
; CV1-LABEL: widenohwo_:
; CV1:       # %bb.0:
; CV1-NEXT:    srawps $r0 = $r0, 16
; CV1-NEXT:    srawps $r1 = $r1, 16
; CV1-NEXT:    ;; # (end cycle 0)
; CV1-NEXT:    srawps $r2 = $r2, 16
; CV1-NEXT:    srawps $r3 = $r3, 16
; CV1-NEXT:    ret
; CV1-NEXT:    ;; # (end cycle 1)
;
; CV2-LABEL: widenohwo_:
; CV2:       # %bb.0:
; CV2-NEXT:    srawps $r0 = $r0, 16
; CV2-NEXT:    srawps $r1 = $r1, 16
; CV2-NEXT:    srawps $r2 = $r2, 16
; CV2-NEXT:    srawps $r3 = $r3, 16
; CV2-NEXT:    ret
; CV2-NEXT:    ;; # (end cycle 0)
  %2 = shufflevector <16 x i16> %0, <16 x i16> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %3 = tail call <2 x i32> @llvm.kvx.wideninto.v2i32(<4 x i16> %2, i32 0)
  %4 = shufflevector <16 x i16> %0, <16 x i16> undef, <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %5 = tail call <2 x i32> @llvm.kvx.wideninto.v2i32(<4 x i16> %4, i32 0)
  %6 = shufflevector <16 x i16> %0, <16 x i16> undef, <4 x i32> <i32 8, i32 9, i32 10, i32 11>
  %7 = tail call <2 x i32> @llvm.kvx.wideninto.v2i32(<4 x i16> %6, i32 0)
  %8 = shufflevector <16 x i16> %0, <16 x i16> undef, <4 x i32> <i32 12, i32 13, i32 14, i32 15>
  %9 = tail call <2 x i32> @llvm.kvx.wideninto.v2i32(<4 x i16> %8, i32 0)
  %10 = shufflevector <2 x i32> %3, <2 x i32> %5, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %11 = shufflevector <2 x i32> %7, <2 x i32> %9, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %12 = shufflevector <4 x i32> %10, <4 x i32> %11, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  ret <8 x i32> %12
}

declare <2 x i32> @llvm.kvx.wideninto.v2i32(<4 x i16>, i32)

define <8 x i32> @widenohwo_z(<16 x i16> %0) {
; CV1-LABEL: widenohwo_z:
; CV1:       # %bb.0:
; CV1-NEXT:    srlwps $r0 = $r0, 16
; CV1-NEXT:    srlwps $r1 = $r1, 16
; CV1-NEXT:    ;; # (end cycle 0)
; CV1-NEXT:    srlwps $r2 = $r2, 16
; CV1-NEXT:    srlwps $r3 = $r3, 16
; CV1-NEXT:    ret
; CV1-NEXT:    ;; # (end cycle 1)
;
; CV2-LABEL: widenohwo_z:
; CV2:       # %bb.0:
; CV2-NEXT:    srlwps $r0 = $r0, 16
; CV2-NEXT:    srlwps $r1 = $r1, 16
; CV2-NEXT:    srlwps $r2 = $r2, 16
; CV2-NEXT:    srlwps $r3 = $r3, 16
; CV2-NEXT:    ret
; CV2-NEXT:    ;; # (end cycle 0)
  %2 = shufflevector <16 x i16> %0, <16 x i16> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %3 = tail call <2 x i32> @llvm.kvx.wideninto.v2i32(<4 x i16> %2, i32 1)
  %4 = shufflevector <16 x i16> %0, <16 x i16> undef, <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %5 = tail call <2 x i32> @llvm.kvx.wideninto.v2i32(<4 x i16> %4, i32 1)
  %6 = shufflevector <16 x i16> %0, <16 x i16> undef, <4 x i32> <i32 8, i32 9, i32 10, i32 11>
  %7 = tail call <2 x i32> @llvm.kvx.wideninto.v2i32(<4 x i16> %6, i32 1)
  %8 = shufflevector <16 x i16> %0, <16 x i16> undef, <4 x i32> <i32 12, i32 13, i32 14, i32 15>
  %9 = tail call <2 x i32> @llvm.kvx.wideninto.v2i32(<4 x i16> %8, i32 1)
  %10 = shufflevector <2 x i32> %3, <2 x i32> %5, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %11 = shufflevector <2 x i32> %7, <2 x i32> %9, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %12 = shufflevector <4 x i32> %10, <4 x i32> %11, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  ret <8 x i32> %12
}

define <8 x i32> @widenohwo_q(<16 x i16> %0) {
; ALL-LABEL: widenohwo_q:
; ALL:       # %bb.0:
; ALL-NEXT:    andd $r0 = $r0, 0xffff0000.@
; ALL-NEXT:    andd $r1 = $r1, 0xffff0000.@
; ALL-NEXT:    andd $r2 = $r2, 0xffff0000.@
; ALL-NEXT:    andd $r3 = $r3, 0xffff0000.@
; ALL-NEXT:    ;; # (end cycle 0)
; ALL-NEXT:    ret
; ALL-NEXT:    ;;
  %2 = shufflevector <16 x i16> %0, <16 x i16> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %3 = tail call <2 x i32> @llvm.kvx.wideninto.v2i32(<4 x i16> %2, i32 2)
  %4 = shufflevector <16 x i16> %0, <16 x i16> undef, <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %5 = tail call <2 x i32> @llvm.kvx.wideninto.v2i32(<4 x i16> %4, i32 2)
  %6 = shufflevector <16 x i16> %0, <16 x i16> undef, <4 x i32> <i32 8, i32 9, i32 10, i32 11>
  %7 = tail call <2 x i32> @llvm.kvx.wideninto.v2i32(<4 x i16> %6, i32 2)
  %8 = shufflevector <16 x i16> %0, <16 x i16> undef, <4 x i32> <i32 12, i32 13, i32 14, i32 15>
  %9 = tail call <2 x i32> @llvm.kvx.wideninto.v2i32(<4 x i16> %8, i32 2)
  %10 = shufflevector <2 x i32> %3, <2 x i32> %5, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %11 = shufflevector <2 x i32> %7, <2 x i32> %9, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %12 = shufflevector <4 x i32> %10, <4 x i32> %11, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  ret <8 x i32> %12
}

define <2 x i32> @widenohwp_(<4 x i16> %0) {
; ALL-LABEL: widenohwp_:
; ALL:       # %bb.0:
; ALL-NEXT:    srawps $r0 = $r0, 16
; ALL-NEXT:    ret
; ALL-NEXT:    ;; # (end cycle 0)
  %2 = tail call <2 x i32> @llvm.kvx.wideninto.v2i32(<4 x i16> %0, i32 0)
  ret <2 x i32> %2
}

define <2 x i32> @widenohwp_z(<4 x i16> %0) {
; ALL-LABEL: widenohwp_z:
; ALL:       # %bb.0:
; ALL-NEXT:    srlwps $r0 = $r0, 16
; ALL-NEXT:    ret
; ALL-NEXT:    ;; # (end cycle 0)
  %2 = tail call <2 x i32> @llvm.kvx.wideninto.v2i32(<4 x i16> %0, i32 1)
  ret <2 x i32> %2
}

define <2 x i32> @widenohwp_q(<4 x i16> %0) {
; ALL-LABEL: widenohwp_q:
; ALL:       # %bb.0:
; ALL-NEXT:    andd $r0 = $r0, 0xffff0000.@
; ALL-NEXT:    ret
; ALL-NEXT:    ;; # (end cycle 0)
  %2 = tail call <2 x i32> @llvm.kvx.wideninto.v2i32(<4 x i16> %0, i32 2)
  ret <2 x i32> %2
}

define <4 x i32> @widenohwq_(<8 x i16> %0) {
; ALL-LABEL: widenohwq_:
; ALL:       # %bb.0:
; ALL-NEXT:    srawps $r0 = $r0, 16
; ALL-NEXT:    srawps $r1 = $r1, 16
; ALL-NEXT:    ret
; ALL-NEXT:    ;; # (end cycle 0)
  %2 = shufflevector <8 x i16> %0, <8 x i16> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %3 = tail call <2 x i32> @llvm.kvx.wideninto.v2i32(<4 x i16> %2, i32 0)
  %4 = shufflevector <8 x i16> %0, <8 x i16> undef, <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %5 = tail call <2 x i32> @llvm.kvx.wideninto.v2i32(<4 x i16> %4, i32 0)
  %6 = shufflevector <2 x i32> %3, <2 x i32> %5, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  ret <4 x i32> %6
}

define <4 x i32> @widenohwq_z(<8 x i16> %0) {
; ALL-LABEL: widenohwq_z:
; ALL:       # %bb.0:
; ALL-NEXT:    srlwps $r0 = $r0, 16
; ALL-NEXT:    srlwps $r1 = $r1, 16
; ALL-NEXT:    ret
; ALL-NEXT:    ;; # (end cycle 0)
  %2 = shufflevector <8 x i16> %0, <8 x i16> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %3 = tail call <2 x i32> @llvm.kvx.wideninto.v2i32(<4 x i16> %2, i32 1)
  %4 = shufflevector <8 x i16> %0, <8 x i16> undef, <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %5 = tail call <2 x i32> @llvm.kvx.wideninto.v2i32(<4 x i16> %4, i32 1)
  %6 = shufflevector <2 x i32> %3, <2 x i32> %5, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  ret <4 x i32> %6
}

define <4 x i32> @widenohwq_q(<8 x i16> %0) {
; ALL-LABEL: widenohwq_q:
; ALL:       # %bb.0:
; ALL-NEXT:    andd $r0 = $r0, 0xffff0000.@
; ALL-NEXT:    andd $r1 = $r1, 0xffff0000.@
; ALL-NEXT:    ret
; ALL-NEXT:    ;; # (end cycle 0)
  %2 = shufflevector <8 x i16> %0, <8 x i16> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %3 = tail call <2 x i32> @llvm.kvx.wideninto.v2i32(<4 x i16> %2, i32 2)
  %4 = shufflevector <8 x i16> %0, <8 x i16> undef, <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %5 = tail call <2 x i32> @llvm.kvx.wideninto.v2i32(<4 x i16> %4, i32 2)
  %6 = shufflevector <2 x i32> %3, <2 x i32> %5, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  ret <4 x i32> %6
}

define <2 x i64> @widenowdp_(<4 x i32> %0) {
; ALL-LABEL: widenowdp_:
; ALL:       # %bb.0:
; ALL-NEXT:    srad $r0 = $r0, 32
; ALL-NEXT:    srad $r1 = $r1, 32
; ALL-NEXT:    ret
; ALL-NEXT:    ;; # (end cycle 0)
  %2 = shufflevector <4 x i32> %0, <4 x i32> undef, <2 x i32> <i32 0, i32 1>
  %3 = tail call i64 @llvm.kvx.widenintos(<2 x i32> %2, i32 0)
  %4 = shufflevector <4 x i32> %0, <4 x i32> undef, <2 x i32> <i32 2, i32 3>
  %5 = tail call i64 @llvm.kvx.widenintos(<2 x i32> %4, i32 0)
  %6 = insertelement <2 x i64> undef, i64 %3, i32 0
  %7 = insertelement <2 x i64> %6, i64 %5, i32 1
  ret <2 x i64> %7
}

declare i64 @llvm.kvx.widenintos(<2 x i32>, i32)

define <2 x i64> @widenowdp_z(<4 x i32> %0) {
; ALL-LABEL: widenowdp_z:
; ALL:       # %bb.0:
; ALL-NEXT:    srld $r0 = $r0, 32
; ALL-NEXT:    srld $r1 = $r1, 32
; ALL-NEXT:    ret
; ALL-NEXT:    ;; # (end cycle 0)
  %2 = shufflevector <4 x i32> %0, <4 x i32> undef, <2 x i32> <i32 0, i32 1>
  %3 = tail call i64 @llvm.kvx.widenintos(<2 x i32> %2, i32 1)
  %4 = shufflevector <4 x i32> %0, <4 x i32> undef, <2 x i32> <i32 2, i32 3>
  %5 = tail call i64 @llvm.kvx.widenintos(<2 x i32> %4, i32 1)
  %6 = insertelement <2 x i64> undef, i64 %3, i32 0
  %7 = insertelement <2 x i64> %6, i64 %5, i32 1
  ret <2 x i64> %7
}

define <2 x i64> @widenowdp_q(<4 x i32> %0) {
; ALL-LABEL: widenowdp_q:
; ALL:       # %bb.0:
; ALL-NEXT:    clrf $r0 = $r0, 31, 0
; ALL-NEXT:    clrf $r1 = $r1, 31, 0
; ALL-NEXT:    ret
; ALL-NEXT:    ;; # (end cycle 0)
  %2 = shufflevector <4 x i32> %0, <4 x i32> undef, <2 x i32> <i32 0, i32 1>
  %3 = tail call i64 @llvm.kvx.widenintos(<2 x i32> %2, i32 2)
  %4 = shufflevector <4 x i32> %0, <4 x i32> undef, <2 x i32> <i32 2, i32 3>
  %5 = tail call i64 @llvm.kvx.widenintos(<2 x i32> %4, i32 2)
  %6 = insertelement <2 x i64> undef, i64 %3, i32 0
  %7 = insertelement <2 x i64> %6, i64 %5, i32 1
  ret <2 x i64> %7
}

define <4 x i64> @widenowdq_(<8 x i32> %0) {
; ALL-LABEL: widenowdq_:
; ALL:       # %bb.0:
; ALL-NEXT:    srad $r0 = $r0, 32
; ALL-NEXT:    srad $r1 = $r1, 32
; ALL-NEXT:    srad $r2 = $r2, 32
; ALL-NEXT:    srad $r3 = $r3, 32
; ALL-NEXT:    ret
; ALL-NEXT:    ;; # (end cycle 0)
  %2 = shufflevector <8 x i32> %0, <8 x i32> undef, <2 x i32> <i32 0, i32 1>
  %3 = tail call i64 @llvm.kvx.widenintos(<2 x i32> %2, i32 0)
  %4 = shufflevector <8 x i32> %0, <8 x i32> undef, <2 x i32> <i32 2, i32 3>
  %5 = tail call i64 @llvm.kvx.widenintos(<2 x i32> %4, i32 0)
  %6 = shufflevector <8 x i32> %0, <8 x i32> undef, <2 x i32> <i32 4, i32 5>
  %7 = tail call i64 @llvm.kvx.widenintos(<2 x i32> %6, i32 0)
  %8 = shufflevector <8 x i32> %0, <8 x i32> undef, <2 x i32> <i32 6, i32 7>
  %9 = tail call i64 @llvm.kvx.widenintos(<2 x i32> %8, i32 0)
  %10 = insertelement <4 x i64> undef, i64 %3, i32 0
  %11 = insertelement <4 x i64> %10, i64 %5, i32 1
  %12 = insertelement <4 x i64> %11, i64 %7, i32 2
  %13 = insertelement <4 x i64> %12, i64 %9, i32 3
  ret <4 x i64> %13
}

define <4 x i64> @widenowdq_z(<8 x i32> %0) {
; ALL-LABEL: widenowdq_z:
; ALL:       # %bb.0:
; ALL-NEXT:    srld $r0 = $r0, 32
; ALL-NEXT:    srld $r1 = $r1, 32
; ALL-NEXT:    srld $r2 = $r2, 32
; ALL-NEXT:    srld $r3 = $r3, 32
; ALL-NEXT:    ret
; ALL-NEXT:    ;; # (end cycle 0)
  %2 = shufflevector <8 x i32> %0, <8 x i32> undef, <2 x i32> <i32 0, i32 1>
  %3 = tail call i64 @llvm.kvx.widenintos(<2 x i32> %2, i32 1)
  %4 = shufflevector <8 x i32> %0, <8 x i32> undef, <2 x i32> <i32 2, i32 3>
  %5 = tail call i64 @llvm.kvx.widenintos(<2 x i32> %4, i32 1)
  %6 = shufflevector <8 x i32> %0, <8 x i32> undef, <2 x i32> <i32 4, i32 5>
  %7 = tail call i64 @llvm.kvx.widenintos(<2 x i32> %6, i32 1)
  %8 = shufflevector <8 x i32> %0, <8 x i32> undef, <2 x i32> <i32 6, i32 7>
  %9 = tail call i64 @llvm.kvx.widenintos(<2 x i32> %8, i32 1)
  %10 = insertelement <4 x i64> undef, i64 %3, i32 0
  %11 = insertelement <4 x i64> %10, i64 %5, i32 1
  %12 = insertelement <4 x i64> %11, i64 %7, i32 2
  %13 = insertelement <4 x i64> %12, i64 %9, i32 3
  ret <4 x i64> %13
}

define <4 x i64> @widenowdq_q(<8 x i32> %0) {
; CV1-LABEL: widenowdq_q:
; CV1:       # %bb.0:
; CV1-NEXT:    clrf $r0 = $r0, 31, 0
; CV1-NEXT:    clrf $r1 = $r1, 31, 0
; CV1-NEXT:    ;; # (end cycle 0)
; CV1-NEXT:    clrf $r2 = $r2, 31, 0
; CV1-NEXT:    clrf $r3 = $r3, 31, 0
; CV1-NEXT:    ret
; CV1-NEXT:    ;; # (end cycle 1)
;
; CV2-LABEL: widenowdq_q:
; CV2:       # %bb.0:
; CV2-NEXT:    clrf $r0 = $r0, 31, 0
; CV2-NEXT:    clrf $r1 = $r1, 31, 0
; CV2-NEXT:    clrf $r2 = $r2, 31, 0
; CV2-NEXT:    clrf $r3 = $r3, 31, 0
; CV2-NEXT:    ret
; CV2-NEXT:    ;; # (end cycle 0)
  %2 = shufflevector <8 x i32> %0, <8 x i32> undef, <2 x i32> <i32 0, i32 1>
  %3 = tail call i64 @llvm.kvx.widenintos(<2 x i32> %2, i32 2)
  %4 = shufflevector <8 x i32> %0, <8 x i32> undef, <2 x i32> <i32 2, i32 3>
  %5 = tail call i64 @llvm.kvx.widenintos(<2 x i32> %4, i32 2)
  %6 = shufflevector <8 x i32> %0, <8 x i32> undef, <2 x i32> <i32 4, i32 5>
  %7 = tail call i64 @llvm.kvx.widenintos(<2 x i32> %6, i32 2)
  %8 = shufflevector <8 x i32> %0, <8 x i32> undef, <2 x i32> <i32 6, i32 7>
  %9 = tail call i64 @llvm.kvx.widenintos(<2 x i32> %8, i32 2)
  %10 = insertelement <4 x i64> undef, i64 %3, i32 0
  %11 = insertelement <4 x i64> %10, i64 %5, i32 1
  %12 = insertelement <4 x i64> %11, i64 %7, i32 2
  %13 = insertelement <4 x i64> %12, i64 %9, i32 3
  ret <4 x i64> %13
}

