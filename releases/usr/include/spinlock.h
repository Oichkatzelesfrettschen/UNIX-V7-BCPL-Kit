/*
 * spinlock.h - simple and optional ticket-based spinlock implementation
 *
 * Inspired by modern kernels, includes optional SMP-aware macros and
 * cache line alignment using CPUID on x86 processors.
 */

#ifndef _SPINLOCK_H_
#define _SPINLOCK_H_

#ifdef __cplusplus
extern "C" {
#endif

#ifndef SPINLOCK_ENABLED
#define SPINLOCK_ENABLED 1
#endif

/* Common spinlock structure */
struct spinlock {
    volatile unsigned int value;
} __attribute__((aligned(64)));

typedef struct spinlock spinlock_t;

static inline void spinlock_init(spinlock_t *lock)
{
    lock->value = 0;
}

static inline unsigned int cpu_cacheline_size(void)
{
#if defined(__i386__) || defined(__x86_64__)
    unsigned int ebx;
    __asm__ volatile("movl $1, %%eax; cpuid" : "=b"(ebx) : : "eax", "ecx", "edx");
    return ((ebx >> 8) & 0xff) * 8;
#else
    return 64;
#endif
}

#if SPINLOCK_ENABLED
static inline void spinlock_lock(spinlock_t *lock)
{
    while (__sync_lock_test_and_set(&lock->value, 1)) {
        while (lock->value) ;
    }
}

static inline void spinlock_unlock(spinlock_t *lock)
{
    __sync_lock_release(&lock->value);
}
#else
#define spinlock_lock(l)   ((void)0)
#define spinlock_unlock(l) ((void)0)
#endif /* SPINLOCK_ENABLED */

/* Optional ticket lock providing fairness */
#ifdef USE_TICKET_LOCK
struct ticket_lock {
    volatile unsigned int next;
    volatile unsigned int owner;
} __attribute__((aligned(64)));

typedef struct ticket_lock ticketlock_t;

static inline void ticket_lock_init(ticketlock_t *t)
{
    t->next = t->owner = 0;
}

static inline void ticket_lock(ticketlock_t *t)
{
    unsigned int ticket = __sync_fetch_and_add(&t->next, 1);
    while (__sync_val_compare_and_swap(&t->owner, ticket, ticket) != ticket)
        ;
}

static inline void ticket_unlock(ticketlock_t *t)
{
    __sync_fetch_and_add(&t->owner, 1);
}
#endif /* USE_TICKET_LOCK */

#ifdef __cplusplus
}
#endif

#endif /* _SPINLOCK_H_ */
