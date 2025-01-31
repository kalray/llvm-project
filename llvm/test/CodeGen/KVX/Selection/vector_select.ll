; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -o - %s | FileCheck %s --check-prefixes=CHECK,CV1
; RUN: llc -mcpu=kv3-2 -o - %s | FileCheck %s --check-prefixes=CHECK,CV2
; RUN: clang -c -o /dev/null %s
; RUN: clang -march=kv3-2 -c -o /dev/null %s

target triple = "kvx-kalray-cos"

define void @test_v1_select(<1 x i8> * %m, <1 x i8> * %n){
; CHECK-LABEL: test_v1_select:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lbz $r2 = 0[$r0]
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    lbs $r1 = 0[$r1]
; CHECK-NEXT:    ;; # (end cycle 1)
; CHECK-NEXT:    compw.eq $r3 = $r2, 0
; CHECK-NEXT:    ;; # (end cycle 3)
; CHECK-NEXT:    compw.gt $r4 = $r1, -1
; CHECK-NEXT:    ;; # (end cycle 4)
; CHECK-NEXT:    andw $r3 = $r3, $r4
; CHECK-NEXT:    ;; # (end cycle 5)
; CHECK-NEXT:    cmoved.wnez $r3 ? $r1 = $r2
; CHECK-NEXT:    ;; # (end cycle 6)
; CHECK-NEXT:    sb 0[$r0] = $r1
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;; # (end cycle 7)
  %v1 = load <1 x i8>, <1 x i8>* %m, align 8
  %v2 = load <1 x i8>, <1 x i8>* %n, align 8
  %c1 = icmp eq <1 x i8> %v1, zeroinitializer
  %c2 = icmp sgt <1 x i8> %v2, <i8 -1>
  %c3 = and <1 x i1> %c1, %c2
  %v3 = select <1 x i1> %c3, <1 x i8> %v1, <1 x i8> %v2
  store <1 x i8> %v3, <1 x i8> * %m, align 8
  ret void
}

define void @test_v2_select(<2 x i8> * %m, <2 x i8> * %n){
; CV1-LABEL: test_v2_select:
; CV1:       # %bb.0:
; CV1-NEXT:    lhz $r2 = 0[$r0]
; CV1-NEXT:    ;; # (end cycle 0)
; CV1-NEXT:    lhz $r1 = 0[$r1]
; CV1-NEXT:    ;; # (end cycle 1)
; CV1-NEXT:    sbmm8 $r2 = $r2, 0x20001
; CV1-NEXT:    ;; # (end cycle 3)
; CV1-NEXT:    sxlbhq $r1 = $r1
; CV1-NEXT:    compnhq.eq $r3 = $r2, 0
; CV1-NEXT:    ;; # (end cycle 4)
; CV1-NEXT:    compnhq.gt $r4 = $r1, -1
; CV1-NEXT:    ;; # (end cycle 5)
; CV1-NEXT:    andw $r3 = $r3, $r4
; CV1-NEXT:    ;; # (end cycle 6)
; CV1-NEXT:    andw $r3 = $r3, 0xff00ff
; CV1-NEXT:    ;; # (end cycle 7)
; CV1-NEXT:    cmovehq.even $r3 ? $r2 = $r1
; CV1-NEXT:    ;; # (end cycle 8)
; CV1-NEXT:    sbmm8 $r1 = $r2, 0x401
; CV1-NEXT:    ;; # (end cycle 9)
; CV1-NEXT:    sh 0[$r0] = $r1
; CV1-NEXT:    ret
; CV1-NEXT:    ;; # (end cycle 10)
;
; CV2-LABEL: test_v2_select:
; CV2:       # %bb.0:
; CV2-NEXT:    lhz $r2 = 0[$r0]
; CV2-NEXT:    ;; # (end cycle 0)
; CV2-NEXT:    lhz $r1 = 0[$r1]
; CV2-NEXT:    ;; # (end cycle 1)
; CV2-NEXT:    compnbo.eq $r3 = $r2, 0
; CV2-NEXT:    ;; # (end cycle 3)
; CV2-NEXT:    compnbo.gt $r4 = $r1, -1
; CV2-NEXT:    ;; # (end cycle 4)
; CV2-NEXT:    andw $r3 = $r3, $r4
; CV2-NEXT:    ;; # (end cycle 5)
; CV2-NEXT:    cmovebo.even $r3 ? $r2 = $r1
; CV2-NEXT:    ;; # (end cycle 6)
; CV2-NEXT:    sh 0[$r0] = $r2
; CV2-NEXT:    ret
; CV2-NEXT:    ;; # (end cycle 7)
  %v1 = load <2 x i8>, <2 x i8>* %m, align 8
  %v2 = load <2 x i8>, <2 x i8>* %n, align 8
  %c1 = icmp eq <2 x i8> %v1, zeroinitializer
  %c2 = icmp sgt <2 x i8> %v2, <i8 -1, i8 -1>
  %c3 = and <2 x i1> %c1, %c2
  %v3 = select <2 x i1> %c3, <2 x i8> %v1, <2 x i8> %v2
  store <2 x i8> %v3, <2 x i8> * %m, align 8
  ret void
}

