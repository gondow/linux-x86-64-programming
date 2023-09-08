# asm/sar-1.s
    .text
    .globl main
    .type main, @function
main:
    movq $-256, %rax
    movb $3, %cl
    sarq %rax
    sarq $2, %rax
    sarq %cl, %rax
    ret
    .size main, .-main
