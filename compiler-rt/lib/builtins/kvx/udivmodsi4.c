/*
 * Copyright (C) 2021 Kalray SA.
 *
 * All rights reserved.
 */
#include "kvxint_div.h"

KVXINT_TEMPLATE_UDIVMOD(32);

uint32_t __udivmodsi4(uint32_t N, uint32_t D, uint32_t *Rp) {
  const struct kvxint_quotient_remainder32 retval = kvxint_udivmod32(N, D);

  if (Rp != NULL) {
    *Rp = retval.remainder;
  }

  return retval.quotient;
}
