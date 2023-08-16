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

#define __KVX_EXT_OP_RED(op, name, inType, midType, outType)                   \
  inline outType __builtin_kvx_##name(inType V) {                              \
    midType M = __builtin_convertvector(V, midType);                           \
    return __builtin_reduce_##op(M);                                           \
  }

#define __KVX_OP_EXT_RED(op, name, inType, outType)                            \
  inline outType __builtin_kvx_##name(inType V) {                              \
    return __builtin_reduce_##op(V);                                           \
  }

__KVX_EXT_OP_RED(add, addrbod, __kvx_v8qi, __kvx_v8di, long)
__KVX_EXT_OP_RED(add, addrbpd, __kvx_v2qi, __kvx_v2di, long)
__KVX_EXT_OP_RED(add, addrbqd, __kvx_v4qi, __kvx_v4di, long)
__KVX_EXT_OP_RED(add, addrbvd, __kvx_v32qi, __kvx_v32di, long)
__KVX_EXT_OP_RED(add, addrbxd, __kvx_v16qi, __kvx_v16di, long)

__KVX_EXT_OP_RED(add, addrhod, __kvx_v8hi, __kvx_v8di, long)
__KVX_EXT_OP_RED(add, addrhpd, __kvx_v2hi, __kvx_v2di, long)
__KVX_EXT_OP_RED(add, addrhqd, __kvx_v4hi, __kvx_v4di, long)
__KVX_EXT_OP_RED(add, addrhvd, __kvx_v32hi, __kvx_v32di, long)
__KVX_EXT_OP_RED(add, addrhxd, __kvx_v16hi, __kvx_v16di, long)

__KVX_EXT_OP_RED(add, addrwod, __kvx_v8si, __kvx_v8di, long)
__KVX_EXT_OP_RED(add, addrwpd, __kvx_v2si, __kvx_v2di, long)
__KVX_EXT_OP_RED(add, addrwqd, __kvx_v4si, __kvx_v4di, long)
__KVX_EXT_OP_RED(add, addrwvd, __kvx_v32si, __kvx_v32di, long)
__KVX_EXT_OP_RED(add, addrwxd, __kvx_v16si, __kvx_v16di, long)

__KVX_EXT_OP_RED(add, addurbod, __kvx_v8qu, __kvx_v8du, unsigned long)
__KVX_EXT_OP_RED(add, addurbpd, __kvx_v2qu, __kvx_v2du, unsigned long)
__KVX_EXT_OP_RED(add, addurbqd, __kvx_v4qu, __kvx_v4du, unsigned long)
__KVX_EXT_OP_RED(add, addurbvd, __kvx_v32qu, __kvx_v32du, unsigned long)
__KVX_EXT_OP_RED(add, addurbxd, __kvx_v16qu, __kvx_v16du, unsigned long)

__KVX_EXT_OP_RED(add, addurhod, __kvx_v8hu, __kvx_v8du, unsigned long)
__KVX_EXT_OP_RED(add, addurhpd, __kvx_v2hu, __kvx_v2du, unsigned long)
__KVX_EXT_OP_RED(add, addurhqd, __kvx_v4hu, __kvx_v4du, unsigned long)
__KVX_EXT_OP_RED(add, addurhvd, __kvx_v32hu, __kvx_v32du, unsigned long)
__KVX_EXT_OP_RED(add, addurhxd, __kvx_v16hu, __kvx_v16du, unsigned long)

__KVX_EXT_OP_RED(add, addurwod, __kvx_v8su, __kvx_v8du, unsigned long)
__KVX_EXT_OP_RED(add, addurwpd, __kvx_v2su, __kvx_v2du, unsigned long)
__KVX_EXT_OP_RED(add, addurwqd, __kvx_v4su, __kvx_v4du, unsigned long)
__KVX_EXT_OP_RED(add, addurwvd, __kvx_v32su, __kvx_v32du, unsigned long)
__KVX_EXT_OP_RED(add, addurwxd, __kvx_v16su, __kvx_v16du, unsigned long)

__KVX_OP_EXT_RED(and, andrbod, __kvx_v8qu, unsigned long)
__KVX_OP_EXT_RED(and, andrbpd, __kvx_v2qu, unsigned long)
__KVX_OP_EXT_RED(and, andrbqd, __kvx_v4qu, unsigned long)
__KVX_OP_EXT_RED(and, andrbvd, __kvx_v32qu, unsigned long)
__KVX_OP_EXT_RED(and, andrbxd, __kvx_v16qu, unsigned long)

__KVX_OP_EXT_RED(and, andrhod, __kvx_v8hu, unsigned long)
__KVX_OP_EXT_RED(and, andrhpd, __kvx_v2hu, unsigned long)
__KVX_OP_EXT_RED(and, andrhqd, __kvx_v4hu, unsigned long)
__KVX_OP_EXT_RED(and, andrhvd, __kvx_v32hu, unsigned long)
__KVX_OP_EXT_RED(and, andrhxd, __kvx_v16hu, unsigned long)

