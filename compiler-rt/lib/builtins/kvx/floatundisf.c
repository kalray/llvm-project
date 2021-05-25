/*
 * Copyright (C) 2021 Kalray SA.
 *
 * All rights reserved.
 */
#include "../int_lib.h"

COMPILER_RT_ABI float __floatundisf(du_int a) { return (double)a; }
