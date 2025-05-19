// Copyright (c) 2004 Robert Nordier.  All rights reserved.

// $Id: su.s,v 1.7 2004/12/18 17:51:16 rn Exp $

                .set STACKBASE,54
                .set STACKEND,55
                .set STKSIZ,0x400000

                .global _start
                .global finish
                .global stop
_start:         cld
// Preserve initial stack pointer in RCX and create a small
// temporary area on the stack for parsing the arguments.
                mov %rsp,%rcx
                sub $256,%rsp
                mov %rsp,%rdi
                inc %rdi
                cmpl $2,(%rcx)
                jb start.4
//
                lea 8(%rcx),%rbx
                mov (%rbx),%rsi
                jmp start.3
//
start.1:        mov $' ',%al
start.2:        cmp %rcx,%rdi
                je start.4
                stosb
start.3:        lodsb
                test %al,%al
                jnz start.2
                add $8,%rbx
                mov (%rbx),%rsi
                test %esi,%esi
                jnz start.1
//
start.4:        mov %rdi,%rbx
                sub %rsp,%rbx
                dec %rbx
                mov %bl,(%rsp,1)
//
                sub %rdi,%rcx
                and $7,%rcx
                xor %eax,%eax
                rep stosb
//
                call rtinit
                push $STKSIZ
                call sbrk
                pop %rcx
//
                mov $G,%rdi
                mov %rax,%rbp
//
                shr $2,%eax
                mov %eax,STACKBASE*4(%rdi)
                add $STKSIZ>>2,%eax
                mov %eax,STACKEND*4(%rdi)
//
                movl $0,(%rbp)
                movl $finish,4(%rbp)
                mov %rsp,%rax
                shr $2,%rax
                mov %eax,8(%rbp)
                mov 4(%rdi),%eax
                jmp *%rax
finish:         xor %eax,%eax
stop:           push %rax
                call rtexit
                call _exit
