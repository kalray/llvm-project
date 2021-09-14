typedef char __attribute__((__vector_size__(8 * sizeof(char)))) v8i8;
typedef char __attribute__((__vector_size__(16 * sizeof(char)))) v16i8;
typedef char __attribute__((__vector_size__(32 * sizeof(char)))) v32i8;

typedef short __attribute__((__vector_size__(4 * sizeof(short)))) v4i16;
typedef short __attribute__((__vector_size__(8 * sizeof(short)))) v8i16;
typedef short __attribute__((__vector_size__(16 * sizeof(short)))) v16i16;

typedef int __attribute__((__vector_size__(2 * sizeof(int)))) v2i32;
typedef int __attribute__((__vector_size__(4 * sizeof(int)))) v4i32;
typedef int __attribute__((__vector_size__(8 * sizeof(int)))) v8i32;

typedef long __attribute__((__vector_size__(2 * sizeof(long)))) v2i64;
typedef long __attribute__((__vector_size__(4 * sizeof(long)))) v4i64;

typedef unsigned int __attribute__((__vector_size__(2 * sizeof(unsigned int))))
v2u32;
typedef unsigned int __attribute__((__vector_size__(4 * sizeof(unsigned int))))
v4u32;
typedef unsigned int __attribute__((__vector_size__(8 * sizeof(unsigned int))))
v8u32;

typedef unsigned long
    __attribute__((__vector_size__(2 * sizeof(unsigned long)))) v2u64;
typedef unsigned long
    __attribute__((__vector_size__(4 * sizeof(unsigned long)))) v4u64;

#define half _Float16
typedef half __attribute__((__vector_size__(4 * sizeof(half)))) v4f16;
typedef half __attribute__((__vector_size__(8 * sizeof(half)))) v8f16;
typedef half __attribute__((__vector_size__(16 * sizeof(half)))) v16f16;

typedef float __attribute__((__vector_size__(2 * sizeof(float)))) v2f32;
typedef float __attribute__((__vector_size__(4 * sizeof(float)))) v4f32;
typedef float __attribute__((__vector_size__(8 * sizeof(float)))) v8f32;

typedef double __attribute__((__vector_size__(2 * sizeof(double)))) v2f64;
typedef double __attribute__((__vector_size__(4 * sizeof(double)))) v4f64;