define void @test_v3_select(<3 x i8> * %m, <3 x i8> * %n){
; CV1-LABEL: test_v3_select:
; CV1:       # %bb.0:
; CV1-NEXT:    lwz $r2 = 0[$r0]
; CV1-NEXT:    ;; # (end cycle 0)
; CV1-NEXT:    lwz $r1 = 0[$r1]
; CV1-NEXT:    ;; # (end cycle 1)
; CV1-NEXT:    sbmm8 $r2 = $r2, 0x8000400020001
; CV1-NEXT:    ;; # (end cycle 3)
; CV1-NEXT:    sxlbhq $r1 = $r1
; CV1-NEXT:    compnhq.eq $r3 = $r2, 0
; CV1-NEXT:    ;; # (end cycle 4)
; CV1-NEXT:    compnhq.gt $r4 = $r1, -1
; CV1-NEXT:    ;; # (end cycle 5)
; CV1-NEXT:    andd $r3 = $r3, $r4
; CV1-NEXT:    ;; # (end cycle 6)
; CV1-NEXT:    andd $r3 = $r3, 0xff00ff.@
; CV1-NEXT:    ;; # (end cycle 7)
; CV1-NEXT:    cmovehq.even $r3 ? $r2 = $r1
; CV1-NEXT:    ;; # (end cycle 8)
; CV1-NEXT:    sbmm8 $r1 = $r2, 0x40100401
; CV1-NEXT:    ;; # (end cycle 9)
; CV1-NEXT:    zxhd $r1 = $r1
; CV1-NEXT:    extfz $r2 = $r1, 23, 16
; CV1-NEXT:    ;; # (end cycle 10)
; CV1-NEXT:    sb 2[$r0] = $r2
; CV1-NEXT:    ;; # (end cycle 11)
; CV1-NEXT:    sh 0[$r0] = $r1
; CV1-NEXT:    ret
; CV1-NEXT:    ;; # (end cycle 12)
;
; CV2-LABEL: test_v3_select:
; CV2:       # %bb.0:
; CV2-NEXT:    lwz $r2 = 0[$r0]
; CV2-NEXT:    ;; # (end cycle 0)
; CV2-NEXT:    lwz $r1 = 0[$r1]
; CV2-NEXT:    ;; # (end cycle 1)
; CV2-NEXT:    compnbo.eq $r3 = $r2, 0
; CV2-NEXT:    ;; # (end cycle 3)
; CV2-NEXT:    compnbo.gt $r4 = $r1, -1
; CV2-NEXT:    ;; # (end cycle 4)
; CV2-NEXT:    andw $r3 = $r3, $r4
; CV2-NEXT:    ;; # (end cycle 5)
; CV2-NEXT:    cmovebo.even $r3 ? $r2 = $r1
; CV2-NEXT:    ;; # (end cycle 6)
; CV2-NEXT:    extfz $r1 = $r2, 23, 16
; CV2-NEXT:    zxhd $r2 = $r2
; CV2-NEXT:    ;; # (end cycle 7)
; CV2-NEXT:    sb 2[$r0] = $r1
; CV2-NEXT:    ;; # (end cycle 8)
; CV2-NEXT:    sh 0[$r0] = $r2
; CV2-NEXT:    ret
; CV2-NEXT:    ;; # (end cycle 9)
  %v1 = load <3 x i8>, <3 x i8>* %m, align 8
  %v2 = load <3 x i8>, <3 x i8>* %n, align 8
  %c1 = icmp eq <3 x i8> %v1, zeroinitializer
  %c2 = icmp sgt <3 x i8> %v2, <i8 -1, i8 -1, i8 -1>
  %c3 = and <3 x i1> %c1, %c2
  %v3 = select <3 x i1> %c3, <3 x i8> %v1, <3 x i8> %v2
  store <3 x i8> %v3, <3 x i8> * %m, align 8
  ret void
}

