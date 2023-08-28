# asm/shr-1.s
    .text
    .globl main
    .type main, @function
main:
    movq $-256, %rax
    movb $3, %cl
    shrq %rax
    shrq $2, %rax
    shrq %cl, %rax
    ret
    .size main, .-main
