; Not failing should be enough
; RUN: llc -O3 -o - %s
target datalayout = "e-S256-p:64:64-i1:8-i8:8-i16:16-i32:32-i64:64-v64:64-v128:128-v256:256-v512:256-v1024:256-f16:16-f32:32-f64:64-a:0:64-m:e-n32:64"
target triple = "kvx-kalray-cos"

; Function Attrs: alwaysinline mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: readwrite)
define void @_pocl_kernel_test(ptr nocapture noundef readonly align 8 %0, ptr nocapture noundef readonly align 8 %1, ptr nocapture noundef writeonly align 8 %2, ptr nocapture readonly %3, i64 %4, i64 %5, i64 %6) local_unnamed_addr #0 !dbg !32 !kernel_arg_addr_space !44 !kernel_arg_access_qual !45 !kernel_arg_type !46 !kernel_arg_base_type !47 !kernel_arg_type_qual !48 !kernel_arg_name !49 !pocl_generated !50 {
  %8 = getelementptr inbounds i8, ptr %3, i64 48
  %9 = load i64, ptr %8, align 8
  %10 = getelementptr i8, ptr %3, i64 56
  %11 = load i64, ptr %10, align 8
  %12 = getelementptr i8, ptr %3, i64 64
  %13 = load i64, ptr %12, align 8
  %14 = getelementptr inbounds i8, ptr %3, i64 24
  %15 = load i64, ptr %14, align 8
  tail call void @llvm.dbg.value(metadata ptr %0, metadata !51, metadata !DIExpression()), !dbg !58
  tail call void @llvm.dbg.value(metadata ptr %1, metadata !54, metadata !DIExpression()), !dbg !58
  tail call void @llvm.dbg.value(metadata ptr %2, metadata !55, metadata !DIExpression()), !dbg !58
  %mul.i.i = mul i64 %9, %4
  %add.i.i = add i64 %15, %mul.i.i
  %umax = tail call i64 @llvm.umax.i64(i64 %9, i64 1)
  %umax10 = tail call i64 @llvm.umax.i64(i64 %11, i64 1)
  %umax12 = tail call i64 @llvm.umax.i64(i64 %13, i64 1)
  br label %pregion_for_entry.pregion_for_init4.i

pregion_for_entry.pregion_for_init4.i:            ; preds = %pregion_for_end1.i, %7
  %_local_id_z.0 = phi i64 [ 0, %7 ], [ %16, %pregion_for_end1.i ]
  br label %pregion_for_entry.pregion_for_init.i

pregion_for_entry.pregion_for_init.i:             ; preds = %pregion_for_end.i, %pregion_for_entry.pregion_for_init4.i
  %_local_id_y.0 = phi i64 [ 0, %pregion_for_entry.pregion_for_init4.i ], [ %17, %pregion_for_end.i ]
  br label %pregion_for_entry.entry.i

pregion_for_end1.i:                               ; preds = %pregion_for_end.i
  %16 = add nuw i64 %_local_id_z.0, 1
  %exitcond13.not = icmp eq i64 %16, %umax12
  br i1 %exitcond13.not, label %test.exit, label %pregion_for_entry.pregion_for_init4.i, !llvm.loop !60

pregion_for_end.i:                                ; preds = %pregion_for_entry.entry.i
  %17 = add nuw i64 %_local_id_y.0, 1
  %exitcond11.not = icmp eq i64 %17, %umax10
  br i1 %exitcond11.not, label %pregion_for_end1.i, label %pregion_for_entry.pregion_for_init.i, !llvm.loop !63

