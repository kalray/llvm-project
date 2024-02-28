// RUN: %clang_cc1 -triple kvx-kalray-cos -S -verify %s

typedef long __attribute__((__vector_size__(16 * sizeof(long)))) v16i64;

v16i64 *toto;

void xfail_load1024(v16i64 *addr) {
  __kvx_x1024 tca = *((__kvx_x1024 *)toto);
  __builtin_kvx_lvc_cond(tca, addr, 1, ".su"); // expected-error {{This builtin accepts a modifier string composed by: ['', '.', '.s'], ['.q2', '.q0', '.q3', '.q1'], ['.dgtz', '.wgtz', '.dltz', '.even', '.dlez', '.dnez', '.wltz', '.odd', '.wnez', '.dgez', '.wlez', '.deqz', '.weqz', '.wgez']}} expected-error {{cannot compile this builtin function yet}}
  *((__kvx_x1024 *)toto) = tca;
}
