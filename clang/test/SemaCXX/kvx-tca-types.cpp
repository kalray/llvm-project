// RUN: %clang_cc1 -triple kvx-kalray-cos -fsyntax-only \
// RUN:   -fcxx-exceptions %s -verify

// TCA 1024
using tca1024_t = __kvx_x1024;
void test1024Alias(int *inp, int *outp) {
  tca1024_t *Matin = (tca1024_t *)inp;
  tca1024_t *Matout = (tca1024_t *)outp;
  *Matout = *Matin;
}

class TestClass1024 {
  // method argument
public:
  void test1024Arg1(__kvx_x1024 Mat, int *ptr) { // expected-error {{invalid use of KVX TCA type}}
    __kvx_x1024 *Matp = (__kvx_x1024 *)ptr;
    *Matp = Mat;
    *Matp1 = Mat;
  }
  void test1024Arg2(const __kvx_x1024 Mat, int *ptr) { // expected-error {{invalid use of KVX TCA type}}
    __kvx_x1024 *Matp = (__kvx_x1024 *)ptr;
    *Matp = Mat;
    *Matp2 = Mat;
  }
  void test1024Arg3(__kvx_x1024 *Mat, int *ptr) {
    __kvx_x1024 *Matp = (__kvx_x1024 *)ptr;
    *Matp = *Mat;
    Matp1 = Matp;
  }
  void test1024Arg4(const __kvx_x1024 *const Mat, int *ptr) {
    __kvx_x1024 *Matp = (__kvx_x1024 *)ptr;
    *Matp = *Mat;
    Matp2 = Matp;
  }
  void test1024Arg5(__kvx_x1024 Mata[], int *ptr) {
    __kvx_x1024 *Matp = (__kvx_x1024 *)ptr;
    *Matp = Mata[0];
    *Matp1 = Mata[1];
  }
  void test1024Arg6(const tca1024_t Mat, int *ptr) { // expected-error {{invalid use of KVX TCA type}}
    __kvx_x1024 *Matp = (__kvx_x1024 *)ptr;
    *Matp = Mat;
    *Matp2 = Mat;
  }
  void test1024Arg7(const tca1024_t *Mat, int *ptr) {
    __kvx_x1024 *Matp = (__kvx_x1024 *)ptr;
    *Matp = *Mat;
    Matp1 = Matp;
  }

  // method return
  __kvx_x1024 test1024Ret1(int *ptr) { // expected-error {{invalid use of KVX TCA type}}
    __kvx_x1024 *Matp = (__kvx_x1024 *)ptr;
    Mat1 = *Matp;
    return *Matp; // expected-error {{invalid use of KVX TCA type}}
  }

  __kvx_x1024 *test1024Ret2(int *ptr) {
    __kvx_x1024 *Matp = (__kvx_x1024 *)ptr;
    Mat2 = *Matp;
    return Matp + 2;
  }

  const __kvx_x1024 *test1024Ret3(int *ptr) {
    __kvx_x1024 *Matp = (__kvx_x1024 *)ptr;
    Matp1 = Matp;
    return Matp + 2;
  }

  const tca1024_t test1024Ret4(int *ptr) { // expected-error {{invalid use of KVX TCA type}}
    __kvx_x1024 *Matp = (__kvx_x1024 *)ptr;
    Matp2 = Matp;
    return *Matp; // expected-error {{invalid use of KVX TCA type}}
  }

  const tca1024_t *test1024Ret5(int *ptr) {
    __kvx_x1024 *Matp = (__kvx_x1024 *)ptr;
    Mat1 = *Matp;
    return Matp + 2;
  }

  // template argument
  template <typename T = __kvx_x1024>
  void test1024Template(T v, T *p) { // expected-note {{candidate template ignored: substitution failure [with T = __kvx_x1024]: invalid use of KVX TCA type}} \
                                         expected-note {{candidate template ignored: substitution failure [with T = __kvx_x1024]: invalid use of KVX TCA type}}
    *(p + 1) = v;
  }

  // class field
public:
  __kvx_x1024 Mat1;
  __kvx_x1024 *Matp1;

private:
  tca1024_t Mat2;
  tca1024_t *Matp2;
};

