/*
 * Copyright (C) 2021 Kalray SA.
 *
 * All rights reserved.
 */
#include "kvxint_div.h"

KVXINT_TEMPLATE_UDIVMOD(64);

int64_t __moddi3(int64_t N, int64_t D) {
  int64_t remainder = kvxint_udivmod64(abs(N), abs(D)).remainder;

  if (N < 0) {
    remainder = -remainder;
  }

  return remainder;
}
