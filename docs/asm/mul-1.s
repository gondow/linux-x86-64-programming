# asm/mul-1.s
    .text
    .globl main
    .type main, @function
main:
    movq $2, %rax
    movq $3, %rbx
    mulq %rbx
    ret
    .size main, .-main
