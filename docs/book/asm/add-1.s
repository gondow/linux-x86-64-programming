# asm/add-1.s
    .text
    .globl main
    .type main, @function
main:
    movq $1, %rax
    addq $999, %rax
    ret
    .size main, .-main
