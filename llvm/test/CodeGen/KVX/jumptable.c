// RUN: clang -target kvx-cos -O2 -S %s -o - | FileCheck %s -check-prefix=NOPIC
// RUN: clang -target kvx-cos -O2 -fPIC -S %s -o - | FileCheck %s -check-prefix=PIC

void f(int *x, int state) {
  switch (state) {
  case 0:
    x[0]++;
    break;
  case 1:
    x[1] += 2;
    break;
  case 2:
    x[2] += 3;
    break;
  case 3:
    x[3] += 4;
    break;
  case 4:
    x[4] += 5;
    break;
  case 5:
    x[5] += 6;
    break;
  case 6:
    x[6] += 7;
    break;
  case 7:
    x[7] += 8;
    break;
  case 8:
    x[8] += 9;
    break;
  }
  // NOPIC-LABEL: f
  // NOPIC-NOT: pcrel
  // NOPIC: igoto
  // NOPIC: ret
  // NOPIC-COUNT-1: {{\.LJTI[0-9]+_[0_9]+}}

  // PIC-LABEL: f
  // PIC: pcrel
  // PIC: igoto
  // PIC: ret
  // PIC-COUNT-10: {{\.LJTI[0-9]+_[0-9]+}}
}
