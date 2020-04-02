// RUN: clang -target kvx-cos -S -O2 -v %s -o - |& FileCheck %s

__int128 shl(__int128 i, int s) {
  return i << s;
  // CHECK-LABEL: shl
  // CHECK: call __ashlti3
}

__int128 sra(__int128 i, int s) {
  return i >> s;
  // CHECK-LABEL: sra
  // CHECK: call __ashrti3
}

__uint128_t srl(__uint128_t i, int s) {
  return i >> s;
  // CHECK-LABEL: srl
  // CHECK: call __lshrti3
}