define void @test_v4_select(<4 x i8> * %m, <4 x i8> * %n){
; CV1-LABEL: test_v4_select:
; CV1:       # %bb.0:
; CV1-NEXT:    lwz $r2 = 0[$r0]
; CV1-NEXT:    ;; # (end cycle 0)
; CV1-NEXT:    lwz $r1 = 0[$r1]
; CV1-NEXT:    ;; # (end cycle 1)
; CV1-NEXT:    sbmm8 $r2 = $r2, 0x8000400020001
; CV1-NEXT:    ;; # (end cycle 3)
; CV1-NEXT:    sxlbhq $r1 = $r1
; CV1-NEXT:    compnhq.eq $r3 = $r2, 0
; CV1-NEXT:    ;; # (end cycle 4)
; CV1-NEXT:    compnhq.gt $r4 = $r1, -1
; CV1-NEXT:    ;; # (end cycle 5)
; CV1-NEXT:    andd $r3 = $r3, $r4
; CV1-NEXT:    ;; # (end cycle 6)
; CV1-NEXT:    andd $r3 = $r3, 0xff00ff.@
; CV1-NEXT:    ;; # (end cycle 7)
; CV1-NEXT:    cmovehq.even $r3 ? $r2 = $r1
; CV1-NEXT:    ;; # (end cycle 8)
; CV1-NEXT:    sbmm8 $r1 = $r2, 0x40100401
; CV1-NEXT:    ;; # (end cycle 9)
; CV1-NEXT:    sw 0[$r0] = $r1
; CV1-NEXT:    ret
; CV1-NEXT:    ;; # (end cycle 10)
;
; CV2-LABEL: test_v4_select:
; CV2:       # %bb.0:
; CV2-NEXT:    lwz $r2 = 0[$r0]
; CV2-NEXT:    ;; # (end cycle 0)
; CV2-NEXT:    lwz $r1 = 0[$r1]
; CV2-NEXT:    ;; # (end cycle 1)
; CV2-NEXT:    compnbo.eq $r3 = $r2, 0
; CV2-NEXT:    ;; # (end cycle 3)
; CV2-NEXT:    compnbo.gt $r4 = $r1, -1
; CV2-NEXT:    ;; # (end cycle 4)
; CV2-NEXT:    andw $r3 = $r3, $r4
; CV2-NEXT:    ;; # (end cycle 5)
; CV2-NEXT:    cmovebo.even $r3 ? $r2 = $r1
; CV2-NEXT:    ;; # (end cycle 6)
; CV2-NEXT:    sw 0[$r0] = $r2
; CV2-NEXT:    ret
; CV2-NEXT:    ;; # (end cycle 7)
  %v1 = load <4 x i8>, <4 x i8>* %m, align 8
  %v2 = load <4 x i8>, <4 x i8>* %n, align 8
  %c1 = icmp eq <4 x i8> %v1, zeroinitializer
  %c2 = icmp sgt <4 x i8> %v2, <i8 -1, i8 -1, i8 -1, i8 -1>
  %c3 = and <4 x i1> %c1, %c2
  %v3 = select <4 x i1> %c3, <4 x i8> %v1, <4 x i8> %v2
  store <4 x i8> %v3, <4 x i8> * %m, align 8
  ret void
}

