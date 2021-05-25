/*
 * Copyright (C) 2021 Kalray SA.
 *
 * All rights reserved.
 */
#include "kvxint_div.h"

KVXINT_TEMPLATE_UDIVMOD(64);

int64_t __divdi3(int64_t N, int64_t D) {
  int64_t quotient = kvxint_udivmod64(abs(N), abs(D)).quotient;

  if ((N ^ D) < 0) {
    quotient = -quotient;
  }

  return quotient;
}
