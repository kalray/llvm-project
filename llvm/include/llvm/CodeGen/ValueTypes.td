//===- ValueTypes.td - ValueType definitions ---------------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// Value types - These values correspond to the register types defined in the
// MachineValueTypes.h file.  If you update anything here, you must update it
// there as well!
//
//===----------------------------------------------------------------------===//

class ValueType<int size, int value> {
  string Namespace = "MVT";
  int Size = size;
  int Value = value;
}

def OtherVT     : ValueType <0       ,  1      >;    // Other" value
def i1          : ValueType <1       ,  2      >;    // One bit boolean value
def i8          : ValueType <8       ,  3      >;    // 8-bit integer value
def i16         : ValueType <16      ,  4      >;    // 16-bit integer value
def i32         : ValueType <32      ,  5      >;    // 32-bit integer value
def i64         : ValueType <64      ,  6      >;    // 64-bit integer value
def i128        : ValueType <128     ,  7      >;    // 128-bit integer value

def bf16        : ValueType <16      ,  8      >;    // 16-bit brain floating point value
def f16         : ValueType <16      ,  9      >;    // 16-bit floating point value
def f32         : ValueType <32      ,  10     >;    // 32-bit floating point value
def f64         : ValueType <64      ,  11     >;    // 64-bit floating point value
def f80         : ValueType <80      ,  12     >;    // 80-bit floating point value
def f128        : ValueType <128     ,  13     >;    // 128-bit floating point value
def ppcf128     : ValueType <128     ,  14     >;    // PPC 128-bit floating point value

def v1i1        : ValueType <1       ,  15     >;    // 1 x i1 vector value
def v2i1        : ValueType <2       ,  16     >;    // 2 x i1 vector value
def v4i1        : ValueType <4       ,  17     >;    // 4 x i1 vector value
def v8i1        : ValueType <8       ,  18     >;    // 8 x i1 vector value
def v16i1       : ValueType <16      ,  19     >;    // 16 x i1 vector value
def v32i1       : ValueType <32      ,  20     >;    // 32 x i1 vector value
def v64i1       : ValueType <64      ,  21     >;    // 64 x i1 vector value
def v128i1      : ValueType <128     ,  22     >;    // 128 x i1 vector value
def v256i1      : ValueType <256     ,  23     >;    // 256 x i1 vector value
def v512i1      : ValueType <512     ,  24     >;    // 512 x i1 vector value
def v1024i1     : ValueType <1024    ,  25     >;    // 1024 x i1 vector value
def v2048i1     : ValueType <2048    ,  26     >;    // 2048 x i1 vector value
def v4096i1     : ValueType <1024    ,  27     >;    // 4096 x i1 vector value

def v1i8        : ValueType <8       ,  28     >;    // 1 x i8  vector value
def v2i8        : ValueType <16      ,  29     >;    // 2 x i8  vector value
def v4i8        : ValueType <32      ,  30     >;    // 4 x i8  vector value
def v8i8        : ValueType <64      ,  31     >;    // 8 x i8  vector value
def v16i8       : ValueType <128     ,  32     >;    // 16 x i8  vector value
def v32i8       : ValueType <256     ,  33     >;    // 32 x i8  vector value
def v64i8       : ValueType <512     ,  34     >;    // 64 x i8  vector value
def v128i8      : ValueType <1024    ,  35     >;    // 128 x i8  vector value
def v256i8      : ValueType <2048    ,  36     >;    // 256 x i8  vector value

def v1i16       : ValueType <16      ,  37     >;    // 1 x i16 vector value
def v2i16       : ValueType <32      ,  38     >;    // 2 x i16 vector value
def v3i16       : ValueType <48      ,  39     >;    // 3 x i16 vector value
def v4i16       : ValueType <64      ,  40     >;    // 4 x i16 vector value
def v8i16       : ValueType <128     ,  41     >;    // 8 x i16 vector value
def v16i16      : ValueType <256     ,  42     >;    // 16 x i16 vector value
def v32i16      : ValueType <512     ,  43     >;    // 32 x i16 vector value
def v64i16      : ValueType <1024    ,  44     >;    // 64 x i16 vector value
def v128i16     : ValueType <2048    ,  45     >;    // 128 x i16 vector value

