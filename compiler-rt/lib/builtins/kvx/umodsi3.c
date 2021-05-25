/*
 * Copyright (C) 2021 Kalray SA.
 *
 * All rights reserved.
 */
#include "kvxint_div.h"

KVXINT_TEMPLATE_UDIVMOD(32);

uint32_t __umodsi3(uint32_t N, uint32_t D) {
  return kvxint_udivmod32(N, D).remainder;
}
