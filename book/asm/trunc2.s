# asm/trunc2.s
    .text
    .globl main
    .type main, @function
main:
    movl $100000, %eax
    movw %ax, %bx
    ret
    .size main, .-main
