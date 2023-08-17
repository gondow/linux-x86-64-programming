# asm/push2.s
    .text
    .globl main
    .type main, @function
main:
    pushw $999
    ret
    .size main, .-main
