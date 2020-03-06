// RUN: clang -target kvx-cos -S %s -O3 -o - | FileCheck %s
typedef unsigned char v8unsigned_char
    __attribute__((__vector_size__(sizeof(unsigned char) * 8)));

v8unsigned_char xor
    (v8unsigned_char a, v8unsigned_char b) {
      v8unsigned_char s = a ^ b;
      return s;

      // CHECK: xor
      // CHECK: xord
      // CHECK: ret
    }

    v8unsigned_char xor_imm(v8unsigned_char a) {
  v8unsigned_char s = a ^ 3;
  return s;
  // CHECK: xor_imm
  // CHECK: xord
  // CHECK: ret
}

v8unsigned_char or (v8unsigned_char a, v8unsigned_char b) {
  v8unsigned_char s = a | b;
  return s;
  // CHECK: or
  // CHECK: ord
  // CHECK: ret
}

v8unsigned_char or_imm(v8unsigned_char a) {
  v8unsigned_char s = a | 15;
  return s;
  // CHECK: or_imm
  // CHECK: ord
  // CHECK: ret
}

v8unsigned_char and (v8unsigned_char a, v8unsigned_char b) {
  v8unsigned_char s = a & b;
  return s;
  // CHECK: and
  // CHECK: andd
  // CHECK: ret
}

v8unsigned_char and_imm(v8unsigned_char a) {
  v8unsigned_char s = a & (unsigned char)0x7F;
  return s;
  // CHECK: and_imm
  // CHECK: andd
  // CHECK: ret
}
