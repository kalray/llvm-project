// RUN: clang -target kvx-cos -S -O2 %s -o - | FileCheck %s

// Derived from llvm-test-suite's MultiSource/Applications/Burg.

struct list {
  void *x;
  struct list *next;
};

typedef struct list *List;

typedef void *(*ListFn)(void *);

void reveachList(f, l) ListFn f;
List l;
{
  if (!l)
    return;
  reveachList(f, l->next);
  (*f)(l->x);
  // CHECK: call reveachList
  // CHECK: copyd [[REGNAME:\$r[0-9]+]] = {{\$r[0-9]+}}
  // CHECK: igoto [[REGNAME]]
}
