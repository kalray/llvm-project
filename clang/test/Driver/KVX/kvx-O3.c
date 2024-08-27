// RUN: %clang -### -O3 %s -o /dev/null |& FileCheck %s
// RUN: %clang -### -O4 %s -o /dev/null |& FileCheck %s
// RUN: %clang -### -Ofast %s -o /dev/null |& FileCheck %s

// RUN: %clang -### -O2 %s -o /dev/null |& FileCheck %s --check-prefix=NO
// RUN: %clang -### -O1 %s -o /dev/null |& FileCheck %s --check-prefix=NO
// RUN: %clang -### -O0 %s -o /dev/null |& FileCheck %s --check-prefix=NO
// RUN: %clang -### -Os %s -o /dev/null |& FileCheck %s --check-prefix=NO
// RUN: %clang -### -Oz %s -o /dev/null |& FileCheck %s --check-prefix=NO


// CHECK: "--enable-unroll-and-jam=true"
// CHECK-SAME: "--enable-loop-flatten=true"
// CHECK-SAME: "--enable-dfa-jump-thread=true"

// NO-NOT: "--enable-unroll-and-jam=true"
// NO-NOT: "--enable-loop-flatten=true"
// NO-NOT: "--enable-dfa-jump-thread=true"
