# asm/imul-2.s
    .text
    .globl main
    .type main, @function
main:
    movq $-2, %rax
    movq $-3, %rbx
    imulq $4, %rax
    imulq %rbx, %rax
    imulq $5, %rbx, %rax
    ret
    .size main, .-main
