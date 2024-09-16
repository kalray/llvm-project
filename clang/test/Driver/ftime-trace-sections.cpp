// FIXME: Find out why in kvx the larger event names (e.g. InstantiateFunction) are not printed
// XFAIL: target=kvx-{{.*}}
// RUN: rm -rf %t && mkdir %t && cd %t
// RUN: %clangxx -S -ftime-trace -ftime-trace-granularity=0 -ftime-trace-verbose -o out %s
// RUN: %python %S/ftime-trace-sections.py < out.json

template <typename T>
void foo(T) {}
void bar() { foo(0); }
