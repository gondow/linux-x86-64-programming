# asm/neg-1.s
    .text
    .globl main
    .type main, @function
main:
    movq $999, %rax
    neg %rax
    neg %rax
    ret
    .size main, .-main
