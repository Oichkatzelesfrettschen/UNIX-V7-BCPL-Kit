/*
 * Register aliases for x86 assemblers.
 *
 * When assembling for 64-bit (X86_64 defined) the RA..RSP macros map to
 * the appropriate 64-bit registers.  Otherwise they expand to their 32-bit
 * counterparts for i686 code.  Additional 8-bit aliases are provided for
 * convenience and are identical in both modes.
 */

.ifdef X86_64
    .set RA, %rax
    .set RB, %rbx
    .set RC, %rcx
    .set RD, %rdx
    .set RSI, %rsi
    .set RDI, %rdi
    .set RBP, %rbp
    .set RSP, %rsp
.else
    .set RA, %eax
    .set RB, %ebx
    .set RC, %ecx
    .set RD, %edx
    .set RSI, %esi
    .set RDI, %edi
    .set RBP, %ebp
    .set RSP, %esp
.endif

.set AL, %al
.set BL, %bl
.set CL, %cl
.set DL, %dl
