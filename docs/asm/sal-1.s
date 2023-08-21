# asm/sal-1.s
    .text
    .globl main
    .type main, @function
main:
    movq $0B11111111, %rax
    movb $3, %cl
    salq %rax
    salq $2, %rax
    salq %cl, %rax
    ret
    .size main, .-main