def v1i32       : ValueType <32      ,  46     >;    // 1 x i32 vector value
def v2i32       : ValueType <64      ,  47     >;    // 2 x i32 vector value
def v3i32       : ValueType <96      ,  48     >;    // 3 x i32 vector value
def v4i32       : ValueType <128     ,  49     >;    // 4 x i32 vector value
def v5i32       : ValueType <160     ,  50     >;    // 5 x i32 vector value
def v8i32       : ValueType <256     ,  51     >;    // 8 x i32 vector value
def v16i32      : ValueType <512     ,  52     >;    // 16 x i32 vector value
def v32i32      : ValueType <1024    ,  53     >;    // 32 x i32 vector value
def v64i32      : ValueType <2048    ,  54     >;    // 64 x i32 vector value
def v128i32     : ValueType <4096    ,  55     >;    // 128 x i32 vector value
def v256i32     : ValueType <8182    ,  56     >;    // 256 x i32 vector value
def v512i32     : ValueType <16384   ,  57     >;    // 512 x i32 vector value
def v1024i32    : ValueType <32768   ,  58     >;    // 1024 x i32 vector value
def v2048i32    : ValueType <65536   ,  59     >;    // 2048 x i32 vector value

def v1i64       : ValueType <64      ,  60     >;    // 1 x i64 vector value
def v2i64       : ValueType <128     ,  61     >;    // 2 x i64 vector value
def v4i64       : ValueType <256     ,  62     >;    // 4 x i64 vector value
def v8i64       : ValueType <512     ,  63     >;    // 8 x i64 vector value
def v16i64      : ValueType <1024    ,  64     >;    // 16 x i64 vector value
def v32i64      : ValueType <2048    ,  65     >;    // 32 x i64 vector value
def v64i64      : ValueType <4096    ,  66     >;    // 64 x i64 vector value
def v128i64     : ValueType <8192    ,  67     >;    // 128 x i64 vector value
def v256i64     : ValueType <16384   ,  68     >;    // 256 x i64 vector value

def v1i128      : ValueType <128     ,  69     >;    // 1 x i128 vector value

def v2f16       : ValueType <32      ,  70     >;    // 2 x f16 vector value
def v3f16       : ValueType <48      ,  71     >;    // 3 x f16 vector value
def v4f16       : ValueType <64      ,  72     >;    // 4 x f16 vector value
def v8f16       : ValueType <128     ,  73     >;    // 8 x f16 vector value
def v16f16      : ValueType <256     ,  74     >;    // 16 x f16 vector value
def v32f16      : ValueType <512     ,  75     >;    // 32 x f16 vector value
def v64f16      : ValueType <1024    ,  76     >;    // 64 x f16 vector value
def v128f16     : ValueType <2048    ,  77     >;    // 128 x f16 vector value
def v2bf16      : ValueType <32      ,  78     >;    // 2 x bf16 vector value
def v3bf16      : ValueType <48      ,  79     >;    // 3 x bf16 vector value
def v4bf16      : ValueType <64      ,  80     >;    // 4 x bf16 vector value
def v8bf16      : ValueType <128     ,  81     >;    // 8 x bf16 vector value
def v16bf16     : ValueType <256     ,  82     >;    // 16 x bf16 vector value
def v32bf16     : ValueType <512     ,  83     >;    // 32 x bf16 vector value
def v64bf16     : ValueType <1024    ,  84     >;    // 64 x bf16 vector value
def v128bf16    : ValueType <2048    ,  85     >;    // 128 x bf16 vector value
def v1f32       : ValueType <32      ,  86     >;    // 1 x f32 vector value
def v2f32       : ValueType <64      ,  87     >;    // 2 x f32 vector value
def v3f32       : ValueType <96      ,  88     >;    // 3 x f32 vector value
def v4f32       : ValueType <128     ,  89     >;    // 4 x f32 vector value
def v5f32       : ValueType <160     ,  90     >;    // 5 x f32 vector value
def v8f32       : ValueType <256     ,  91     >;    // 8 x f32 vector value
def v16f32      : ValueType <512     ,  92     >;    // 16 x f32 vector value
def v32f32      : ValueType <1024    ,  93     >;    // 32 x f32 vector value
def v64f32      : ValueType <2048    ,  94     >;    // 64 x f32 vector value
def v128f32     : ValueType <4096    ,  95     >;    // 128 x f32 vector value
def v256f32     : ValueType <8182    ,  96     >;    // 256 x f32 vector value
def v512f32     : ValueType <16384   ,  97     >;    // 512 x f32 vector value
def v1024f32    : ValueType <32768   ,  98     >;    // 1024 x f32 vector value
def v2048f32    : ValueType <65536   ,  99     >;    // 2048 x f32 vector value
def v1f64       : ValueType <64      ,  100    >;    // 1 x f64 vector value
def v2f64       : ValueType <128     ,  101    >;    // 2 x f64 vector value
def v4f64       : ValueType <256     ,  102    >;    // 4 x f64 vector value
def v8f64       : ValueType <512     ,  103    >;    // 8 x f64 vector value
def v16f64      : ValueType <1024    ,  104    >;    // 16 x f64 vector value
def v32f64      : ValueType <2048    ,  105    >;    // 32 x f64 vector value
def v64f64      : ValueType <4096    ,  106    >;    // 64 x f64 vector value
def v128f64     : ValueType <8192    ,  107    >;    // 128 x f64 vector value
def v256f64     : ValueType <16384   ,  108    >;    // 256 x f64 vector value

