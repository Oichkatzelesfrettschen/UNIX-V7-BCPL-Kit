// Common syscall numbers and register conventions
// References:
//  - Linux i386 system calls: arch/x86/entry/syscalls/syscall_32.tbl
//  - Linux x86-64 system calls: arch/x86/entry/syscalls/syscall_64.tbl
//  - FreeBSD i386 system calls: sys/sys/syscall.h

/* Linux i386 syscall numbers */
.set SYS_EXIT_LINUX32,     1
.set SYS_READ_LINUX32,     3
.set SYS_WRITE_LINUX32,    4
.set SYS_OPEN_LINUX32,     5
.set SYS_CLOSE_LINUX32,    6
.set SYS_LSEEK_LINUX32,    0x13
.set SYS_BRK_LINUX32,      45
.set SYS_IOCTL_LINUX32,    0x36

/* Linux x86-64 syscall numbers */
.set SYS_EXIT_LINUX64,     60
.set SYS_READ_LINUX64,     0
.set SYS_WRITE_LINUX64,    1
.set SYS_OPEN_LINUX64,     2
.set SYS_CLOSE_LINUX64,    3
.set SYS_LSEEK_LINUX64,    8
.set SYS_BRK_LINUX64,      12
.set SYS_IOCTL_LINUX64,    16

/* FreeBSD i386 syscall numbers */
.set SYS_EXIT_FREEBSD,     1
.set SYS_READ_FREEBSD,     3
.set SYS_WRITE_FREEBSD,    4
.set SYS_OPEN_FREEBSD,     5
.set SYS_CLOSE_FREEBSD,    6
.set SYS_LSEEK_FREEBSD,    0x13
.set SYS_SBRK_FREEBSD,     17
.set SYS_IOCTL_FREEBSD,    0x36

/* Register conventions:
 *  Linux i386:    eax=syscall#, ebx,ecx,edx as first three args
 *  Linux x86-64:  rax=syscall#, rdi,rsi,rdx,r10,r8,r9 as args; rcx moved to r10
 *  FreeBSD i386:  eax=syscall#, ebx,ecx,edx as args, int $0x80
 */
