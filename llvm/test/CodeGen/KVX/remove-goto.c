// RUN: clang -S %s -O1 -o - | FileCheck %s
// RUN: clang -S %s -O2 -o - | FileCheck %s

typedef struct list_data_s {
  short data16;
  short idx;
} list_data;

typedef struct list_head_s {
  struct list_head_s *next;
  struct list_data_s *info;
} list_head;

list_head *core_list_reverse(list_head *list) {
  list_head *next = 0, *tmp;
  while (list) {
    tmp = list->next;
    list->next = next;
    next = list;
    list = tmp;
  }
  return next;

  // CHECK: core_list_reverse
  // CHECK-NOT: goto
  // CHECK: ret
}
