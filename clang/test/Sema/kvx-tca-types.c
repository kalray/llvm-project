// RUN: %clang_cc1 -triple kvx-kalray-cos -fsyntax-only %s -verify

// The use of KVX TCA types is strongly restricted. Non-pointer TCA variables
// can only be declared in functions and a limited number of operations are
// supported on these types. This test case checks that invalid uses of TCA
// types are correctly prevented.

// TCA 1024
// typedef
typedef __kvx_x1024 tca1024_t;
void test1024Typedef(tca1024_t *inp, int *outp) {
  tca1024_t *Matout = (tca1024_t *)outp;
  *Matout = *inp;
}

// function argument
void test1024Arg1(__kvx_x1024 Mat, int *ptr) { // expected-error {{invalid use of KVX TCA type}}
  __kvx_x1024 *Matp = (__kvx_x1024 *)ptr;
  *Matp = Mat;
}

void test1024Arg2(const __kvx_x1024 Mat, int *ptr) { // expected-error {{invalid use of KVX TCA type}}
  __kvx_x1024 *Matp = (__kvx_x1024 *)ptr;
  *Matp = Mat;
}

void test1024Arg3(__kvx_x1024 *Mat, int *ptr) {
  __kvx_x1024 *Matp = (__kvx_x1024 *)ptr;
  *Matp = *Mat;
}

void test1024Arg4(const __kvx_x1024 *const Mat, int *ptr) {
  __kvx_x1024 *Matp = (__kvx_x1024 *)ptr;
  *Matp = *Mat;
}

void test1024Arg5(__kvx_x1024 Mata[], int *ptr) {
  __kvx_x1024 *Matp = (__kvx_x1024 *)ptr;
  *Matp = Mata[0];
}

void test1024Arg6(const tca1024_t Mat, int *ptr) { // expected-error {{invalid use of KVX TCA type}}
  __kvx_x1024 *Matp = (__kvx_x1024 *)ptr;
  *Matp = Mat;
}

void test1024Arg7(const tca1024_t *Mat, int *ptr) {
  __kvx_x1024 *Matp = (__kvx_x1024 *)ptr;
  *Matp = *Mat;
}

// function return
__kvx_x1024 test1024Ret1(int *ptr) { // expected-error {{invalid use of KVX TCA type}}
  __kvx_x1024 *Matp = (__kvx_x1024 *)ptr;
  return *Matp; // expected-error {{invalid use of KVX TCA type}}
}

const tca1024_t test1024Ret4(int *ptr) { // expected-error {{invalid use of KVX TCA type}}
  __kvx_x1024 *Matp = (__kvx_x1024 *)ptr;
  return *Matp; // expected-error {{invalid use of KVX TCA type}}
}

// global
__kvx_x1024 globalMat;        // expected-error {{invalid use of KVX TCA type}}
const __kvx_x1024 globalMat2; // expected-error {{invalid use of KVX TCA type}}
__kvx_x1024 *globalMatp;
const __kvx_x1024 *const globalMatp2;
tca1024_t globaltca1024_t; // expected-error {{invalid use of KVX TCA type}}

// sizeof / alignof
int test1024SizeofAlignof(int *ptr) {
  __kvx_x1024 *Matp = (__kvx_x1024 *)ptr;
  __kvx_x1024 Mat = *Matp;
  unsigned sizet = sizeof(__kvx_x1024);
  unsigned alignt = __alignof__(__kvx_x1024);
  unsigned sizev = sizeof(Mat);
  unsigned alignv = __alignof__(Mat);
  return sizet + alignt + sizev + alignv;
}

// operators
int test1024Operators1(__kvx_x1024 *ptr) {
  __kvx_x1024 Mat1 = *(ptr + 0);
  __kvx_x1024 Mat2 = *(ptr + 1);
  __kvx_x1024 Mat3 = *(ptr + 2);
  if (Mat1) // expected-error {{statement requires expression of scalar type ('__kvx_x1024' invalid)}}
    *(ptr + 10) = Mat1;
  if (!Mat2) // expected-error {{invalid argument type '__kvx_x1024' to unary expression}}
    *(ptr + 11) = Mat3;
  int c1 = Mat1 && Mat2; // expected-error {{invalid operands to binary expression ('__kvx_x1024' and '__kvx_x1024')}}
  int c2 = Mat2 == Mat3; // expected-error {{invalid operands to binary expression ('__kvx_x1024' and '__kvx_x1024')}}
  int c3 = Mat2 < Mat1;  // expected-error {{invalid operands to binary expression ('__kvx_x1024' and '__kvx_x1024')}}
  return c1 || c2 || c3;
}

