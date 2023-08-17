# asm/add-imm2.s
    .text
    .globl main
    .type main, @function
main:
    movq $0, %rax
    addq $-1, %rax
    ret
    .size main, .-main
