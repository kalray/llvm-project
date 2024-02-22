// RUN: %clang_cc1 -triple kvx-kalray-cos -emit-llvm -disable-free -disable-llvm-verifier -o - %s | FileCheck %s
struct B {
  int i,j;
  B (const int I, const int J) : i(I), j(J) {}
  B (const B& x) : i(x.i), j(1) {};  // copy ctor
};

// See that v0 passed as pointer
// CHECK: void @_Z7test_it1B(ptr noundef %v0)
void test_it(B v0){
    B x = (B&&)v0;
}

// See that a copy of iii is passed in the stack
int main() {
    B iii = {1,2};
    test_it(iii);
}
// CHECK: iii = alloca %struct.B, align 4
// CHECK-NEXT: agg.tmp = alloca %struct.B, align 4
// CHECK-NEXT: call void @_ZN1BC1Eii(ptr noundef nonnull align 4 dereferenceable(8) %iii, i32 noundef 1, i32 noundef 2)
// CHECK-NEXT: call void @_ZN1BC1ERKS_(ptr noundef nonnull align 4 dereferenceable(8) %agg.tmp, ptr noundef nonnull align 4 dereferenceable(8) %iii)
// CHECK-NEXT: call void @_Z7test_it1B(ptr noundef %agg.tmp)
