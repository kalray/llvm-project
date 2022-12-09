// Run `$CC -E storec.C > storec.c` and `$CC -E -DKV3_2_ONLY storec.C > storec-kv3-2.c` to regenerate

typedef int __attribute__((__vector_size__(2 * sizeof(int)))) v2i32;
typedef int __attribute__((__vector_size__(4 * sizeof(int)))) v4i32;
typedef int __attribute__((__vector_size__(8 * sizeof(int)))) v8i32;
typedef short __attribute__((__vector_size__(4 * sizeof(short)))) v4i16;
typedef short __attribute__((__vector_size__(8 * sizeof(short)))) v8i16;
typedef short __attribute__((__vector_size__(16 * sizeof(short)))) v16i16;

#define STOREC(suffix, T, declsuffix, storemod) \
    void storec##declsuffix(T a, void * ptr, unsigned long cond) {__builtin_kvx_storec##suffix(a, ptr, cond, storemod);}

#define STOREC_READY(suffix, T, declsuffix, storemod) \
    int storec##declsuffix##_r(T a, void * ptr, int * load, unsigned long cond) {\
        int ready = __builtin_kvx_ready(*load);\
        __builtin_kvx_storec##suffix(a, ptr, cond, storemod, ready);\
        return ready;\
    }

#ifndef KV3_2_ONLY
// Vary type of store value, no ready
STOREC(b, unsigned char, bc, ".dltz")
STOREC(b, unsigned long, bl, ".dltz")
STOREC(h, unsigned short, hs, ".dltz")
STOREC(h, unsigned long, hl, ".dltz")
STOREC(w, unsigned int, wi, ".dltz")
STOREC(w, unsigned long, wl, ".dltz")
STOREC(d, unsigned long, dl, ".dltz")
STOREC(q, unsigned __int128, q, ".dltz")
STOREC(hf, _Float16, hf, ".dltz")
STOREC(wf, float, wf, ".dltz")
STOREC(df, double, df, ".dltz")
STOREC(64, v2i32, 64, ".dltz")
STOREC(64, v4i16, 64h, ".dltz")
STOREC(128, v4i32, 128, ".dltz")
STOREC(128, v8i16, 128h, ".dltz")
STOREC(256, v16i16, 256h, ".dltz")

// Same, with ready
STOREC_READY(b, unsigned char, bc, ".dltz")
STOREC_READY(b, unsigned long, bl, ".dltz")
STOREC_READY(h, unsigned short, hs, ".dltz")
STOREC_READY(h, unsigned long, hl, ".dltz")
STOREC_READY(w, unsigned int, wi, ".dltz")
STOREC_READY(w, unsigned long, wl, ".dltz")
STOREC_READY(d, unsigned long, dl, ".dltz")
STOREC_READY(q, unsigned __int128, q, ".dltz")
STOREC_READY(hf, _Float16, hf, ".dltz")
STOREC_READY(wf, float, wf, ".dltz")
STOREC_READY(df, double, df, ".dltz")
STOREC_READY(64, v2i32, 64, ".dltz")
STOREC_READY(64, v4i16, 64h, ".dltz")
STOREC_READY(128, v4i32, 128, ".dltz")
STOREC_READY(128, v8i16, 128h, ".dltz")
STOREC_READY(256, v16i16, 256h, ".dltz")

// Vary lsucond modifier
STOREC(256, v8i32, 256_dltz, ".dltz")
STOREC(256, v8i32, 256_dnez, ".dnez")
STOREC(256, v8i32, 256_deqz, ".deqz")
STOREC(256, v8i32, 256_dgez, ".dgez")
STOREC(256, v8i32, 256_dlez, ".dlez")
STOREC(256, v8i32, 256_dgtz, ".dgtz")
STOREC(256, v8i32, 256_odd, ".odd")
STOREC(256, v8i32, 256_even, ".even")
STOREC(256, v8i32, 256_wnez, ".wnez")
STOREC(256, v8i32, 256_weqz, ".weqz")
STOREC(256, v8i32, 256_wltz, ".wltz")
STOREC(256, v8i32, 256_wgez, ".wgez")
STOREC(256, v8i32, 256_wlez, ".wlez")
STOREC(256, v8i32, 256_wgtz, ".wgtz")
#endif

#ifdef KV3_2_ONLY
// lsumask modifier
STOREC(256, v8i32, 256_mt, ".mt")
STOREC(256, v8i32, 256_mf, ".mf")
STOREC(128, v4i32, 128_mt, ".mt")
STOREC(128, v4i32, 128_mf, ".mf")
STOREC(64, v2i32, 64_mt, ".mt")
STOREC(64, v2i32, 64_mf, ".mf")
#endif

#ifndef KV3_2_ONLY
void storec_vol(int a, void * ptr, unsigned long cond) {
    __builtin_kvx_storecw(a, ptr, cond, ".wgez", 1);
    __builtin_kvx_storecw(a, ptr, cond, ".wgez", 1);
}

void storec_novol(int a, void *ptr, unsigned long cond) {
  __builtin_kvx_storecw(a, ptr, cond, ".wgez", 0);
  __builtin_kvx_storecw(a, ptr, cond, ".wgez", 0);
}

int storec_r_vol(int a, void *ptr, int *load, unsigned long cond) {
  int ready = __builtin_kvx_ready(*load);
  __builtin_kvx_storecw(a, ptr, cond, ".wgez", ready, 1);
  __builtin_kvx_storecw(a, ptr, cond, ".wgez", ready, 1);
  return ready;
}

int storec_r_novol(int a, void *ptr, int *load, unsigned long cond) {
  int ready = __builtin_kvx_ready(*load);
  __builtin_kvx_storecw(a, ptr, cond, ".wgez", ready, 0);
  __builtin_kvx_storecw(a, ptr, cond, ".wgez", ready, 0);
  return ready;
}

void ready_then_storec(int *addr0, int *addr1, int *addr2,
                       int *to0, int *to1, int *to2, unsigned long cond) {
  int a = *(addr0);
  int b = *(addr1);
  int c = *(addr2);
  int ready = __builtin_kvx_ready(a, b, c);
  __builtin_kvx_storecw(a, to0, cond, ".wgez", ready);
  __builtin_kvx_storecw(b, to1, cond, ".wgez", ready);
  __builtin_kvx_storecw(c, to2, cond, ".wgez", ready);
}

void load_then_storec(int * addr0, int * addr1, int * addr2,
                      int * to0, int * to1, int * to2, long cond){
    int a = *(addr0);
    int b = *(addr1);
    int c = *(addr2);
    if (cond >= 0) {
        *to0 = a;
        *to1 = b;
        *to2 = c;
    }
}
#endif