// template
template <typename T>
class ClassTemplate10241 {
  T t;
};
template <typename T>
class ClassTemplate10242 {
  T *t;
};
template <typename T>
class ClassTemplate10243 {
  int foo(T t) { return 10; }
};
template <typename T, typename... Ts>
class ClassTemplate10244 {
public:
  T operator()(Ts...) const {} // expected-error {{invalid use of KVX TCA type}}
};
void test1024Template() {
  ClassTemplate10241<__kvx_x1024> t1;
  ClassTemplate10241<__kvx_x1024 *> t2;
  ClassTemplate10242<__kvx_x1024> t3;
  ClassTemplate10242<__kvx_x1024 *> t4;

  ClassTemplate10243<int(int, int, int)> t5;
  // The following case is not prevented but it ok, this function type cannot be
  // instantiated because we prevent any function from returning an TCA type.
  ClassTemplate10243<__kvx_x1024(int, int, int)> t6;
  ClassTemplate10243<int(__kvx_x1024, int, int)> t7; // expected-error {{invalid use of KVX TCA type}}

  ClassTemplate10244<int, int, int, __kvx_x1024> t8; // expected-note {{in instantiation of template class 'ClassTemplate10244<int, int, int, __kvx_x1024>' requested here}}
  ClassTemplate10244<int, int, int, __kvx_x1024 *> t9;

  TestClass1024 tc;
  __kvx_x1024 Mat;
  __kvx_x1024 *Matp = &Mat;
  tc.test1024Template(&Mat, &Matp);
  tc.test1024Template<tca1024_t *>(&Mat, &Matp);
  tc.test1024Template(Mat, Matp);            // expected-error {{no matching member function for call to 'test1024Template'}}
  tc.test1024Template<tca1024_t>(Mat, Matp); // expected-error {{no matching member function for call to 'test1024Template'}}
}

// trailing return type
auto test1024Trailing1() {
  __kvx_x1024 Mat;
  return Mat; // expected-error {{invalid use of KVX TCA type}}
}
auto test1024Trailing2() {
  __kvx_x1024 *Matp;
  return Matp;
}
auto test1024Trailing3() -> tca1024_t { // expected-error {{invalid use of KVX TCA type}}
  __kvx_x1024 Mat;
  return Mat; // expected-error {{invalid use of KVX TCA type}}
}
auto test1024Trailing4() -> tca1024_t * {
  __kvx_x1024 *Matp;
  return Matp;
}

// new/delete
void test1024NewDelete() {
  __kvx_x1024 *Matp1 = new __kvx_x1024;
  __kvx_x1024 *Matp2 = new __kvx_x1024[100];
  delete Matp1;
  delete[] Matp2;
}

void foo(__kvx_x1024 *);

// lambdas expressions
void Test1024Lambda() {
  auto f1 = [](void *ptr) -> __kvx_x1024 {
    __kvx_x1024 *Matp = (__kvx_x1024 *)ptr;
    return *Matp; // expected-error {{invalid use of KVX TCA type}}
  };
  auto f2 = [](void *ptr) {
    __kvx_x1024 *Matp = (__kvx_x1024 *)ptr;
    return *Matp; // expected-error {{invalid use of KVX TCA type}}
  };
  auto f3 = [](__kvx_x1024, unsigned char vc) { __kvx_x1024 Mat; foo(&Mat); return Mat; }; // expected-error {{invalid use of KVX TCA type}} expected-error {{invalid use of KVX TCA type}}
}

// cast
void Test1024Cast() {
  __kvx_x1024 Mat;
  int *ip = reinterpret_cast<int *>(&Mat);
  __kvx_x1024 *Mat2 = reinterpret_cast<__kvx_x1024 *>(ip);
}

// throw
void Test1024Throw() {
  __kvx_x1024 Mat;
  throw Mat; // expected-error {{invalid use of KVX TCA type}}
}

// TCA 512
// alias
using tca512_t = __kvx_x512;
void test512Alias(int *inp, int *outp) {
  tca512_t *Widein = (tca512_t *)inp;
  tca512_t *Wideout = (tca512_t *)outp;
  *Wideout = *Widein;
}

class TestClass512 {
  // method argument
public:
  void test512Arg1(__kvx_x512 Wide, int *ptr) { // expected-error {{invalid use of KVX TCA type}}
    __kvx_x512 *Widep = (__kvx_x512 *)ptr;
    *Widep = Wide;
    *Widep1 = Wide;
  }
  void test512Arg2(const __kvx_x512 Wide, int *ptr) { // expected-error {{invalid use of KVX TCA type}}
    __kvx_x512 *Widep = (__kvx_x512 *)ptr;
    *Widep = Wide;
    *Widep2 = Wide;
  }
  void test512Arg3(__kvx_x512 *Wide, int *ptr) {
    __kvx_x512 *Widep = (__kvx_x512 *)ptr;
    *Widep = *Wide;
    Widep1 = Widep;
  }
  void test512Arg4(const __kvx_x512 *const Wide, int *ptr) {
    __kvx_x512 *Widep = (__kvx_x512 *)ptr;
    *Widep = *Wide;
    Widep2 = Widep;
  }
  void test512Arg5(__kvx_x512 Widea[], int *ptr) {
    __kvx_x512 *Widep = (__kvx_x512 *)ptr;
    *Widep = Widea[0];
    *Widep1 = Widea[1];
  }
  void test512Arg6(const tca512_t Wide, int *ptr) { // expected-error {{invalid use of KVX TCA type}}
    __kvx_x512 *Widep = (__kvx_x512 *)ptr;
    *Widep = Wide;
    *Widep2 = Wide;
  }
  void test512Arg7(const tca512_t *Wide, int *ptr) {
    __kvx_x512 *Widep = (__kvx_x512 *)ptr;
    *Widep = *Wide;
    Widep1 = Widep;
  }

