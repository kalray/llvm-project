; NOTE: Assertions have been autogenerated by utils/update_analyze_test_checks.py
; RUN: opt -mcpu=kv3-1 -mtriple=kvx-kalray-cos -passes='print<cost-model>' -cost-kind=throughput -disable-output %s 2>&1 | FileCheck %s --check-prefix=CV1
; RUN: opt -mcpu=kv3-2 -mtriple=kvx-kalray-cos -passes='print<cost-model>' -cost-kind=throughput -disable-output %s 2>&1 | FileCheck %s --check-prefix=CV2

target triple = "kvx-kalray-cos"

define void @reduce_umin() {
; CV1-LABEL: 'reduce_umin'
; CV1-NEXT:  Cost Model: Invalid cost for instruction: %V2i1 = call i1 @llvm.vector.reduce.umin.v2i1(<2 x i1> undef)
; CV1-NEXT:  Cost Model: Invalid cost for instruction: %V3i1 = call i1 @llvm.vector.reduce.umin.v3i1(<3 x i1> undef)
; CV1-NEXT:  Cost Model: Invalid cost for instruction: %V4i1 = call i1 @llvm.vector.reduce.umin.v4i1(<4 x i1> undef)
; CV1-NEXT:  Cost Model: Invalid cost for instruction: %V8i1 = call i1 @llvm.vector.reduce.umin.v8i1(<8 x i1> undef)
; CV1-NEXT:  Cost Model: Invalid cost for instruction: %V16i1 = call i1 @llvm.vector.reduce.umin.v16i1(<16 x i1> undef)
; CV1-NEXT:  Cost Model: Invalid cost for instruction: %V32i1 = call i1 @llvm.vector.reduce.umin.v32i1(<32 x i1> undef)
; CV1-NEXT:  Cost Model: Found an estimated cost of 3 for instruction: %V2i8 = call i8 @llvm.vector.reduce.umin.v2i8(<2 x i8> undef)
; CV1-NEXT:  Cost Model: Found an estimated cost of 3 for instruction: %V3i8 = call i8 @llvm.vector.reduce.umin.v3i8(<3 x i8> undef)
; CV1-NEXT:  Cost Model: Found an estimated cost of 4 for instruction: %V4i8 = call i8 @llvm.vector.reduce.umin.v4i8(<4 x i8> undef)
; CV1-NEXT:  Cost Model: Found an estimated cost of 11 for instruction: %V8i8 = call i8 @llvm.vector.reduce.umin.v8i8(<8 x i8> undef)
; CV1-NEXT:  Cost Model: Found an estimated cost of 21 for instruction: %V16i8 = call i8 @llvm.vector.reduce.umin.v16i8(<16 x i8> undef)
; CV1-NEXT:  Cost Model: Found an estimated cost of 39 for instruction: %V32i8 = call i8 @llvm.vector.reduce.umin.v32i8(<32 x i8> undef)
; CV1-NEXT:  Cost Model: Found an estimated cost of 73 for instruction: %V64i8 = call i8 @llvm.vector.reduce.umin.v64i8(<64 x i8> undef)
; CV1-NEXT:  Cost Model: Found an estimated cost of 3 for instruction: %V2i16 = call i16 @llvm.vector.reduce.umin.v2i16(<2 x i16> undef)
; CV1-NEXT:  Cost Model: Found an estimated cost of 6 for instruction: %V4i16 = call i16 @llvm.vector.reduce.umin.v4i16(<4 x i16> undef)
; CV1-NEXT:  Cost Model: Found an estimated cost of 12 for instruction: %V8i16 = call i16 @llvm.vector.reduce.umin.v8i16(<8 x i16> undef)
; CV1-NEXT:  Cost Model: Found an estimated cost of 22 for instruction: %V16i16 = call i16 @llvm.vector.reduce.umin.v16i16(<16 x i16> undef)
; CV1-NEXT:  Cost Model: Found an estimated cost of 3 for instruction: %V2i32 = call i32 @llvm.vector.reduce.umin.v2i32(<2 x i32> undef)
; CV1-NEXT:  Cost Model: Found an estimated cost of 7 for instruction: %V4i32 = call i32 @llvm.vector.reduce.umin.v4i32(<4 x i32> undef)
; CV1-NEXT:  Cost Model: Found an estimated cost of 13 for instruction: %V8i32 = call i32 @llvm.vector.reduce.umin.v8i32(<8 x i32> undef)
; CV1-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %V2i64 = call i64 @llvm.vector.reduce.umin.v2i64(<2 x i64> undef)
; CV1-NEXT:  Cost Model: Found an estimated cost of 4 for instruction: %V4i64 = call i64 @llvm.vector.reduce.umin.v4i64(<4 x i64> undef)
; CV1-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: ret void
;
; CV2-LABEL: 'reduce_umin'
; CV2-NEXT:  Cost Model: Invalid cost for instruction: %V2i1 = call i1 @llvm.vector.reduce.umin.v2i1(<2 x i1> undef)
; CV2-NEXT:  Cost Model: Invalid cost for instruction: %V3i1 = call i1 @llvm.vector.reduce.umin.v3i1(<3 x i1> undef)
; CV2-NEXT:  Cost Model: Invalid cost for instruction: %V4i1 = call i1 @llvm.vector.reduce.umin.v4i1(<4 x i1> undef)
; CV2-NEXT:  Cost Model: Invalid cost for instruction: %V8i1 = call i1 @llvm.vector.reduce.umin.v8i1(<8 x i1> undef)
; CV2-NEXT:  Cost Model: Invalid cost for instruction: %V16i1 = call i1 @llvm.vector.reduce.umin.v16i1(<16 x i1> undef)
; CV2-NEXT:  Cost Model: Invalid cost for instruction: %V32i1 = call i1 @llvm.vector.reduce.umin.v32i1(<32 x i1> undef)
; CV2-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %V2i8 = call i8 @llvm.vector.reduce.umin.v2i8(<2 x i8> undef)
; CV2-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %V3i8 = call i8 @llvm.vector.reduce.umin.v3i8(<3 x i8> undef)
; CV2-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %V4i8 = call i8 @llvm.vector.reduce.umin.v4i8(<4 x i8> undef)
; CV2-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %V8i8 = call i8 @llvm.vector.reduce.umin.v8i8(<8 x i8> undef)
; CV2-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %V16i8 = call i8 @llvm.vector.reduce.umin.v16i8(<16 x i8> undef)
; CV2-NEXT:  Cost Model: Found an estimated cost of 3 for instruction: %V32i8 = call i8 @llvm.vector.reduce.umin.v32i8(<32 x i8> undef)
; CV2-NEXT:  Cost Model: Found an estimated cost of 4 for instruction: %V64i8 = call i8 @llvm.vector.reduce.umin.v64i8(<64 x i8> undef)
; CV2-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %V2i16 = call i16 @llvm.vector.reduce.umin.v2i16(<2 x i16> undef)
; CV2-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %V4i16 = call i16 @llvm.vector.reduce.umin.v4i16(<4 x i16> undef)
; CV2-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %V8i16 = call i16 @llvm.vector.reduce.umin.v8i16(<8 x i16> undef)
; CV2-NEXT:  Cost Model: Found an estimated cost of 3 for instruction: %V16i16 = call i16 @llvm.vector.reduce.umin.v16i16(<16 x i16> undef)
; CV2-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %V2i32 = call i32 @llvm.vector.reduce.umin.v2i32(<2 x i32> undef)
; CV2-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %V4i32 = call i32 @llvm.vector.reduce.umin.v4i32(<4 x i32> undef)
; CV2-NEXT:  Cost Model: Found an estimated cost of 3 for instruction: %V8i32 = call i32 @llvm.vector.reduce.umin.v8i32(<8 x i32> undef)
; CV2-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %V2i64 = call i64 @llvm.vector.reduce.umin.v2i64(<2 x i64> undef)
; CV2-NEXT:  Cost Model: Found an estimated cost of 3 for instruction: %V4i64 = call i64 @llvm.vector.reduce.umin.v4i64(<4 x i64> undef)
; CV2-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: ret void
;
  %V2i1 = call i1 @llvm.vector.reduce.umin.v2i1(<2 x i1> undef)
  %V3i1 = call i1 @llvm.vector.reduce.umin.v3i1(<3 x i1> undef)
  %V4i1 = call i1 @llvm.vector.reduce.umin.v4i1(<4 x i1> undef)
  %V8i1 = call i1 @llvm.vector.reduce.umin.v8i1(<8 x i1> undef)
  %V16i1 = call i1 @llvm.vector.reduce.umin.v16i1(<16 x i1> undef)
  %V32i1 = call i1 @llvm.vector.reduce.umin.v32i1(<32 x i1> undef)
  %V2i8 = call i8 @llvm.vector.reduce.umin.v2i8(<2 x i8> undef)
  %V3i8 = call i8 @llvm.vector.reduce.umin.v3i8(<3 x i8> undef)
  %V4i8 = call i8 @llvm.vector.reduce.umin.v4i8(<4 x i8> undef)
  %V8i8 = call i8 @llvm.vector.reduce.umin.v8i8(<8 x i8> undef)
  %V16i8 = call i8 @llvm.vector.reduce.umin.v16i8(<16 x i8> undef)
  %V32i8 = call i8 @llvm.vector.reduce.umin.v32i8(<32 x i8> undef)
  %V64i8 = call i8 @llvm.vector.reduce.umin.v64i8(<64 x i8> undef)
  %V2i16 = call i16 @llvm.vector.reduce.umin.v2i16(<2 x i16> undef)
  %V4i16 = call i16 @llvm.vector.reduce.umin.v4i16(<4 x i16> undef)
  %V8i16 = call i16 @llvm.vector.reduce.umin.v8i16(<8 x i16> undef)
  %V16i16 = call i16 @llvm.vector.reduce.umin.v16i16(<16 x i16> undef)
  %V2i32 = call i32 @llvm.vector.reduce.umin.v2i32(<2 x i32> undef)
  %V4i32 = call i32 @llvm.vector.reduce.umin.v4i32(<4 x i32> undef)
  %V8i32 = call i32 @llvm.vector.reduce.umin.v8i32(<8 x i32> undef)
  %V2i64 = call i64 @llvm.vector.reduce.umin.v2i64(<2 x i64> undef)
  %V4i64 = call i64 @llvm.vector.reduce.umin.v4i64(<4 x i64> undef)
  ret void
}

