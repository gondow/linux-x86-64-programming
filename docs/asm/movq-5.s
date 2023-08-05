# asm/movq-5.s
    .text
    .globl main
    .type main, @function
main:
    movq $999, -8(%rsp)
    ret
    .size main, .-main