  // method return
  __kvx_x512 test512Ret1(int *ptr) { // expected-error {{invalid use of KVX TCA type}}
    __kvx_x512 *Widep = (__kvx_x512 *)ptr;
    Wide1 = *Widep;
    return *Widep; // expected-error {{invalid use of KVX TCA type}}
  }

  __kvx_x512 *test512Ret2(int *ptr) {
    __kvx_x512 *Widep = (__kvx_x512 *)ptr;
    Wide2 = *Widep;
    return Widep + 2;
  }

  const __kvx_x512 *test512Ret3(int *ptr) {
    __kvx_x512 *Widep = (__kvx_x512 *)ptr;
    Widep1 = Widep;
    return Widep + 2;
  }

  const tca512_t test512Ret4(int *ptr) { // expected-error {{invalid use of KVX TCA type}}
    __kvx_x512 *Widep = (__kvx_x512 *)ptr;
    Widep2 = Widep;
    return *Widep; // expected-error {{invalid use of KVX TCA type}}
  }

  const tca512_t *test512Ret5(int *ptr) {
    __kvx_x512 *Widep = (__kvx_x512 *)ptr;
    Wide1 = *Widep;
    return Widep + 2;
  }

  // template argument
  template <typename T = __kvx_x512>
  void test512Template(T v, T *p) { // expected-note {{candidate template ignored: substitution failure [with T = __kvx_x512]: invalid use of KVX TCA type}} \
                                         expected-note {{candidate template ignored: substitution failure [with T = __kvx_x512]: invalid use of KVX TCA type}}
    *(p + 1) = v;
  }

  // class field
public:
  __kvx_x512 Wide1;
  __kvx_x512 *Widep1;

private:
  tca512_t Wide2;
  tca512_t *Widep2;
};

// template
template <typename T>
class ClassTemplate5121 {
  T t;
};
template <typename T>
class ClassTemplate5122 {
  T *t;
};
template <typename T>
class ClassTemplate5123 {
  int foo(T t) { return 10; }
};
template <typename T, typename... Ts>
class ClassTemplate5124 {
public:
  T operator()(Ts...) const {} // expected-error {{invalid use of KVX TCA type}}
};
void test512Template() {
  ClassTemplate5121<__kvx_x512> t1;
  ClassTemplate5121<__kvx_x512 *> t2;
  ClassTemplate5122<__kvx_x512> t3;
  ClassTemplate5122<__kvx_x512 *> t4;

  ClassTemplate5123<int(int, int, int)> t5;
  // The following case is not prevented but it ok, this function type cannot be
  // instantiated because we prevent any function from returning an TCA type.
  ClassTemplate5123<__kvx_x512(int, int, int)> t6;
  ClassTemplate5123<int(__kvx_x512, int, int)> t7; // expected-error {{invalid use of KVX TCA type}}

  ClassTemplate5124<int, int, int, __kvx_x512> t8; // expected-note {{in instantiation of template class 'ClassTemplate5124<int, int, int, __kvx_x512>' requested here}}
  ClassTemplate5124<int, int, int, __kvx_x512 *> t9;

  TestClass512 tc;
  __kvx_x512 Wide;
  __kvx_x512 *Widep = &Wide;
  tc.test512Template(&Wide, &Widep);
  tc.test512Template<tca512_t *>(&Wide, &Widep);
  tc.test512Template(Wide, Widep);           // expected-error {{no matching member function for call to 'test512Template'}}
  tc.test512Template<tca512_t>(Wide, Widep); // expected-error {{no matching member function for call to 'test512Template'}}
}

