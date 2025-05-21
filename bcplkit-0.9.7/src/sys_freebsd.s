// Copyright (c) 2004 Robert Nordier.  All rights reserved.

// BCPL compiler runtime
// System interface: FreeBSD (i386)
// Syscall numbers from FreeBSD sys/sys/syscall.h

                .include "sys_defs.inc"

                .global _exit
_exit:          mov $SYS_EXIT_FREEBSD,%eax
                int $0x80

                .global read
read:           mov $SYS_READ_FREEBSD,%eax
                int $0x80
                jc error
                ret

                .global write
write:          mov $SYS_WRITE_FREEBSD,%eax
                int $0x80
                jc error
                ret

                .global open
open:           mov $SYS_OPEN_FREEBSD,%eax
                int $0x80
                jc error
                ret

                .global close
close:          mov $SYS_CLOSE_FREEBSD,%eax
                int $0x80
                jc error
                ret

                .global olseek
olseek:         mov $SYS_LSEEK_FREEBSD,%eax
                int $0x80
                jc error
                ret

                .global sbrk
sbrk:           mov 4(%esp),%ecx
                mov curbrk,%eax
                add %eax,4(%esp)
                mov $SYS_SBRK_FREEBSD,%eax
                int $0x80
                jc error
                mov curbrk,%eax
                add %ecx,curbrk
                ret

                .global ioctl
ioctl:          mov $SYS_IOCTL_FREEBSD,%eax
                int $0x80
                jc error
                ret

error:          mov %eax,errno
                mov $-1,%eax
                ret

                .set TERMIOSZ,0x40
                .set TIOCGETA,0x402c7413

                .global isatty
isatty:         sub $TERMIOSZ,%esp
                push %esp
                push $TIOCGETA
                push 0xc+TERMIOSZ(%esp)
                call ioctl
                mov $0,%eax
                jc isatty.1
                inc %eax
isatty.1:       add $0xc+TERMIOSZ,%esp
                ret

                .global oflags
// Set to the value of O_TRUNC | O_CREAT | O_WRONLY in <fcntl.h>
oflags:         .long 0x601

                .data
curbrk:         .long _end
errno:          .long 0
