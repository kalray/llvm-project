// RUN: kvx-cos-clang -v -march=kv3-2 -o /dev/null %s 2>&1 | FileCheck %s
// CHECK:{{.*}}/kv3-2

int main() { return 0; }
