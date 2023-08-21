# asm/setg.s
    .text
    .globl main
    .type main, @function
main:
    movq $10, %rax
    cmpq $0, %rax
    setg %al
    ret
    .size main, .-main
