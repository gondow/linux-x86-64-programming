# asm/div-1.s
    .text
    .globl main
    .type main, @function
main:
    movq $999, %rax
    movq $0, %rdx
    movq $30, %rbx
    divq %rbx
    ret
    .size main, .-main
