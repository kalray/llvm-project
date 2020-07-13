// RUN: clang -target kvx-cos -S -O1 %s -o - | FileCheck %s

// The test ensures no regressions of useless zero_extend generation (see
// T12472).

typedef int size_t;

int __strncmp(const char *s1, const char *s2, size_t n) {
  if (n == 0)
    return 0;
  while (n-- != 0 && *s1 == *s2) {
    if (n == 0 || *s1 == '\0')
      break;
    s1++;
    s2++;
  }
  return (*(unsigned char *)s1) - (*(unsigned char *)s2);
}

// CHECK-NOT: zxbd
