# asm/dec-1.s
    .text
    .globl main
    .type main, @function
main:
    movq $0, %rax
    dec %rax
    ret
    .size main, .-main
