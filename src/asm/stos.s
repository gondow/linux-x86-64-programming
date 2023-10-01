# asm/stos.s
    .text
    .globl main
    .type main, @function
main:
    movq $0x1122334455667788, %rax
    leaq -128(%rsp), %rdi
    movl $4, %ecx
    rep stosq
    ret
    .size main, .-main
