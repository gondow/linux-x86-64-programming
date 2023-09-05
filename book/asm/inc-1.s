# asm/inc-1.s
    .text
    .globl main
    .type main, @function
main:
    movq $0, %rax
    inc %rax
    ret
    .size main, .-main
