// RUN: %clang_cc1 -triple kvx-cos-kalray %s -S -verify
float foo(float y) {
  return __builtin_kvx_fsrecw(y, ".invalid"); //expected-error {{This builtin accept a modifier string composed by: ['', '.', '.s']}} expected-error {{cannot compile this builtin function yet}}
}

float bar(float y) {
  return __builtin_kvx_fsrecw(y, ".rn.s");
}
