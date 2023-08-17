# asm/adc-3.s
    .text
    .globl main
    .type main, @function
main:
    movq $0xFFFFFFFFFFFFFFFF, %rax
    pushq $999
    addq $1, %rax
    adcq (%rsp), %rax
    ret
    .size main, .-main
