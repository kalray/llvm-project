/*
 * Copyright (C) 2021 Kalray SA.
 *
 * All rights reserved.
 */
#include "kvxint_div.h"

KVXINT_TEMPLATE_UDIVMOD(32);

int32_t __modsi3(int32_t N, int32_t D) {
  int32_t remainder = kvxint_udivmod32(abs(N), abs(D)).remainder;

  if (N < 0) {
    remainder = -remainder;
  }

  return remainder;
}
