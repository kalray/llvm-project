// RUN: clang --target=kvx-cos -S %s -O0 -g3 -o - | FileCheck %s

int other(int *, int *);

int noalign(int n, int n2, int n3) {
  int c = 7;
  int i = 1234;
  i -= n;
  i += n2;
  i *= n3;
  return other(&c, &i);
  // CHECK-LABEL: noalign:
  // CHECK: addd $r12 = $r12, -32
  // CHECK-NEXT: ;;
  // CHECK-NEXT: .cfi_def_cfa_offset 32
  // CHECK-NEXT: get $r16 = $ra
  // CHECK-NEXT: ;;
  // CHECK-NEXT: sd 0[$r12] = $r16
  // CHECK-NEXT: ;;
  // CHECK-NEXT: .cfi_offset 67, -32
  // CHECK: addd $r12 = $r12, 32
  // CHECK-NEXT: ;;
  // CHECK-NEXT: .cfi_def_cfa_offset 0
  // CHECK: ret
}

typedef int more_aligned_int __attribute__((aligned(128)));

int other1(int *, more_aligned_int *);

int stackrealign1(int n, int n2, int n3) {
  int c = 7;
  more_aligned_int i = 1234;
  i -= n;
  i += n2;
  i *= n3;
  return other1(&c, &i);
  // CHECK-LABEL: stackrealign1:
  // CHECK: addd $r12 = $r12, -384
  // CHECK-NEXT: ;;
  // CHECK-NEXT: .cfi_def_cfa_offset 384
  // CHECK-NEXT: copyd $r32 = $r12
  // CHECK-NEXT: ;;
  // CHECK-NEXT: .cfi_def_cfa_register 32
  // CHECK: sd 8[$r12] = $r16
  // CHECK-NEXT: ;;
  // CHECK-NEXT: .cfi_escape 0x10, 0x43, 0x02, 0x7c, 0x08
  // CHECK-NEXT: sd 0[$r12] = $r14
  // CHECK-NEXT: ;;
  // CHECK-NEXT: .cfi_escape 0x10, 0x0e, 0x02, 0x7c, 0x00
  // CHECK-NEXT: copyd $r14 = $r32
  // CHECK-NEXT: ;;
  // CHECK-NEXT: .cfi_def_cfa_register 14
  // CHECK: copyd $r32 = $r14
  // CHECK-NEXT: ;;
  // CHECK-NEXT: .cfi_def_cfa_register 32
  // CHECK: set $ra = $r16
  // CHECK-NEXT: ;;
  // CHECK-NEXT: .cfi_restore 67
  // CHECK: copyd $r12 = $r32
  // CHECK-NEXT: ;;
  // CHECK-NEXT: .cfi_def_cfa_register 12
  // CHECK: ret
}

int other2(int *, int, more_aligned_int *);

int stackrealign2(int n) {
  int *av = (int *)alloca(sizeof(int) * n);
  for (int j = 0; j < n; j++)
    av[j] = n - j;
  more_aligned_int i = 1234;
  return other2(av, n, &i);
  // CHECK-LABEL: stackrealign2:
  // CHECK: addd $r12 = $r12, -384
  // CHECK-NEXT: ;;
  // CHECK-NEXT: .cfi_def_cfa_offset 384
  // CHECK-NEXT: copyd $r32 = $r12
  // CHECK-NEXT: ;;
  // CHECK-NEXT: .cfi_def_cfa_register 32
  // CHECK: copyd $r33 = $r14
  // CHECK-NEXT: ;;
  // CHECK-NEXT: copyd $r14 = $r12
  // CHECK-NEXT: ;;
  // CHECK: sd 16[$r12] = $r16
  // CHECK-NEXT: ;;
  // CHECK-NEXT: .cfi_escape 0x10, 0x43, 0x02, 0x7e, 0x10
  // CHECK-NEXT: sd 8[$r12] = $r33
  // CHECK-NEXT: ;;
  // CHECK-NEXT: .cfi_escape 0x10, 0x0e, 0x02, 0x7e, 0x08
  // CHECK_NEXT: ;;
  // CHECK-NEXT: sd 0[$r12] = $r31
  // CHECK-NEXT: ;;
  // CHECK-NEXT: .cfi_escape 0x10, 0x1f, 0x02, 0x7e, 0x00
  // CHECK-NEXT: copyd $r31 = $r32
  // CHECK-NEXT: ;;
  // CHECK-NEXT: .cfi_def_cfa_register 31
  // CHECK: copyd $r32 = $r31
  // CHECK-NEXT: ;;
  // CHECK-NEXT: .cfi_def_cfa_register 32
  // CHECK: set $ra = $r16
  // CHECK-NEXT: ;;
  // CHECK-NEXT: .cfi_restore 67
  // CHECK-NEXT: ld $r14 = 8[$r12]
  // CHECK-NEXT: ;;
  // CHECK-NEXT: copyd $r12 = $r32
  // CHECK-NEXT: ;;
  // CHECK-NEXT: .cfi_def_cfa_register 12
  // CHECK: ret
}

int other4(int *, int, int *);

int teststackalloca(int n) {
  int *av = (int *)alloca(sizeof(int) * n);
  for (int j = 0; j < n; j++)
    av[j] = n - j;
  int i = 1234;
  return other4(av, n, &i);
  // CHECK-LABEL: teststackalloca:
  // CHECK: addd $r12 = $r12, -64
  // CHECK-NEXT: ;;
  // CHECK-NEXT: .cfi_def_cfa_offset 64
  // CHECK: copyd $r14 = $r12
  // CHECK-NEXT: ;;
  // CHECK-NEXT: .cfi_def_cfa_register 14
  // CHECK: copyd $r12 = $r14
  // CHECK-NEXT: ;;
  // CHECK-NEXT: .cfi_def_cfa_register 12
  // CHECK: ret
}
