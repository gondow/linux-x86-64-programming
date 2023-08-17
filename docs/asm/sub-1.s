# asm/sub-1.s
    .text
    .globl main
    .type main, @function
main:
    movq $1000, %rax
    subq $999, %rax
    ret
    .size main, .-main
