# asm/cmp-test.s
    .text
    .globl main
    .type main, @function
main:
    cmpq $0, %rax
    testq %rax, %rax
    ret
    .size main, .-main
