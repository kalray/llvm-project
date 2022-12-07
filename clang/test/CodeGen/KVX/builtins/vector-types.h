typedef signed char v2i8 __attribute__((__vector_size__(2 * sizeof(char))));
typedef signed char v4i8 __attribute__((__vector_size__(4 * sizeof(char))));
typedef signed char v8i8 __attribute__((__vector_size__(8 * sizeof(char))));
typedef signed char v16i8 __attribute__((__vector_size__(16 * sizeof(char))));
typedef signed char v32i8 __attribute__((__vector_size__(32 * sizeof(char))));

typedef unsigned char v2u8 __attribute__((__vector_size__(2 * sizeof(char))));
typedef unsigned char v4u8 __attribute__((__vector_size__(4 * sizeof(char))));
typedef unsigned char v8u8 __attribute__((__vector_size__(8 * sizeof(char))));
typedef unsigned char v16u8 __attribute__((__vector_size__(16 * sizeof(char))));
typedef unsigned char v32u8 __attribute__((__vector_size__(32 * sizeof(char))));

typedef signed short v2i16 __attribute__((__vector_size__(2 * sizeof(short))));
typedef signed short v4i16 __attribute__((__vector_size__(4 * sizeof(short))));
typedef signed short v8i16 __attribute__((__vector_size__(8 * sizeof(short))));
typedef signed short v16i16 __attribute__((__vector_size__(16 * sizeof(short))));
typedef signed short v32i16 __attribute__((__vector_size__(32 * sizeof(short))));

typedef unsigned short v2u16 __attribute__((__vector_size__(2 * sizeof(short))));
typedef unsigned short v4u16 __attribute__((__vector_size__(4 * sizeof(short))));
typedef unsigned short v8u16 __attribute__((__vector_size__(8 * sizeof(short))));
typedef unsigned short v16u16 __attribute__((__vector_size__(16 * sizeof(short))));
typedef unsigned short v32u16 __attribute__((__vector_size__(32 * sizeof(short))));

typedef signed int v2i32 __attribute__((__vector_size__(2 * sizeof(int))));
typedef signed int v4i32 __attribute__((__vector_size__(4 * sizeof(int))));
typedef signed int v8i32 __attribute__((__vector_size__(8 * sizeof(int))));
typedef signed int v16i32 __attribute__((__vector_size__(16 * sizeof(int))));

typedef unsigned int v2u32 __attribute__((__vector_size__(2 * sizeof(int))));
typedef unsigned int v4u32 __attribute__((__vector_size__(4 * sizeof(int))));
typedef unsigned int v8u32 __attribute__((__vector_size__(8 * sizeof(int))));
typedef unsigned int v16u32 __attribute__((__vector_size__(16 * sizeof(int))));

typedef signed long v2i64 __attribute__((__vector_size__(2 * sizeof(long))));
typedef signed long v4i64 __attribute__((__vector_size__(4 * sizeof(long))));

typedef unsigned long v2u64 __attribute__((__vector_size__(2 * sizeof(long))));
typedef unsigned long v4u64 __attribute__((__vector_size__(4 * sizeof(long))));

typedef signed long v8i64 __attribute__((__vector_size__(8 * sizeof(long))));
typedef signed long v16i64 __attribute__((__vector_size__(16 * sizeof(long))));

#define half _Float16
typedef half __attribute__((__vector_size__(2 * sizeof(half)))) v2f16;
typedef half __attribute__((__vector_size__(4 * sizeof(half)))) v4f16;
typedef half __attribute__((__vector_size__(8 * sizeof(half)))) v8f16;
typedef half __attribute__((__vector_size__(16 * sizeof(half)))) v16f16;

typedef float __attribute__((__vector_size__(2 * sizeof(float)))) v2f32;
typedef float __attribute__((__vector_size__(4 * sizeof(float)))) v4f32;
typedef float __attribute__((__vector_size__(8 * sizeof(float)))) v8f32;

typedef double __attribute__((__vector_size__(2 * sizeof(double)))) v2f64;
typedef double __attribute__((__vector_size__(4 * sizeof(double)))) v4f64;
