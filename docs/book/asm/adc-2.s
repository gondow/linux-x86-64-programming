# asm/adc-2.s
    .text
    .globl main
    .type main, @function
main:
    movq $0xFFFFFFFFFFFFFFFF, %rax
    pushq $999
    addq $1, %rax # オーバーフローでCFが立つ
    adcq $2, (%rsp)
    ret
    .size main, .-main