define void @test_v8_select(<8 x i8> * %m, <8 x i8> * %n){
; CV1-LABEL: test_v8_select:
; CV1:       # %bb.0:
; CV1-NEXT:    ld $r2 = 0[$r0]
; CV1-NEXT:    ;; # (end cycle 0)
; CV1-NEXT:    ld $r1 = 0[$r1]
; CV1-NEXT:    ;; # (end cycle 1)
; CV1-NEXT:    sbmm8 $r2 = $r2, 0x8000400020001
; CV1-NEXT:    sbmm8 $r3 = $r2, 0x80004000200010
; CV1-NEXT:    ;; # (end cycle 3)
; CV1-NEXT:    sxlbhq $r1 = $r1
; CV1-NEXT:    sxmbhq $r4 = $r1
; CV1-NEXT:    compnhq.eq $r5 = $r3, 0
; CV1-NEXT:    compnhq.eq $r6 = $r2, 0
; CV1-NEXT:    ;; # (end cycle 4)
; CV1-NEXT:    compnhq.gt $r7 = $r4, -1
; CV1-NEXT:    compnhq.gt $r8 = $r1, -1
; CV1-NEXT:    ;; # (end cycle 5)
; CV1-NEXT:    andd $r5 = $r5, $r7
; CV1-NEXT:    andd $r6 = $r6, $r8
; CV1-NEXT:    ;; # (end cycle 6)
; CV1-NEXT:    andd $r5 = $r5, 0xff00ff.@
; CV1-NEXT:    andd $r6 = $r6, 0xff00ff.@
; CV1-NEXT:    ;; # (end cycle 7)
; CV1-NEXT:    cmovehq.even $r6 ? $r2 = $r1
; CV1-NEXT:    cmovehq.even $r5 ? $r3 = $r4
; CV1-NEXT:    ;; # (end cycle 8)
; CV1-NEXT:    sbmm8 $r1 = $r3, 0x40100401
; CV1-NEXT:    sbmm8 $r2 = $r2, 0x40100401
; CV1-NEXT:    ;; # (end cycle 9)
; CV1-NEXT:    insf $r2 = $r1, 63, 32
; CV1-NEXT:    ;; # (end cycle 10)
; CV1-NEXT:    sd 0[$r0] = $r2
; CV1-NEXT:    ret
; CV1-NEXT:    ;; # (end cycle 11)
;
; CV2-LABEL: test_v8_select:
; CV2:       # %bb.0:
; CV2-NEXT:    ld $r2 = 0[$r0]
; CV2-NEXT:    ;; # (end cycle 0)
; CV2-NEXT:    ld $r1 = 0[$r1]
; CV2-NEXT:    ;; # (end cycle 1)
; CV2-NEXT:    compnbo.eq $r3 = $r2, 0
; CV2-NEXT:    ;; # (end cycle 3)
; CV2-NEXT:    compnbo.gt $r4 = $r1, -1
; CV2-NEXT:    ;; # (end cycle 4)
; CV2-NEXT:    andd $r3 = $r3, $r4
; CV2-NEXT:    ;; # (end cycle 5)
; CV2-NEXT:    cmovebo.even $r3 ? $r2 = $r1
; CV2-NEXT:    ;; # (end cycle 6)
; CV2-NEXT:    sd 0[$r0] = $r2
; CV2-NEXT:    ret
; CV2-NEXT:    ;; # (end cycle 7)
  %v1 = load <8 x i8>, <8 x i8>* %m, align 8
  %v2 = load <8 x i8>, <8 x i8>* %n, align 8
  %c1 = icmp eq <8 x i8> %v1, zeroinitializer
  %c2 = icmp sgt <8 x i8> %v2, <i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1>
  %c3 = and <8 x i1> %c1, %c2
  %v3 = select <8 x i1> %c3, <8 x i8> %v1, <8 x i8> %v2
  store <8 x i8> %v3, <8 x i8> * %m, align 8
  ret void
}

