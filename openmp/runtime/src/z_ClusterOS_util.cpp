/*
 * z_ClusterOS_util.cpp -- platform specific routines.
 * Comes from z_Linux_util.cpp
 */

//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "kmp.h"
#include "kmp_wait_release.h"
#include "kmp_wrapper_getpid.h"

#include <sys/time.h>
#include <sys/times.h>

struct kmp_sys_timer {
  struct timespec start;
};

// Convert timespec to nanoseconds.
#define TS2NS(timespec)                                                        \
  (((timespec).tv_sec * (long int)1e9) + (timespec).tv_nsec)

static struct kmp_sys_timer __kmp_sys_timer_data;

#if KMP_HANDLE_SIGNALS
typedef void (*sig_func_t)(int);
STATIC_EFI2_WORKAROUND struct sigaction __kmp_sighldrs[NSIG];
static sigset_t __kmp_sigset;
#endif

static int __kmp_init_runtime = FALSE;

static int __kmp_fork_count = 0;

static pthread_condattr_t __kmp_suspend_cond_attr;
static pthread_mutexattr_t __kmp_suspend_mutex_attr;

static kmp_cond_align_t __kmp_wait_cv;
static kmp_mutex_align_t __kmp_wait_mx;

kmp_uint64 __kmp_ticks_per_msec = 1000000;

#ifdef DEBUG_SUSPEND
static void __kmp_print_cond(char *buffer, kmp_cond_align_t *cond) {
  KMP_SNPRINTF(buffer, 128, "(cond (lock (%ld, %d)), (descr (%p)))",
               cond->c_cond.__c_lock.__status, cond->c_cond.__c_lock.__spinlock,
               cond->c_cond.__c_waiting);
}
#endif


/* Set thread stack info according to values returned by pthread_getattr_np().
   If values are unreasonable, assume call failed and use incremental stack
   refinement method instead. Returns TRUE if the stack parameters could be
   determined exactly, FALSE if incremental refinement is necessary. */
static kmp_int32 __kmp_set_stack_info(int gtid, kmp_info_t *th) {
  int stack_data;
  /* Use incremental refinement starting from initial conservative estimate */
  TCW_PTR(th->th.th_info.ds.ds_stacksize, 0);
  TCW_PTR(th->th.th_info.ds.ds_stackbase, &stack_data);
  TCW_4(th->th.th_info.ds.ds_stackgrow, TRUE);
  return FALSE;
}

static void *__kmp_launch_worker(void *thr) {
  void *volatile padding = 0;
  int gtid;

  gtid = ((kmp_info_t *)thr)->th.th_info.ds.ds_gtid;
  __kmp_gtid_set_specific(gtid);
#ifdef KMP_TDATA_GTID
  __kmp_gtid = gtid;
#endif

  if (__kmp_stkoffset > 0 && gtid > 0) {
    padding = KMP_ALLOCA(gtid * __kmp_stkoffset);
  }

  KMP_MB();
  __kmp_set_stack_info(gtid, (kmp_info_t *)thr);

  __kmp_check_stack_overlap((kmp_info_t *)thr);

  return __kmp_launch_thread((kmp_info_t *)thr);
}

void __kmp_create_worker(int gtid, kmp_info_t *th, size_t stack_size) {
  pthread_t handle;
  pthread_attr_t thread_attr;
  int status;

  th->th.th_info.ds.ds_gtid = gtid;

  if (KMP_UBER_GTID(gtid)) {
    KA_TRACE(10, ("__kmp_create_worker: uber thread (%d)\n", gtid));
    th->th.th_info.ds.ds_thread = pthread_self();
    __kmp_set_stack_info(gtid, th);
    __kmp_check_stack_overlap(th);
    return;
  }

  KA_TRACE(10, ("__kmp_create_worker: try to create thread (%d)\n", gtid));

  KMP_MB(); /* Flush all pending memory write invalidates.  */

#ifdef KMP_THREAD_ATTR
  status = pthread_attr_init(&thread_attr);
  if (status != 0)
    __kmp_fatal(KMP_MSG(CantInitThreadAttrs), KMP_ERR(status), __kmp_msg_null);

  status = pthread_attr_setdetachstate(&thread_attr, PTHREAD_CREATE_JOINABLE);
  if (status != 0)
    __kmp_fatal(KMP_MSG(CantSetWorkerState), KMP_ERR(status), __kmp_msg_null);

  /* Set stack size for this thread now.
     The multiple of 2 is there because on some machines, requesting an unusual
     stacksize causes the thread to have an offset before the dummy alloca()
     takes place to create the offset.  Since we want the user to have a
     sufficient stacksize AND support a stack offset, we alloca() twice the
     offset so that the upcoming alloca() does not eliminate any premade offset,
     and also gives the user the stack space they requested for all threads */
  stack_size += gtid * __kmp_stkoffset * 2;

  KA_TRACE(10, ("__kmp_create_worker: T#%d, default stacksize = %lu bytes, "
                "__kmp_stksize = %lu bytes, final stacksize = %lu bytes\n",
                gtid, KMP_DEFAULT_STKSIZE, __kmp_stksize, stack_size));

  status = pthread_attr_setstacksize(&thread_attr, stack_size);
#ifdef KMP_BACKUP_STKSIZE
  if (status != 0) {
    if (!__kmp_env_stksize) {
      stack_size = KMP_BACKUP_STKSIZE + gtid * __kmp_stkoffset;
      __kmp_stksize = KMP_BACKUP_STKSIZE;
      KA_TRACE(10, ("__kmp_create_worker: T#%d, default stacksize = %lu bytes, "
                    "__kmp_stksize = %lu bytes, (backup) final stacksize = %lu "
                    "bytes\n",
                    gtid, KMP_DEFAULT_STKSIZE, __kmp_stksize, stack_size));
      status = pthread_attr_setstacksize(&thread_attr, stack_size);
    }
  }
#endif /* KMP_BACKUP_STKSIZE */
  if (status != 0)
    __kmp_fatal(KMP_MSG(CantSetWorkerStackSize, stack_size), KMP_ERR(status),
                KMP_HNT(ChangeWorkerStackSize), __kmp_msg_null);
#endif /* KMP_THREAD_ATTR */

  status =
      pthread_create(&handle, &thread_attr, __kmp_launch_worker, (void *)th);
  if (status != 0 || !handle) { // ??? Why do we check handle??
    if (status == EINVAL) {
      __kmp_fatal(KMP_MSG(CantSetWorkerStackSize, stack_size), KMP_ERR(status),
                  KMP_HNT(IncreaseWorkerStackSize), __kmp_msg_null);
    }
    if (status == ENOMEM) {
      __kmp_fatal(KMP_MSG(CantSetWorkerStackSize, stack_size), KMP_ERR(status),
                  KMP_HNT(DecreaseWorkerStackSize), __kmp_msg_null);
    }
    if (status == EAGAIN) {
      __kmp_fatal(KMP_MSG(NoResourcesForWorkerThread), KMP_ERR(status),
                  KMP_HNT(Decrease_NUM_THREADS), __kmp_msg_null);
    }
    KMP_SYSFAIL("pthread_create", status);
  }

  th->th.th_info.ds.ds_thread = handle;

#ifdef KMP_THREAD_ATTR
  status = pthread_attr_destroy(&thread_attr);
  if (status) {
    kmp_msg_t err_code = KMP_ERR(status);
    __kmp_msg(kmp_ms_warning, KMP_MSG(CantDestroyThreadAttrs), err_code,
              __kmp_msg_null);
    if (__kmp_generate_warnings == kmp_warnings_off) {
      __kmp_str_free(&err_code.str);
    }
  }
#endif /* KMP_THREAD_ATTR */

  KMP_MB(); /* Flush all pending memory write invalidates.  */

  KA_TRACE(10, ("__kmp_create_worker: done creating thread (%d)\n", gtid));

} // __kmp_create_worker

