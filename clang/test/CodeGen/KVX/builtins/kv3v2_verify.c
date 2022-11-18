// RUN: %clang_cc1 -O2 -triple kvx-kalray-cos -target-cpu kv3-2 -verify %s

void dflushsw(unsigned long w, unsigned long s) {
  __builtin_kvx_dflushsw(w, s, "");
  __builtin_kvx_dflushsw(w, s, ".");
  __builtin_kvx_dflushsw(w, s, ".l1");
  __builtin_kvx_dflushsw(w, s, ".l2");
  __builtin_kvx_dflushsw(w, s, 1, "."); // expected-error {{too many arguments to function call, expected 3, have 4}}
  __builtin_kvx_dflushsw(w, s); // expected-error {{too few arguments to function call, expected 3, have 2}}
}
