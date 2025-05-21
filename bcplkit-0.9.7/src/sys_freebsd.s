// Copyright (c) 2004 Robert Nordier.  All rights reserved.

// BCPL compiler runtime
// System interface: FreeBSD
// Uses register aliases defined in regs.inc

                .include "sys_defs.inc"

                .global _exit
_exit:          mov $1,RA
                int $0x80

                .global read
read:           mov $3,RA
                int $0x80
                jc error
                ret

                .global write
write:          mov $4,RA
                int $0x80
                jc error
                ret

                .global open
open:           mov $5,RA
                int $0x80
                jc error
                ret

                .global close
close:          mov $6,RA
                int $0x80
                jc error
                ret

                .global olseek
olseek:         mov $0x13,RA
                int $0x80
                jc error
                ret

                .global sbrk
sbrk:           mov 4(RSP),RC
                mov curbrk,RA
                add RA,4(RSP)
                mov $17,RA
                int $0x80
                jc error
                mov curbrk,RA
                add RC,curbrk
                ret

                .global ioctl
ioctl:          mov $0x36,RA
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
