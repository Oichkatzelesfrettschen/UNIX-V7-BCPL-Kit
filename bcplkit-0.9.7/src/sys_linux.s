// Copyright (c) 2004 Robert Nordier.  All rights reserved.

// BCPL compiler runtime
// System interface: Linux
// Uses register aliases defined in regs.inc

                .include "sys_defs.inc"

                .global _exit
_exit:          mov $1,RA
                jmp syscall

                .global read
read:           mov $3,RA
                jmp syscall

                .global write
write:          mov $4,RA
                jmp syscall

                .global open
open:           mov $5,RA
                jmp syscall

                .global close
close:          mov $6,RA
                jmp syscall

                .global olseek
olseek:         mov $0x13,RA
                jmp syscall

                .global sbrk
sbrk:           mov curbrk,RA
                test RA,RA
                jnz 1f
                call brk
1:              push RA
                add 8(RSP),RA
                call brk
                pop RA
                ret

brk:            push RA
                mov $45,RA
                call syscall
                pop RC
                mov RA,curbrk
                ret

                .global ioctl
ioctl:          mov $0x36,RA

syscall:        push RD
                push RC
                push RB
                mov 0x10(RSP),RB
                mov 0x14(RSP),RC
                mov 0x18(RSP),RD
                int $0x80
                or RA,RA
                jge 1f
                neg RA
                mov RA,errno
                mov $-1,RA
                stc
1:              pop RB
                pop RC
                pop RD
                ret

                .set TERMIOSZ,0x40
                .set TCGETS,0x5401

                .global isatty
isatty:         sub $TERMIOSZ,RSP
                push RSP
                push $TCGETS
                push 0xc+TERMIOSZ(RSP)
                call ioctl
                mov $0,RA
                jc isatty.1
                inc RA
isatty.1:       add $0xc+TERMIOSZ,RSP
                ret

                .global oflags
// Set to the value of O_TRUNC | O_CREAT | O_WRONLY in <fcntl.h>
oflags:         .long 01101

                .data
                .global curbrk
curbrk:         .long 0
                .global errno
errno:          .long 0
