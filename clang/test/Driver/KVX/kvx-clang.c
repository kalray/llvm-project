// RUN: kvx-cos-clang -### -v -o /dev/null %s 2>&1 | FileCheck %s --check-prefix=COS -vv
// RUN: kvx-cos-clang++ -### -v -o /dev/null %s 2>&1 | FileCheck %s --check-prefix=COS -vv

// RUN: kvx-mbr-clang -### -v -o /dev/null %s 2>&1 | FileCheck %s --check-prefixes=MBR,CONF1 -vv
// RUN: kvx-mbr-clang++ -### -v -o /dev/null %s 2>&1 | FileCheck %s --check-prefixes=MBR,CONF1 -vv

// RUN: kvx-mbr-clang -### -mhal -v -o /dev/null %s 2>&1 | FileCheck %s --check-prefixes=MBR,FONC -vv
// RUN: kvx-mbr-clang++ -### -mhal -v -o /dev/null %s 2>&1 | FileCheck %s --check-prefixes=MBR,FONC -vv


// COS: Target: kvx-kalray-cos
// MBR: Target: kvx-kalray-mbr
// CONF1: {{.*}}__mppa_bare_runtime__{{.*}}
// FONC-NOT: __mppa_bare_runtime__

// COS: {{.*}}kvx-cos-as
// MBR: {{.*}}kvx-mbr-as

// COS: kvx-cos-ld
// MBR: kvx-mbr-ld
// CONF1-DAG:--defsym=exec_on_main=1
// CONF1-DAG:--defsym=mppa_bare_runtime=1
// FONC-NOT:--defsym=exec_on_main=1
// FONC-NOT:--defsym=mppa_bare_runtime=1
