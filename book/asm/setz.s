# asm/setz.s
    .text
    .globl main
    .type main, @function
main:
    movq $0, %rax
    cmpq $0, %rax
    setz %al
    ret
    .size main, .-main
