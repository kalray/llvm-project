/*
 * Copyright (C) 2021 Kalray SA.
 *
 * All rights reserved.
 */
#include "kvxint_div.h"

KVXINT_TEMPLATE_UDIVMOD(64);

uint64_t __udivdi3(uint64_t N, uint64_t D) {
  return kvxint_udivmod64(N, D).quotient;
}