// trailing return type
auto test512Trailing1() {
  __kvx_x512 Wide;
  return Wide; // expected-error {{invalid use of KVX TCA type}}
}
auto test512Trailing2() {
  __kvx_x512 *Widep;
  return Widep;
}
auto test512Trailing3() -> tca512_t { // expected-error {{invalid use of KVX TCA type}}
  __kvx_x512 Wide;
  return Wide; // expected-error {{invalid use of KVX TCA type}}
}
auto test512Trailing4() -> tca512_t * {
  __kvx_x512 *Widep;
  return Widep;
}

// new/delete
void test512NewDelete() {
  __kvx_x512 *Widep1 = new __kvx_x512;
  __kvx_x512 *Widep2 = new __kvx_x512[100];
  delete Widep1;
  delete[] Widep2;
}

void bar(__kvx_x512 *);
// lambdas expressions
void Test512Lambda() {
  auto f1 = [](void *ptr) -> __kvx_x512 {
    __kvx_x512 *Widep = (__kvx_x512 *)ptr;
    return *Widep; // expected-error {{invalid use of KVX TCA type}}
  };
  auto f2 = [](void *ptr) {
    __kvx_x512 *Widep = (__kvx_x512 *)ptr;
    return *Widep; // expected-error {{invalid use of KVX TCA type}}
  };
  auto f3 = [] { __kvx_x512 Wide; bar(&Wide); return Wide; }; // expected-error {{invalid use of KVX TCA type}}
}

// cast
void Test512Cast() {
  __kvx_x512 Wide;
  int *ip = reinterpret_cast<int *>(&Wide);
  __kvx_x512 *Wide2 = reinterpret_cast<__kvx_x512 *>(ip);
}

// throw
void Test512Throw() {
  __kvx_x512 Wide;
  throw Wide; // expected-error {{invalid use of KVX TCA type}}
}

// TCA 256
using tca256_t = __kvx_x256;
void test256Alias(int *inp, int *outp) {
  tca256_t *Vecin = (tca256_t *)inp;
  tca256_t *Vecout = (tca256_t *)outp;
  *Vecout = *Vecin;
}

class TestClass256 {
  // method argument
public:
  void test256Arg1(__kvx_x256 Vec, int *ptr) { // expected-error {{invalid use of KVX TCA type}}
    __kvx_x256 *Vecp = (__kvx_x256 *)ptr;
    *Vecp = Vec;
    *Vecp1 = Vec;
  }
  void test256Arg2(const __kvx_x256 Vec, int *ptr) { // expected-error {{invalid use of KVX TCA type}}
    __kvx_x256 *Vecp = (__kvx_x256 *)ptr;
    *Vecp = Vec;
    *Vecp2 = Vec;
  }
  void test256Arg3(__kvx_x256 *Vec, int *ptr) {
    __kvx_x256 *Vecp = (__kvx_x256 *)ptr;
    *Vecp = *Vec;
    Vecp1 = Vecp;
  }
  void test256Arg4(const __kvx_x256 *const Vec, int *ptr) {
    __kvx_x256 *Vecp = (__kvx_x256 *)ptr;
    *Vecp = *Vec;
    Vecp2 = Vecp;
  }
  void test256Arg5(__kvx_x256 Veca[], int *ptr) {
    __kvx_x256 *Vecp = (__kvx_x256 *)ptr;
    *Vecp = Veca[0];
    *Vecp1 = Veca[1];
  }
  void test256Arg6(const tca256_t Vec, int *ptr) { // expected-error {{invalid use of KVX TCA type}}
    __kvx_x256 *Vecp = (__kvx_x256 *)ptr;
    *Vecp = Vec;
    *Vecp2 = Vec;
  }
  void test256Arg7(const tca256_t *Vec, int *ptr) {
    __kvx_x256 *Vecp = (__kvx_x256 *)ptr;
    *Vecp = *Vec;
    Vecp1 = Vecp;
  }

  // method return
  __kvx_x256 test256Ret1(int *ptr) { // expected-error {{invalid use of KVX TCA type}}
    __kvx_x256 *Vecp = (__kvx_x256 *)ptr;
    Vec1 = *Vecp;
    return *Vecp; // expected-error {{invalid use of KVX TCA type}}
  }

  __kvx_x256 *test256Ret2(int *ptr) {
    __kvx_x256 *Vecp = (__kvx_x256 *)ptr;
    Vec2 = *Vecp;
    return Vecp + 2;
  }

  const __kvx_x256 *test256Ret3(int *ptr) {
    __kvx_x256 *Vecp = (__kvx_x256 *)ptr;
    Vecp1 = Vecp;
    return Vecp + 2;
  }

  const tca256_t test256Ret4(int *ptr) { // expected-error {{invalid use of KVX TCA type}}
    __kvx_x256 *Vecp = (__kvx_x256 *)ptr;
    Vecp2 = Vecp;
    return *Vecp; // expected-error {{invalid use of KVX TCA type}}
  }

