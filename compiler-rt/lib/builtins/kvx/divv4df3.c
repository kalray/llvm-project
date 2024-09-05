#define FP_TYPE DOUBLE
#define FP_VECTOR_DEPTH 4

#include "divvxf.h"

define_divm3(rn);
define_divm3(ru);
define_divm3(rd);
define_divm3(rz);
define_selector;

fp_mode __divm3(fp_mode a, fp_mode b);
fp_mode __divm3(fp_mode a, fp_mode b) { return selector[get_round()](a, b); }