void test1024Operators2(int *ptr) {
  __kvx_x1024 *Matp = (__kvx_x1024 *)ptr;
  __kvx_x1024 Mat1 = *(Matp + 0);
  __kvx_x1024 Mat2 = *(Matp + 1);
  __kvx_x1024 Mat3 = *(Matp + 2);
  Mat1 = -Mat1;       // expected-error {{invalid argument type '__kvx_x1024' to unary expression}}
  Mat2 = Mat1 + Mat3; // expected-error {{invalid operands to binary expression ('__kvx_x1024' and '__kvx_x1024')}}
  Mat2 = Mat2 * Mat3; // expected-error {{invalid operands to binary expression ('__kvx_x1024' and '__kvx_x1024')}}
  Mat3 = Mat3 | Mat3; // expected-error {{invalid operands to binary expression ('__kvx_x1024' and '__kvx_x1024')}}
  Mat3 = Mat3 << 2;   // expected-error {{invalid operands to binary expression ('__kvx_x1024' and 'int')}}
  *(Matp + 10) = Mat1;
  *(Matp + 11) = Mat2;
  *(Matp + 12) = Mat3;
}

unsigned char test1024Operators3(int *ptr) {
  __kvx_x1024 *Matp = (__kvx_x1024 *)ptr;
  __kvx_x1024 Mat1 = *(Matp + 0);
  __kvx_x1024 Mat2 = *(Matp + 1);
  __kvx_x1024 Mat3 = *(Matp + 2);
  Mat1 ? *(Matp + 10) = Mat2 : *(Matp + 11) = Mat3; // expected-error {{used type '__kvx_x1024' where arithmetic or pointer type is required}}
  Mat2 = Mat3;
  return Mat2[1]; // expected-error {{subscripted value is not an array, pointer, or vector}}
}

void test1024Operators4(int v, void *ptr) {
  __kvx_x1024 *Matp = (__kvx_x1024 *)ptr;
  __kvx_x1024 Mat1 = (__kvx_x1024)v;    // expected-error {{used type '__kvx_x1024' where arithmetic or pointer type is required}}
  __kvx_x1024 Mat2 = (__kvx_x1024)Matp; // expected-error {{used type '__kvx_x1024' where arithmetic or pointer type is required}}
}

// TCA 512
// typedef
typedef __kvx_x512 tca512_t;
void test512Typedef(int *inp, int *outp) {
  tca512_t *Widein = (tca512_t *)inp;
  tca512_t *Wideout = (tca512_t *)outp;
  *Wideout = *Widein;
}

// function argument
void test512Arg1(__kvx_x512 Wide, int *ptr) { // expected-error {{invalid use of KVX TCA type}}
  __kvx_x512 *Widep = (__kvx_x512 *)ptr;
  *Widep = Wide;
}

void test512Arg2(const __kvx_x512 Wide, int *ptr) { // expected-error {{invalid use of KVX TCA type}}
  __kvx_x512 *Widep = (__kvx_x512 *)ptr;
  *Widep = Wide;
}

void test512Arg3(__kvx_x512 *Wide, int *ptr) {
  __kvx_x512 *Widep = (__kvx_x512 *)ptr;
  *Widep = *Wide;
}

void test512Arg4(const __kvx_x512 *const Wide, int *ptr) {
  __kvx_x512 *Widep = (__kvx_x512 *)ptr;
  *Widep = *Wide;
}

void test512Arg5(__kvx_x512 Widea[], int *ptr) {
  __kvx_x512 *Widep = (__kvx_x512 *)ptr;
  *Widep = Widea[0];
}

void test512Arg6(const tca512_t Wide, int *ptr) { // expected-error {{invalid use of KVX TCA type}}
  __kvx_x512 *Widep = (__kvx_x512 *)ptr;
  *Widep = Wide;
}

