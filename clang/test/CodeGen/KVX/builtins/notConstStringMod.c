// NOTE: Assertions have been autogenerated by utils/update_cc_test_checks.py
// RUN: %clang_cc1 -S -verify -o /dev/null -triple kvx-kalray-cos %s

double ffmawd(float a, float b, double c, const char *v) {
  return __builtin_kvx_ffmaxwd(a, b, c, v); // expected-error {{This builtin accepts a modifier string composed by: ['', '.', '.rn', '.rd', '.ru', '.rz'], ['', '.', '.s']}}  expected-error {{cannot compile this builtin function yet}}
}
