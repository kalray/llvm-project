// RUN: clang -target kvx-cos -S %s -O2 -o - | FileCheck %s

void imm_imm_positive_bump(int *x) {
  for (int i = 0; i < 100; ++i)
    x[i] = i;
  // CHECK: imm_imm_positive_bump
  // CHECK: make
  // CHECK: loopdo
  // CHECK: ret
}

void imm_imm_negative_bump(int *x) {
  for (int i = 99; i >= 0; --i)
    x[i] = i;
  // CHECK: imm_imm_negative_bump
  // CHECK: make
  // CHECK: loopdo
  // ret
}

void imm_nonzero_reg_positive_bump(int *x, int n) {
  for (int i = 3; i < n; ++i)
    x[i] = i;
  // CHECK: imm_nonzero_reg_positive_bump
  // CHECK: loopdo
  // CHECK: ret
}

void imm_nonzero_reg_negative_bump(int *x, int n) {
  for (int i = 99; i >= n; --i)
    x[i] = i;
  // CHECK: imm_nonzero_reg_negative_bump
  // CHECK: sbfd
  // CHECK: loopdo
  // CHECK: ret
}

void imm_zero_reg_positive_bump(int *x, int n) {
  for (int i = 0; i < n; ++i)
    x[i] = i;
  // CHECK: imm_zero_reg_positive_bump
  // CHECK: loopdo
  // CHECK: ret
}

void imm_zero_reg_negative_bump(int *x, int n) {
  for (int i = 0; i >= n; --i)
    x[-i] = i;
  // CHECK: imm_zero_reg_negative_bump
  // CHECK: sbfd
  // CHECK: loopdo
  // CHECK: ret
}

void reg_imm_nonzero_negative_bump(int *x, int start) {
  for (int i = start; i >= 3; --i)
    x[i] = i;
  // CHECK: reg_imm_nonzero_negative_bump
  // CHECK: make
  // CHECK: sbfd
  // CHECK: loopdo
  // CHECK: ret
}

void reg_imm_nonzero_positive_bump(int *x, int start) {
  for (int i = start; i < 100; ++i)
    x[i] = i;
  // CHECK: reg_imm_nonzero_positive_bump
  // CHECK: sbfd
  // CHECK: loopdo
  // CHECK: ret
}

void reg_imm_zero_positive_bump(int *x, int start) {
  for (int i = start; i <= 0; ++i)
    x[-i] = i;
  // CHECK: reg_imm_zero_positive_bump
  // CHECK: negd
  // CHECK: loopdo
  // CHECK: ret
}

void reg_imm_zero_negative_bump(int *x, int start) {
  for (int i = start; i >= 0; --i)
    x[i] = i;
  // CHECK: reg_imm_zero_negative_bump
  // CHECK: loopdo
  // CHECK: ret
}

void reg_reg_positive_bump(int *x, int start, int end) {
  for (int i = start; i < end; ++i)
    x[i] = i;
  // CHECK: reg_reg_positive_bump
  // CHECK: sbfd
  // CHECK: loopdo
  // CHECK: ret
}

void reg_reg_negative_bump(int *x, int start, int end) {
  for (int i = start; i >= end; --i)
    x[i] = i;
  // CHECK: reg_reg_negative_bump
  // CHECK: sbfd
  // CHECK: loopdo
  // CHECK: ret
}
