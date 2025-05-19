/* Register aliases for x86 architectures */

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
