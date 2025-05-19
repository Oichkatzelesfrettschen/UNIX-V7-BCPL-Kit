// Copyright (c) 2004 Robert Nordier.  All rights reserved.

// $Id: su.s,v 1.7 2004/12/18 17:51:16 rn Exp $

                .include "sys_defs.inc"

                .set STACKBASE,54
                .set STACKEND,55
                .set STKSIZ,0x400000

                .global _start
                .global finish
                .global stop
_start:         cld
// Preserve initial stack pointer in RCX and create a small
// temporary area on the stack for parsing the arguments.
                mov RSP,RC
                sub $256,RSP
                mov RSP,RDI
                inc RDI
                cmpl $2,(RC)
                jb start.4
//
                lea 8(RC),RB
                mov (RB),RSI
                jmp start.3
//
start.1:        mov $' ',%al
start.2:        cmp RC,RDI
                je start.4
                stosb
start.3:        lodsb
                test %al,%al
                jnz start.2
                add $8,RB
                mov (RB),RSI
                test RSI,RSI
                jnz start.1
//
start.4:        mov RDI,RB
                sub RSP,RB
                dec RB
                mov %bl,(RSP,1)
//
                sub RDI,RC
                and $7,RC
                xor RA,RA
                rep stosb
//
                call rtinit
                push $STKSIZ
                call sbrk
                pop RC
//
                mov $G,RDI
                mov RA,RBP
//
                shr $2,RA
                mov RA,STACKBASE*4(RDI)
                add $STKSIZ>>2,RA
                mov RA,STACKEND*4(RDI)
//
                movl $0,(RBP)
                movl $finish,4(RBP)
                mov RSP,RA
                shr $2,RA
                mov RA,8(RBP)
                mov 4(RDI),RA
                jmp *RA
finish:         xor RA,RA
stop:           push RA
                call rtexit
                call _exit
