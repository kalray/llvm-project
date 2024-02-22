// Run `$CC -E ready.C > ready.c` to regenerate

typedef char __attribute__((__vector_size__(2 * sizeof(char)))) v2i8;
typedef char __attribute__((__vector_size__(4 * sizeof(char)))) v4i8;
typedef char __attribute__((__vector_size__(8 * sizeof(char)))) v8i8;

typedef short __attribute__((__vector_size__(2 * sizeof(short)))) v2i16;
typedef short __attribute__((__vector_size__(4 * sizeof(short)))) v4i16;
typedef short __attribute__((__vector_size__(8 * sizeof(short)))) v8i16;

typedef _Float16 __attribute__((__vector_size__(2 * sizeof(_Float16)))) v2f16;
typedef _Float16 __attribute__((__vector_size__(4 * sizeof(_Float16)))) v4f16;

typedef int __attribute__((__vector_size__(2 * sizeof(int)))) v2i32;
typedef int __attribute__((__vector_size__(4 * sizeof(int)))) v4i32;
typedef int __attribute__((__vector_size__(8 * sizeof(int)))) v8i32;

typedef float __attribute__((__vector_size__(2 * sizeof(float)))) v2f32;
typedef float __attribute__((__vector_size__(4 * sizeof(float)))) v4f32;
typedef float __attribute__((__vector_size__(8 * sizeof(float)))) v8f32;

typedef long __attribute__((__vector_size__(2 * sizeof(long)))) v2i64;
typedef long __attribute__((__vector_size__(4 * sizeof(long)))) v4i64;

typedef double __attribute__((__vector_size__(2 * sizeof(double)))) v2f64;
typedef double __attribute__((__vector_size__(4 * sizeof(double)))) v4f64;

#define READY(T) long ready_##T(T * addr) { return __builtin_kvx_ready(*addr); }

READY(int)
READY(long)
READY(v2i8)
READY(v2i16)
READY(v2i32)
READY(v2i64)
READY(v4i8)
READY(v4i16)
READY(v4i32)
READY(v4i64)
READY(v8i8)
READY(_Float16)
READY(float)
READY(double)
READY(v2f16)
READY(v2f32)
READY(v2f64)
READY(v4f16)
READY(v4f32)
READY(v4f64)
READY(__int128)
READY(v8i16)
READY(v8i32)
READY(char)

#define READY2(T, U) long ready_##T##_##U(T * addr1, U * addr2) { return __builtin_kvx_ready(*addr1, *addr2); }

READY2(int, v4f32)
READY2(long, int)
READY2(float, v8i8)

#define READY3(T, U, V) long ready_##T##_##U##_##V(T * addr1, U * addr2, V * addr3) { return __builtin_kvx_ready(*addr1, *addr2, *addr3); }

READY3(int, long, float)
READY3(__int128, v8i8, v2i64)
READY3(char, short, double)

#define READY4(T, U, V, W) long ready_##T##_##U##_##V##_##W(T * addr1, U * addr2, V * addr3, W * addr4) { return __builtin_kvx_ready(*addr1, *addr2, *addr3, *addr4); }

READY4(char, short, int, long)
READY4(_Float16, float, double, v4i64)
READY4(v8f32, v4i32, __int128, char)

