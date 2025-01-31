// NOTE: Assertions have been autogenerated by utils/update_cc_test_checks.py
// RUN: %clang_cc1 -triple kvx-kalray-cos  -S -emit-llvm %s -o - -O1 | FileCheck %s
typedef long __attribute__((__vector_size__(32))) v4i64_t;
// CHECK-LABEL: @test_tca_builtins(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = load volatile <256 x i1>, ptr [[V:%.*]], align 32, !tbaa [[TBAA2:![0-9]+]]
// CHECK-NEXT:    [[TMP1:%.*]] = tail call <256 x i1> @llvm.kvx.xmovetq(<256 x i1> [[TMP0]], i64 0, i64 1, i32 1)
// CHECK-NEXT:    store volatile <256 x i1> [[TMP1]], ptr [[V]], align 32, !tbaa [[TBAA2]]
// CHECK-NEXT:    [[TMP2:%.*]] = load volatile <256 x i1>, ptr [[V]], align 32, !tbaa [[TBAA2]]
// CHECK-NEXT:    [[TMP3:%.*]] = tail call <256 x i1> @llvm.kvx.xmovetq(<256 x i1> [[TMP2]], i64 3, i64 2, i32 0)
// CHECK-NEXT:    store volatile <256 x i1> [[TMP3]], ptr [[V]], align 32, !tbaa [[TBAA2]]
// CHECK-NEXT:    [[TMP4:%.*]] = tail call <256 x i1> @llvm.kvx.xmoveto(i64 1, i64 2, i64 3, i64 4)
// CHECK-NEXT:    [[ARRAYIDX4:%.*]] = getelementptr inbounds <256 x i1>, ptr [[V]], i64 1
// CHECK-NEXT:    store volatile <256 x i1> [[TMP4]], ptr [[ARRAYIDX4]], align 32, !tbaa [[TBAA2]]
// CHECK-NEXT:    [[TMP5:%.*]] = tail call <256 x i1> @llvm.kvx.xmoveto256(<4 x i64> <i64 0, i64 1, i64 2, i64 3>)
// CHECK-NEXT:    [[TMP6:%.*]] = load volatile <256 x i1>, ptr [[V]], align 32, !tbaa [[TBAA2]]
// CHECK-NEXT:    [[TMP7:%.*]] = tail call <512 x i1> @llvm.kvx.cat.v512i1(<256 x i1> [[TMP5]], <256 x i1> [[TMP6]])
// CHECK-NEXT:    [[TMP8:%.*]] = tail call <256 x i1> @llvm.kvx.xaligno.v512i1(<512 x i1> [[TMP7]], i64 16)
// CHECK-NEXT:    [[TMP9:%.*]] = tail call <512 x i1> @llvm.kvx.cat.v512i1(<256 x i1> [[TMP5]], <256 x i1> [[TMP8]])
// CHECK-NEXT:    [[TMP10:%.*]] = tail call <4 x i64> @llvm.kvx.xaccesso.v512i1(<512 x i1> [[TMP9]], i64 1)
// CHECK-NEXT:    [[TMP11:%.*]] = load volatile <1024 x i1>, ptr [[M:%.*]], align 32, !tbaa [[TBAA6:![0-9]+]]
// CHECK-NEXT:    [[TMP12:%.*]] = tail call <256 x i1> @llvm.kvx.xconvdhv0(<256 x i1> [[TMP5]], <1024 x i1> [[TMP11]], i32 0, i32 0)
// CHECK-NEXT:    [[TMP13:%.*]] = tail call <256 x i1> @llvm.kvx.xconvdhv1(<256 x i1> [[TMP12]], <1024 x i1> [[TMP11]], i32 1, i32 1)
// CHECK-NEXT:    [[TMP14:%.*]] = load volatile <512 x i1>, ptr [[W:%.*]], align 32, !tbaa [[TBAA8:![0-9]+]]
// CHECK-NEXT:    [[TMP15:%.*]] = tail call <256 x i1> @llvm.kvx.xconvwbv(<1024 x i1> [[TMP11]], i32 1, i32 0)
// CHECK-NEXT:    [[TMP16:%.*]] = tail call <256 x i1> @llvm.kvx.xfmma242hw0(<256 x i1> [[TMP13]], <512 x i1> [[TMP14]], <256 x i1> [[TMP13]], <256 x i1> [[TMP15]])
// CHECK-NEXT:    [[TMP17:%.*]] = tail call <256 x i1> @llvm.kvx.xfmma242hw1(<256 x i1> [[TMP16]], <512 x i1> [[TMP14]], <256 x i1> [[TMP13]], <256 x i1> [[TMP16]])
// CHECK-NEXT:    [[TMP18:%.*]] = tail call <256 x i1> @llvm.kvx.xfmma242hw2(<256 x i1> [[TMP17]], <512 x i1> [[TMP14]], <256 x i1> [[TMP17]], <256 x i1> [[TMP16]])
// CHECK-NEXT:    [[TMP19:%.*]] = tail call <256 x i1> @llvm.kvx.xfmma242hw3(<256 x i1> [[TMP18]], <512 x i1> [[TMP14]], <256 x i1> [[TMP17]], <256 x i1> [[TMP18]])
// CHECK-NEXT:    [[TMP20:%.*]] = tail call <512 x i1> @llvm.kvx.xfmma444hw(<256 x i1> [[TMP18]], <256 x i1> [[TMP19]], <512 x i1> [[TMP14]])
// CHECK-NEXT:    [[TMP21:%.*]] = tail call <1024 x i1> @llvm.kvx.xmma444hbd0(<256 x i1> [[TMP19]], <256 x i1> [[TMP19]], <1024 x i1> [[TMP11]], i32 0)
// CHECK-NEXT:    [[TMP22:%.*]] = tail call <1024 x i1> @llvm.kvx.xmma444hbd1(<256 x i1> [[TMP19]], <256 x i1> [[TMP19]], <1024 x i1> [[TMP21]], i32 0)
// CHECK-NEXT:    [[TMP23:%.*]] = tail call <1024 x i1> @llvm.kvx.xmma484hbd(<512 x i1> [[TMP20]], <256 x i1> [[TMP19]], <1024 x i1> [[TMP22]], i32 0)
// CHECK-NEXT:    [[TMP24:%.*]] = tail call <1024 x i1> @llvm.kvx.xmma444hd(<256 x i1> [[TMP19]], <256 x i1> [[TMP19]], <1024 x i1> [[TMP23]], i32 0)
// CHECK-NEXT:    [[TMP25:%.*]] = tail call <1024 x i1> @llvm.kvx.xmma444hbd0(<256 x i1> [[TMP19]], <256 x i1> [[TMP19]], <1024 x i1> [[TMP24]], i32 1)
// CHECK-NEXT:    [[TMP26:%.*]] = tail call <1024 x i1> @llvm.kvx.xmma444hbd1(<256 x i1> [[TMP19]], <256 x i1> [[TMP19]], <1024 x i1> [[TMP25]], i32 1)
// CHECK-NEXT:    [[TMP27:%.*]] = tail call <1024 x i1> @llvm.kvx.xmma484hbd(<512 x i1> [[TMP20]], <256 x i1> [[TMP19]], <1024 x i1> [[TMP26]], i32 1)
// CHECK-NEXT:    [[TMP28:%.*]] = tail call <1024 x i1> @llvm.kvx.xmma444hd(<256 x i1> [[TMP19]], <256 x i1> [[TMP19]], <1024 x i1> [[TMP27]], i32 1)
// CHECK-NEXT:    [[TMP29:%.*]] = tail call <1024 x i1> @llvm.kvx.xmma444hbd0(<256 x i1> [[TMP19]], <256 x i1> [[TMP19]], <1024 x i1> [[TMP28]], i32 2)
// CHECK-NEXT:    [[TMP30:%.*]] = tail call <1024 x i1> @llvm.kvx.xmma444hbd1(<256 x i1> [[TMP19]], <256 x i1> [[TMP19]], <1024 x i1> [[TMP29]], i32 2)
// CHECK-NEXT:    [[TMP31:%.*]] = tail call <1024 x i1> @llvm.kvx.xmma484hbd(<512 x i1> [[TMP20]], <256 x i1> [[TMP19]], <1024 x i1> [[TMP30]], i32 2)
// CHECK-NEXT:    [[TMP32:%.*]] = tail call <1024 x i1> @llvm.kvx.xmma444hd(<256 x i1> [[TMP19]], <256 x i1> [[TMP19]], <1024 x i1> [[TMP31]], i32 2)
// CHECK-NEXT:    [[TMP33:%.*]] = tail call <1024 x i1> @llvm.kvx.xmma444hbd0(<256 x i1> [[TMP19]], <256 x i1> [[TMP19]], <1024 x i1> [[TMP32]], i32 3)
// CHECK-NEXT:    [[TMP34:%.*]] = tail call <1024 x i1> @llvm.kvx.xmma444hbd1(<256 x i1> [[TMP19]], <256 x i1> [[TMP19]], <1024 x i1> [[TMP33]], i32 3)
// CHECK-NEXT:    [[TMP35:%.*]] = tail call <1024 x i1> @llvm.kvx.xmma484hbd(<512 x i1> [[TMP20]], <256 x i1> [[TMP19]], <1024 x i1> [[TMP34]], i32 3)
// CHECK-NEXT:    [[TMP36:%.*]] = tail call <1024 x i1> @llvm.kvx.xmma444hd(<256 x i1> [[TMP19]], <256 x i1> [[TMP19]], <1024 x i1> [[TMP35]], i32 3)
// CHECK-NEXT:    [[TMP37:%.*]] = tail call <512 x i1> @llvm.kvx.xmma484bw(<256 x i1> [[TMP19]], <256 x i1> [[TMP19]], <512 x i1> [[TMP20]], i32 0)
// CHECK-NEXT:    [[TMP38:%.*]] = tail call <512 x i1> @llvm.kvx.xmma484bw(<256 x i1> [[TMP19]], <256 x i1> [[TMP19]], <512 x i1> [[TMP37]], i32 1)
// CHECK-NEXT:    [[TMP39:%.*]] = tail call <512 x i1> @llvm.kvx.xmma484bw(<256 x i1> [[TMP19]], <256 x i1> [[TMP19]], <512 x i1> [[TMP38]], i32 2)
// CHECK-NEXT:    [[TMP40:%.*]] = tail call <512 x i1> @llvm.kvx.xmma484bw(<256 x i1> [[TMP19]], <256 x i1> [[TMP19]], <512 x i1> [[TMP39]], i32 3)
// CHECK-NEXT:    [[TMP41:%.*]] = tail call <1024 x i1> @llvm.kvx.xmt44d(<1024 x i1> [[TMP36]])
// CHECK-NEXT:    [[TMP42:%.*]] = tail call <256 x i1> @llvm.kvx.xfscalewv(<256 x i1> [[TMP18]], i32 7, i32 0, i32 0)
// CHECK-NEXT:    [[TMP43:%.*]] = tail call <256 x i1> @llvm.kvx.xfnarrow44wh(<512 x i1> [[TMP40]], i32 0, i32 1)
// CHECK-NEXT:    [[TMP44:%.*]] = tail call <256 x i1> @llvm.kvx.xfscalewv(<256 x i1> [[TMP42]], i32 0, i32 0, i32 1)
// CHECK-NEXT:    [[TMP45:%.*]] = tail call { <4 x i64>, <256 x i1> } @llvm.kvx.xswapo256(<4 x i64> [[TMP10]], <256 x i1> [[TMP44]])
// CHECK-NEXT:    [[TMP46:%.*]] = extractvalue { <4 x i64>, <256 x i1> } [[TMP45]], 1
// CHECK-NEXT:    [[TMP47:%.*]] = extractvalue { <4 x i64>, <256 x i1> } [[TMP45]], 0
// CHECK-NEXT:    [[TMP48:%.*]] = tail call <256 x i1> @llvm.kvx.xfscalewv(<256 x i1> [[TMP46]], i32 7, i32 0, i32 1)
// CHECK-NEXT:    [[TMP49:%.*]] = tail call <256 x i1> @llvm.kvx.lv(ptr nonnull [[V]], i32 1)
// CHECK-NEXT:    [[ARRAYIDX9:%.*]] = getelementptr inbounds <256 x i1>, ptr [[V]], i64 4
// CHECK-NEXT:    [[TMP50:%.*]] = tail call <1024 x i1> @llvm.kvx.lvc(<1024 x i1> [[TMP41]], ptr nonnull [[ARRAYIDX9]], i32 1, i32 0)
// CHECK-NEXT:    [[ARRAYIDX10:%.*]] = getelementptr inbounds <256 x i1>, ptr [[V]], i64 5
// CHECK-NEXT:    [[TMP51:%.*]] = tail call <1024 x i1> @llvm.kvx.lvc.cond(<1024 x i1> [[TMP50]], ptr nonnull [[ARRAYIDX10]], i64 [[A:%.*]], i32 0, i32 0, i32 6)
// CHECK-NEXT:    tail call void @llvm.kvx.sv(ptr nonnull [[V]], <256 x i1> [[TMP49]])
// CHECK-NEXT:    tail call void @llvm.kvx.sv.cond(ptr nonnull [[ARRAYIDX4]], <256 x i1> [[TMP49]], i64 1, i32 7)
// CHECK-NEXT:    store volatile <512 x i1> [[TMP40]], ptr [[W]], align 32, !tbaa [[TBAA8]]
// CHECK-NEXT:    store volatile <1024 x i1> [[TMP51]], ptr [[M]], align 32, !tbaa [[TBAA6]]
// CHECK-NEXT:    ret <4 x i64> [[TMP47]]
//
v4i64_t test_tca_builtins(long a, long b, long c, long d, volatile __kvx_x256 *v, volatile __kvx_x512 *w, volatile __kvx_x1024 *m) {
  v4i64_t vt = {0, 1, 2, 3};
  __kvx_x256 lv, lv2, lv3;
  v[0] = __builtin_kvx_xmovetq(v[0], 0, 1, ".h1");
  v[0] = __builtin_kvx_xmovetq(v[0], 3, 2, ".h0");
  v[1] = __builtin_kvx_xmoveto(1, 2, 3, 4);
  lv = __builtin_kvx_xmoveto256(vt);
  vt = __builtin_kvx_xmovefo256(lv);
  __kvx_x512 buf = __builtin_kvx_xcat512(lv, v[0]);
  lv2 = __builtin_kvx_xaligno512(buf, 16);
  __kvx_x512 buf2 = __builtin_kvx_xcat512(lv, lv2);
  vt = __builtin_kvx_xaccesso512(buf2, 1);
  __kvx_x1024 lm = m[0];
  lv = __builtin_kvx_xconvdhv0(lv, lm, ".RN.sat");
  lv = __builtin_kvx_xconvdhv1(lv, lm, ".Ru.satu");
  lv2 = __builtin_kvx_xconvdhv(lm, ".rhu.sat");
  lv2 = __builtin_kvx_xconvwbv0(lv2, lm, ".ru.sat");
  lv2 = __builtin_kvx_xconvwbv1(lv2, lm, ".rd.satu");
  lv2 = __builtin_kvx_xconvwbv2(lv2, lm, ".rz.sat");
  lv2 = __builtin_kvx_xconvwbv3(lv2, lm, ".rhu.satu");
  __kvx_x512 lw = w[0];
  lv2 = __builtin_kvx_xconvwbv(lm, ".ru.sat");
  lv2 = __builtin_kvx_xfmma242hw0(lv, lw, lv, lv2);
  lv = __builtin_kvx_xfmma242hw1(lv2, lw, lv, lv2);
  lv2 = __builtin_kvx_xfmma242hw2(lv, lw, lv, lv2);
  lv = __builtin_kvx_xfmma242hw3(lv2, lw, lv, lv2);
  lw = __builtin_kvx_xfmma444hw(lv2, lv, lw);
  lm = __builtin_kvx_xmma444hbd0(lv, lv, lm, ".s");
  lm = __builtin_kvx_xmma444hbd1(lv, lv, lm, ".s");
  lm = __builtin_kvx_xmma484hbd(lw, lv, lm, "");
  lm = __builtin_kvx_xmma444hd(lv, lv, lm, "");
  lm = __builtin_kvx_xmma444hbd0(lv, lv, lm, ".su");
  lm = __builtin_kvx_xmma444hbd1(lv, lv, lm, ".su");
  lm = __builtin_kvx_xmma484hbd(lw, lv, lm, ".su");
  lm = __builtin_kvx_xmma444hd(lv, lv, lm, ".su");
  lm = __builtin_kvx_xmma444hbd0(lv, lv, lm, ".u");
  lm = __builtin_kvx_xmma444hbd1(lv, lv, lm, ".u");
  lm = __builtin_kvx_xmma484hbd(lw, lv, lm, ".u");
  lm = __builtin_kvx_xmma444hd(lv, lv, lm, ".u");
  lm = __builtin_kvx_xmma444hbd0(lv, lv, lm, ".us");
  lm = __builtin_kvx_xmma444hbd1(lv, lv, lm, ".us");
  lm = __builtin_kvx_xmma484hbd(lw, lv, lm, ".us");
  lm = __builtin_kvx_xmma444hd(lv, lv, lm, ".us");
  lw = __builtin_kvx_xmma484bw(lv, lv, lw, ".");
  lw = __builtin_kvx_xmma484bw(lv, lv, lw, ".su");
  lw = __builtin_kvx_xmma484bw(lv, lv, lw, ".u");
  lw = __builtin_kvx_xmma484bw(lv, lv, lw, ".us");
  lm = __builtin_kvx_xmt44d(lm);
  lv = __builtin_kvx_xfscalewv(lv2, "");
  lv2 = __builtin_kvx_xfnarrow44wh(lw, ".rn.s");
  lv = __builtin_kvx_xfscalewv(lv, ".rn..relu");
  vt = __builtin_kvx_xswapo256(&lv, vt);
  lv = __builtin_kvx_xfscalewv(lv, "...relu");
  lv = __builtin_kvx_lv_cond(lv, &v[3], a, ".s.even");
  lv2 = __builtin_kvx_lv(v, ".s");
  lm = __builtin_kvx_lvc(lm, &v[4], ".s.q0");
  lm = __builtin_kvx_lvc_cond(lm, &v[5], a, ".q0.odd");
  __builtin_kvx_sv(&v[0], lv2);
  __builtin_kvx_sv_cond(&v[1], lv2, 1, ".even");
  w[0] = lw;
  m[0] = lm;
  return vt;
}
