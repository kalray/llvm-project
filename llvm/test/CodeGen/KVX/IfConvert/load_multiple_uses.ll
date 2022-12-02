; RUN: llc -verify-machineinstrs %s -o /dev/null
; Not breaking the compiler is good enough.

target triple = "kvx-kalray-cos"

%struct.vorbis_look_psy = type { i32, %struct.vorbis_info_psy*, float***, float**, float*, i64*, i64*, i64, i64, i32, i32, i64 }
%struct.vorbis_info_psy = type { i32, float, float, [3 x float], float, float, float, [17 x float], i32, float, float, float, i32, i32, i32, [3 x [17 x float]], [40 x float], float, i32, i32, i32, i32, double }

define void @max_seeds(%struct.vorbis_look_psy* nocapture readonly %0, float* nocapture readonly %1, float* nocapture %2) {
  %4 = getelementptr inbounds %struct.vorbis_look_psy, %struct.vorbis_look_psy* %0, i64 0, i32 5
  %5 = getelementptr inbounds %struct.vorbis_look_psy, %struct.vorbis_look_psy* %0, i64 0, i32 7
  %6 = getelementptr inbounds %struct.vorbis_look_psy, %struct.vorbis_look_psy* %0, i64 0, i32 0
  %7 = load i32, i32* %6, align 8
  %8 = icmp sgt i32 %7, 1
  br i1 %8, label %9, label %69

9:
  %10 = load i64*, i64** %4, align 8
  %11 = load i64, i64* %10, align 8
  %12 = getelementptr inbounds %struct.vorbis_look_psy, %struct.vorbis_look_psy* %0, i64 0, i32 9
  %13 = load i32, i32* %12, align 8
  %14 = ashr i32 %13, 1
  %15 = sub nsw i32 0, %14
  %16 = sext i32 %15 to i64
  %17 = add i64 %11, %16
  %18 = load i64, i64* %5, align 8
  %19 = sub i64 %17, %18
  %20 = getelementptr inbounds float, float* %1, i64 %19
  br label %21

21:
  %22 = phi i32 [ %7, %9 ], [ %59, %64 ]
  %23 = phi i64 [ %18, %9 ], [ %68, %64 ]
  %24 = phi i64 [ %11, %9 ], [ %67, %64 ]
  %25 = phi i64* [ %10, %9 ], [ %65, %64 ]
  %26 = phi i64 [ 1, %9 ], [ %61, %64 ]
  %27 = phi i64 [ 0, %9 ], [ %60, %64 ]
  %28 = load float, float* %20, align 4
  %29 = getelementptr inbounds i64, i64* %25, i64 %26
  %30 = load i64, i64* %29, align 8
  %31 = add nsw i64 %30, %24
  %32 = ashr i64 %31, 1
  %33 = sub nsw i64 %32, %23
  %34 = sext i32 %22 to i64
  %35 = icmp sge i64 %27, %34
  %36 = icmp sgt i64 %24, %33
  %37 = or i1 %35, %36
  br i1 %37, label %58, label %38

38:
  %39 = phi i64 [ %181, %184 ], [ %27, %21 ]
  %40 = phi i32 [ %180, %184 ], [ %22, %21 ]
  %41 = phi i32 [ %179, %184 ], [ %22, %21 ]
  %42 = getelementptr inbounds float, float* %2, i64 %39
  %43 = load float, float* %42, align 4
  %44 = fcmp olt float %43, %28
  br i1 %44, label %45, label %47

45:
  store float %28, float* %42, align 4
  %46 = load i32, i32* %6, align 8
  br label %47

47:
  %48 = phi i32 [ %41, %38 ], [ %46, %45 ]
  %49 = phi i32 [ %40, %38 ], [ %46, %45 ]
  %50 = add nsw i64 %39, 1
  %51 = sext i32 %49 to i64
  %52 = icmp slt i64 %50, %51
  br i1 %52, label %53, label %58

53:
  %54 = load i64*, i64** %4, align 8
  %55 = getelementptr inbounds i64, i64* %54, i64 %50
  %56 = load i64, i64* %55, align 8
  %57 = icmp sgt i64 %56, %33
  br i1 %57, label %58, label %70

58:
  %59 = phi i32 [ %22, %21 ], [ %48, %53 ], [ %48, %47 ], [ %77, %76 ], [ %77, %82 ], [ %94, %93 ], [ %94, %99 ], [ %111, %110 ], [ %111, %116 ], [ %128, %127 ], [ %128, %133 ], [ %145, %144 ], [ %145, %150 ], [ %162, %161 ], [ %162, %167 ], [ %179, %178 ], [ %179, %184 ]
  %60 = phi i64 [ %27, %21 ], [ %50, %53 ], [ %50, %47 ], [ %79, %76 ], [ %79, %82 ], [ %96, %93 ], [ %96, %99 ], [ %113, %110 ], [ %113, %116 ], [ %130, %127 ], [ %130, %133 ], [ %147, %144 ], [ %147, %150 ], [ %164, %161 ], [ %164, %167 ], [ %181, %178 ], [ %181, %184 ]
  %61 = add nsw i64 %60, 1
  %62 = sext i32 %59 to i64
  %63 = icmp slt i64 %61, %62
  br i1 %63, label %64, label %69

64:
  %65 = load i64*, i64** %4, align 8
  %66 = getelementptr inbounds i64, i64* %65, i64 %60
  %67 = load i64, i64* %66, align 8
  %68 = load i64, i64* %5, align 8
  br label %21

69:
  ret void

70:
  %71 = getelementptr inbounds float, float* %2, i64 %50
  %72 = load float, float* %71, align 4
  %73 = fcmp olt float %72, %28
  br i1 %73, label %74, label %76

74:
  store float %28, float* %71, align 4
  %75 = load i32, i32* %6, align 8
  br label %76

76:
  %77 = phi i32 [ %48, %70 ], [ %75, %74 ]
  %78 = phi i32 [ %49, %70 ], [ %75, %74 ]
  %79 = add nsw i64 %39, 2
  %80 = sext i32 %78 to i64
  %81 = icmp slt i64 %79, %80
  br i1 %81, label %82, label %58

82:
  %83 = load i64*, i64** %4, align 8
  %84 = getelementptr inbounds i64, i64* %83, i64 %79
  %85 = load i64, i64* %84, align 8
  %86 = icmp sgt i64 %85, %33
  br i1 %86, label %58, label %87

87:
  %88 = getelementptr inbounds float, float* %2, i64 %79
  %89 = load float, float* %88, align 4
  %90 = fcmp olt float %89, %28
  br i1 %90, label %91, label %93

91:
  store float %28, float* %88, align 4
  %92 = load i32, i32* %6, align 8
  br label %93

93:
  %94 = phi i32 [ %77, %87 ], [ %92, %91 ]
  %95 = phi i32 [ %78, %87 ], [ %92, %91 ]
  %96 = add nsw i64 %39, 3
  %97 = sext i32 %95 to i64
  %98 = icmp slt i64 %96, %97
  br i1 %98, label %99, label %58

99:
  %100 = load i64*, i64** %4, align 8
  %101 = getelementptr inbounds i64, i64* %100, i64 %96
  %102 = load i64, i64* %101, align 8
  %103 = icmp sgt i64 %102, %33
  br i1 %103, label %58, label %104

104:
  %105 = getelementptr inbounds float, float* %2, i64 %96
  %106 = load float, float* %105, align 4
  %107 = fcmp olt float %106, %28
  br i1 %107, label %108, label %110

108:
  store float %28, float* %105, align 4
  %109 = load i32, i32* %6, align 8
  br label %110

110:
  %111 = phi i32 [ %94, %104 ], [ %109, %108 ]
  %112 = phi i32 [ %95, %104 ], [ %109, %108 ]
  %113 = add nsw i64 %39, 4
  %114 = sext i32 %112 to i64
  %115 = icmp slt i64 %113, %114
  br i1 %115, label %116, label %58

116:
  %117 = load i64*, i64** %4, align 8
  %118 = getelementptr inbounds i64, i64* %117, i64 %113
  %119 = load i64, i64* %118, align 8
  %120 = icmp sgt i64 %119, %33
  br i1 %120, label %58, label %121

121:
  %122 = getelementptr inbounds float, float* %2, i64 %113
  %123 = load float, float* %122, align 4
  %124 = fcmp olt float %123, %28
  br i1 %124, label %125, label %127

125:
  store float %28, float* %122, align 4
  %126 = load i32, i32* %6, align 8
  br label %127

127:
  %128 = phi i32 [ %111, %121 ], [ %126, %125 ]
  %129 = phi i32 [ %112, %121 ], [ %126, %125 ]
  %130 = add nsw i64 %39, 5
  %131 = sext i32 %129 to i64
  %132 = icmp slt i64 %130, %131
  br i1 %132, label %133, label %58

133:
  %134 = load i64*, i64** %4, align 8
  %135 = getelementptr inbounds i64, i64* %134, i64 %130
  %136 = load i64, i64* %135, align 8
  %137 = icmp sgt i64 %136, %33
  br i1 %137, label %58, label %138

138:
  %139 = getelementptr inbounds float, float* %2, i64 %130
  %140 = load float, float* %139, align 4
  %141 = fcmp olt float %140, %28
  br i1 %141, label %142, label %144

142:
  store float %28, float* %139, align 4
  %143 = load i32, i32* %6, align 8
  br label %144

144:
  %145 = phi i32 [ %128, %138 ], [ %143, %142 ]
  %146 = phi i32 [ %129, %138 ], [ %143, %142 ]
  %147 = add nsw i64 %39, 6
  %148 = sext i32 %146 to i64
  %149 = icmp slt i64 %147, %148
  br i1 %149, label %150, label %58

150:
  %151 = load i64*, i64** %4, align 8
  %152 = getelementptr inbounds i64, i64* %151, i64 %147
  %153 = load i64, i64* %152, align 8
  %154 = icmp sgt i64 %153, %33
  br i1 %154, label %58, label %155

155:
  %156 = getelementptr inbounds float, float* %2, i64 %147
  %157 = load float, float* %156, align 4
  %158 = fcmp olt float %157, %28
  br i1 %158, label %159, label %161

159:
  store float %28, float* %156, align 4
  %160 = load i32, i32* %6, align 8
  br label %161

161:
  %162 = phi i32 [ %145, %155 ], [ %160, %159 ]
  %163 = phi i32 [ %146, %155 ], [ %160, %159 ]
  %164 = add nsw i64 %39, 7
  %165 = sext i32 %163 to i64
  %166 = icmp slt i64 %164, %165
  br i1 %166, label %167, label %58

167:
  %168 = load i64*, i64** %4, align 8
  %169 = getelementptr inbounds i64, i64* %168, i64 %164
  %170 = load i64, i64* %169, align 8
  %171 = icmp sgt i64 %170, %33
  br i1 %171, label %58, label %172

172:
  %173 = getelementptr inbounds float, float* %2, i64 %164
  %174 = load float, float* %173, align 4
  %175 = fcmp olt float %174, %28
  br i1 %175, label %176, label %178

176:
  store float %28, float* %173, align 4
  %177 = load i32, i32* %6, align 8
  br label %178

178:
  %179 = phi i32 [ %162, %172 ], [ %177, %176 ]
  %180 = phi i32 [ %163, %172 ], [ %177, %176 ]
  %181 = add nsw i64 %39, 8
  %182 = sext i32 %180 to i64
  %183 = icmp slt i64 %181, %182
  br i1 %183, label %184, label %58

184:
  %185 = load i64*, i64** %4, align 8
  %186 = getelementptr inbounds i64, i64* %185, i64 %181
  %187 = load i64, i64* %186, align 8
  %188 = icmp sgt i64 %187, %33
  br i1 %188, label %58, label %38
}
