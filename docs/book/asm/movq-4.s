# asm/movq-4.s
    .text
    .globl main
    .type main, @function
main:
    movq $999, %rax
    ret
    .size main, .-main