pregion_for_entry.entry.i:                        ; preds = %pregion_for_entry.entry.i, %pregion_for_entry.pregion_for_init.i
  %_local_id_x.0 = phi i64 [ 0, %pregion_for_entry.pregion_for_init.i ], [ %21, %pregion_for_entry.entry.i ]
  %add1.i.i = add i64 %add.i.i, %_local_id_x.0, !dbg !66
  tail call void @llvm.dbg.value(metadata i64 %add1.i.i, metadata !56, metadata !DIExpression(DW_OP_LLVM_convert, 64, DW_ATE_unsigned, DW_OP_LLVM_convert, 32, DW_ATE_unsigned, DW_OP_stack_value)), !dbg !58
  %sext.i = shl i64 %add1.i.i, 32, !dbg !67
  %idxprom.i = ashr exact i64 %sext.i, 32, !dbg !67
  %arrayidx.i = getelementptr inbounds <2 x i32>, ptr %0, i64 %idxprom.i, !dbg !67
  %18 = load <2 x i32>, ptr %arrayidx.i, align 8, !dbg !67, !llvm.access.group !68
  %arrayidx2.i = getelementptr inbounds <2 x i32>, ptr %1, i64 %idxprom.i, !dbg !70
  %19 = load <2 x i32>, ptr %arrayidx2.i, align 8, !dbg !70, !llvm.access.group !68
  %20 = icmp ult <2 x i32> %18, %19, !dbg !71
  %.splat.i = shufflevector <2 x i1> %20, <2 x i1> poison, <2 x i32> zeroinitializer, !dbg !72
  %..i = select <2 x i1> %.splat.i, <2 x i32> %18, <2 x i32> %19, !dbg !72
  %arrayidx9.i = getelementptr inbounds <2 x i32>, ptr %2, i64 %idxprom.i, !dbg !73
  store <2 x i32> %..i, ptr %arrayidx9.i, align 8, !dbg !74, !tbaa !75, !llvm.access.group !68
  %21 = add nuw i64 %_local_id_x.0, 1
  %exitcond.not = icmp eq i64 %21, %umax
  br i1 %exitcond.not, label %pregion_for_end.i, label %pregion_for_entry.entry.i, !llvm.loop !78

test.exit:                                        ; preds = %pregion_for_end1.i
  ret void
}

; Function Attrs: nofree norecurse nosync nounwind memory(readwrite, inaccessiblemem: none)
define void @_pocl_kernel_test_workgroup(ptr nocapture readonly %0, ptr nocapture readonly %1, i64 %2, i64 %3, i64 %4) local_unnamed_addr #1 !dbg !80 {
  %6 = load ptr, ptr %0, align 8
  %7 = load ptr, ptr %6, align 8
  %8 = getelementptr i8, ptr %0, i64 8
  %9 = load ptr, ptr %8, align 8
  %10 = load ptr, ptr %9, align 8
  %11 = getelementptr i8, ptr %0, i64 16
  %12 = load ptr, ptr %11, align 8
  %13 = load ptr, ptr %12, align 8
  %14 = getelementptr inbounds i8, ptr %1, i64 48
  %15 = load i64, ptr %14, align 8
  %16 = getelementptr i8, ptr %1, i64 56
  %17 = load i64, ptr %16, align 8
  %18 = getelementptr i8, ptr %1, i64 64
  %19 = load i64, ptr %18, align 8
  %20 = getelementptr inbounds i8, ptr %1, i64 24
  %21 = load i64, ptr %20, align 8
  tail call void @llvm.dbg.value(metadata ptr %7, metadata !51, metadata !DIExpression()), !dbg !81
  tail call void @llvm.dbg.value(metadata ptr %10, metadata !54, metadata !DIExpression()), !dbg !81
  tail call void @llvm.dbg.value(metadata ptr %13, metadata !55, metadata !DIExpression()), !dbg !81
  %mul.i.i.i = mul i64 %15, %2
  %add.i.i.i = add i64 %21, %mul.i.i.i
  %umax = tail call i64 @llvm.umax.i64(i64 %15, i64 1)
  %umax10 = tail call i64 @llvm.umax.i64(i64 %17, i64 1)
  %umax12 = tail call i64 @llvm.umax.i64(i64 %19, i64 1)
  br label %pregion_for_entry.pregion_for_init4.i.i

