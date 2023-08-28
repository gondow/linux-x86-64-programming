# asm/pop2.s
    .text
    .globl main
    .type main, @function
main:
    pushw $999
    popw %ax
    ret
    .size main, .-main
