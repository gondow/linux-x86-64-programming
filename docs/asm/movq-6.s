# asm/movq-6.s
    .text
    .globl main
    .type main, @function
main:
    movq $main, %rax
    ret
    .size main, .-main