declare i1 @llvm.vector.reduce.umin.v2i1(<2 x i1>)
declare i1 @llvm.vector.reduce.umin.v3i1(<3 x i1>)
declare i1 @llvm.vector.reduce.umin.v4i1(<4 x i1>)
declare i1 @llvm.vector.reduce.umin.v8i1(<8 x i1>)
declare i1 @llvm.vector.reduce.umin.v16i1(<16 x i1>)
declare i1 @llvm.vector.reduce.umin.v32i1(<32 x i1>)
declare i8 @llvm.vector.reduce.umin.v2i8(<2 x i8>)
declare i8 @llvm.vector.reduce.umin.v3i8(<3 x i8>)
declare i8 @llvm.vector.reduce.umin.v4i8(<4 x i8>)
declare i8 @llvm.vector.reduce.umin.v8i8(<8 x i8>)
declare i8 @llvm.vector.reduce.umin.v16i8(<16 x i8>)
declare i8 @llvm.vector.reduce.umin.v32i8(<32 x i8>)
declare i8 @llvm.vector.reduce.umin.v64i8(<64 x i8>)
declare i16 @llvm.vector.reduce.umin.v2i16(<2 x i16>)
declare i16 @llvm.vector.reduce.umin.v4i16(<4 x i16>)
declare i16 @llvm.vector.reduce.umin.v8i16(<8 x i16>)
declare i16 @llvm.vector.reduce.umin.v16i16(<16 x i16>)
declare i32 @llvm.vector.reduce.umin.v2i32(<2 x i32>)
declare i32 @llvm.vector.reduce.umin.v4i32(<4 x i32>)
declare i32 @llvm.vector.reduce.umin.v8i32(<8 x i32>)
declare i64 @llvm.vector.reduce.umin.v2i64(<2 x i64>)
declare i64 @llvm.vector.reduce.umin.v4i64(<4 x i64>)
