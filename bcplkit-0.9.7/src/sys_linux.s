// Copyright (c) 2004 Robert Nordier.  All rights reserved.

// BCPL compiler runtime
// System interface: Linux (i386)
// Syscall numbers from Linux arch/x86/entry/syscalls/syscall_32.tbl

                .include "sys_defs.inc"

                .global _exit
_exit:          mov $SYS_EXIT_LINUX32,%eax
                jmp syscall

                .global read
read:           mov $SYS_READ_LINUX32,%eax
                jmp syscall

                .global write
write:          mov $SYS_WRITE_LINUX32,%eax
                jmp syscall

                .global open
open:           mov $SYS_OPEN_LINUX32,%eax
                jmp syscall

                .global close
close:          mov $SYS_CLOSE_LINUX32,%eax
                jmp syscall

                .global olseek
olseek:         mov $SYS_LSEEK_LINUX32,%eax
                jmp syscall

                .global sbrk
sbrk:           mov curbrk,%eax
                test %eax,%eax
                jnz 1f
                call brk
1:              push %eax
                add 8(%esp),%eax
                call brk
                pop %eax
                ret

brk:            push %eax
                mov $SYS_BRK_LINUX32,%eax
                call syscall
                pop %ecx
                mov %eax,curbrk
                ret

                .global ioctl
ioctl:          mov $SYS_IOCTL_LINUX32,%eax

syscall:        push %edx
                push %ecx
                push %ebx
                mov 0x10(%esp),%ebx
                mov 0x14(%esp),%ecx
                mov 0x18(%esp),%edx
                int $0x80
                or %eax,%eax
                jge 1f
                neg %eax
                mov %eax,errno
                mov $-1,%eax
                stc
1:              pop %ebx
                pop %ecx
                pop %edx
                ret

                .set TERMIOSZ,0x40
                .set TCGETS,0x5401

                .global isatty
isatty:         sub $TERMIOSZ,%esp
                push %esp
                push $TCGETS
                push 0xc+TERMIOSZ(%esp)
                call ioctl
                mov $0,%eax
                jc isatty.1
                inc %eax
isatty.1:       add $0xc+TERMIOSZ,%esp
                ret

                .global oflags
// Set to the value of O_TRUNC | O_CREAT | O_WRONLY in <fcntl.h>
oflags:         .long 01101

                .data
                .global curbrk
curbrk:         .long 0
                .global errno
errno:          .long 0