void test512Arg7(const tca512_t *Wide, int *ptr) {
  __kvx_x512 *Widep = (__kvx_x512 *)ptr;
  *Widep = *Wide;
}

// function return
__kvx_x512 test512Ret1(int *ptr) { // expected-error {{invalid use of KVX TCA type}}
  __kvx_x512 *Widep = (__kvx_x512 *)ptr;
  return *Widep; // expected-error {{invalid use of KVX TCA type}}
}

__kvx_x512 *test512Ret2(int *ptr) {
  __kvx_x512 *Widep = (__kvx_x512 *)ptr;
  return Widep + 2;
}

const __kvx_x512 *test512Ret3(int *ptr) {
  __kvx_x512 *Widep = (__kvx_x512 *)ptr;
  return Widep + 2;
}

const tca512_t test512Ret4(int *ptr) { // expected-error {{invalid use of KVX TCA type}}
  __kvx_x512 *Widep = (__kvx_x512 *)ptr;
  return *Widep; // expected-error {{invalid use of KVX TCA type}}
}

const tca512_t *test512Ret5(int *ptr) {
  __kvx_x512 *Widep = (__kvx_x512 *)ptr;
  return Widep + 2;
}

// global
__kvx_x512 globalWide;        // expected-error {{invalid use of KVX TCA type}}
const __kvx_x512 globalWide2; // expected-error {{invalid use of KVX TCA type}}
__kvx_x512 *globalWidep;
const __kvx_x512 *const globalWidep2;
tca512_t globaltca512_t; // expected-error {{invalid use of KVX TCA type}}

// sizeof / alignof
int test512SizeofAlignof(int *ptr) {
  __kvx_x512 *Widep = (__kvx_x512 *)ptr;
  __kvx_x512 Wide = *Widep;
  unsigned sizet = sizeof(__kvx_x512);
  unsigned alignt = __alignof__(__kvx_x512);
  unsigned sizev = sizeof(Wide);
  unsigned alignv = __alignof__(Wide);
  return sizet + alignt + sizev + alignv;
}

// operators
int test512Operators1(int *ptr) {
  __kvx_x512 *Widep = (__kvx_x512 *)ptr;
  __kvx_x512 Wide1 = *(Widep + 0);
  __kvx_x512 Wide2 = *(Widep + 1);
  __kvx_x512 Wide3 = *(Widep + 2);
  if (Wide1) // expected-error {{statement requires expression of scalar type ('__kvx_x512' invalid)}}
    *(Widep + 10) = Wide1;
  if (!Wide2) // expected-error {{invalid argument type '__kvx_x512' to unary expression}}
    *(Widep + 11) = Wide3;
  int c1 = Wide1 && Wide2; // expected-error {{invalid operands to binary expression ('__kvx_x512' and '__kvx_x512')}}
  int c2 = Wide2 == Wide3; // expected-error {{invalid operands to binary expression ('__kvx_x512' and '__kvx_x512')}}
  int c3 = Wide2 < Wide1;  // expected-error {{invalid operands to binary expression ('__kvx_x512' and '__kvx_x512')}}
  return c1 || c2 || c3;
}

void test512Operators2(int *ptr) {
  __kvx_x512 *Widep = (__kvx_x512 *)ptr;
  __kvx_x512 Wide1 = *(Widep + 0);
  __kvx_x512 Wide2 = *(Widep + 1);
  __kvx_x512 Wide3 = *(Widep + 2);
  Wide1 = -Wide1;        // expected-error {{invalid argument type '__kvx_x512' to unary expression}}
  Wide2 = Wide1 + Wide3; // expected-error {{invalid operands to binary expression ('__kvx_x512' and '__kvx_x512')}}
  Wide2 = Wide2 * Wide3; // expected-error {{invalid operands to binary expression ('__kvx_x512' and '__kvx_x512')}}
  Wide3 = Wide3 | Wide3; // expected-error {{invalid operands to binary expression ('__kvx_x512' and '__kvx_x512')}}
  Wide3 = Wide3 << 2;    // expected-error {{invalid operands to binary expression ('__kvx_x512' and 'int')}}
  *(Widep + 10) = Wide1;
  *(Widep + 11) = Wide2;
  *(Widep + 12) = Wide3;
}

