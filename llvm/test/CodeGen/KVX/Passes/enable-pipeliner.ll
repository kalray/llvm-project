; RUN: llc -mtriple=kvx -O2 -enable-kvx-pipeliner -debug-pass=Structure %s -o /dev/null 2>&1 | grep -v "Verify generated machine code" | FileCheck %s --check-prefix=ENABLE
; RUN: llc -mtriple=kvx -O3 -disable-kvx-pipeliner -debug-pass=Structure %s -o /dev/null 2>&1 | grep -v "Verify generated machine code" | FileCheck %s --check-prefix=DISABLE

; ENABLE: Modulo Software Pipelining
; DISABLE-NOT: Modulo Software Pipelining
