# asm/ror-1.s
    .text
    .globl main
    .type main, @function
main:
    movq $0B11111111, %rax
    movb $3, %cl
    rorq %rax
    rorq $2, %rax
    rorq %cl, %rax
    ret
    .size main, .-main
