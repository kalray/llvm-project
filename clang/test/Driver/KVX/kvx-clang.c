// RUN: kvx-cos-clang -v 2>&1 | FileCheck %s --check-prefix=COS
// RUN: kvx-cos-clang++ -v 2>&1 | FileCheck %s --check-prefix=COS
// RUN: kvx-cos-clang-cl -v 2>&1 | FileCheck %s --check-prefix=COS
// RUN: kvx-cos-clang-cpp -v 2>&1 | FileCheck %s --check-prefix=COS

// RUN: kvx-mbr-clang -v 2>&1 | FileCheck %s --check-prefix=MBR
// RUN: kvx-mbr-clang++ -v 2>&1 | FileCheck %s --check-prefix=MBR
// RUN: kvx-mbr-clang-cl -v 2>&1 | FileCheck %s --check-prefix=MBR
// RUN: kvx-mbr-clang-cpp -v 2>&1 | FileCheck %s --check-prefix=MBR

// COS: Target: kvx-unknown-cos
// MBR: Target: kvx-unknown-mbr
