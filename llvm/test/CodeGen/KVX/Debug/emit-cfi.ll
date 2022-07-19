; RUN: llc < %s | FileCheck %s
; CHECK-LABEL: foo:
; CHECK:              .cfi_sections .debug_frame
; CHECK-NEXT:         .cfi_startproc
; CHECK-NEXT: # %bb.0:
; CHECK-NEXT:         addd $r12 = $r12, -512
; CHECK-NEXT:         ;;
; CHECK-NEXT:         .cfi_def_cfa_offset 512
; CHECK-NEXT:         .loc    1 3 1 prologue_end              # /tmp/test.c:3:1
; CHECK-NEXT:         addd $r12 = $r12, 512
; CHECK-NEXT:         ;;
; CHECK-NEXT:         ret
; CHECK-NEXT:         ;;
; CHECK-NEXT: .Ltmp0:
; CHECK-NEXT: .Lfunc_end0:
; CHECK-NEXT:         .size   foo, .Lfunc_end0-foo
; CHECK-NEXT:         .cfi_endproc

target triple = "kvx-unknown-cos"

define dso_local void @foo() #0 !dbg !7 {
  %1 = alloca [128 x i32], align 4
  call void @llvm.dbg.declare(metadata [128 x i32]* %1, metadata !11, metadata !DIExpression()), !dbg !16
  ret void, !dbg !17
}

declare void @llvm.dbg.declare(metadata, metadata, metadata) #1

attributes #0 = { noinline nounwind optnone "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nofree nosync nounwind readnone speculatable willreturn }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!3, !4, !5}
!llvm.ident = !{!6}

!0 = distinct !DICompileUnit(language: DW_LANG_C99, file: !1, producer: "Kalray clang version 12.0.1", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !2, splitDebugInlining: false, nameTableKind: None)
!1 = !DIFile(filename: "test.c", directory: "tmp")
!2 = !{}
!3 = !{i32 7, !"Dwarf Version", i32 4}
!4 = !{i32 2, !"Debug Info Version", i32 3}
!5 = !{i32 1, !"wchar_size", i32 4}
!6 = !{!"Kalray clang version 12.0.1"}
!7 = distinct !DISubprogram(name: "foo", scope: !8, file: !8, line: 1, type: !9, scopeLine: 1, spFlags: DISPFlagDefinition, unit: !0, retainedNodes: !2)
!8 = !DIFile(filename: "/tmp/test.c", directory: "")
!9 = !DISubroutineType(types: !10)
!10 = !{null}
!11 = !DILocalVariable(name: "d", scope: !7, file: !8, line: 2, type: !12)
!12 = !DICompositeType(tag: DW_TAG_array_type, baseType: !13, size: 4096, elements: !14)
!13 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!14 = !{!15}
!15 = !DISubrange(count: 128)
!16 = !DILocation(line: 2, column: 7, scope: !7)
!17 = !DILocation(line: 3, column: 1, scope: !7)