pregion_for_entry.pregion_for_init4.i.i:          ; preds = %pregion_for_end1.i.i, %5
  %_local_id_z.i.0 = phi i64 [ 0, %5 ], [ %22, %pregion_for_end1.i.i ]
  br label %pregion_for_entry.pregion_for_init.i.i

pregion_for_entry.pregion_for_init.i.i:           ; preds = %pregion_for_end.i.i, %pregion_for_entry.pregion_for_init4.i.i
  %_local_id_y.i.0 = phi i64 [ 0, %pregion_for_entry.pregion_for_init4.i.i ], [ %23, %pregion_for_end.i.i ]
  br label %pregion_for_entry.entry.i.i

pregion_for_end1.i.i:                             ; preds = %pregion_for_end.i.i
  %22 = add nuw i64 %_local_id_z.i.0, 1
  %exitcond13.not = icmp eq i64 %22, %umax12
  br i1 %exitcond13.not, label %_pocl_kernel_test.exit, label %pregion_for_entry.pregion_for_init4.i.i, !llvm.loop !84

pregion_for_end.i.i:                              ; preds = %pregion_for_entry.entry.i.i
  %23 = add nuw i64 %_local_id_y.i.0, 1
  %exitcond11.not = icmp eq i64 %23, %umax10
  br i1 %exitcond11.not, label %pregion_for_end1.i.i, label %pregion_for_entry.pregion_for_init.i.i, !llvm.loop !85

pregion_for_entry.entry.i.i:                      ; preds = %pregion_for_entry.entry.i.i, %pregion_for_entry.pregion_for_init.i.i
  %_local_id_x.i.0 = phi i64 [ 0, %pregion_for_entry.pregion_for_init.i.i ], [ %27, %pregion_for_entry.entry.i.i ]
  %add1.i.i.i = add i64 %add.i.i.i, %_local_id_x.i.0, !dbg !86
  tail call void @llvm.dbg.value(metadata i64 %add1.i.i.i, metadata !56, metadata !DIExpression(DW_OP_LLVM_convert, 64, DW_ATE_unsigned, DW_OP_LLVM_convert, 32, DW_ATE_unsigned, DW_OP_stack_value)), !dbg !81
  %sext.i.i = shl i64 %add1.i.i.i, 32, !dbg !87
  %idxprom.i.i = ashr exact i64 %sext.i.i, 32, !dbg !87
  %arrayidx.i.i = getelementptr inbounds <2 x i32>, ptr %7, i64 %idxprom.i.i, !dbg !87
  %24 = load <2 x i32>, ptr %arrayidx.i.i, align 8, !dbg !87, !llvm.access.group !68
  %arrayidx2.i.i = getelementptr inbounds <2 x i32>, ptr %10, i64 %idxprom.i.i, !dbg !88
  %25 = load <2 x i32>, ptr %arrayidx2.i.i, align 8, !dbg !88, !llvm.access.group !68
  %26 = icmp ult <2 x i32> %24, %25, !dbg !89
  %.splat.i.i = shufflevector <2 x i1> %26, <2 x i1> poison, <2 x i32> zeroinitializer, !dbg !90
  %..i.i = select <2 x i1> %.splat.i.i, <2 x i32> %24, <2 x i32> %25, !dbg !90
  %arrayidx9.i.i = getelementptr inbounds <2 x i32>, ptr %13, i64 %idxprom.i.i, !dbg !91
  store <2 x i32> %..i.i, ptr %arrayidx9.i.i, align 8, !dbg !92, !tbaa !75, !llvm.access.group !68
  %27 = add nuw i64 %_local_id_x.i.0, 1
  %exitcond.not = icmp eq i64 %27, %umax
  br i1 %exitcond.not, label %pregion_for_end.i.i, label %pregion_for_entry.entry.i.i, !llvm.loop !93

_pocl_kernel_test.exit:                           ; preds = %pregion_for_end1.i.i
  ret void
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i64 @llvm.umax.i64(i64, i64) #2

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare void @llvm.dbg.value(metadata, metadata, metadata) #3

