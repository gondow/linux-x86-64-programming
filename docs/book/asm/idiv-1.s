# asm/idiv-1.s
    .text
    .globl main
    .type main, @function
main:
    movq $-999, %rax
    cqto
    movq $30, %rbx
    idivq %rbx
    ret
    .size main, .-main
