// 64-bit Linux system interface for BCPL runtime
// Derived from original 32-bit sys_linux.s

        .text
        .global _exit, read, write, open, close, olseek, sbrk, ioctl, isatty
        .global oflags, curbrk, errno

_exit:
        mov $60, %rax
        jmp syscall_common

read:
        mov $0, %rax
        jmp syscall_common

write:
        mov $1, %rax
        jmp syscall_common

open:
        mov $2, %rax
        jmp syscall_common

close:
        mov $3, %rax
        jmp syscall_common

olseek:
        mov $8, %rax
        jmp syscall_common

sbrk:
        mov curbrk(%rip), %rax
        test %rax, %rax
        jnz 1f
        call brk_call
1:
        push %rax
        add %rdi, %rax
        call brk_call
        pop %rax
        ret

brk_call:
        mov %rax, %rdi
        mov $12, %rax
        syscall
        mov %rdi, curbrk(%rip)
        ret

ioctl:
        mov $16, %rax
        jmp syscall_common

syscall_common:
        mov %rcx, %r10
        syscall
        test %rax, %rax
        jns 1f
        neg %rax
        mov %rax, errno(%rip)
        mov $-1, %rax
        stc
1:      ret

        .set TERMIOSZ,0x40
        .set TCGETS,0x5401

isatty:
        sub $TERMIOSZ, %rsp
        mov %rsp, %rdx
        mov $TCGETS, %rsi
        call ioctl
        mov $0, %eax
        jc 1f
        inc %eax
1:      add $TERMIOSZ, %rsp
        ret

        .data
oflags: .long 01101
curbrk: .quad 0
errno:  .quad 0
