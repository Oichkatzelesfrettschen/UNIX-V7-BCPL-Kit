#pragma once
#ifndef _SPINLOCK_H_
#define _SPINLOCK_H_

/*
 * Simple spinlock and ticket lock implementation.  The lock
 * type is selected at compile time by defining USE_TICKET_LOCK
 * to a non-zero value.
 */

#ifndef USE_TICKET_LOCK
#define USE_TICKET_LOCK 0
#endif

#if USE_TICKET_LOCK

/* Ticket lock implementation */
typedef struct ticket_lock {
    volatile unsigned head;
    volatile unsigned tail;
} ticket_lock_t;

static inline void ticket_lock_init(ticket_lock_t *lock)
{
    lock->head = lock->tail = 0;
}

static inline void ticket_lock_acquire(ticket_lock_t *lock)
{
    unsigned ticket = __sync_fetch_and_add(&lock->tail, 1);
    while (__sync_val_compare_and_swap(&lock->head, ticket, ticket) != ticket)
        ;
}

static inline void ticket_lock_release(ticket_lock_t *lock)
{
    __sync_fetch_and_add(&lock->head, 1);
}

typedef ticket_lock_t lock_t;
#define lock_init   ticket_lock_init
#define lock_acquire    ticket_lock_acquire
#define lock_release    ticket_lock_release

#else /* USE_TICKET_LOCK */

/* Simple spinlock implementation */
typedef struct spinlock {
    volatile int locked;
} spinlock_t;

static inline void spinlock_init(spinlock_t *lock)
{
    lock->locked = 0;
}

static inline void spin_lock(spinlock_t *lock)
{
    while (__sync_lock_test_and_set(&lock->locked, 1)) {
        while (lock->locked)
            ;
    }
}

static inline void spin_unlock(spinlock_t *lock)
{
    __sync_lock_release(&lock->locked);
}

typedef spinlock_t lock_t;
#define lock_init   spinlock_init
#define lock_acquire    spin_lock
#define lock_release    spin_unlock

#endif /* USE_TICKET_LOCK */

#endif /* _SPINLOCK_H_ */
