# asm/rol-1.s
    .text
    .globl main
    .type main, @function
main:
    movq $0B11111111, %rax
    movb $3, %cl
    rolq %rax
    rolq $2, %rax
    rolq %cl, %rax
    ret
    .size main, .-main
