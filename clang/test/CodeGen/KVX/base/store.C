// Run `$CC -E store.C > store.c` to regenerate

typedef int __attribute__((__vector_size__(2 * sizeof(int)))) v2i32;
typedef int __attribute__((__vector_size__(4 * sizeof(int)))) v4i32;
typedef int __attribute__((__vector_size__(8 * sizeof(int)))) v8i32;
typedef short __attribute__((__vector_size__(4 * sizeof(short)))) v4i16;
typedef short __attribute__((__vector_size__(8 * sizeof(short)))) v8i16;
typedef short __attribute__((__vector_size__(16 * sizeof(short)))) v16i16;

#define STORE(suffix, T, declsuffix) \
    void store##declsuffix(T a, void * ptr) {__builtin_kvx_store##suffix(a, ptr);} \
    int store##declsuffix##_r(T a, void * ptr, int * load) {\
        int ready = __builtin_kvx_ready(*load);\
        __builtin_kvx_store##suffix(a, ptr, ready);\
        return ready;\
    }

STORE(b, unsigned char, bc)
STORE(b, unsigned long, bl)
STORE(h, unsigned short, hs)
STORE(h, unsigned long, hl)
STORE(w, unsigned int, wi)
STORE(w, unsigned long, wl)
STORE(d, unsigned long, dl)
STORE(q, unsigned __int128, q)
STORE(hf, _Float16, hf)
STORE(wf, float, wf)
STORE(df, double, df)
STORE(64, v2i32, 64)
STORE(64, v4i16, 64h)
STORE(128, v4i32, 128)
STORE(128, v8i16, 128h)
STORE(256, v8i32, 256)
STORE(256, v16i16, 256h)

void store_vol(int a, void * ptr) {
    __builtin_kvx_storew(a, ptr, 1);
    __builtin_kvx_storew(a, ptr, 1);
}

void store_novol(int a, void * ptr) {
    __builtin_kvx_storew(a, ptr, 0);
    __builtin_kvx_storew(a, ptr, 0);
}

int store_r_vol(int a, void * ptr, int * load) {
    int ready = __builtin_kvx_ready(*load);
    __builtin_kvx_storew(a, ptr, ready, 1);
    __builtin_kvx_storew(a, ptr, ready, 1);
    return ready;
}

int store_r_novol(int a, void * ptr, int * load) {
    int ready = __builtin_kvx_ready(*load);
    __builtin_kvx_storew(a, ptr, ready, 0);
    __builtin_kvx_storew(a, ptr, ready, 0);
    return ready;
}

void ready_then_store(int * addr0, int * addr1, int * addr2,
                      int * to0, int * to1, int * to2){
    int a = *(addr0);
    int b = *(addr1);
    int c = *(addr2);
    int ready = __builtin_kvx_ready(a, b, c);
    __builtin_kvx_storew(a, to0, ready);
    __builtin_kvx_storew(b, to1, ready);
    __builtin_kvx_storew(c, to2, ready);
}

void load_then_store(int * addr0, int * addr1, int * addr2,
                     int * to0, int * to1, int * to2){
    int a = *(addr0);
    int b = *(addr1);
    int c = *(addr2);
    *to0 = a;
    *to1 = b;
    *to2 = c;
}

void store_imm(int * addr, int sv, int ready){
  __builtin_kvx_storew(sv, &addr[1], ready);
}

