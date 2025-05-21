/* Common syscall numbers and calling conventions
 *
 * References:
 * - Linux: arch/x86/entry/syscalls/syscall_32.tbl and syscall_64.tbl
 * - FreeBSD: sys/sys/syscall.h
 */

/* Linux 32-bit (i386) syscall numbers */
.set LINUX32_EXIT,    1
.set LINUX32_READ,    3
.set LINUX32_WRITE,   4
.set LINUX32_OPEN,    5
.set LINUX32_CLOSE,   6
.set LINUX32_LSEEK,   13
.set LINUX32_BRK,     45
.set LINUX32_IOCTL,   54

/* Linux 64-bit syscall numbers */
.set LINUX64_EXIT,    60
.set LINUX64_READ,    0
.set LINUX64_WRITE,   1
.set LINUX64_OPEN,    2
.set LINUX64_CLOSE,   3
.set LINUX64_LSEEK,   8
.set LINUX64_BRK,     12
.set LINUX64_IOCTL,   16

/* FreeBSD 32-bit syscall numbers */
.set FBSD32_EXIT,     1
.set FBSD32_READ,     3
.set FBSD32_WRITE,    4
.set FBSD32_OPEN,     5
.set FBSD32_CLOSE,    6
.set FBSD32_LSEEK,    0x13
.set FBSD32_BRK,      17
.set FBSD32_IOCTL,    0x36

/* Register conventions
 * Linux i386:   eax=number, ebx,ecx,edx,esi,edi,ebp = args 1..6
 * Linux x86_64: rax=number, rdi,rsi,rdx,r10,r8,r9   = args 1..6
 * FreeBSD i386: eax=number, args pushed on stack
 */