def nxv1i1      : ValueType <1       ,  109    >;    // n x  1 x i1  vector value
def nxv2i1      : ValueType <2       ,  110    >;    // n x  2 x i1  vector value
def nxv4i1      : ValueType <4       ,  111    >;    // n x  4 x i1  vector value
def nxv8i1      : ValueType <8       ,  112    >;    // n x  8 x i1  vector value
def nxv16i1     : ValueType <16      ,  113    >;    // n x 16 x i1  vector value
def nxv32i1     : ValueType <32      ,  114    >;    // n x 32 x i1  vector value
def nxv64i1     : ValueType <64      ,  115    >;    // n x  64 x i1  vector value

def nxv1i8      : ValueType <8       ,  116    >;    // n x  1 x i8  vector value
def nxv2i8      : ValueType <16      ,  117    >;    // n x  2 x i8  vector value
def nxv4i8      : ValueType <32      ,  118    >;    // n x  4 x i8  vector value
def nxv8i8      : ValueType <64      ,  119    >;    // n x  8 x i8  vector value
def nxv16i8     : ValueType <128     ,  120    >;    // n x 16 x i8  vector value
def nxv32i8     : ValueType <256     ,  121    >;    // n x 32 x i8  vector value
def nxv64i8     : ValueType <512     ,  122    >;    // n x  64 x i8  vector value

def nxv1i16     : ValueType <16      ,  123    >;    // n x  1 x i16 vector value
def nxv2i16     : ValueType <32      ,  124    >;    // n x  2 x i16 vector value
def nxv4i16     : ValueType <64      ,  125    >;    // n x  4 x i16 vector value
def nxv8i16     : ValueType <128     ,  126    >;    // n x  8 x i16 vector value
def nxv16i16    : ValueType <256     ,  127    >;    // n x 16 x i16 vector value
def nxv32i16    : ValueType <512     ,  128    >;    // n x 32 x i16 vector value

def nxv1i32     : ValueType <32      ,  129    >;    // n x  1 x i32 vector value
def nxv2i32     : ValueType <64      ,  130    >;    // n x  2 x i32 vector value
def nxv4i32     : ValueType <128     ,  131    >;    // n x  4 x i32 vector value
def nxv8i32     : ValueType <256     ,  132    >;    // n x  8 x i32 vector value
def nxv16i32    : ValueType <512     ,  133    >;    // n x 16 x i32 vector value
def nxv32i32    : ValueType <1024    ,  134    >;    // n x 32 x i32 vector value

