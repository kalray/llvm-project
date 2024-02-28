// RUN: %clang_cc1 -triple kvx-kalray-cos -target-cpu kv3-2 -S -verify %s

typedef long __attribute__((__vector_size__(2 * sizeof(long)))) v2i64;
typedef long __attribute__((__vector_size__(4 * sizeof(long)))) v4i64;

void wrong_ready(int sv, void * addr, unsigned long cond, v4i64 big_sv, v2i64 mid_sv){
  __builtin_kvx_loadcwz(sv, addr, cond, ".mt"); // expected-error {{lsomask modifier is not available for this builtin. Try using __builtin_kvx_loadc[64|128|256] instead}} expected-error {{cannot compile this builtin function yet}}
  __builtin_kvx_loadc256(big_sv, addr, cond, ".toto"); // expected-error {{Expects either a lsucond: ['.dgtz', '.wgtz', '.dltz', '.even', '.dlez', '.dnez', '.wltz', '.odd', '.wnez', '.dgez', '.wlez', '.deqz', '.weqz', '.wgez'] or a lsomask: ['.mtc', '.mf', '.mt', '.mfc']}} expected-error {{cannot compile this builtin function yet}}
}
