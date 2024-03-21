; RUN: opt -S -passes=atomic-expand -o %t %s | FileCheck %s --implicit-check-not="= atomic{{.*}}i8" --check-prefix=IR < %t
; IR-COUNT-4: cmpxchg ptr{{.*}}i32

target triple = "kvx-kalray-cos"

%struct.atomic_flag = type { i8 }

define dso_local i32 @a() {
  %1 = alloca i32, align 4
  %2 = load i32, ptr %1, align 4
  ret i32 %2
}

define internal i1 @atomic_flag_test_and_set(%struct.atomic_flag* %0) {
  %2 = alloca %struct.atomic_flag*, align 8
  store %struct.atomic_flag* %0, %struct.atomic_flag** %2, align 8
  %3 = load %struct.atomic_flag*, %struct.atomic_flag** %2, align 8
  %4 = call i1 @atomic_flag_test_and_set_explicit(%struct.atomic_flag* %3, i32 5)
  ret i1 %4
}

define internal i1 @atomic_flag_test_and_set_explicit(%struct.atomic_flag* %0, i32 %1) {
  %3 = alloca %struct.atomic_flag*, align 8
  %4 = alloca i32, align 4
  %5 = alloca i8, align 1
  %6 = alloca i8, align 1
  store %struct.atomic_flag* %0, %struct.atomic_flag** %3, align 8
  store i32 %1, ptr %4, align 4
  %7 = load %struct.atomic_flag*, %struct.atomic_flag** %3, align 8
  %8 = getelementptr inbounds %struct.atomic_flag, %struct.atomic_flag* %7, i32 0, i32 0
  %9 = load i32, ptr %4, align 4
  store i8 1, ptr %5, align 1
  switch i32 %9, label %10 [
    i32 1, label %13
    i32 2, label %13
    i32 3, label %16
    i32 4, label %19
    i32 5, label %22
  ]

10:
  %11 = load i8, ptr %5, align 1
  %12 = atomicrmw volatile xchg ptr %8, i8 %11 monotonic
  store i8 %12, ptr %6, align 1
  br label %25

13:
  %14 = load i8, ptr %5, align 1
  %15 = atomicrmw volatile xchg ptr %8, i8 %14 acquire
  store i8 %15, ptr %6, align 1
  br label %25

16:
  %17 = load i8, ptr %5, align 1
  %18 = atomicrmw volatile xchg ptr %8, i8 %17 release
  store i8 %18, ptr %6, align 1
  br label %25

19:
  %20 = load i8, ptr %5, align 1
  %21 = atomicrmw volatile xchg ptr %8, i8 %20 acq_rel
  store i8 %21, ptr %6, align 1
  br label %25

22:
  %23 = load i8, ptr %5, align 1
  %24 = atomicrmw volatile xchg ptr %8, i8 %23 seq_cst
  store i8 %24, ptr %6, align 1
  br label %25

25:
  %26 = load i8, ptr %6, align 1
  %27 = trunc i8 %26 to i1
  ret i1 %27
}
