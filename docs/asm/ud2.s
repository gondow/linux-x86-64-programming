# asm/ud2.s
    .text
    .globl main
    .type main, @function
main:
    ud2
    ret
    .size main, .-main