void __kmp_exit_thread(int exit_status) {
  pthread_exit((void *)(intptr_t)exit_status);
} // __kmp_exit_thread

void __kmp_reap_worker(kmp_info_t *th) {
  void *exit_val;

  KMP_MB(); /* Flush all pending memory write invalidates.  */

  KA_TRACE(
      10, ("__kmp_reap_worker: try to reap T#%d\n", th->th.th_info.ds.ds_gtid));

#ifdef KMP_DEBUG
  int status = pthread_join(th->th.th_info.ds.ds_thread, &exit_val);
  /* Don't expose these to the user until we understand when they trigger */
  if (status != 0) {
    __kmp_fatal(KMP_MSG(ReapWorkerError), KMP_ERR(status), __kmp_msg_null);
  }
  if (exit_val != th) {
    KA_TRACE(10, ("__kmp_reap_worker: worker T#%d did not reap properly, "
                  "exit_val = %p\n",
                  th->th.th_info.ds.ds_gtid, exit_val));
  }
#else
  pthread_join(th->th.th_info.ds.ds_thread, &exit_val);
#endif /* KMP_DEBUG */

  KA_TRACE(10, ("__kmp_reap_worker: done reaping T#%d\n",
                th->th.th_info.ds.ds_gtid));

  KMP_MB(); /* Flush all pending memory write invalidates.  */
}

#if KMP_HANDLE_SIGNALS

static void __kmp_null_handler(int signo) {
  //  Do nothing, for doing SIG_IGN-type actions.
} // __kmp_null_handler

static void __kmp_team_handler(int signo) {
  if (__kmp_global.g.g_abort == 0) {
/* Stage 1 signal handler, let's shut down all of the threads */
#ifdef KMP_DEBUG
    __kmp_debug_printf("__kmp_team_handler: caught signal = %d\n", signo);
#endif
    switch (signo) {
    case SIGHUP:
    case SIGINT:
    case SIGQUIT:
    case SIGILL:
    case SIGABRT:
    case SIGFPE:
    case SIGBUS:
    case SIGSEGV:
#ifdef SIGSYS
    case SIGSYS:
#endif
    case SIGTERM:
      if (__kmp_debug_buf) {
        __kmp_dump_debug_buffer();
      }
      __kmp_unregister_library(); // cleanup shared memory
      KMP_MB(); // Flush all pending memory write invalidates.
      TCW_4(__kmp_global.g.g_abort, signo);
      KMP_MB(); // Flush all pending memory write invalidates.
      TCW_4(__kmp_global.g.g_done, TRUE);
      KMP_MB(); // Flush all pending memory write invalidates.
      break;
    default:
#ifdef KMP_DEBUG
      __kmp_debug_printf("__kmp_team_handler: unknown signal type");
#endif
      break;
    }
  }
} // __kmp_team_handler

static void __kmp_sigaction(int signum, const struct sigaction *act,
                            struct sigaction *oldact) {
  int rc = sigaction(signum, act, oldact);
  KMP_CHECK_SYSFAIL_ERRNO("sigaction", rc);
}

static void __kmp_install_one_handler(int sig, sig_func_t handler_func,
                                      int parallel_init) {
  KMP_MB(); // Flush all pending memory write invalidates.
  KB_TRACE(60,
           ("__kmp_install_one_handler( %d, ..., %d )\n", sig, parallel_init));
  if (parallel_init) {
    struct sigaction new_action;
    struct sigaction old_action;
    new_action.sa_handler = handler_func;
    new_action.sa_flags = 0;
    sigfillset(&new_action.sa_mask);
    __kmp_sigaction(sig, &new_action, &old_action);
    if (old_action.sa_handler == __kmp_sighldrs[sig].sa_handler) {
      sigaddset(&__kmp_sigset, sig);
    } else {
      // Restore/keep user's handler if one previously installed.
      __kmp_sigaction(sig, &old_action, NULL);
    }
  } else {
    // Save initial/system signal handlers to see if user handlers installed.
    __kmp_sigaction(sig, NULL, &__kmp_sighldrs[sig]);
  }
  KMP_MB(); // Flush all pending memory write invalidates.
} // __kmp_install_one_handler

