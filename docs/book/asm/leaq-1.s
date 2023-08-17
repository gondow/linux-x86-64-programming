# asm/leaq-1.s
    .text
    .globl main
    .type main, @function
main:
    leaq main(%rip), %rax
    ret
    .size main, .-main