def nxv1i64     : ValueType <64      ,  135    >;    // n x  1 x i64 vector value
def nxv2i64     : ValueType <128     ,  136    >;    // n x  2 x i64 vector value
def nxv4i64     : ValueType <256     ,  137    >;    // n x  4 x i64 vector value
def nxv8i64     : ValueType <512     ,  138    >;    // n x  8 x i64 vector value
def nxv16i64    : ValueType <1024    ,  139    >;    // n x 16 x i64 vector value
def nxv32i64    : ValueType <2048    ,  140    >;    // n x 32 x i64 vector value

def nxv1f16     : ValueType <32      ,  141    >;    // n x   1 x f16 vector value
def nxv2f16     : ValueType <32      ,  142    >;    // n x  2 x f16 vector value
def nxv4f16     : ValueType <64      ,  143    >;    // n x  4 x f16 vector value
def nxv8f16     : ValueType <128     ,  144    >;    // n x  8 x f16 vector value
def nxv16f16    : ValueType <256     ,  145    >;    // n x  16 x f16 vector value
def nxv32f16    : ValueType <512     ,  146    >;    // n x  32 x f16 vector value
def nxv2bf16    : ValueType <32      ,  147    >;    // n x  2 x bf16 vector value
def nxv4bf16    : ValueType <64      ,  148    >;    // n x  4 x bf16 vector value
def nxv8bf16    : ValueType <128     ,  149    >;    // n x  8 x bf16 vector value
def nxv1f32     : ValueType <32      ,  150    >;    // n x  1 x f32 vector value
def nxv2f32     : ValueType <64      ,  151    >;    // n x  2 x f32 vector value
def nxv4f32     : ValueType <128     ,  152    >;    // n x  4 x f32 vector value
def nxv8f32     : ValueType <256     ,  153    >;    // n x  8 x f32 vector value
def nxv16f32    : ValueType <512     ,  154    >;    // n x 16 x f32 vector value
def nxv1f64     : ValueType <64      ,  155    >;    // n x  1 x f64 vector value
def nxv2f64     : ValueType <128     ,  156    >;    // n x  2 x f64 vector value
def nxv4f64     : ValueType <256     ,  157    >;    // n x  4 x f64 vector value
def nxv8f64     : ValueType <512     ,  158    >;    // n x  8 x f64 vector value

def x86mmx      : ValueType <64      ,  159    >;    // X86 MMX value
def FlagVT      : ValueType <0       ,  160    >;    // Pre-RA sched glue
def isVoid      : ValueType <0       ,  161    >;    // Produces no value
def untyped     : ValueType <8       ,  162    >;    // Produces an untyped value
def funcref     : ValueType <0       ,  163    >;    // WebAssembly's funcref type
def externref   : ValueType <0       ,  164    >;    // WebAssembly's externref type
def x86amx      : ValueType <8192    ,  165    >;    // X86 AMX value

def token  : ValueType<0  ,  248>;   // TokenTy
def MetadataVT: ValueType<0,  249>;  // Metadata

// Pseudo valuetype mapped to the current pointer size to any address space.
// Should only be used in TableGen.
def iPTRAny   : ValueType<0, 250>;

// Pseudo valuetype to represent "vector of any size"
def vAny   : ValueType<0  , 251>;

// Pseudo valuetype to represent "float of any format"
def fAny   : ValueType<0  , 252>;

// Pseudo valuetype to represent "integer of any bit width"
def iAny   : ValueType<0  , 253>;

// Pseudo valuetype mapped to the current pointer size.
def iPTR   : ValueType<0  , 254>;

// Pseudo valuetype to represent "any type of any size".
def Any    : ValueType<0  , 255>;

/// This class is for targets that want to use pointer types in patterns
/// with the GlobalISelEmitter.  Targets must define their own pointer
/// derived from this class.  The scalar argument should be an
/// integer type with the same bit size as the ponter.
/// e.g. def p0 : PtrValueType <i64, 0>;

class PtrValueType <ValueType scalar, int addrspace> :
    ValueType<scalar.Size, scalar.Value> {
  int AddrSpace = addrspace;
}