static void __kmp_remove_one_handler(int sig) {
  KB_TRACE(60, ("__kmp_remove_one_handler( %d )\n", sig));
  if (sigismember(&__kmp_sigset, sig)) {
    struct sigaction old;
    KMP_MB(); // Flush all pending memory write invalidates.
    __kmp_sigaction(sig, &__kmp_sighldrs[sig], &old);
    if ((old.sa_handler != __kmp_team_handler) &&
        (old.sa_handler != __kmp_null_handler)) {
      // Restore the users signal handler.
      KB_TRACE(10, ("__kmp_remove_one_handler: oops, not our handler, "
                    "restoring: sig=%d\n",
                    sig));
      __kmp_sigaction(sig, &old, NULL);
    }
    sigdelset(&__kmp_sigset, sig);
    KMP_MB(); // Flush all pending memory write invalidates.
  }
} // __kmp_remove_one_handler

void __kmp_install_signals(int parallel_init) {
  KB_TRACE(10, ("__kmp_install_signals( %d )\n", parallel_init));
  if (__kmp_handle_signals || !parallel_init) {
    // If ! parallel_init, we do not install handlers, just save original
    // handlers. Let us do it even __handle_signals is 0.
    sigemptyset(&__kmp_sigset);
    __kmp_install_one_handler(SIGHUP, __kmp_team_handler, parallel_init);
    __kmp_install_one_handler(SIGINT, __kmp_team_handler, parallel_init);
    __kmp_install_one_handler(SIGQUIT, __kmp_team_handler, parallel_init);
    __kmp_install_one_handler(SIGILL, __kmp_team_handler, parallel_init);
    __kmp_install_one_handler(SIGABRT, __kmp_team_handler, parallel_init);
    __kmp_install_one_handler(SIGFPE, __kmp_team_handler, parallel_init);
    __kmp_install_one_handler(SIGBUS, __kmp_team_handler, parallel_init);
    __kmp_install_one_handler(SIGSEGV, __kmp_team_handler, parallel_init);
#ifdef SIGSYS
    __kmp_install_one_handler(SIGSYS, __kmp_team_handler, parallel_init);
#endif // SIGSYS
    __kmp_install_one_handler(SIGTERM, __kmp_team_handler, parallel_init);
#ifdef SIGPIPE
    __kmp_install_one_handler(SIGPIPE, __kmp_team_handler, parallel_init);
#endif // SIGPIPE
  }
} // __kmp_install_signals

void __kmp_remove_signals(void) {
  int sig;
  KB_TRACE(10, ("__kmp_remove_signals()\n"));
  for (sig = 1; sig < NSIG; ++sig) {
    __kmp_remove_one_handler(sig);
  }
} // __kmp_remove_signals

#endif // KMP_HANDLE_SIGNALS

void __kmp_enable(int new_state) {
  int status, old_state;
  status = pthread_setcancelstate(new_state, &old_state);
  KMP_CHECK_SYSFAIL("pthread_setcancelstate", status);
  KMP_DEBUG_ASSERT(old_state == PTHREAD_CANCEL_DISABLE);
}

void __kmp_disable(int *old_state) {
  int status;
  status = pthread_setcancelstate(PTHREAD_CANCEL_DISABLE, old_state);
  KMP_CHECK_SYSFAIL("pthread_setcancelstate", status);
}

void __kmp_suspend_initialize(void) {
  int status;
  status = pthread_mutexattr_init(&__kmp_suspend_mutex_attr);
  KMP_CHECK_SYSFAIL("pthread_mutexattr_init", status);
  status = pthread_condattr_init(&__kmp_suspend_cond_attr);
  KMP_CHECK_SYSFAIL("pthread_condattr_init", status);
}

void __kmp_suspend_initialize_thread(kmp_info_t *th) {
  int old_value = KMP_ATOMIC_LD_RLX(&th->th.th_suspend_init_count);
  int new_value = __kmp_fork_count + 1;
  // Return if already initialized
  if (old_value == new_value)
    return;
  // Wait, then return if being initialized
  if (old_value == -1 || !__kmp_atomic_compare_store(
                             &th->th.th_suspend_init_count, old_value, -1)) {
    while (KMP_ATOMIC_LD_ACQ(&th->th.th_suspend_init_count) != new_value) {
      KMP_CPU_PAUSE();
    }
  } else {
    // Claim to be the initializer and do initializations
    int status;
    status = pthread_cond_init(&th->th.th_suspend_cv.c_cond,
                               &__kmp_suspend_cond_attr);
    KMP_CHECK_SYSFAIL("pthread_cond_init", status);
    status = pthread_mutex_init(&th->th.th_suspend_mx.m_mutex,
                                &__kmp_suspend_mutex_attr);
    KMP_CHECK_SYSFAIL("pthread_mutex_init", status);
    KMP_ATOMIC_ST_REL(&th->th.th_suspend_init_count, new_value);
  }
}

void __kmp_suspend_uninitialize_thread(kmp_info_t *th) {
  if (KMP_ATOMIC_LD_ACQ(&th->th.th_suspend_init_count) > __kmp_fork_count) {
    /* this means we have initialize the suspension pthread objects for this
       thread in this instance of the process */
    int status;

    status = pthread_cond_destroy(&th->th.th_suspend_cv.c_cond);
    if (status != 0 && status != EBUSY) {
      KMP_SYSFAIL("pthread_cond_destroy", status);
    }
    status = pthread_mutex_destroy(&th->th.th_suspend_mx.m_mutex);
    if (status != 0 && status != EBUSY) {
      KMP_SYSFAIL("pthread_mutex_destroy", status);
    }
    --th->th.th_suspend_init_count;
    KMP_DEBUG_ASSERT(KMP_ATOMIC_LD_RLX(&th->th.th_suspend_init_count) ==
                     __kmp_fork_count);
  }
}

