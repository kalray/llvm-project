// RUN: clang -target k1c-cos -S -O2 %s -o - | FileCheck %s

void test0(int a, int *p) {
  if (a) {
    *p = a;
  }
  // CHECK: cb.weqz
  // CHECK: sw
  // CHECK: ret
}

void test1(int a, int *p) {
  if (a == 0) {
    *p = a;
  }
  // CHECK: cb.wnez
  // CHECK: make
  // CHECK: sw
  // CHECK: ret
}

void test2(int a, int *p) {
  if (a > 0) {
    *p = a;
  }
  // CHECK: cb.wlez
  // CHECK: sw
  // CHECK: ret
}

void test3(int a, int *p) {
  if (a >= 0) {
    *p = a;
  }
  // CHECK: cb.wltz
  // CHECK: sw
  // CHECK: ret
}

void test4(int a, int *p) {
  if (a < 0) {
    *p = a;
  }
  // CHECK: cb.wgez
  // CHECK: sw
  // CHECK: ret
}

void test5(int a, int *p) {
  if (a <= 0) {
    *p = a;
  }
  // CHECK: cb.wgtz
  // CHECK: sw
  // CHECK: ret
}

void test6(int a, int *p) {
  if (a > 1) {
    *p = a;
  }
  // CHECK: compw.lt $r{{[0-9]+}} = $r{{[0-9]+}}, 2
  // CHECK: cb.odd
  // CHECK: sw
  // CHECK: ret
}

void test7(int a, int *p) {
  if (a >= 1) {
    *p = a;
  }
  // CHECK: cb.wlez
  // CHECK: sw
  // CHECK: ret
}

void test8(int a, int *p) {
  if (a < 1) {
    *p = a;
  }
  // CHECK: cb.wgtz
  // CHECK: sw
  // CHECK: ret
}

void test9(int a, int *p) {
  if (a <= 1) {
    *p = a;
  }
  // CHECK: compw.gt $r{{[0-9]+}} = $r{{[0-9]+}}, 1
  // CHECK: cb.odd
  // CHECK: sw
  // CHECK: ret
}

void test10(long a, long *p) {
  if (a) {
    *p = a;
  }
  // CHECK: cb.deqz
  // CHECK: sd
  // CHECK: ret
}

void test11(long a, long *p) {
  if (a == 0) {
    *p = a;
  }
  // CHECK: cb.dnez
  // CHECK: make
  // CHECK: sd
  // CHECK: ret
}

void test12(long a, long *p) {
  if (a > 0) {
    *p = a;
  }
  // CHECK: cb.dlez
  // CHECK: sd
  // CHECK: ret
}

void test13(long a, long *p) {
  if (a >= 0) {
    *p = a;
  }
  // CHECK: cb.dltz
  // CHECK: sd
  // CHECK: ret
}

void test14(long a, long *p) {
  if (a < 0) {
    *p = a;
  }
  // CHECK: cb.dgez
  // CHECK: sd
  // CHECK: ret
}

void test15(long a, long *p) {
  if (a <= 0) {
    *p = a;
  }
  // CHECK: cb.dgtz
  // CHECK: sd
  // CHECK: ret
}

void test16(long a, long *p) {
  if (a > 1) {
    *p = a;
  }
  // CHECK: compd.lt $r{{[0-9]+}} = $r{{[0-9]+}}, 2
  // CHECK: cb.odd
  // CHECK: sd
  // CHECK: ret
}

void test17(long a, long *p) {
  if (a >= 1) {
    *p = a;
  }
  // CHECK: cb.dlez
  // CHECK: sd
  // CHECK: ret
}

void test18(long a, long *p) {
  if (a < 1) {
    *p = a;
  }
  // CHECK: cb.dgtz
  // CHECK: sd
  // CHECK: ret
}

void test19(long a, long *p) {
  if (a <= 1) {
    *p = a;
  }
  // CHECK: compd.gt $r{{[0-9]+}} = $r{{[0-9]+}}, 1
  // CHECK: cb.odd
  // CHECK: sd
  // CHECK: ret
}

void test20(long a, long b, long *p) {
  if (a == b) {
    *p = a;
  }
  // CHECK: compd.ne $r{{[0-9]+}} = $r{{[0-9]+}}, $r{{[0-9]+}}
  // CHECK: cb.odd
  // CHECK: sd
  // CHECK: ret
}

void test21(long a, long b, long *p) {
  if (a != b) {
    *p = a;
  }
  // CHECK: compd.eq $r{{[0-9]+}} = $r{{[0-9]+}}, $r{{[0-9]+}}
  // CHECK: cb.odd
  // CHECK: sd
  // CHECK: ret
}

void test22(int a, int *p) {
  if (a != 0) {
    *p = a;
  }
  // CHECK: cb.weqz
  // CHECK: sw
  // CHECK: ret
}

void test23(short a, int *p) {
  if (a != 0) {
    *p = a;
  }
  // CHECK: cb.weqz
  // CHECK: sw
  // CHECK: ret
}

void test24(int a, int *p) {
  if ((a & 1) == 0) {
    *p = a;
  }
  // CHECK: cb.odd
  // CHECK: sw
  // CHECK: ret
}

void test25(int a, int *p) {
  if (a & 1) {
    *p = a;
  }
  // CHECK: cb.even
  // CHECK: sw
  // CHECK: ret
}

void test26(long a, int *p) {
  if ((a & 1) == 0) {
    *p = a;
  }
  // CHECK: cb.odd
  // CHECK: sw
  // CHECK: ret
}

void test27(long a, int *p) {
  if (a & 1) {
    *p = a;
  }
  // CHECK: cb.even
  // CHECK: sw
  // CHECK: ret
}