unsigned char test512Operators3(int *ptr) {
  __kvx_x512 *Widep = (__kvx_x512 *)ptr;
  __kvx_x512 Wide1 = *(Widep + 0);
  __kvx_x512 Wide2 = *(Widep + 1);
  __kvx_x512 Wide3 = *(Widep + 2);
  Wide1 ? *(Widep + 10) = Wide2 : *(Widep + 11) = Wide3; // expected-error {{used type '__kvx_x512' where arithmetic or pointer type is required}}
  Wide2 = Wide3;
  return Wide2[1]; // expected-error {{subscripted value is not an array, pointer, or vector}}
}

void test512Operators4(int v, void *ptr) {
  __kvx_x512 *Widep = (__kvx_x512 *)ptr;
  __kvx_x512 Wide1 = (__kvx_x512)v;     // expected-error {{used type '__kvx_x512' where arithmetic or pointer type is required}}
  __kvx_x512 Wide2 = (__kvx_x512)Widep; // expected-error {{used type '__kvx_x512' where arithmetic or pointer type is required}}
}

// TCA 256
// typedef
typedef __kvx_x256 tca256_t;
void test256Typedef(int *inp, int *outp) {
  tca256_t *Vecin = (tca256_t *)inp;
  tca256_t *Vecout = (tca256_t *)outp;
  *Vecout = *Vecin;
}

// function argument
void test256Arg1(__kvx_x256 Vec, int *ptr) { // expected-error {{invalid use of KVX TCA type}}
  __kvx_x256 *Vecp = (__kvx_x256 *)ptr;
  *Vecp = Vec;
}

void test256Arg2(const __kvx_x256 Vec, int *ptr) { // expected-error {{invalid use of KVX TCA type}}
  __kvx_x256 *Vecp = (__kvx_x256 *)ptr;
  *Vecp = Vec;
}

void test256Arg3(__kvx_x256 *Vec, int *ptr) {
  __kvx_x256 *Vecp = (__kvx_x256 *)ptr;
  *Vecp = *Vec;
}

void test256Arg4(const __kvx_x256 *const Vec, int *ptr) {
  __kvx_x256 *Vecp = (__kvx_x256 *)ptr;
  *Vecp = *Vec;
}

void test256Arg5(__kvx_x256 Veca[], int *ptr) {
  __kvx_x256 *Vecp = (__kvx_x256 *)ptr;
  *Vecp = Veca[0];
}

void test256Arg6(const tca256_t Vec, int *ptr) { // expected-error {{invalid use of KVX TCA type}}
  __kvx_x256 *Vecp = (__kvx_x256 *)ptr;
  *Vecp = Vec;
}

void test256Arg7(const tca256_t *Vec, int *ptr) {
  __kvx_x256 *Vecp = (__kvx_x256 *)ptr;
  *Vecp = *Vec;
}

// function return
__kvx_x256 test256Ret1(int *ptr) { // expected-error {{invalid use of KVX TCA type}}
  __kvx_x256 *Vecp = (__kvx_x256 *)ptr;
  return *Vecp; // expected-error {{invalid use of KVX TCA type}}
}

__kvx_x256 *test256Ret2(int *ptr) {
  __kvx_x256 *Vecp = (__kvx_x256 *)ptr;
  return Vecp + 2;
}

const __kvx_x256 *test256Ret3(int *ptr) {
  __kvx_x256 *Vecp = (__kvx_x256 *)ptr;
  return Vecp + 2;
}

const tca256_t test256Ret4(int *ptr) { // expected-error {{invalid use of KVX TCA type}}
  __kvx_x256 *Vecp = (__kvx_x256 *)ptr;
  return *Vecp; // expected-error {{invalid use of KVX TCA type}}
}

const tca256_t *test256Ret5(int *ptr) {
  __kvx_x256 *Vecp = (__kvx_x256 *)ptr;
  return Vecp + 2;
}

// global
__kvx_x256 globalVec;        // expected-error {{invalid use of KVX TCA type}}
const __kvx_x256 globalVec2; // expected-error {{invalid use of KVX TCA type}}
__kvx_x256 *globalVecp;
const __kvx_x256 *const globalVecp2;
tca256_t globaltca256_t; // expected-error {{invalid use of KVX TCA type}}