// return true if lock obtained, false otherwise
int __kmp_try_suspend_mx(kmp_info_t *th) {
  return (pthread_mutex_trylock(&th->th.th_suspend_mx.m_mutex) == 0);
}

void __kmp_lock_suspend_mx(kmp_info_t *th) {
  int status = pthread_mutex_lock(&th->th.th_suspend_mx.m_mutex);
  KMP_CHECK_SYSFAIL("pthread_mutex_lock", status);
}

void __kmp_unlock_suspend_mx(kmp_info_t *th) {
  int status = pthread_mutex_unlock(&th->th.th_suspend_mx.m_mutex);
  KMP_CHECK_SYSFAIL("pthread_mutex_unlock", status);
}

/* This routine puts the calling thread to sleep after setting the
   sleep bit for the indicated flag variable to true. */
template <class C>
static inline void __kmp_suspend_template(int th_gtid, C *flag) {
  KMP_TIME_DEVELOPER_PARTITIONED_BLOCK(USER_suspend);
  kmp_info_t *th = __kmp_threads[th_gtid];
  int status;
  typename C::flag_t old_spin;

  KF_TRACE(30, ("__kmp_suspend_template: T#%d enter for flag = %p\n", th_gtid,
                flag->get()));

  __kmp_suspend_initialize_thread(th);

  __kmp_lock_suspend_mx(th);

  KF_TRACE(10, ("__kmp_suspend_template: T#%d setting sleep bit for spin(%p)\n",
                th_gtid, flag->get()));

  /* TODO: shouldn't this use release semantics to ensure that
     __kmp_suspend_initialize_thread gets called first? */
  old_spin = flag->set_sleeping();
  TCW_PTR(th->th.th_sleep_loc, (void *)flag);
  th->th.th_sleep_loc_type = flag->get_type();
  if (__kmp_dflt_blocktime == KMP_MAX_BLOCKTIME &&
      __kmp_pause_status != kmp_soft_paused) {
    flag->unset_sleeping();
    TCW_PTR(th->th.th_sleep_loc, NULL);
    th->th.th_sleep_loc_type = flag_unset;
    __kmp_unlock_suspend_mx(th);
    return;
  }
  KF_TRACE(5, ("__kmp_suspend_template: T#%d set sleep bit for spin(%p)==%x,"
               " was %x\n",
               th_gtid, flag->get(), flag->load(), old_spin));

  if (flag->done_check_val(old_spin) || flag->done_check()) {
    flag->unset_sleeping();
    TCW_PTR(th->th.th_sleep_loc, NULL);
    th->th.th_sleep_loc_type = flag_unset;
    KF_TRACE(5, ("__kmp_suspend_template: T#%d false alarm, reset sleep bit "
                 "for spin(%p)\n",
                 th_gtid, flag->get()));
  } else {
    /* Encapsulate in a loop as the documentation states that this may
       "with low probability" return when the condition variable has
       not been signaled or broadcast */
    int deactivated = FALSE;

    while (flag->is_sleeping()) {
#ifdef DEBUG_SUSPEND
      char buffer[128];
      __kmp_suspend_count++;
      __kmp_print_cond(buffer, &th->th.th_suspend_cv);
      __kmp_printf("__kmp_suspend_template: suspending T#%d: %s\n", th_gtid,
                   buffer);
#endif
      // Mark the thread as no longer active (only in the first iteration of the
      // loop).
      if (!deactivated) {
        th->th.th_active = FALSE;
        if (th->th.th_active_in_pool) {
          th->th.th_active_in_pool = FALSE;
          KMP_ATOMIC_DEC(&__kmp_thread_pool_active_nth);
          KMP_DEBUG_ASSERT(TCR_4(__kmp_thread_pool_active_nth) >= 0);
        }
        deactivated = TRUE;
      }

      KMP_DEBUG_ASSERT(th->th.th_sleep_loc);
      KMP_DEBUG_ASSERT(flag->get_type() == th->th.th_sleep_loc_type);

#if USE_SUSPEND_TIMEOUT
      struct timespec now;
      struct timeval tval;
      int msecs;

      status = gettimeofday(&tval, NULL);
      KMP_CHECK_SYSFAIL_ERRNO("gettimeofday", status);
      TIMEVAL_TO_TIMESPEC(&tval, &now);

      msecs = (4 * __kmp_dflt_blocktime) + 200;
      now.tv_sec += msecs / 1000;
      now.tv_nsec += (msecs % 1000) * 1000;

      KF_TRACE(15, ("__kmp_suspend_template: T#%d about to perform "
                    "pthread_cond_timedwait\n",
                    th_gtid));
      status = pthread_cond_timedwait(&th->th.th_suspend_cv.c_cond,
                                      &th->th.th_suspend_mx.m_mutex, &now);
#else
      KF_TRACE(15, ("__kmp_suspend_template: T#%d about to perform"
                    " pthread_cond_wait\n",
                    th_gtid));
      status = pthread_cond_wait(&th->th.th_suspend_cv.c_cond,
                                 &th->th.th_suspend_mx.m_mutex);
#endif // USE_SUSPEND_TIMEOUT

      if ((status != 0) && (status != EINTR) && (status != ETIMEDOUT)) {
        KMP_SYSFAIL("pthread_cond_wait", status);
      }

      KMP_DEBUG_ASSERT(flag->get_type() == flag->get_ptr_type());

      if (!flag->is_sleeping() &&
          ((status == EINTR) || (status == ETIMEDOUT))) {
        // if interrupt or timeout, and thread is no longer sleeping, we need to
        // make sure sleep_loc gets reset; however, this shouldn't be needed if
        // we woke up with resume
        flag->unset_sleeping();
        TCW_PTR(th->th.th_sleep_loc, NULL);
        th->th.th_sleep_loc_type = flag_unset;
      }
#ifdef KMP_DEBUG
      if (status == ETIMEDOUT) {
        if (flag->is_sleeping()) {
          KF_TRACE(100,
                   ("__kmp_suspend_template: T#%d timeout wakeup\n", th_gtid));
        } else {
          KF_TRACE(2, ("__kmp_suspend_template: T#%d timeout wakeup, sleep bit "
                       "not set!\n",
                       th_gtid));
          TCW_PTR(th->th.th_sleep_loc, NULL);
          th->th.th_sleep_loc_type = flag_unset;
        }
      } else if (flag->is_sleeping()) {
        KF_TRACE(100,
                 ("__kmp_suspend_template: T#%d spurious wakeup\n", th_gtid));
      }
#endif
    } // while

    // Mark the thread as active again (if it was previous marked as inactive)
    if (deactivated) {
      th->th.th_active = TRUE;
      if (TCR_4(th->th.th_in_pool)) {
        KMP_ATOMIC_INC(&__kmp_thread_pool_active_nth);
        th->th.th_active_in_pool = TRUE;
      }
    }
  }
  // We may have had the loop variable set before entering the loop body;
  // so we need to reset sleep_loc.
  TCW_PTR(th->th.th_sleep_loc, NULL);
  th->th.th_sleep_loc_type = flag_unset;

  KMP_DEBUG_ASSERT(!flag->is_sleeping());
  KMP_DEBUG_ASSERT(!th->th.th_sleep_loc);
#ifdef DEBUG_SUSPEND
  {
    char buffer[128];
    __kmp_print_cond(buffer, &th->th.th_suspend_cv);
    __kmp_printf("__kmp_suspend_template: T#%d has awakened: %s\n", th_gtid,
                 buffer);
  }
#endif

  KF_TRACE(30, ("__kmp_suspend_template: T#%d exit\n", th_gtid));
  __kmp_unlock_suspend_mx(th);
}

