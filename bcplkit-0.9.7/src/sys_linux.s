// Copyright (c) 2004 Robert Nordier.  All rights reserved.

// BCPL compiler runtime
// System interface: Linux (i386)
// Numbers from arch/x86/entry/syscalls/syscall_32.tbl
// Uses the i386 int $0x80 calling convention

                .include "sys_defs.inc"

                .global _exit
_exit:          mov $LINUX32_EXIT,RA
                jmp syscall

                .global read
read:           mov $LINUX32_READ,RA
                jmp syscall

                .global write
write:          mov $LINUX32_WRITE,RA
                jmp syscall

                .global open
open:           mov $LINUX32_OPEN,RA
                jmp syscall

                .global close
close:          mov $LINUX32_CLOSE,RA
                jmp syscall

                .global olseek
olseek:         mov $LINUX32_LSEEK,RA
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
                mov $LINUX32_BRK,RA
                call syscall
                pop RC
                mov RA,curbrk
                ret

                .global ioctl
ioctl:          mov $LINUX32_IOCTL,RA

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
