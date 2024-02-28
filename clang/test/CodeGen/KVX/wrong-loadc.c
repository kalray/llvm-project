// RUN: %clang_cc1 -triple kvx-kalray-cos -S -verify %s

typedef struct {long a, b;} s128;
typedef long __attribute__((__vector_size__(8 * sizeof(long)))) v8i64;

void wrong_load(s128 *s, v8i64 v, int sv, void * addr, unsigned long cond){
  __builtin_kvx_loadcwz(sv, addr, cond, ".wnez", 0, 1); // expected-error {{No more than 5 arguments are allowed}} expected-error {{cannot compile this builtin function yet}}
  __builtin_kvx_loadcwz(sv, addr, cond, ".wnez", sv); // expected-error {{volatile flag should be a constant argument (e.g. 0 or 1)}} expected-error {{cannot compile this builtin function yet}}
  __builtin_kvx_loadcwz(sv, addr, cond, ".mt"); // expected-error {{lsomask modifier is not available for this builtin. Try using __builtin_kvx_loadc[64|128|256] instead}} expected-error {{cannot compile this builtin function yet}}
  __builtin_kvx_loadcwz(sv, addr, cond, ".toto"); // expected-error {{Expects a lsucond, one of: '.dgtz', '.wgtz', '.dltz', '.even', '.dlez', '.dnez', '.wltz', '.odd', '.wnez', '.dgez', '.wlez', '.deqz', '.weqz', '.wgez'}} expected-error {{cannot compile this builtin function yet}}
  __builtin_kvx_loadcwz(sv, addr, cond, ".toto.wlez"); // expected-error {{invalid variant modifier, should be one of: '', '.', '.s', '.u', '.us'}} expected-error {{cannot compile this builtin function yet}}
}
