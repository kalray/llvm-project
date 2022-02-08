// T18088
// RUN: %clang -target x86_64 -Werror -fobjc-arc -fobjc-arc-exceptions -fno-objc-arc -Xclang -verify -c -o /dev/null %s
// expected-no-diagnostics
