/*
 * Copyright (C) 2021 Kalray SA.
 *
 * All rights reserved.
 */
#include "kvxint_div.h"

KVXINT_TEMPLATE_UDIVMOD(32);

int32_t __divsi3(int32_t N, int32_t D) {
  int32_t quotient = kvxint_udivmod32(abs(N), abs(D)).quotient;

  if ((N ^ D) < 0) {
    quotient = -quotient;
  }

  return quotient;
}
