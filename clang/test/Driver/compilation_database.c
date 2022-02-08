// RUN: mkdir -p %t.workdir && cd %t.workdir
// RUN: %clang -MD -MP --sysroot=somewhere -S -x c %s -xc++ %s -Wall -MJ - -no-canonical-prefixes 2>&1 | FileCheck %s
// RUN: not %clang -S -x c %s -MJ %s/non-existant -no-canonical-prefixes 2>&1 | FileCheck --check-prefix=ERROR %s

// CHECK: { "directory": "{{[^"]*}}workdir",  "file": "[[SRC:[^"]+[/|\\]compilation_database.c]]", "output": "compilation_database.s", "arguments": ["{{[^"]*}}clang{{[^"]*}}", "-xc", "[[SRC]]", "--sysroot=somewhere", "-S", "-Wall",{{.*}} "--target={{[^"]+}}"]},
// CHECK: { "directory": "{{.*}}",  "file": "[[SRC:[^"]+[/|\\]compilation_database.c]]", "output": "compilation_database.s", "arguments": ["{{[^"]*}}clang{{[^"]*}}", "-xc++", "[[SRC]]", "--sysroot=somewhere", "-S", "-Wall",{{.*}} "--target={{[^"]+}}"]},
// ERROR: error: compilation database '{{.*}}/non-existant' could not be opened:

int main(void) {
  return 0;
}
