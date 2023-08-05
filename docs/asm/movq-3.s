# asm/movq-3.s
    .text
    .globl main
    .type main, @function
main:
    movq $999, -8(%rsp)
    movq -8(%rsp), %rax
    ret
    .size main, .-main