template <bool C, bool S>
void __kmp_suspend_32(int th_gtid, kmp_flag_32<C, S> *flag) {
  __kmp_suspend_template(th_gtid, flag);
}
template <bool C, bool S>
void __kmp_suspend_64(int th_gtid, kmp_flag_64<C, S> *flag) {
  __kmp_suspend_template(th_gtid, flag);
}
template <bool C, bool S>
void __kmp_atomic_suspend_64(int th_gtid, kmp_atomic_flag_64<C, S> *flag) {
  __kmp_suspend_template(th_gtid, flag);
}
void __kmp_suspend_oncore(int th_gtid, kmp_flag_oncore *flag) {
  __kmp_suspend_template(th_gtid, flag);
}

template void __kmp_suspend_32<false, false>(int, kmp_flag_32<false, false> *);
template void __kmp_suspend_64<false, true>(int, kmp_flag_64<false, true> *);
template void __kmp_suspend_64<true, false>(int, kmp_flag_64<true, false> *);
template void
__kmp_atomic_suspend_64<false, true>(int, kmp_atomic_flag_64<false, true> *);
template void
__kmp_atomic_suspend_64<true, false>(int, kmp_atomic_flag_64<true, false> *);

/* This routine signals the thread specified by target_gtid to wake up
   after setting the sleep bit indicated by the flag argument to FALSE.
   The target thread must already have called __kmp_suspend_template() */
template <class C>
static inline void __kmp_resume_template(int target_gtid, C *flag) {
  KMP_TIME_DEVELOPER_PARTITIONED_BLOCK(USER_resume);
  kmp_info_t *th = __kmp_threads[target_gtid];
  int status;

#ifdef KMP_DEBUG
  int gtid = TCR_4(__kmp_init_gtid) ? __kmp_get_gtid() : -1;
#endif

  KF_TRACE(30, ("__kmp_resume_template: T#%d wants to wakeup T#%d enter\n",
                gtid, target_gtid));
  KMP_DEBUG_ASSERT(gtid != target_gtid);

  __kmp_suspend_initialize_thread(th);

  __kmp_lock_suspend_mx(th);

  if (!flag || flag != th->th.th_sleep_loc) {
    // coming from __kmp_null_resume_wrapper, or thread is now sleeping on a
    // different location; wake up at new location
    flag = (C *)CCAST(void *, th->th.th_sleep_loc);
  }

  // First, check if the flag is null or its type has changed. If so, someone
  // else woke it up.
  if (!flag) { // Thread doesn't appear to be sleeping on anything
    KF_TRACE(5, ("__kmp_resume_template: T#%d exiting, thread T#%d already "
                 "awake: flag(%p)\n",
                 gtid, target_gtid, (void *)NULL));
    __kmp_unlock_suspend_mx(th);
    return;
  } else if (flag->get_type() != th->th.th_sleep_loc_type) {
    // Flag type does not appear to match this function template; possibly the
    // thread is sleeping on something else. Try null resume again.
    KF_TRACE(
        5,
        ("__kmp_resume_template: T#%d retrying, thread T#%d Mismatch flag(%p), "
         "spin(%p) type=%d ptr_type=%d\n",
         gtid, target_gtid, flag, flag->get(), flag->get_type(),
         th->th.th_sleep_loc_type));
    __kmp_unlock_suspend_mx(th);
    __kmp_null_resume_wrapper(th);
    return;
  } else { // if multiple threads are sleeping, flag should be internally
    // referring to a specific thread here
    if (!flag->is_sleeping()) {
      KF_TRACE(5, ("__kmp_resume_template: T#%d exiting, thread T#%d already "
                   "awake: flag(%p): %u\n",
                   gtid, target_gtid, flag->get(), (unsigned int)flag->load()));
      __kmp_unlock_suspend_mx(th);
      return;
    }
  }
  KMP_DEBUG_ASSERT(flag);
  flag->unset_sleeping();
  TCW_PTR(th->th.th_sleep_loc, NULL);
  th->th.th_sleep_loc_type = flag_unset;

  KF_TRACE(5, ("__kmp_resume_template: T#%d about to wakeup T#%d, reset "
               "sleep bit for flag's loc(%p): %u\n",
               gtid, target_gtid, flag->get(), (unsigned int)flag->load()));

#ifdef DEBUG_SUSPEND
  {
    char buffer[128];
    __kmp_print_cond(buffer, &th->th.th_suspend_cv);
    __kmp_printf("__kmp_resume_template: T#%d resuming T#%d: %s\n", gtid,
                 target_gtid, buffer);
  }
#endif
  status = pthread_cond_signal(&th->th.th_suspend_cv.c_cond);
  KMP_CHECK_SYSFAIL("pthread_cond_signal", status);
  __kmp_unlock_suspend_mx(th);
  KF_TRACE(30, ("__kmp_resume_template: T#%d exiting after signaling wake up"
                " for T#%d\n",
                gtid, target_gtid));
}

