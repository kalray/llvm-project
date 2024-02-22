// Run `$CC -E loadc.C > loadc.c` and `$CC -E -DKV3_2_ONLY loadc.C > loadc-kv3-2.c` to regenerate

typedef int __attribute__((__vector_size__(2 * sizeof(int)))) v2i32;
typedef int __attribute__((__vector_size__(4 * sizeof(int)))) v4i32;
typedef int __attribute__((__vector_size__(8 * sizeof(int)))) v8i32;

#define LOADC(suffix, T, declsuffix, loadmod) \
    T loadc##declsuffix(T a, void * ptr, unsigned long cond) {return __builtin_kvx_loadc##suffix(a, ptr, cond, loadmod);}

#ifndef KV3_2_ONLY
// Vary value type
LOADC(bz, unsigned char, bc, ".dltz")
LOADC(bz, unsigned long, bl, ".dltz")
LOADC(hz, unsigned short, hs, ".dltz")
LOADC(hz, unsigned long, hl, ".dltz")
LOADC(wz, unsigned int, wi, ".dltz")
LOADC(wz, unsigned long, wl, ".dltz")
LOADC(d, unsigned long, dl, ".dltz")
LOADC(q, unsigned __int128, q, ".dltz")
LOADC(hf, _Float16, hf, ".dltz")
LOADC(wf, float, wf, ".dltz")
LOADC(df, double, df, ".dltz")
LOADC(64, v2i32, 64, ".dltz")
LOADC(128, v4i32, 128, ".dltz")

// Try variant modifier
LOADC(wz, unsigned long, wls, ".s.dltz")
LOADC(wz, unsigned long, wlu, ".u.dltz")
LOADC(wz, unsigned long, wlus, ".us.dltz")

// Vary lsucond modifier
LOADC(256, v8i32, 256_dltz, ".dltz")
LOADC(256, v8i32, 256_dnez, ".dnez")
LOADC(256, v8i32, 256_deqz, ".deqz")
LOADC(256, v8i32, 256_dgez, ".dgez")
LOADC(256, v8i32, 256_dlez, ".dlez")
LOADC(256, v8i32, 256_dgtz, ".dgtz")
LOADC(256, v8i32, 256_odd, ".odd")
LOADC(256, v8i32, 256_even, ".even")
LOADC(256, v8i32, 256_wnez, ".wnez")
LOADC(256, v8i32, 256_weqz, ".weqz")
LOADC(256, v8i32, 256_wltz, ".wltz")
LOADC(256, v8i32, 256_wgez, ".wgez")
LOADC(256, v8i32, 256_wlez, ".wlez")
LOADC(256, v8i32, 256_wgtz, ".wgtz")
#endif

#ifdef KV3_2_ONLY
// lsumask modifier
LOADC(256, v8i32, 256_mt, ".mt")
LOADC(256, v8i32, 256_mf, ".mf")
LOADC(256, v8i32, 256_mtc, ".mtc")
LOADC(256, v8i32, 256_mfc, ".mfc")
LOADC(128, v4i32, 128_mt, ".mt")
LOADC(128, v4i32, 128_mf, ".mf")
LOADC(128, v4i32, 128_mtc, ".mtc")
LOADC(128, v4i32, 128_mfc, ".mfc")
LOADC(64, v2i32, 64_mt, ".mt")
LOADC(64, v2i32, 64_mf, ".mf")
LOADC(64, v2i32, 64_mtc, ".mtc")
LOADC(64, v2i32, 64_mfc, ".mfc")
#endif

#ifndef KV3_2_ONLY
int loadc_vol(int a, void * ptr, unsigned long cond) {
    int x = __builtin_kvx_loadcwz(a, ptr, cond, ".wgez", 1);
    x = __builtin_kvx_loadcwz(a, ptr, cond, ".wgez", 1);
    return x;
}

int loadc_novol(int a, void *ptr, unsigned long cond) {
  int x = __builtin_kvx_loadcwz(a, ptr, cond, ".wgez", 0);
  x = __builtin_kvx_loadcwz(a, ptr, cond, ".wgez", 0);
  return x;
}
#endif
