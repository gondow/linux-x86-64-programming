# asm/movq-1.s
    .text
    .globl main
    .type main, @function
main:
    movq $999, %rax
    movq %rax, %rbx
    ret
    .size main, .-main