template <bool C, bool S>
void __kmp_resume_32(int target_gtid, kmp_flag_32<C, S> *flag) {
  __kmp_resume_template(target_gtid, flag);
}
template <bool C, bool S>
void __kmp_resume_64(int target_gtid, kmp_flag_64<C, S> *flag) {
  __kmp_resume_template(target_gtid, flag);
}
template <bool C, bool S>
void __kmp_atomic_resume_64(int target_gtid, kmp_atomic_flag_64<C, S> *flag) {
  __kmp_resume_template(target_gtid, flag);
}
void __kmp_resume_oncore(int target_gtid, kmp_flag_oncore *flag) {
  __kmp_resume_template(target_gtid, flag);
}

template void __kmp_resume_32<false, true>(int, kmp_flag_32<false, true> *);
template void __kmp_resume_32<false, false>(int, kmp_flag_32<false, false> *);
template void __kmp_resume_64<false, true>(int, kmp_flag_64<false, true> *);
template void
__kmp_atomic_resume_64<false, true>(int, kmp_atomic_flag_64<false, true> *);

void __kmp_yield() { sched_yield(); }

void __kmp_gtid_set_specific(int gtid) {
  if (!__kmp_init_gtid) {
    KA_TRACE(
        50,
        ("__kmp_gtid_set_specific: runtime shutdown, not setting thread id\n"));
    return;
  }
  KA_TRACE(50, ("__kmp_gtid_get_specific: key:%d gtid:%d\n",
                __kmp_gtid_threadprivate_key, gtid + 1));
  int status = pthread_setspecific(__kmp_gtid_threadprivate_key,
                                   (void *)(intptr_t)(gtid + 1));
  KMP_CHECK_SYSFAIL("pthread_setspecific", status);
}

int __kmp_gtid_get_specific() {
  int gtid;
  if (!__kmp_init_gtid) {
    KA_TRACE(50, ("__kmp_gtid_get_specific: runtime shutdown, returning "
                  "KMP_GTID_SHUTDOWN\n"));
    return KMP_GTID_SHUTDOWN;
  }
  gtid = (int)(size_t)pthread_getspecific(__kmp_gtid_threadprivate_key);
  if (gtid == 0) {
    gtid = KMP_GTID_DNE;
  } else {
    gtid--;
  }
  KA_TRACE(50, ("__kmp_gtid_get_specific: key:%d gtid:%d\n",
                __kmp_gtid_threadprivate_key, gtid));
  return gtid;
}

double __kmp_read_cpu_time(void) {
  /*clock_t   t;*/
  struct tms buffer;

  /*t =*/times(&buffer);

  return (double)(buffer.tms_utime + buffer.tms_cutime) /
         (double)CLOCKS_PER_SEC;
}

int __kmp_read_system_info(struct kmp_sys_info *info) {
  info->maxrss = 0; /* the maximum resident set size utilized (in kilobytes) */
  info->minflt = 0; /* the number of page faults serviced without any I/O */
  info->majflt = 0; /* the number of page faults serviced that required I/O */
  info->nswap = 0; // the number of times a process was "swapped" out of memory
  info->inblock = 0; // the number of times the file system had to perform input
  info->oublock = 0; // number of times the file system had to perform output
  info->nvcsw = 0; /* the number of times a context switch was voluntarily */
  info->nivcsw = 0; /* the number of times a context switch was forced */

  return 1;
}

void __kmp_read_system_time(double *delta) {
  double t_ns;
  struct timeval tval;
  struct timespec stop;
  int status;

  status = gettimeofday(&tval, NULL);
  KMP_CHECK_SYSFAIL_ERRNO("gettimeofday", status);
  TIMEVAL_TO_TIMESPEC(&tval, &stop);
  t_ns = (double)(TS2NS(stop) - TS2NS(__kmp_sys_timer_data.start));
  *delta = (t_ns * 1e-9);
}

void __kmp_clear_system_time(void) {
  struct timeval tval;
  int status;
  status = gettimeofday(&tval, NULL);
  KMP_CHECK_SYSFAIL_ERRNO("gettimeofday", status);
  TIMEVAL_TO_TIMESPEC(&tval, &__kmp_sys_timer_data.start);
}

static int __kmp_get_xproc(void) {

  int r = 0;
  r = sysconf(_SC_NPROCESSORS_ONLN);
  return r > 0 ? r : 2; /* guess value of 2 if OS told us 0 */

} // __kmp_get_xproc

int __kmp_read_from_file(char const *path, char const *format, ...) {
  int result;
  va_list args;

  va_start(args, format);
  FILE *f = fopen(path, "rb");
  if (f == NULL)
    return 0;
  result = vfscanf(f, format, args);
  fclose(f);

  return result;
}

