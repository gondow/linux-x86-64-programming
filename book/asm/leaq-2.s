# asm/leaq-2.s
    .text
    .globl main
    .type main, @function
main:
    movq $8, %rsi
    leaq -8(%rsp, %rsi, 4), %rax
    ret
    .size main, .-main
