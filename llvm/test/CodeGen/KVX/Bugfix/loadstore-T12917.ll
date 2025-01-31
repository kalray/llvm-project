; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -o - %s -O2 -disable-kvx-loadstore-packing=false | FileCheck %s
; RUN: clang -O2 -mllvm -disable-kvx-loadstore-packing=false -c -o /dev/null %s

target triple = "kvx-kalray-cos"
; Reported in T12917.

@b = common global i32 0, align 4
@c = common global i32 0, align 4
@a = common global i32 0, align 4

define i32 @f(){
; CHECK-LABEL: f:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    addd $r12 = $r12, -32
; CHECK-NEXT:    get $r16 = $ra
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    sd 24[$r12] = $r16
; CHECK-NEXT:    call g
; CHECK-NEXT:    ;; # (end cycle 1)
; CHECK-NEXT:    sxwd $r0 = $r0
; CHECK-NEXT:    make $r15 = a
; CHECK-NEXT:    make $r16 = c
; CHECK-NEXT:    make $r17 = 4
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    lo $r8r9r10r11 = 0[$r0]
; CHECK-NEXT:    ;; # (end cycle 1)
; CHECK-NEXT:    lo $r32r33r34r35 = 0[$r8]
; CHECK-NEXT:    ;; # (end cycle 4)
; CHECK-NEXT:    lo $r4r5r6r7 = 0[$r9]
; CHECK-NEXT:    ;; # (end cycle 5)
; CHECK-NEXT:    lo $r0r1r2r3 = 0[$r10]
; CHECK-NEXT:    ;; # (end cycle 6)
; CHECK-NEXT:    lo $r8r9r10r11 = 0[$r11]
; CHECK-NEXT:    ;; # (end cycle 7)
; CHECK-NEXT:    lwz $r15 = 0[$r15]
; CHECK-NEXT:    ;; # (end cycle 8)
; CHECK-NEXT:    sw 0[$r16] = $r17
; CHECK-NEXT:    make $r16 = b
; CHECK-NEXT:    ;; # (end cycle 9)
; CHECK-NEXT:    sw 0[$r16] = $r17
; CHECK-NEXT:    ;; # (end cycle 10)
; CHECK-NEXT:    cb.weqz $r15 ? .LBB0_2
; CHECK-NEXT:    ;;
; CHECK-NEXT:  # %bb.1: # %if.then
; CHECK-NEXT:    faddd $r15 = $r32, 0x0
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    faddd $r15 = $r15, $r33
; CHECK-NEXT:    ;; # (end cycle 4)
; CHECK-NEXT:    faddd $r15 = $r15, $r34
; CHECK-NEXT:    ;; # (end cycle 8)
; CHECK-NEXT:    faddd $r15 = $r15, $r35
; CHECK-NEXT:    ;; # (end cycle 12)
; CHECK-NEXT:    faddd $r4 = $r15, $r4
; CHECK-NEXT:    ;; # (end cycle 16)
; CHECK-NEXT:    faddd $r4 = $r4, $r5
; CHECK-NEXT:    ;; # (end cycle 20)
; CHECK-NEXT:    faddd $r4 = $r4, $r6
; CHECK-NEXT:    ;; # (end cycle 24)
; CHECK-NEXT:    faddd $r4 = $r4, $r7
; CHECK-NEXT:    ;; # (end cycle 28)
; CHECK-NEXT:    faddd $r0 = $r4, $r0
; CHECK-NEXT:    ;; # (end cycle 32)
; CHECK-NEXT:    faddd $r0 = $r0, $r1
; CHECK-NEXT:    ;; # (end cycle 36)
; CHECK-NEXT:    faddd $r0 = $r0, $r2
; CHECK-NEXT:    ;; # (end cycle 40)
; CHECK-NEXT:    faddd $r0 = $r0, $r3
; CHECK-NEXT:    ;; # (end cycle 44)
; CHECK-NEXT:    faddd $r0 = $r0, $r8
; CHECK-NEXT:    ;; # (end cycle 48)
; CHECK-NEXT:    faddd $r0 = $r0, $r9
; CHECK-NEXT:    ;; # (end cycle 52)
; CHECK-NEXT:    faddd $r0 = $r0, $r10
; CHECK-NEXT:    ;; # (end cycle 56)
; CHECK-NEXT:    faddd $r0 = $r0, $r11
; CHECK-NEXT:    call h
; CHECK-NEXT:    ;; # (end cycle 60)
; CHECK-NEXT:  .LBB0_2: # %if.end
; CHECK-NEXT:    ld $r16 = 24[$r12]
; CHECK-NEXT:    ;; # (end cycle 0)
; CHECK-NEXT:    set $ra = $r16
; CHECK-NEXT:    addd $r12 = $r12, 32
; CHECK-NEXT:    ;; # (end cycle 5)
; CHECK-NEXT:    ret
; CHECK-NEXT:    ;;
entry:
  %call = tail call i32 bitcast (i32 (...)* @g to i32 ()*)() #2
  %conv = sext i32 %call to i64
  %0 = inttoptr i64 %conv to double**
  %1 = load double*, double** %0, align 8
  %2 = load double, double* %1, align 8
  %arrayidx7.1 = getelementptr inbounds double, double* %1, i64 1
  %3 = load double, double* %arrayidx7.1, align 8
  %arrayidx7.2 = getelementptr inbounds double, double* %1, i64 2
  %4 = load double, double* %arrayidx7.2, align 8
  %arrayidx7.3 = getelementptr inbounds double, double* %1, i64 3
  %5 = load double, double* %arrayidx7.3, align 8
  %arrayidx.1 = getelementptr inbounds double*, double** %0, i64 1
  %6 = load double*, double** %arrayidx.1, align 8
  %7 = load double, double* %6, align 8
  %arrayidx7.1.1 = getelementptr inbounds double, double* %6, i64 1
  %8 = load double, double* %arrayidx7.1.1, align 8
  %arrayidx7.2.1 = getelementptr inbounds double, double* %6, i64 2
  %9 = load double, double* %arrayidx7.2.1, align 8
  %arrayidx7.3.1 = getelementptr inbounds double, double* %6, i64 3
  %10 = load double, double* %arrayidx7.3.1, align 8
  %arrayidx.2 = getelementptr inbounds double*, double** %0, i64 2
  %11 = load double*, double** %arrayidx.2, align 8
  %12 = load double, double* %11, align 8
  %arrayidx7.1.2 = getelementptr inbounds double, double* %11, i64 1
  %13 = load double, double* %arrayidx7.1.2, align 8
  %arrayidx7.2.2 = getelementptr inbounds double, double* %11, i64 2
  %14 = load double, double* %arrayidx7.2.2, align 8
  %arrayidx7.3.2 = getelementptr inbounds double, double* %11, i64 3
  %15 = load double, double* %arrayidx7.3.2, align 8
  %arrayidx.3 = getelementptr inbounds double*, double** %0, i64 3
  %16 = load double*, double** %arrayidx.3, align 8
  %17 = load double, double* %16, align 8
  %arrayidx7.1.3 = getelementptr inbounds double, double* %16, i64 1
  %18 = load double, double* %arrayidx7.1.3, align 8
  %arrayidx7.2.3 = getelementptr inbounds double, double* %16, i64 2
  %19 = load double, double* %arrayidx7.2.3, align 8
  %arrayidx7.3.3 = getelementptr inbounds double, double* %16, i64 3
  %20 = load double, double* %arrayidx7.3.3, align 8
  store i32 4, i32* @c, align 4
  store i32 4, i32* @b, align 4
  %21 = load i32, i32* @a, align 4
  %tobool = icmp eq i32 %21, 0
  br i1 %tobool, label %if.end, label %if.then

if.then:                                          ; preds = %entry
  %add = fadd double %2, 0.000000e+00
  %add.1 = fadd double %add, %3
  %add.2 = fadd double %add.1, %4
  %add.3 = fadd double %add.2, %5
  %add.120 = fadd double %add.3, %7
  %add.1.1 = fadd double %add.120, %8
  %add.2.1 = fadd double %add.1.1, %9
  %add.3.1 = fadd double %add.2.1, %10
  %add.221 = fadd double %add.3.1, %12
  %add.1.2 = fadd double %add.221, %13
  %add.2.2 = fadd double %add.1.2, %14
  %add.3.2 = fadd double %add.2.2, %15
  %add.322 = fadd double %add.3.2, %17
  %add.1.3 = fadd double %add.322, %18
  %add.2.3 = fadd double %add.1.3, %19
  %add.3.3 = fadd double %add.2.3, %20
  %call11 = tail call i32 bitcast (i32 (...)* @h to i32 (double)*)(double %add.3.3) #2
  br label %if.end

if.end:                                           ; preds = %entry, %if.then
  ret i32 undef
}

declare i32 @g(...) #1

declare i32 @h(...) #1