void __kmp_runtime_initialize(void) {
  int status;
  pthread_mutexattr_t mutex_attr;
  pthread_condattr_t cond_attr;

  if (__kmp_init_runtime) {
    return;
  }

  __kmp_init_runtime = TRUE;

  __kmp_xproc = __kmp_get_xproc();

  if (sysconf(_SC_THREADS)) {

    /* Query the maximum number of threads */
    __kmp_type_convert(sysconf(_SC_THREAD_THREADS_MAX), &(__kmp_sys_max_nth));
    if (__kmp_sys_max_nth == -1) {
      /* Unlimited threads for NPTL */
      __kmp_sys_max_nth = INT_MAX;
    } else if (__kmp_sys_max_nth <= 1) {
      /* Can't tell, just use PTHREAD_THREADS_MAX */
      __kmp_sys_max_nth = KMP_MAX_NTH;
    }

    /* Query the minimum stack size */
    __kmp_sys_min_stksize = sysconf(_SC_THREAD_STACK_MIN);
    if (__kmp_sys_min_stksize <= 1) {
      __kmp_sys_min_stksize = KMP_MIN_STKSIZE;
    }
  }

  /* Set up minimum number of threads to switch to TLS gtid */
  __kmp_tls_gtid_min = KMP_TLS_GTID_MIN;

  status = pthread_key_create(&__kmp_gtid_threadprivate_key,
                              __kmp_internal_end_dest);
  KMP_CHECK_SYSFAIL("pthread_key_create", status);
  status = pthread_mutexattr_init(&mutex_attr);
  KMP_CHECK_SYSFAIL("pthread_mutexattr_init", status);
  status = pthread_mutex_init(&__kmp_wait_mx.m_mutex, &mutex_attr);
  KMP_CHECK_SYSFAIL("pthread_mutex_init", status);
  status = pthread_mutexattr_destroy(&mutex_attr);
  KMP_CHECK_SYSFAIL("pthread_mutexattr_destroy", status);
  status = pthread_condattr_init(&cond_attr);
  KMP_CHECK_SYSFAIL("pthread_condattr_init", status);
  status = pthread_cond_init(&__kmp_wait_cv.c_cond, &cond_attr);
  KMP_CHECK_SYSFAIL("pthread_cond_init", status);
  status = pthread_condattr_destroy(&cond_attr);
  KMP_CHECK_SYSFAIL("pthread_condattr_destroy", status);
}

void __kmp_runtime_destroy(void) {
  int status;

  if (!__kmp_init_runtime) {
    return; // Nothing to do.
  }

  status = pthread_key_delete(__kmp_gtid_threadprivate_key);
  KMP_CHECK_SYSFAIL("pthread_key_delete", status);

  status = pthread_mutex_destroy(&__kmp_wait_mx.m_mutex);
  if (status != 0 && status != EBUSY) {
    KMP_SYSFAIL("pthread_mutex_destroy", status);
  }
  status = pthread_cond_destroy(&__kmp_wait_cv.c_cond);
  if (status != 0 && status != EBUSY) {
    KMP_SYSFAIL("pthread_cond_destroy", status);
  }
  __kmp_init_runtime = FALSE;
}

/* Put the thread to sleep for a time period */
/* NOTE: not currently used anywhere */
void __kmp_thread_sleep(int millis) { sleep((millis + 500) / 1000); }

/* Calculate the elapsed wall clock time for the user */
void __kmp_elapsed(double *t) {
  struct timeval tv;

  int status = gettimeofday(&tv, NULL);
  KMP_CHECK_SYSFAIL_ERRNO("gettimeofday", status);
  *t =
      (double)tv.tv_usec * (1.0 / (double)KMP_USEC_PER_SEC) + (double)tv.tv_sec;
}

/* Calculate the elapsed wall clock tick for the user */
void __kmp_elapsed_tick(double *t) { *t = 1 / (double)CLOCKS_PER_SEC; }

/* Return the current time stamp in nsec */
kmp_uint64 __kmp_now_nsec() {
  struct timeval t;
  gettimeofday(&t, NULL);
  kmp_uint64 nsec = (kmp_uint64)KMP_NSEC_PER_SEC * (kmp_uint64)t.tv_sec +
                    (kmp_uint64)1000 * (kmp_uint64)t.tv_usec;
  return nsec;
}

/* Determine whether the given address is mapped into the current address
   space. */

int __kmp_is_address_mapped(void *addr) {

  int found = 0;
  int rc;

  /* On GNUish OSes, read the /proc/<pid>/maps pseudo-file to get all the
     address ranges mapped into the address space. */

  char *name = __kmp_str_format("/proc/%d/maps", getpid());
  FILE *file = NULL;

  file = fopen(name, "r");
  KMP_ASSERT(file != NULL);

  for (;;) {

    void *beginning = NULL;
    void *ending = NULL;
    char perms[5];

    rc = fscanf(file, "%p-%p %4s %*[^\n]\n", &beginning, &ending, perms);
    if (rc == EOF) {
      break;
    }
    KMP_ASSERT(rc == 3 &&
               KMP_STRLEN(perms) == 4); // Make sure all fields are read.

    // Ending address is not included in the region, but beginning is.
    if ((addr >= beginning) && (addr < ending)) {
      perms[2] = 0; // 3th and 4th character does not matter.
      if (strcmp(perms, "rw") == 0) {
        // Memory we are looking for should be readable and writable.
        found = 1;
      }
      break;
    }
  }

  // Free resources.
  fclose(file);
  KMP_INTERNAL_FREE(name);
  return found;
} // __kmp_is_address_mapped

#ifdef USE_LOAD_BALANCE
// FIXME: The function is not correct, since it doesn't return
// the average load, but the current load
int __kmp_get_load_balance(int max) {
  return mppa_cos_get_total_running_threads();
}
#endif // USE_LOAD_BALANCE

