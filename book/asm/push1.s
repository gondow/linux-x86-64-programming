# asm/push1.s
    .text
    .globl main
    .type main, @function
main:
    pushq $999
    ret
    .size main, .-main