attributes #0 = { alwaysinline mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: readwrite) "no-builtins" "no-jump-tables"="true" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "stackrealign" "uniform-work-group-size"="true" }
attributes #1 = { nofree norecurse nosync nounwind memory(readwrite, inaccessiblemem: none) "no-jump-tables"="true" }
attributes #2 = { mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #3 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!2, !3, !4, !5, !6}
!opencl.ocl.version = !{!7}
!llvm.ident = !{!8}
!pocl_meta = !{!9, !10, !11, !12, !13, !14, !15, !16, !17, !18, !19, !20, !21, !22, !23, !24, !25, !26, !27, !28, !29, !30, !31}

!0 = distinct !DICompileUnit(language: DW_LANG_OpenCL, file: !1, producer: "Kalray clang version 19.0.0acb-5.2.0", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, splitDebugInlining: false, nameTableKind: None)
!1 = !DIFile(filename: "/nfs/home/dsampaio/csw/.cache/pocl/kcache/<stdin>", directory: "/nfs/home/dsampaio/csw")
!2 = !{i32 7, !"Dwarf Version", i32 4}
!3 = !{i32 2, !"Debug Info Version", i32 3}
!4 = !{i32 1, !"wchar_size", i32 4}
!5 = !{i32 7, !"debug-info-assignment-tracking", i1 true}
!6 = !{i32 8, !"PIC Level", i32 2}
!7 = !{i32 1, i32 2}
!8 = !{!"Kalray clang version 19.0.0acb-5.2.0"}
!9 = !{!"device_address_bits", i64 64}
!10 = !{!"device_arg_buffer_launcher", i8 0}
!11 = !{!"device_grid_launcher", i8 0}
!12 = !{!"device_is_spmd", i8 0}
!13 = !{!"KernelName", !"test"}
!14 = !{!"WGMaxGridDimWidth", i64 0}
!15 = !{!"WGLocalSizeX", i64 0}
!16 = !{!"WGLocalSizeY", i64 0}
!17 = !{!"WGLocalSizeZ", i64 0}
!18 = !{!"WGDynamicLocalSize", i8 1}
!19 = !{!"WGAssumeZeroGlobalOffset", i8 0}
!20 = !{!"device_global_as_id", i64 1}
!21 = !{!"device_local_as_id", i64 3}
!22 = !{!"device_constant_as_id", i64 2}
!23 = !{!"device_args_as_id", i64 0}
!24 = !{!"device_context_as_id", i64 0}
!25 = !{!"device_side_printf", i8 1}
!26 = !{!"device_alloca_locals", i8 0}
!27 = !{!"device_autolocals_to_args", i64 1}
!28 = !{!"device_max_witem_dim", i64 3}
!29 = !{!"device_max_witem_sizes_0", i64 16}
!30 = !{!"device_max_witem_sizes_1", i64 16}
!31 = !{!"device_max_witem_sizes_2", i64 16}
!32 = distinct !DISubprogram(name: "_pocl_kernel_test", scope: !33, file: !33, line: 1, type: !34, scopeLine: 2, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0)
!33 = !DIFile(filename: ".cache/pocl/kcache/tempfile_VExysE.cl", directory: "/nfs/home/dsampaio/csw")
!34 = !DISubroutineType(cc: DW_CC_LLVM_OpenCLKernel, types: !35)
!35 = !{null, !36, !36, !36}
!36 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !37, size: 64)
!37 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint2", file: !38, line: 188, baseType: !39)
!38 = !DIFile(filename: "devimage/toolchain_default/toolroot/opt/kalray/accesscore/share/pocl/include/opencl-c-base.h", directory: "/nfs/home/dsampaio/csw")
!39 = !DICompositeType(tag: DW_TAG_array_type, baseType: !40, size: 64, flags: DIFlagVector, elements: !42)
!40 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint", file: !38, line: 125, baseType: !41)
!41 = !DIBasicType(name: "unsigned int", size: 32, encoding: DW_ATE_unsigned)
!42 = !{!43}
!43 = !DISubrange(count: 2)
!44 = !{i32 1, i32 1, i32 1}
!45 = !{!"none", !"none", !"none"}
!46 = !{!"uint2*", !"uint2*", !"uint2*"}
!47 = !{!"uint __attribute__((ext_vector_type(2)))*", !"uint __attribute__((ext_vector_type(2)))*", !"uint __attribute__((ext_vector_type(2)))*"}
!48 = !{!"", !"", !""}
!49 = !{!"srcA", !"srcB", !"dst"}
!50 = !{i32 1}
!51 = !DILocalVariable(name: "srcA", arg: 1, scope: !52, file: !33, line: 1, type: !36)
!52 = distinct !DISubprogram(name: "test", scope: !33, file: !33, line: 1, type: !34, scopeLine: 2, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !53)
!53 = !{!51, !54, !55, !56}
!54 = !DILocalVariable(name: "srcB", arg: 2, scope: !52, file: !33, line: 1, type: !36)
!55 = !DILocalVariable(name: "dst", arg: 3, scope: !52, file: !33, line: 1, type: !36)
!56 = !DILocalVariable(name: "tid", scope: !52, file: !33, line: 3, type: !57)
!57 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!58 = !DILocation(line: 0, scope: !52, inlinedAt: !59)
!59 = distinct !DILocation(line: 1, scope: !32)
!60 = distinct !{!60, !61}
!61 = !{!"llvm.loop.parallel_accesses", !62}
!62 = distinct !{}
!63 = distinct !{!63, !64}
!64 = !{!"llvm.loop.parallel_accesses", !65}
!65 = distinct !{}
!66 = !DILocation(line: 3, column: 16, scope: !52, inlinedAt: !59)
!67 = !DILocation(line: 5, column: 17, scope: !52, inlinedAt: !59)
!68 = !{!69, !65, !62}
!69 = distinct !{}
!70 = !DILocation(line: 5, column: 32, scope: !52, inlinedAt: !59)
!71 = !DILocation(line: 5, column: 30, scope: !52, inlinedAt: !59)
!72 = !DILocation(line: 5, column: 16, scope: !52, inlinedAt: !59)
!73 = !DILocation(line: 5, column: 5, scope: !52, inlinedAt: !59)
!74 = !DILocation(line: 5, column: 14, scope: !52, inlinedAt: !59)
!75 = !{!76, !76, i64 0}
!76 = !{!"omnipotent char", !77, i64 0}
!77 = !{!"Simple C/C++ TBAA"}
!78 = distinct !{!78, !79}
!79 = !{!"llvm.loop.parallel_accesses", !69}
!80 = distinct !DISubprogram(name: "_pocl_kernel_test_workgroup", scope: !33, file: !33, line: 1, type: !34, scopeLine: 2, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0)
!81 = !DILocation(line: 0, scope: !52, inlinedAt: !82)
!82 = distinct !DILocation(line: 1, scope: !32, inlinedAt: !83)
!83 = distinct !DILocation(line: 1, scope: !80)
!84 = distinct !{!84, !61}
!85 = distinct !{!85, !64}
!86 = !DILocation(line: 3, column: 16, scope: !52, inlinedAt: !82)
!87 = !DILocation(line: 5, column: 17, scope: !52, inlinedAt: !82)
!88 = !DILocation(line: 5, column: 32, scope: !52, inlinedAt: !82)
!89 = !DILocation(line: 5, column: 30, scope: !52, inlinedAt: !82)
!90 = !DILocation(line: 5, column: 16, scope: !52, inlinedAt: !82)
!91 = !DILocation(line: 5, column: 5, scope: !52, inlinedAt: !82)
!92 = !DILocation(line: 5, column: 14, scope: !52, inlinedAt: !82)
!93 = distinct !{!93, !79}
