/*
 * Copyright (C) 2021 Kalray SA.
 *
 * All rights reserved.
 */
#ifndef RTLIB_KVX_KVXINT_DIV_H
#define RTLIB_KVX_KVXINT_DIV_H

#include "kvxint.h"

#ifdef __linux__
#include <signal.h>
#include <sys/syscall.h>
#include <unistd.h>
#endif

static inline int kvxint_div0(void) {
  /* This weak symbol makes it possible to return
   * zeros for divmod when the denominator is 0.
   * The default behavior makes the application crashes.
   * One usage of this feature would be the OpenCL-C division
   * where the result should be undefined instead of crashing
   * the user application.
   */
  extern void _KVX_DIVMOD_ZERO_RETURN_ZERO __attribute__((weak));

  if (&_KVX_DIVMOD_ZERO_RETURN_ZERO) {
    return 0;
  }
  /* Waiting for Linux green light to support
   * division by zero with SIGFPE */
#if 0
  siginfo_t uinfo = {
      .si_code = FPE_INTDIV,
      .si_pid = getpid(),
      .si_uid = getuid(),
  };

  syscall(rt_sigqueueinfo, uinfo.si_pid, SIGFPE, &uinfo);
  /* The syscall can fail (eg. queue is full),
   * fallthrough ensures we raise something */
#endif
  __builtin_kvx_errop();
  __builtin_unreachable();
}

/*
 * This division template is based upon the TMS320C6000 division algorithm.
 * Its complexity is of O(n) where n is clz(denominator) - clz(numerator),
 * which becomes a very costly operations on some 64-bits divisions.
 * NOTE: Comparing benchmarks with compiler-rt's generic code,
 * there is room for improvements on these worst cases. Compiler-rt uses
 * an implementation adapted from PowerPC Compiler writer's guide.
 */
#define KVXINT_TEMPLATE_UDIVMOD(n)                                             \
  struct kvxint_quotient_remainder##n {                                        \
    uint##n##_t quotient, remainder;                                           \
  };                                                                           \
                                                                               \
  static inline struct kvxint_quotient_remainder##n kvxint_udivmod##n(         \
      uint##n##_t N, uint##n##_t D) {                                          \
    uint##n##_t Q, R;                                                          \
                                                                               \
    if (D != 0) {                                                              \
      Q = 0;                                                                   \
      R = N;                                                                   \
                                                                               \
      if (D <= N) { /* Else, Q is zero, R is N */                              \
        const unsigned shift = clz(D) - clz(N);                                \
                                                                               \
        D <<= shift;                                                           \
                                                                               \
        if (R >= D) {                                                          \
          R -= D;                                                              \
          Q = UINT##n##_C(1) << shift;                                         \
        }                                                                      \
                                                                               \
        if (shift != 0) {                                                      \
          const uint##n##_t mask = (UINT##n##_C(1) << shift) - 1;              \
          unsigned i = shift;                                                  \
                                                                               \
          D >>= 1;                                                             \
                                                                               \
          do {                                                                 \
            R = stsu(D, R);                                                    \
            i--;                                                               \
          } while (i != 0);                                                    \
                                                                               \
          Q += R & mask;                                                       \
          R >>= shift;                                                         \
        }                                                                      \
      }                                                                        \
    } else {                                                                   \
      Q = kvxint_div0();                                                       \
      R = 0;                                                                   \
    }                                                                          \
                                                                               \
    return (struct kvxint_quotient_remainder##n){.quotient = Q,                \
                                                 .remainder = R};              \
  }

/* RTLIB_KVX_KVXINT_DIV_H */
#endif
