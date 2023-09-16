# asm/movq-12.s
    .text
    .globl main
    .type main, @function
main:
    movq %r8, (%rbp, %r9)
    movq %r8, 0x1000
    .size main, .-main
