; RUN: llc -disable-kvx-hwloops=false -O2 -o - %s | FileCheck %s
; RUN: clang -O2 -c -o /dev/null %s -mllvm -disable-kvx-hwloops=false

target triple = "kvx-kalray-cos"

; CHECK: loopdo
define void @matrix_add_const(i32 %N, i32* nocapture %A, i32 %val) {
entry:
  %cmp6 = icmp sgt i32 %N, 0
  br i1 %cmp6, label %for.body.preheader, label %for.end

for.body.preheader:
  %0 = zext i32 %N to i64
  %wide.trip.count = zext i32 %N to i64
  br label %for.body

for.body:
  %indvars.iv = phi i64 [ 0, %for.body.preheader ], [ %indvars.iv.next, %for.body ]
  call void @llvm.dbg.value(metadata i64 %indvars.iv, metadata !17, metadata !DIExpression()), !dbg !18
  %1 = add nuw nsw i64 %indvars.iv, %0
  %arrayidx = getelementptr inbounds i32, i32* %A, i64 %1
  %2 = load i32, i32* %arrayidx, align 4
  %add1 = add nsw i32 %2, %val
  store i32 %add1, i32* %arrayidx, align 4
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %exitcond = icmp eq i64 %indvars.iv.next, %wide.trip.count
  br i1 %exitcond, label %for.end, label %for.body

for.end:
  ret void
}

declare void @llvm.dbg.value(metadata, metadata, metadata)

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!3, !4, !5}

!0 = distinct !DICompileUnit(language: DW_LANG_C99, file: !1, producer: "Kalray clang version 10.0.1 (git:software/tools/llvm-project 0f66d49cb01c4b28a3b01dfef928f1e3f9d8f701)", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, enums: !2, splitDebugInlining: false, nameTableKind: None)
!1 = !DIFile(filename: "/tmp/test.c", directory: "/work1/dsampaio/csw/llvm-project")
!2 = !{}
!3 = !{i32 7, !"Dwarf Version", i32 2}
!4 = !{i32 2, !"Debug Info Version", i32 3}
!5 = !{i32 1, !"wchar_size", i32 4}
!6 = !{!"Kalray clang version 10.0.1 (git:software/tools/llvm-project 0f66d49cb01c4b28a3b01dfef928f1e3f9d8f701)"}
!7 = distinct !DISubprogram(name: "matrix_add_const", scope: !8, file: !8, line: 2, type: !9, scopeLine: 3, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !13)
!8 = !DIFile(filename: "/tmp/test.c", directory: "")
!9 = !DISubroutineType(types: !10)
!10 = !{null, !11, !12, !11}
!11 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!12 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !11, size: 64)
!13 = !{!14, !15, !16, !17}
!14 = !DILocalVariable(name: "N", arg: 1, scope: !7, file: !8, line: 2, type: !11)
!15 = !DILocalVariable(name: "A", arg: 2, scope: !7, file: !8, line: 2, type: !12)
!16 = !DILocalVariable(name: "val", arg: 3, scope: !7, file: !8, line: 2, type: !11)
!17 = !DILocalVariable(name: "j", scope: !7, file: !8, line: 4, type: !11)
!18 = !DILocation(line: 0, scope: !7)
