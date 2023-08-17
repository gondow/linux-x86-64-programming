# asm/movq-2.s
    .text
    .globl main
    .type main, @function
main:
    movq $999, %rax
    movq %rax, -8(%rsp)
    ret
    .size main, .-main