// we really only need the case with 1 argument, because CLANG always build
// a struct of pointers to shared variables referenced in the outlined function
int __kmp_invoke_microtask(microtask_t pkfn, int gtid, int tid, int argc,
                           void *p_argv[]
#if OMPT_SUPPORT
                           ,
                           void **exit_frame_ptr
#endif
) {
#if OMPT_SUPPORT
  *exit_frame_ptr = OMPT_GET_FRAME_ADDRESS(0);
#endif

  switch (argc) {
  default:
    fprintf(stderr, "Too many args to microtask: %d!\n", argc);
    fflush(stderr);
    exit(-1);
  case 0:
    (*pkfn)(&gtid, &tid);
    break;
  case 1:
    (*pkfn)(&gtid, &tid, p_argv[0]);
    break;
  case 2:
    (*pkfn)(&gtid, &tid, p_argv[0], p_argv[1]);
    break;
  case 3:
    (*pkfn)(&gtid, &tid, p_argv[0], p_argv[1], p_argv[2]);
    break;
  case 4:
    (*pkfn)(&gtid, &tid, p_argv[0], p_argv[1], p_argv[2], p_argv[3]);
    break;
  case 5:
    (*pkfn)(&gtid, &tid, p_argv[0], p_argv[1], p_argv[2], p_argv[3], p_argv[4]);
    break;
  case 6:
    (*pkfn)(&gtid, &tid, p_argv[0], p_argv[1], p_argv[2], p_argv[3], p_argv[4],
            p_argv[5]);
    break;
  case 7:
    (*pkfn)(&gtid, &tid, p_argv[0], p_argv[1], p_argv[2], p_argv[3], p_argv[4],
            p_argv[5], p_argv[6]);
    break;
  case 8:
    (*pkfn)(&gtid, &tid, p_argv[0], p_argv[1], p_argv[2], p_argv[3], p_argv[4],
            p_argv[5], p_argv[6], p_argv[7]);
    break;
  case 9:
    (*pkfn)(&gtid, &tid, p_argv[0], p_argv[1], p_argv[2], p_argv[3], p_argv[4],
            p_argv[5], p_argv[6], p_argv[7], p_argv[8]);
    break;
  case 10:
    (*pkfn)(&gtid, &tid, p_argv[0], p_argv[1], p_argv[2], p_argv[3], p_argv[4],
            p_argv[5], p_argv[6], p_argv[7], p_argv[8], p_argv[9]);
    break;
  case 11:
    (*pkfn)(&gtid, &tid, p_argv[0], p_argv[1], p_argv[2], p_argv[3], p_argv[4],
            p_argv[5], p_argv[6], p_argv[7], p_argv[8], p_argv[9], p_argv[10]);
    break;
  case 12:
    (*pkfn)(&gtid, &tid, p_argv[0], p_argv[1], p_argv[2], p_argv[3], p_argv[4],
            p_argv[5], p_argv[6], p_argv[7], p_argv[8], p_argv[9], p_argv[10],
            p_argv[11]);
    break;
  case 13:
    (*pkfn)(&gtid, &tid, p_argv[0], p_argv[1], p_argv[2], p_argv[3], p_argv[4],
            p_argv[5], p_argv[6], p_argv[7], p_argv[8], p_argv[9], p_argv[10],
            p_argv[11], p_argv[12]);
    break;
  case 14:
    (*pkfn)(&gtid, &tid, p_argv[0], p_argv[1], p_argv[2], p_argv[3], p_argv[4],
            p_argv[5], p_argv[6], p_argv[7], p_argv[8], p_argv[9], p_argv[10],
            p_argv[11], p_argv[12], p_argv[13]);
    break;
  case 15:
    (*pkfn)(&gtid, &tid, p_argv[0], p_argv[1], p_argv[2], p_argv[3], p_argv[4],
            p_argv[5], p_argv[6], p_argv[7], p_argv[8], p_argv[9], p_argv[10],
            p_argv[11], p_argv[12], p_argv[13], p_argv[14]);
    break;
  case 16:
    (*pkfn)(&gtid, &tid, p_argv[0], p_argv[1], p_argv[2], p_argv[3], p_argv[4],
            p_argv[5], p_argv[6], p_argv[7], p_argv[8], p_argv[9], p_argv[10],
            p_argv[11], p_argv[12], p_argv[13], p_argv[14], p_argv[15]);
    break;
  case 17:
    (*pkfn)(&gtid, &tid, p_argv[0], p_argv[1], p_argv[2], p_argv[3], p_argv[4],
            p_argv[5], p_argv[6], p_argv[7], p_argv[8], p_argv[9], p_argv[10],
            p_argv[11], p_argv[12], p_argv[13], p_argv[14], p_argv[15],
            p_argv[16]);
    break;
  }

  return 1;
}

void __kmp_hidden_helper_worker_thread_wait() {
  KMP_ASSERT(0 && "Hidden helper task is not supported on this OS");
}

void __kmp_do_initialize_hidden_helper_threads() {
  KMP_ASSERT(0 && "Hidden helper task is not supported on this OS");
}

void __kmp_hidden_helper_threads_initz_wait() {
  KMP_ASSERT(0 && "Hidden helper task is not supported on this OS");
}

void __kmp_hidden_helper_initz_release() {
  KMP_ASSERT(0 && "Hidden helper task is not supported on this OS");
}

void __kmp_hidden_helper_main_thread_wait() {
  KMP_ASSERT(0 && "Hidden helper task is not supported on this OS");
}

void __kmp_hidden_helper_main_thread_release() {
  KMP_ASSERT(0 && "Hidden helper task is not supported on this OS");
}

void __kmp_hidden_helper_worker_thread_signal() {
  KMP_ASSERT(0 && "Hidden helper task is not supported on this OS");
}

void __kmp_hidden_helper_threads_deinitz_wait() {
  KMP_ASSERT(0 && "Hidden helper task is not supported on this OS");
}

void __kmp_hidden_helper_threads_deinitz_release() {
  KMP_ASSERT(0 && "Hidden helper task is not supported on this OS");
}

// end of file //
