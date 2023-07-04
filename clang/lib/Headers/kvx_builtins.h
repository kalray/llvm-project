#ifndef __H__KVX_BUILTINS__
#define __H__KVX_BUILTINS__

#if defined(__llvm__) && defined(__kv3_1__)
/** LLVM KV3-1 emulation of KV3-2 builtins */

#define __get_v4i16_low(a) __builtin_shufflevector((a), (a), 0, 1, 2, 3)
#define __get_v4i16_high(a) __builtin_shufflevector((a), (a), 4, 5, 6, 7)

#define __builtin_kvx_fmulho(a, b, mod)                                        \
  (__kvx_v8hi) __builtin_shufflevector(                                        \
      __builtin_kvx_fmulhq(__get_v4i16_low(a), __get_v4i16_low(b), mod),       \
      __builtin_kvx_fmulhq(__get_v4i16_high(a), __get_v4i16_high(b), mod), 0,  \
      1, 2, 3, 4, 5, 6, 7)

#define __get_v8i16_low(a)                                                     \
  __builtin_shufflevector((a), (a), 0, 1, 2, 3, 4, 5, 6, 7)
#define __get_v8i16_high(a)                                                    \
  __builtin_shufflevector((a), (a), 8, 9, 10, 11, 12, 13, 14, 15)

#define __builtin_kvx_fmulhx(a, b, mod)                                        \
  (__kvx_v16hi) __builtin_shufflevector(                                       \
      __builtin_kvx_fmulho(__get_v8i16_low(a), __get_v8i16_low(b), mod),       \
      __builtin_kvx_fmulho(__get_v8i16_high(a), __get_v8i16_high(b), mod), 0,  \
      1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15)

#endif // defined(__llvm__) && defined(__kv3_1__)

#define __KVX_EXT_ADD_RED(name, inType, midType, outType)                      \
  inline outType __builtin_kvx_##name(inType V) {                              \
    midType M = __builtin_convertvector(V, midType);                           \
    return __builtin_reduce_add(M);                                            \
  }

__KVX_EXT_ADD_RED(addrbod, __kvx_v8qi, __kvx_v8di, long)
__KVX_EXT_ADD_RED(addrbpd, __kvx_v2qi, __kvx_v2di, long)
__KVX_EXT_ADD_RED(addrbqd, __kvx_v4qi, __kvx_v4di, long)
__KVX_EXT_ADD_RED(addrbvd, __kvx_v32qi, __kvx_v32di, long)
__KVX_EXT_ADD_RED(addrbxd, __kvx_v16qi, __kvx_v16di, long)

__KVX_EXT_ADD_RED(addrhod, __kvx_v8hi, __kvx_v8di, long)
__KVX_EXT_ADD_RED(addrhpd, __kvx_v2hi, __kvx_v2di, long)
__KVX_EXT_ADD_RED(addrhqd, __kvx_v4hi, __kvx_v4di, long)
__KVX_EXT_ADD_RED(addrhvd, __kvx_v32hi, __kvx_v32di, long)
__KVX_EXT_ADD_RED(addrhxd, __kvx_v16hi, __kvx_v16di, long)

__KVX_EXT_ADD_RED(addrwod, __kvx_v8si, __kvx_v8di, long)
__KVX_EXT_ADD_RED(addrwpd, __kvx_v2si, __kvx_v2di, long)
__KVX_EXT_ADD_RED(addrwqd, __kvx_v4si, __kvx_v4di, long)
__KVX_EXT_ADD_RED(addrwvd, __kvx_v32si, __kvx_v32di, long)
__KVX_EXT_ADD_RED(addrwxd, __kvx_v16si, __kvx_v16di, long)

__KVX_EXT_ADD_RED(addurbod, __kvx_v8qu, __kvx_v8du, unsigned long)
__KVX_EXT_ADD_RED(addurbpd, __kvx_v2qu, __kvx_v2du, unsigned long)
__KVX_EXT_ADD_RED(addurbqd, __kvx_v4qu, __kvx_v4du, unsigned long)
__KVX_EXT_ADD_RED(addurbvd, __kvx_v32qu, __kvx_v32du, unsigned long)
__KVX_EXT_ADD_RED(addurbxd, __kvx_v16qu, __kvx_v16du, unsigned long)

__KVX_EXT_ADD_RED(addurhod, __kvx_v8hu, __kvx_v8du, unsigned long)
__KVX_EXT_ADD_RED(addurhpd, __kvx_v2hu, __kvx_v2du, unsigned long)
__KVX_EXT_ADD_RED(addurhqd, __kvx_v4hu, __kvx_v4du, unsigned long)
__KVX_EXT_ADD_RED(addurhvd, __kvx_v32hu, __kvx_v32du, unsigned long)
__KVX_EXT_ADD_RED(addurhxd, __kvx_v16hu, __kvx_v16du, unsigned long)

__KVX_EXT_ADD_RED(addurwod, __kvx_v8su, __kvx_v8du, unsigned long)
__KVX_EXT_ADD_RED(addurwpd, __kvx_v2su, __kvx_v2du, unsigned long)
__KVX_EXT_ADD_RED(addurwqd, __kvx_v4su, __kvx_v4du, unsigned long)
__KVX_EXT_ADD_RED(addurwvd, __kvx_v32su, __kvx_v32du, unsigned long)
__KVX_EXT_ADD_RED(addurwxd, __kvx_v16su, __kvx_v16du, unsigned long)

#undef __KVX_EXT_ADD_RED
#endif /* __H__KVX_BUILTINS__ */
