// RUN: clang -emit-llvm -S %s -o - -target kvx-cos | FileCheck %s

unsigned char lbz(void *p) {
  return __builtin_kvx_lbz(p, ".u", 0);
  // CHECK: @lbz
  // CHECK: [[a:%.+]] = addrspacecast i8* {{%.+}} to i8 addrspace(9)*
  // CHECK: [[b:%.+]] = load i8, i8 addrspace(9)* [[a]], align 1
  // CHECK: {{%.+}} = zext i8 [[b]] to i64
  // CHECK: ret
}

int lbs_volatile(void *p) {
  return __builtin_kvx_lbs(p, ".us", 1);
  // CHECK: @lbs_volatile
  // CHECK: [[a:%.+]] = addrspacecast i8* {{%.+}} to i8 addrspace(10)*
  // CHECK: [[b:%.+]] = load volatile i8, i8 addrspace(10)* [[a]], align 1
  // CHECK: {{%.+}} = sext i8 [[b]] to i64
  // CHECK: ret
}

unsigned short lhz(void *p) {
  return __builtin_kvx_lhz(p, ".u", 0);
  // CHECK: @lhz
  // CHECK: [[a:%.+]] = addrspacecast i8* {{%.+}} to i16 addrspace(9)*
  // CHECK: [[b:%.+]] = load i16, i16 addrspace(9)* [[a]], align 2
  // CHECK: {{%.+}} = zext i16 [[b]] to i64
  // CHECK: ret
}

int lhs_volatile(void *p) {
  return __builtin_kvx_lhs(p, ".us", 1);
  // CHECK: @lhs_volatile
  // CHECK: [[a:%.+]] = addrspacecast i8* {{%.+}} to i16 addrspace(10)*
  // CHECK: [[b:%.+]] = load volatile i16, i16 addrspace(10)* [[a]], align 2
  // CHECK: {{%.+}} = sext i16 [[b]] to i64
  // CHECK: ret
}

unsigned int lwz(void *p) {
  return __builtin_kvx_lwz(p, ".u", 0);
  // CHECK: @lwz
  // CHECK: [[a:%.+]] = addrspacecast i8* {{%.+}} to i32 addrspace(9)*
  // CHECK: [[b:%.+]] = load i32, i32 addrspace(9)* [[a]], align 4
  // CHECK: {{%.+}} = zext i32 [[b]] to i64
  // CHECK: ret
}

int lws_volatile(void *p) {
  return __builtin_kvx_lws(p, ".us", 1);
  // CHECK: @lws_volatile
  // CHECK: [[a:%.+]] = addrspacecast i8* {{%.+}} to i32 addrspace(10)*
  // CHECK: [[b:%.+]] = load volatile i32, i32 addrspace(10)* [[a]], align 4
  // CHECK: {{%.+}} = sext i32 [[b]] to i64
  // CHECK: ret
}

float lwf(void *p) {
  return __builtin_kvx_lwf(p, ".s", 1);
  // CHECK: @lwf
  // CHECK: [[a:%.+]] = addrspacecast i8* {{%.+}} to float addrspace(11)*
  // CHECK: {{%.+}} = load volatile float, float addrspace(11)* [[a]], align 4
  // CHECK: ret
}

long ld(void *p) {
  return __builtin_kvx_ld(p, ".s", 1);
  // CHECK: @ld
  // CHECK: [[a:%.+]] = addrspacecast i8* {{%.+}} to i64 addrspace(11)*
  // CHECK: {{%.+}} = load volatile i64, i64 addrspace(11)* [[a]], align 8
  // CHECK: ret
}

double ldf(void *p) {
  return __builtin_kvx_ldf(p, ".s", 1);
  // CHECK: @ld
  // CHECK: [[a:%.+]] = addrspacecast i8* {{%.+}} to double addrspace(11)*
  // CHECK: {{%.+}} = load volatile double, double addrspace(11)* [[a]], align 8
  // CHECK: ret
}

typedef char int8x8_t __attribute__((__vector_size__(8 * sizeof(char))));

int8x8_t ldbo(void *p) {
  return __builtin_kvx_ldbo(p, ".s", 1);
  // CHECK: @ldbo
  // CHECK: [[a:%.+]] = addrspacecast i8* {{%.+}} to <8 x i8> addrspace(11)*
  // CHECK: {{%.+}} = load volatile <8 x i8>, <8 x i8> addrspace(11)* [[a]],
  // align 8 CHECK: ret
}

typedef short int16x4_t __attribute__((__vector_size__(4 * sizeof(short))));

int16x4_t ldhq(void *p) {
  return __builtin_kvx_ldhq(p, ".s", 1);
  // CHECK: @ldhq
  // CHECK: [[a:%.+]] = addrspacecast i8* {{%.+}} to <4 x i16> addrspace(11)*
  // CHECK: {{%.+}} = load volatile <4 x i16>, <4 x i16> addrspace(11)* [[a]],
  // align 8 CHECK: ret
}

typedef int int32x2_t __attribute__((__vector_size__(2 * sizeof(int))));

int32x2_t ldwp(void *p) {
  return __builtin_kvx_ldwp(p, ".s", 1);
  // CHECK: @ldwp
  // CHECK: [[a:%.+]] = addrspacecast i8* {{%.+}} to <2 x i32> addrspace(11)*
  // CHECK: {{%.+}} = load volatile <2 x i32>, <2 x i32> addrspace(11)* [[a]],
  // align 8 CHECK: ret
}

typedef float float32x2_t __attribute__((__vector_size__(2 * sizeof(float))));

float32x2_t ldfwp(void *p) {
  return __builtin_kvx_ldfwp(p, ".s", 1);
  // CHECK: @ldfwp
  // CHECK: [[a:%.+]] = addrspacecast i8* {{%.+}} to <2 x float> addrspace(11)*
  // CHECK: {{%.+}} = load volatile <2 x float>, <2 x float> addrspace(11)*
  // [[a]], align 8 CHECK: ret
}

void sdbo(void *p, int8x8_t v) {
  __builtin_kvx_sdbo(p, v, 1);
  // CHECK: @sdbo
  // CHECK: store volatile <8 x i8> {{%.+}}, <8 x i8>* {{%.+}}, align 8
  // CHECK: ret
}

void sdhq(void *p, int16x4_t v) {
  __builtin_kvx_sdhq(p, v, 1);
  // CHECK: @sdhq
  // CHECK: store volatile <4 x i16> {{%.+}}, <4 x i16>* {{%.+}}, align 8
  // CHECK: ret
}

void sdwp(void *p, int32x2_t v) {
  __builtin_kvx_sdwp(p, v, 1);
  // CHECK: @sdwp
  // CHECK: store volatile <2 x i32> {{%.+}}, <2 x i32>* {{%.+}}, align 8
  // CHECK: ret
}

void sdfwp(void *p, float32x2_t v) {
  __builtin_kvx_sdfwp(p, v, 1);
  // CHECK: @sdfwp
  // CHECK: store volatile <2 x float> {{%.+}}, <2 x float>* {{%.+}}, align 8
  // CHECK: ret
}
