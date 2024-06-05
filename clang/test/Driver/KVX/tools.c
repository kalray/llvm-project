// RUN: %clang -### --target=kvx-kalray-mbr -v -o /dev/null %s -march=kv3-1 2>&1 | FileCheck %s --check-prefixes=ALL,MBR,KV3_1
// RUN: %clang -### --target=kvx-kalray-mbr -v -o /dev/null %s -march=kv3-2 2>&1 | FileCheck %s --check-prefixes=ALL,MBR,KV3_2
// RUN: %clang -### --target=kvx-kalray-mbr -v -o /dev/null %s -march=kv4-1 2>&1 | FileCheck %s --check-prefixes=ALL,MBR,KV4_1
// RUN: %clang -### --target=kvx-kalray-cos -v -o /dev/null %s -march=kv3-1 2>&1 | FileCheck %s --check-prefixes=ALL,COS,KV3_1
// RUN: %clang -### --target=kvx-kalray-cos -v -o /dev/null %s -march=kv3-2 2>&1 | FileCheck %s --check-prefixes=ALL,COS,KV3_2

// RUN: %clang -### --target=kvx-mbr -v -o /dev/null %s -march=kv3-1 2>&1 | FileCheck %s --check-prefixes=ALL,MBR,KV3_1
// RUN: %clang -### --target=kvx-mbr -v -o /dev/null %s -march=kv3-2 2>&1 | FileCheck %s --check-prefixes=ALL,MBR,KV3_2
// RUN: %clang -### --target=kvx-mbr -v -o /dev/null %s -march=kv4-1 2>&1 | FileCheck %s --check-prefixes=ALL,MBR,KV4_1
// RUN: %clang -### --target=kvx-cos -v -o /dev/null %s -march=kv3-1 2>&1 | FileCheck %s --check-prefixes=ALL,COS,KV3_1
// RUN: %clang -### --target=kvx-cos -v -o /dev/null %s -march=kv3-2 2>&1 | FileCheck %s --check-prefixes=ALL,COS,KV3_2

// Downstream tests only, for default target = kvx
// RUN: %clang -### --target=mbr -v -o /dev/null %s -march=kv3-1 2>&1 | FileCheck %s --check-prefixes=ALL,MBR,KV3_1
// RUN: %clang -### --target=mbr -v -o /dev/null %s -march=kv3-2 2>&1 | FileCheck %s --check-prefixes=ALL,MBR,KV3_2
// RUN: %clang -### --target=mbr -v -o /dev/null %s -march=kv4-1 2>&1 | FileCheck %s --check-prefixes=ALL,MBR,KV4_1
// RUN: %clang -### --target=cos -v -o /dev/null %s -march=kv3-1 2>&1 | FileCheck %s --check-prefixes=ALL,COS,KV3_1
// RUN: %clang -### --target=cos -v -o /dev/null %s -march=kv3-2 2>&1 | FileCheck %s --check-prefixes=ALL,COS,KV3_2

int main (void) { return 0; }

// clang -cc1 command:

// ALL-DAG: -no-integrated-as
// MBR-DAG: "-triple" "kvx-{{.*}}-mbr"
// COS-DAG: "-triple" "kvx-{{.*}}-cos"
// KV3_1-DAG: "-target-cpu" "kv3-1"
// KV3_2-DAG: "-target-cpu" "kv3-2"
// KV4_1-DAG: "-target-cpu" "kv4-1"

// as command:
// MBR: kvx-mbr-as
// COS: kvx-cos-as
// KV3_1-DAG: march=kv3-1
// KV3_2-DAG: march=kv3-2
// KV4_1-DAG: march=kv4-1

// ld command:
// MBR: kvx-mbr-ld
// COS: kvx-cos-ld
