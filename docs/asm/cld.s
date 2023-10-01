# asm/cld.s
    .text
    .globl main
    .type main, @function
main:
    std
    cld
    ret
    .size main, .-main
