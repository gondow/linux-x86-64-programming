# asm/nop.s
    .text
    .globl main
    .type main, @function
main:
    nop
    ret
    .size main, .-main