__KVX_OP_EXT_RED(and, andrwod, __kvx_v8su, unsigned long)
__KVX_OP_EXT_RED(and, andrwpd, __kvx_v2su, unsigned long)
__KVX_OP_EXT_RED(and, andrwqd, __kvx_v4su, unsigned long)
__KVX_OP_EXT_RED(and, andrwvd, __kvx_v32su, unsigned long)
__KVX_OP_EXT_RED(and, andrwxd, __kvx_v16su, unsigned long)

__KVX_OP_EXT_RED(max, maxrbod, __kvx_v8qi, long)
__KVX_OP_EXT_RED(max, maxrbpd, __kvx_v2qi, long)
__KVX_OP_EXT_RED(max, maxrbqd, __kvx_v4qi, long)
__KVX_OP_EXT_RED(max, maxrbvd, __kvx_v32qi, long)
__KVX_OP_EXT_RED(max, maxrbxd, __kvx_v16qi, long)

__KVX_OP_EXT_RED(max, maxrhod, __kvx_v8hi, long)
__KVX_OP_EXT_RED(max, maxrhpd, __kvx_v2hi, long)
__KVX_OP_EXT_RED(max, maxrhqd, __kvx_v4hi, long)
__KVX_OP_EXT_RED(max, maxrhvd, __kvx_v32hi, long)
__KVX_OP_EXT_RED(max, maxrhxd, __kvx_v16hi, long)

__KVX_OP_EXT_RED(max, maxrwod, __kvx_v8si, long)
__KVX_OP_EXT_RED(max, maxrwpd, __kvx_v2si, long)
__KVX_OP_EXT_RED(max, maxrwqd, __kvx_v4si, long)
__KVX_OP_EXT_RED(max, maxrwvd, __kvx_v32si, long)
__KVX_OP_EXT_RED(max, maxrwxd, __kvx_v16si, long)

__KVX_OP_EXT_RED(max, maxurbod, __kvx_v8qu, unsigned long)
__KVX_OP_EXT_RED(max, maxurbpd, __kvx_v2qu, unsigned long)
__KVX_OP_EXT_RED(max, maxurbqd, __kvx_v4qu, unsigned long)
__KVX_OP_EXT_RED(max, maxurbvd, __kvx_v32qu, unsigned long)
__KVX_OP_EXT_RED(max, maxurbxd, __kvx_v16qu, unsigned long)

__KVX_OP_EXT_RED(max, maxurhod, __kvx_v8hu, unsigned long)
__KVX_OP_EXT_RED(max, maxurhpd, __kvx_v2hu, unsigned long)
__KVX_OP_EXT_RED(max, maxurhqd, __kvx_v4hu, unsigned long)
__KVX_OP_EXT_RED(max, maxurhvd, __kvx_v32hu, unsigned long)
__KVX_OP_EXT_RED(max, maxurhxd, __kvx_v16hu, unsigned long)

__KVX_OP_EXT_RED(max, maxurwod, __kvx_v8su, unsigned long)
__KVX_OP_EXT_RED(max, maxurwpd, __kvx_v2su, unsigned long)
__KVX_OP_EXT_RED(max, maxurwqd, __kvx_v4su, unsigned long)
__KVX_OP_EXT_RED(max, maxurwvd, __kvx_v32su, unsigned long)
__KVX_OP_EXT_RED(max, maxurwxd, __kvx_v16su, unsigned long)

__KVX_OP_EXT_RED(min, minrbod, __kvx_v8qi, long)
__KVX_OP_EXT_RED(min, minrbpd, __kvx_v2qi, long)
__KVX_OP_EXT_RED(min, minrbqd, __kvx_v4qi, long)
__KVX_OP_EXT_RED(min, minrbvd, __kvx_v32qi, long)
__KVX_OP_EXT_RED(min, minrbxd, __kvx_v16qi, long)

__KVX_OP_EXT_RED(min, minrhod, __kvx_v8hi, long)
__KVX_OP_EXT_RED(min, minrhpd, __kvx_v2hi, long)
__KVX_OP_EXT_RED(min, minrhqd, __kvx_v4hi, long)
__KVX_OP_EXT_RED(min, minrhvd, __kvx_v32hi, long)
__KVX_OP_EXT_RED(min, minrhxd, __kvx_v16hi, long)

__KVX_OP_EXT_RED(min, minrwod, __kvx_v8si, long)
__KVX_OP_EXT_RED(min, minrwpd, __kvx_v2si, long)
__KVX_OP_EXT_RED(min, minrwqd, __kvx_v4si, long)
__KVX_OP_EXT_RED(min, minrwvd, __kvx_v32si, long)
__KVX_OP_EXT_RED(min, minrwxd, __kvx_v16si, long)

