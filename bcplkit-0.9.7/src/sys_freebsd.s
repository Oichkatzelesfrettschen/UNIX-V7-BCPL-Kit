// Copyright (c) 2004 Robert Nordier.  All rights reserved.

// BCPL compiler runtime
// System interface: FreeBSD (i386)
// Numbers from sys/sys/syscall.h
// Arguments are passed on the stack for int $0x80

                .include "sys_defs.inc"

                .global _exit
_exit:          mov $FBSD32_EXIT,RA
                int $0x80

                .global read
read:           mov $FBSD32_READ,RA
                int $0x80
                jc error
                ret

                .global write
write:          mov $FBSD32_WRITE,RA
                int $0x80
                jc error
                ret

                .global open
open:           mov $FBSD32_OPEN,RA
                int $0x80
                jc error
                ret

                .global close
close:          mov $FBSD32_CLOSE,RA
                int $0x80
                jc error
                ret

                .global olseek
olseek:         mov $FBSD32_LSEEK,RA
                int $0x80
                jc error
                ret

                .global sbrk
sbrk:           mov 4(RSP),RC
                mov curbrk,RA
                add RA,4(RSP)
                mov $FBSD32_BRK,RA
                int $0x80
                jc error
                mov curbrk,RA
                add RC,curbrk
                ret

                .global ioctl
ioctl:          mov $FBSD32_IOCTL,RA
                int $0x80
                jc error
                ret

error:          mov RA,errno
                mov $-1,RA
                ret

                .set TERMIOSZ,0x40
                .set TIOCGETA,0x402c7413

                .global isatty
isatty:         sub $TERMIOSZ,RSP
                push RSP
                push $TIOCGETA
                push 0xc+TERMIOSZ(RSP)
                call ioctl
                mov $0,RA
                jc isatty.1
                inc RA
isatty.1:       add $0xc+TERMIOSZ,RSP
                ret

                .global oflags
// Set to the value of O_TRUNC | O_CREAT | O_WRONLY in <fcntl.h>
oflags:         .long 0x601

                .data
curbrk:         .long _end
errno:          .long 0