  const tca256_t *test256Ret5(int *ptr) {
    __kvx_x256 *Vecp = (__kvx_x256 *)ptr;
    Vec1 = *Vecp;
    return Vecp + 2;
  }

  // template argument
  template <typename T = __kvx_x256>
  void test256Template(T v, T *p) { // expected-note {{candidate template ignored: substitution failure [with T = __kvx_x256]: invalid use of KVX TCA type}} \
                                         expected-note {{candidate template ignored: substitution failure [with T = __kvx_x256]: invalid use of KVX TCA type}}
    *(p + 1) = v;
  }

  // class field
public:
  __kvx_x256 Vec1;
  __kvx_x256 *Vecp1;

private:
  tca256_t Vec2;
  tca256_t *Vecp2;
};

// template
template <typename T>
class ClassTemplate2561 {
  T t;
};
template <typename T>
class ClassTemplate2562 {
  T *t;
};
template <typename T>
class ClassTemplate2563 {
  int foo(T t) { return 10; }
};
template <typename T, typename... Ts>
class ClassTemplate2564 {
public:
  T operator()(Ts...) const {} // expected-error {{invalid use of KVX TCA type}}
};
void test256Template() {
  ClassTemplate2561<__kvx_x256> t1;
  ClassTemplate2561<__kvx_x256 *> t2;
  ClassTemplate2562<__kvx_x256> t3;
  ClassTemplate2562<__kvx_x256 *> t4;

  ClassTemplate2563<int(int, int, int)> t5;
  // The following case is not prevented but it ok, this function type cannot be
  // instantiated because we prevent any function from returning an TCA type.
  ClassTemplate2563<__kvx_x256(int, int, int)> t6;
  ClassTemplate2563<int(__kvx_x256, int, int)> t7; // expected-error {{invalid use of KVX TCA type}}

  ClassTemplate2564<int, int, int, __kvx_x256> t8; // expected-note {{in instantiation of template class 'ClassTemplate2564<int, int, int, __kvx_x256>' requested here}}
  ClassTemplate2564<int, int, int, __kvx_x256 *> t9;

  TestClass256 tc;
  __kvx_x256 Vec;
  __kvx_x256 *Vecp = &Vec;
  tc.test256Template(&Vec, &Vecp);
  tc.test256Template<tca256_t *>(&Vec, &Vecp);
  tc.test256Template(Vec, Vecp);           // expected-error {{no matching member function for call to 'test256Template'}}
  tc.test256Template<tca256_t>(Vec, Vecp); // expected-error {{no matching member function for call to 'test256Template'}}
}

// trailing return type
auto test256Trailing1() {
  __kvx_x256 Vec;
  return Vec; // expected-error {{invalid use of KVX TCA type}}
}
auto test256Trailing2() {
  __kvx_x256 *Vecp;
  return Vecp;
}
auto test256Trailing3() -> tca256_t { // expected-error {{invalid use of KVX TCA type}}
  __kvx_x256 Vec;
  return Vec; // expected-error {{invalid use of KVX TCA type}}
}
auto test256Trailing4() -> tca256_t * {
  __kvx_x256 *Vecp;
  return Vecp;
}

// new/delete
void test256NewDelete() {
  __kvx_x256 *Vecp1 = new __kvx_x256;
  __kvx_x256 *Vecp2 = new __kvx_x256[100];
  delete Vecp1;
  delete[] Vecp2;
}

void beer(__kvx_x256 *);
// lambdas expressions
void Test256Lambda() {
  auto f1 = [](void *ptr) -> __kvx_x256 {
    __kvx_x256 *Vecp = (__kvx_x256 *)ptr;
    return *Vecp; // expected-error {{invalid use of KVX TCA type}}
  };
  auto f2 = [](void *ptr) {
    __kvx_x256 *Vecp = (__kvx_x256 *)ptr;
    return *Vecp; // expected-error {{invalid use of KVX TCA type}}
  };
  auto f3 = [](__kvx_x256) { __kvx_x256 Vec; beer(&Vec); return Vec; }; // expected-error {{invalid use of KVX TCA type}} expected-error {{invalid use of KVX TCA type}}
}

// cast
void Test256Cast() {
  __kvx_x256 Vec;
  int *ip = reinterpret_cast<int *>(&Vec);
  __kvx_x256 *Vec2 = reinterpret_cast<__kvx_x256 *>(ip);
}

// throw
void Test256Throw() {
  __kvx_x256 Vec;
  throw Vec; // expected-error {{invalid use of KVX TCA type}}
}