// local
void test256Local(int *ptr, unsigned char vc) {
  __kvx_x256 *Vecp = (__kvx_x256 *)ptr;
  __kvx_x256 Vec1 = *Vecp;
  __kvx_x256 Vec2 = __builtin_kvx_xmoveto(vc, vc, vc, 1);
  *Vecp = Vec2;
}

// sizeof / alignof
int test256SizeofAlignof(int *ptr) {
  __kvx_x256 *Vecp = (__kvx_x256 *)ptr;
  __kvx_x256 Vec = *Vecp;
  unsigned sizet = sizeof(__kvx_x256);
  unsigned alignt = __alignof__(__kvx_x256);
  unsigned sizev = sizeof(Vec);
  unsigned alignv = __alignof__(Vec);
  return sizet + alignt + sizev + alignv;
}

// operators
int test256Operators1(int *ptr) {
  __kvx_x256 *Vecp = (__kvx_x256 *)ptr;
  __kvx_x256 Vec1 = *(Vecp + 0);
  __kvx_x256 Vec2 = *(Vecp + 1);
  __kvx_x256 Vec3 = *(Vecp + 2);
  if (Vec1) // expected-error {{statement requires expression of scalar type ('__kvx_x256' invalid)}}
    *(Vecp + 10) = Vec1;
  if (!Vec2) // expected-error {{invalid argument type '__kvx_x256' to unary expression}}
    *(Vecp + 11) = Vec3;
  int c1 = Vec1 && Vec2; // expected-error {{invalid operands to binary expression ('__kvx_x256' and '__kvx_x256')}}
  int c2 = Vec2 == Vec3; // expected-error {{invalid operands to binary expression ('__kvx_x256' and '__kvx_x256')}}
  int c3 = Vec2 < Vec1;  // expected-error {{invalid operands to binary expression ('__kvx_x256' and '__kvx_x256')}}
  return c1 || c2 || c3;
}

void test256Operators2(int *ptr) {
  __kvx_x256 *Vecp = (__kvx_x256 *)ptr;
  __kvx_x256 Vec1 = *(Vecp + 0);
  __kvx_x256 Vec2 = *(Vecp + 1);
  __kvx_x256 Vec3 = *(Vecp + 2);
  Vec1 = -Vec1;       // expected-error {{invalid argument type '__kvx_x256' to unary expression}}
  Vec2 = Vec1 + Vec3; // expected-error {{invalid operands to binary expression ('__kvx_x256' and '__kvx_x256')}}
  Vec2 = Vec2 * Vec3; // expected-error {{invalid operands to binary expression ('__kvx_x256' and '__kvx_x256')}}
  Vec3 = Vec3 | Vec3; // expected-error {{invalid operands to binary expression ('__kvx_x256' and '__kvx_x256')}}
  Vec3 = Vec3 << 2;   // expected-error {{invalid operands to binary expression ('__kvx_x256' and 'int')}}
  *(Vecp + 10) = Vec1;
  *(Vecp + 11) = Vec2;
  *(Vecp + 12) = Vec3;
}

unsigned char test256Operators3(int *ptr) {
  __kvx_x256 *Vecp = (__kvx_x256 *)ptr;
  __kvx_x256 Vec1 = *(Vecp + 0);
  __kvx_x256 Vec2 = *(Vecp + 1);
  __kvx_x256 Vec3 = *(Vecp + 2);
  Vec1 ? *(Vecp + 10) = Vec2 : *(Vecp + 11) = Vec3; // expected-error {{used type '__kvx_x256' where arithmetic or pointer type is required}}
  Vec2 = Vec3;
  return Vec2[1]; // expected-error {{subscripted value is not an array, pointer, or vector}}
}

void test256Operators4(int v, void *ptr) {
  __kvx_x256 *Vecp = (__kvx_x256 *)ptr;
  __kvx_x256 Vec1 = (__kvx_x256)v;    // expected-error {{used type '__kvx_x256' where arithmetic or pointer type is required}}
  __kvx_x256 Vec2 = (__kvx_x256)Vecp; // expected-error {{used type '__kvx_x256' where arithmetic or pointer type is required}}
}
