#pragma once

#include <stdint.h>
#include <stdalign.h>

#ifdef __cplusplus
extern "C" {
#endif

static inline unsigned int detect_cache_line_size(void)
{
#if defined(__i386__) || defined(__x86_64__)
    unsigned int eax = 1, ebx, ecx, edx;
    __asm__ __volatile__(
        "cpuid"
        : "=a"(eax), "=b"(ebx), "=c"(ecx), "=d"(edx)
        : "a"(eax)
    );
    return ((ebx >> 8) & 0xff) * 8;
#else
    return 64;
#endif
}

#ifndef CACHE_LINE_SIZE
#define CACHE_LINE_SIZE 64
#endif

struct spinlock {
    volatile uint32_t locked;
} __attribute__((aligned(CACHE_LINE_SIZE)));

static inline void spin_lock(struct spinlock *lock)
{
    while (__sync_lock_test_and_set(&lock->locked, 1)) {
        while (lock->locked)
            ;
    }
}

static inline void spin_unlock(struct spinlock *lock)
{
    __sync_lock_release(&lock->locked);
}

#ifdef __cplusplus
}
#endif