define void @test_v16_select(<16 x i8> * %m, <16 x i8> * %n){
; CV1-LABEL: test_v16_select:
; CV1:       # %bb.0:
; CV1-NEXT:    lq $r2r3 = 0[$r0]
; CV1-NEXT:    ;; # (end cycle 0)
; CV1-NEXT:    lq $r4r5 = 0[$r1]
; CV1-NEXT:    ;; # (end cycle 1)
; CV1-NEXT:    sbmm8 $r3 = $r3, 0x80004000200010
; CV1-NEXT:    sbmm8 $r6 = $r3, 0x8000400020001
; CV1-NEXT:    ;; # (end cycle 3)
; CV1-NEXT:    sxmbhq $r5 = $r5
; CV1-NEXT:    sxlbhq $r7 = $r5
; CV1-NEXT:    compnhq.eq $r8 = $r6, 0
; CV1-NEXT:    compnhq.eq $r9 = $r3, 0
; CV1-NEXT:    ;; # (end cycle 4)
; CV1-NEXT:    sbmm8 $r1 = $r2, 0x8000400020001
; CV1-NEXT:    compnhq.gt $r10 = $r7, -1
; CV1-NEXT:    compnhq.gt $r11 = $r5, -1
; CV1-NEXT:    sxlbhq $r15 = $r4
; CV1-NEXT:    ;; # (end cycle 5)
; CV1-NEXT:    sbmm8 $r2 = $r2, 0x80004000200010
; CV1-NEXT:    sxmbhq $r4 = $r4
; CV1-NEXT:    andd $r8 = $r8, $r10
; CV1-NEXT:    andd $r9 = $r9, $r11
; CV1-NEXT:    ;; # (end cycle 6)
; CV1-NEXT:    andd $r8 = $r8, 0xff00ff.@
; CV1-NEXT:    andd $r9 = $r9, 0xff00ff.@
; CV1-NEXT:    compnhq.eq $r10 = $r1, 0
; CV1-NEXT:    compnhq.eq $r11 = $r2, 0
; CV1-NEXT:    ;; # (end cycle 7)
; CV1-NEXT:    cmovehq.even $r9 ? $r3 = $r5
; CV1-NEXT:    cmovehq.even $r8 ? $r6 = $r7
; CV1-NEXT:    compnhq.gt $r16 = $r15, -1
; CV1-NEXT:    compnhq.gt $r17 = $r4, -1
; CV1-NEXT:    ;; # (end cycle 8)
; CV1-NEXT:    sbmm8 $r3 = $r3, 0x40100401
; CV1-NEXT:    andd $r5 = $r11, $r17
; CV1-NEXT:    andd $r7 = $r10, $r16
; CV1-NEXT:    sbmm8 $r9 = $r6, 0x40100401
; CV1-NEXT:    ;; # (end cycle 9)
; CV1-NEXT:    andd $r5 = $r5, 0xff00ff.@
; CV1-NEXT:    andd $r6 = $r7, 0xff00ff.@
; CV1-NEXT:    insf $r9 = $r3, 63, 32
; CV1-NEXT:    ;; # (end cycle 10)
; CV1-NEXT:    cmovehq.even $r6 ? $r1 = $r15
; CV1-NEXT:    cmovehq.even $r5 ? $r2 = $r4
; CV1-NEXT:    ;; # (end cycle 11)
; CV1-NEXT:    sbmm8 $r2 = $r2, 0x40100401
; CV1-NEXT:    sbmm8 $r8 = $r1, 0x40100401
; CV1-NEXT:    ;; # (end cycle 12)
; CV1-NEXT:    insf $r8 = $r2, 63, 32
; CV1-NEXT:    ;; # (end cycle 13)
; CV1-NEXT:    sq 0[$r0] = $r8r9
; CV1-NEXT:    ret
; CV1-NEXT:    ;; # (end cycle 14)
;
; CV2-LABEL: test_v16_select:
; CV2:       # %bb.0:
; CV2-NEXT:    lq $r2r3 = 0[$r0]
; CV2-NEXT:    ;; # (end cycle 0)
; CV2-NEXT:    lq $r4r5 = 0[$r1]
; CV2-NEXT:    ;; # (end cycle 1)
; CV2-NEXT:    compnbo.eq $r1 = $r3, 0
; CV2-NEXT:    compnbo.eq $r7 = $r2, 0
; CV2-NEXT:    ;; # (end cycle 3)
; CV2-NEXT:    compnbo.gt $r6 = $r5, -1
; CV2-NEXT:    compnbo.gt $r8 = $r4, -1
; CV2-NEXT:    ;; # (end cycle 4)
; CV2-NEXT:    andd $r1 = $r1, $r6
; CV2-NEXT:    andd $r6 = $r7, $r8
; CV2-NEXT:    ;; # (end cycle 5)
; CV2-NEXT:    cmovebo.even $r6 ? $r2 = $r4
; CV2-NEXT:    cmovebo.even $r1 ? $r3 = $r5
; CV2-NEXT:    ;; # (end cycle 6)
; CV2-NEXT:    sq 0[$r0] = $r2r3
; CV2-NEXT:    ret
; CV2-NEXT:    ;; # (end cycle 7)
  %v1 = load <16 x i8>, <16 x i8>* %m, align 16
  %v2 = load <16 x i8>, <16 x i8>* %n, align 16
  %c1 = icmp eq <16 x i8> %v1, zeroinitializer
  %c2 = icmp sgt <16 x i8> %v2, <i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1>
  %c3 = and <16 x i1> %c1, %c2
  %v3 = select <16 x i1> %c3, <16 x i8> %v1, <16 x i8> %v2
  store <16 x i8> %v3, <16 x i8> * %m, align 16
  ret void
}

