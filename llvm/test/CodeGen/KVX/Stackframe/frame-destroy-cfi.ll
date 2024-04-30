; RUN: llc -O0 -o - %s | FileCheck %s
; CHECK: .cfi_restore 14
; CHECK: .cfi_restore 67
; CHECK: .cfi_def_cfa_offset 0
; CHECK-NEXT: ret

source_filename = "/nfs/home/dsampaio/csw/gdb/gdb/testsuite/gdb.base/watch-cond.c"
target datalayout = "e-S256-p:64:64-i1:8-i8:8-i16:16-i32:32-i64:64-v64:64-v128:128-v256:256-v512:256-v1024:256-f16:16-f32:32-f64:64-a:0:64-m:e-n32:64"
target triple = "kvx-kalray-cos"

@global = dso_local global i32 0, align 4, !dbg !0
@global2 = dso_local global i32 0, align 4, !dbg !5

declare void @llvm.dbg.declare(metadata, metadata, metadata) #1

define dso_local void @func2(ptr %foo) #0 {
entry:
  ret void
}


attributes #0 = { noinline nounwind optnone "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #1 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }

!llvm.dbg.cu = !{!2}
!llvm.module.flags = !{!9, !10, !11, !12}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(name: "global", scope: !2, file: !7, line: 18, type: !8, isLocal: false, isDefinition: true)
!2 = distinct !DICompileUnit(language: DW_LANG_C11, file: !3, producer: "Kalray clang version 19.0.0acb-5.2.0", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, globals: !4, splitDebugInlining: false, nameTableKind: None)
!3 = !DIFile(filename: "/nfs/home/dsampaio/csw/gdb/gdb/testsuite/gdb.base/watch-cond.c", directory: "/nfs/home/dsampaio/csw/build_llvm_Debug")
!4 = !{!0, !5}
!5 = !DIGlobalVariableExpression(var: !6, expr: !DIExpression())
!6 = distinct !DIGlobalVariable(name: "global2", scope: !2, file: !7, line: 19, type: !8, isLocal: false, isDefinition: true)
!7 = !DIFile(filename: "gdb/gdb/testsuite/gdb.base/watch-cond.c", directory: "/nfs/home/dsampaio/csw")
!8 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!9 = !{i32 7, !"Dwarf Version", i32 4}
!10 = !{i32 2, !"Debug Info Version", i32 3}
!11 = !{i32 1, !"wchar_size", i32 4}
!12 = !{i32 7, !"frame-pointer", i32 2}
