// Copyright (c) 2004 Robert Nordier.  All rights reserved.

// $Id: su.s,v 1.7 2004/12/18 17:51:16 rn Exp $

                .set STACKBASE,54
                .set STACKEND,55
                .set STKSIZ,0x400000

                .global _start
                .global finish
                .global stop
_start:         cld
//
                mov %esp,%ecx
                sub $256,%esp
                mov %esp,%edi
                inc %edi
                cmpl $2,(%ecx)
                jb start.4
//
                lea 8(%ecx),%ebx
                mov (%ebx),%esi
                jmp start.3
//
start.1:        mov $' ',%al
start.2:        cmp %ecx,%edi
                je start.4
                stosb
start.3:        lodsb
                test %al,%al
                jnz start.2
                add $4,%ebx
                mov (%ebx),%esi
                test %esi,%esi
                jnz start.1
//
start.4:        mov %edi,%ebx
                sub %esp,%ebx
                dec %ebx
                mov %bl,(%esp,1)
//
                sub %edi,%ecx
                and $3,%ecx
                xor %eax,%eax
                rep stosb
//
                call rtinit
                push $STKSIZ
                call sbrk
                pop %ecx
//
                mov $G,%edi
                mov %eax,%ebp
//
                shr $2,%eax
                mov %eax,STACKBASE*4(%edi)
                add $STKSIZ>>2,%eax
                mov %eax,STACKEND*4(%edi)
//
                movl $0,(%ebp)
                movl $finish,4(%ebp)
                mov %esp,%eax
                shr $2,%eax
                mov %eax,8(%ebp)
                mov 4(%edi),%eax
                jmp *%eax
finish:         xor %eax,%eax
stop:           push %eax
                call rtexit
                call _exit