define void @test_v32_select(<32 x i8> * %m, <32 x i8> * %n){
; CV1-LABEL: test_v32_select:
; CV1:       # %bb.0:
; CV1-NEXT:    lo $r8r9r10r11 = 0[$r0]
; CV1-NEXT:    ;; # (end cycle 0)
; CV1-NEXT:    lo $r4r5r6r7 = 0[$r1]
; CV1-NEXT:    ;; # (end cycle 1)
; CV1-NEXT:    sbmm8 $r9 = $r9, 0x80004000200010
; CV1-NEXT:    sbmm8 $r15 = $r9, 0x8000400020001
; CV1-NEXT:    ;; # (end cycle 3)
; CV1-NEXT:    sxmbhq $r5 = $r5
; CV1-NEXT:    sxlbhq $r16 = $r5
; CV1-NEXT:    compnhq.eq $r37 = $r15, 0
; CV1-NEXT:    compnhq.eq $r38 = $r9, 0
; CV1-NEXT:    ;; # (end cycle 4)
; CV1-NEXT:    sbmm8 $r2 = $r11, 0x8000400020001
; CV1-NEXT:    compnhq.gt $r39 = $r16, -1
; CV1-NEXT:    compnhq.gt $r40 = $r5, -1
; CV1-NEXT:    sxlbhq $r42 = $r6
; CV1-NEXT:    ;; # (end cycle 5)
; CV1-NEXT:    sbmm8 $r3 = $r11, 0x80004000200010
; CV1-NEXT:    sbmm8 $r11 = $r8, 0x8000400020001
; CV1-NEXT:    andd $r37 = $r37, $r39
; CV1-NEXT:    andd $r38 = $r38, $r40
; CV1-NEXT:    ;; # (end cycle 6)
; CV1-NEXT:    sbmm8 $r8 = $r8, 0x80004000200010
; CV1-NEXT:    andd $r37 = $r37, 0xff00ff.@
; CV1-NEXT:    andd $r38 = $r38, 0xff00ff.@
; CV1-NEXT:    sxlbhq $r39 = $r4
; CV1-NEXT:    ;; # (end cycle 7)
; CV1-NEXT:    sxmbhq $r4 = $r4
; CV1-NEXT:    compnhq.eq $r35 = $r11, 0
; CV1-NEXT:    compnhq.eq $r36 = $r8, 0
; CV1-NEXT:    compnhq.gt $r40 = $r39, -1
; CV1-NEXT:    ;; # (end cycle 8)
; CV1-NEXT:    cmovehq.even $r38 ? $r9 = $r5
; CV1-NEXT:    cmovehq.even $r37 ? $r15 = $r16
; CV1-NEXT:    andd $r16 = $r35, $r40
; CV1-NEXT:    compnhq.gt $r43 = $r4, -1
; CV1-NEXT:    ;; # (end cycle 9)
; CV1-NEXT:    sbmm8 $r5 = $r15, 0x40100401
; CV1-NEXT:    sbmm8 $r9 = $r9, 0x40100401
; CV1-NEXT:    andd $r15 = $r36, $r43
; CV1-NEXT:    compnhq.eq $r17 = $r2, 0
; CV1-NEXT:    ;; # (end cycle 10)
; CV1-NEXT:    sbmm8 $r1 = $r10, 0x8000400020001
; CV1-NEXT:    sbmm8 $r10 = $r10, 0x80004000200010
; CV1-NEXT:    compnhq.eq $r32 = $r3, 0
; CV1-NEXT:    ;; # (end cycle 11)
; CV1-NEXT:    insf $r5 = $r9, 63, 32
; CV1-NEXT:    sxmbhq $r6 = $r6
; CV1-NEXT:    andd $r9 = $r15, 0xff00ff.@
; CV1-NEXT:    andd $r15 = $r16, 0xff00ff.@
; CV1-NEXT:    ;; # (end cycle 12)
; CV1-NEXT:    compnhq.gt $r16 = $r42, -1
; CV1-NEXT:    compnhq.eq $r33 = $r1, 0
; CV1-NEXT:    compnhq.eq $r34 = $r10, 0
; CV1-NEXT:    compnhq.gt $r35 = $r6, -1
; CV1-NEXT:    ;; # (end cycle 13)
; CV1-NEXT:    cmovehq.even $r9 ? $r8 = $r4
; CV1-NEXT:    andd $r9 = $r34, $r35
; CV1-NEXT:    cmovehq.even $r15 ? $r11 = $r39
; CV1-NEXT:    ;; # (end cycle 14)
; CV1-NEXT:    sbmm8 $r4 = $r11, 0x40100401
; CV1-NEXT:    sbmm8 $r8 = $r8, 0x40100401
; CV1-NEXT:    andd $r11 = $r33, $r16
; CV1-NEXT:    ;; # (end cycle 15)
; CV1-NEXT:    sxmbhq $r7 = $r7
; CV1-NEXT:    sxlbhq $r41 = $r7
; CV1-NEXT:    ;; # (end cycle 16)
; CV1-NEXT:    insf $r4 = $r8, 63, 32
; CV1-NEXT:    andd $r8 = $r9, 0xff00ff.@
; CV1-NEXT:    andd $r9 = $r11, 0xff00ff.@
; CV1-NEXT:    compnhq.gt $r11 = $r41, -1
; CV1-NEXT:    ;; # (end cycle 17)
; CV1-NEXT:    cmovehq.even $r9 ? $r1 = $r42
; CV1-NEXT:    andd $r9 = $r17, $r11
; CV1-NEXT:    cmovehq.even $r8 ? $r10 = $r6
; CV1-NEXT:    compnhq.gt $r15 = $r7, -1
; CV1-NEXT:    ;; # (end cycle 18)
; CV1-NEXT:    andd $r1 = $r32, $r15
; CV1-NEXT:    sbmm8 $r6 = $r1, 0x40100401
; CV1-NEXT:    sbmm8 $r8 = $r10, 0x40100401
; CV1-NEXT:    ;; # (end cycle 19)
; CV1-NEXT:    andd $r1 = $r1, 0xff00ff.@
; CV1-NEXT:    insf $r6 = $r8, 63, 32
; CV1-NEXT:    andd $r8 = $r9, 0xff00ff.@
; CV1-NEXT:    ;; # (end cycle 20)
; CV1-NEXT:    cmovehq.even $r8 ? $r2 = $r41
; CV1-NEXT:    cmovehq.even $r1 ? $r3 = $r7
; CV1-NEXT:    ;; # (end cycle 21)
; CV1-NEXT:    sbmm8 $r1 = $r3, 0x40100401
; CV1-NEXT:    sbmm8 $r7 = $r2, 0x40100401
; CV1-NEXT:    ;; # (end cycle 22)
; CV1-NEXT:    insf $r7 = $r1, 63, 32
; CV1-NEXT:    ;; # (end cycle 23)
; CV1-NEXT:    so 0[$r0] = $r4r5r6r7
; CV1-NEXT:    ret
; CV1-NEXT:    ;; # (end cycle 24)
;
; CV2-LABEL: test_v32_select:
; CV2:       # %bb.0:
; CV2-NEXT:    lo $r4r5r6r7 = 0[$r0]
; CV2-NEXT:    ;; # (end cycle 0)
; CV2-NEXT:    lo $r8r9r10r11 = 0[$r1]
; CV2-NEXT:    ;; # (end cycle 1)
; CV2-NEXT:    compnbo.eq $r1 = $r5, 0
; CV2-NEXT:    compnbo.eq $r3 = $r4, 0
; CV2-NEXT:    compnbo.eq $r15 = $r6, 0
; CV2-NEXT:    ;; # (end cycle 3)
; CV2-NEXT:    compnbo.gt $r2 = $r9, -1
; CV2-NEXT:    compnbo.gt $r16 = $r8, -1
; CV2-NEXT:    compnbo.gt $r17 = $r10, -1
; CV2-NEXT:    ;; # (end cycle 4)
; CV2-NEXT:    andd $r1 = $r1, $r2
; CV2-NEXT:    compnbo.eq $r2 = $r7, 0
; CV2-NEXT:    andd $r3 = $r3, $r16
; CV2-NEXT:    ;; # (end cycle 5)
; CV2-NEXT:    compnbo.gt $r1 = $r11, -1
; CV2-NEXT:    cmovebo.even $r3 ? $r4 = $r8
; CV2-NEXT:    cmovebo.even $r1 ? $r5 = $r9
; CV2-NEXT:    andd $r9 = $r15, $r17
; CV2-NEXT:    ;; # (end cycle 6)
; CV2-NEXT:    andd $r1 = $r2, $r1
; CV2-NEXT:    cmovebo.even $r9 ? $r6 = $r10
; CV2-NEXT:    ;; # (end cycle 7)
; CV2-NEXT:    cmovebo.even $r1 ? $r7 = $r11
; CV2-NEXT:    ;; # (end cycle 8)
; CV2-NEXT:    so 0[$r0] = $r4r5r6r7
; CV2-NEXT:    ret
; CV2-NEXT:    ;; # (end cycle 9)
  %v1 = load <32 x i8>, <32 x i8>* %m, align 32
  %v2 = load <32 x i8>, <32 x i8>* %n, align 32
  %c1 = icmp eq <32 x i8> %v1, zeroinitializer
  %c2 = icmp sgt <32 x i8> %v2, <i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1>
  %c3 = and <32 x i1> %c1, %c2
  %v3 = select <32 x i1> %c3, <32 x i8> %v1, <32 x i8> %v2
  store <32 x i8> %v3, <32 x i8> * %m, align 32
  ret void
}