__KVX_OP_EXT_RED(min, minurbod, __kvx_v8qu, unsigned long)
__KVX_OP_EXT_RED(min, minurbpd, __kvx_v2qu, unsigned long)
__KVX_OP_EXT_RED(min, minurbqd, __kvx_v4qu, unsigned long)
__KVX_OP_EXT_RED(min, minurbvd, __kvx_v32qu, unsigned long)
__KVX_OP_EXT_RED(min, minurbxd, __kvx_v16qu, unsigned long)

__KVX_OP_EXT_RED(min, minurhod, __kvx_v8hu, unsigned long)
__KVX_OP_EXT_RED(min, minurhpd, __kvx_v2hu, unsigned long)
__KVX_OP_EXT_RED(min, minurhqd, __kvx_v4hu, unsigned long)
__KVX_OP_EXT_RED(min, minurhvd, __kvx_v32hu, unsigned long)
__KVX_OP_EXT_RED(min, minurhxd, __kvx_v16hu, unsigned long)

__KVX_OP_EXT_RED(min, minurwod, __kvx_v8su, unsigned long)
__KVX_OP_EXT_RED(min, minurwpd, __kvx_v2su, unsigned long)
__KVX_OP_EXT_RED(min, minurwqd, __kvx_v4su, unsigned long)
__KVX_OP_EXT_RED(min, minurwvd, __kvx_v32su, unsigned long)
__KVX_OP_EXT_RED(min, minurwxd, __kvx_v16su, unsigned long)

__KVX_OP_EXT_RED(or, orrbod, __kvx_v8qu, unsigned long)
__KVX_OP_EXT_RED(or, orrbpd, __kvx_v2qu, unsigned long)
__KVX_OP_EXT_RED(or, orrbqd, __kvx_v4qu, unsigned long)
__KVX_OP_EXT_RED(or, orrbvd, __kvx_v32qu, unsigned long)
__KVX_OP_EXT_RED(or, orrbxd, __kvx_v16qu, unsigned long)

__KVX_OP_EXT_RED(or, orrhod, __kvx_v8hu, unsigned long)
__KVX_OP_EXT_RED(or, orrhpd, __kvx_v2hu, unsigned long)
__KVX_OP_EXT_RED(or, orrhqd, __kvx_v4hu, unsigned long)
__KVX_OP_EXT_RED(or, orrhvd, __kvx_v32hu, unsigned long)
__KVX_OP_EXT_RED(or, orrhxd, __kvx_v16hu, unsigned long)

__KVX_OP_EXT_RED(or, orrwod, __kvx_v8su, unsigned long)
__KVX_OP_EXT_RED(or, orrwpd, __kvx_v2su, unsigned long)
__KVX_OP_EXT_RED(or, orrwqd, __kvx_v4su, unsigned long)
__KVX_OP_EXT_RED(or, orrwvd, __kvx_v32su, unsigned long)
__KVX_OP_EXT_RED(or, orrwxd, __kvx_v16su, unsigned long)

__KVX_OP_EXT_RED(xor, xorrbod, __kvx_v8qu, unsigned long)
__KVX_OP_EXT_RED(xor, xorrbpd, __kvx_v2qu, unsigned long)
__KVX_OP_EXT_RED(xor, xorrbqd, __kvx_v4qu, unsigned long)
__KVX_OP_EXT_RED(xor, xorrbvd, __kvx_v32qu, unsigned long)
__KVX_OP_EXT_RED(xor, xorrbxd, __kvx_v16qu, unsigned long)

__KVX_OP_EXT_RED(xor, xorrhod, __kvx_v8hu, unsigned long)
__KVX_OP_EXT_RED(xor, xorrhpd, __kvx_v2hu, unsigned long)
__KVX_OP_EXT_RED(xor, xorrhqd, __kvx_v4hu, unsigned long)
__KVX_OP_EXT_RED(xor, xorrhvd, __kvx_v32hu, unsigned long)
__KVX_OP_EXT_RED(xor, xorrhxd, __kvx_v16hu, unsigned long)

__KVX_OP_EXT_RED(xor, xorrwod, __kvx_v8su, unsigned long)
__KVX_OP_EXT_RED(xor, xorrwpd, __kvx_v2su, unsigned long)
__KVX_OP_EXT_RED(xor, xorrwqd, __kvx_v4su, unsigned long)
__KVX_OP_EXT_RED(xor, xorrwvd, __kvx_v32su, unsigned long)
__KVX_OP_EXT_RED(xor, xorrwxd, __kvx_v16su, unsigned long)

#undef __KVX_EXT_OP_RED
#undef __KVX_OP_EXT_RED
#endif /* __H__KVX_BUILTINS__ */
