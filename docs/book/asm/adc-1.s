# asm/adc-1.s
    .text
    .globl main
    .type main, @function
main:
    movq $0xFFFFFFFFFFFFFFFF, %rax
    addq $1, %rax  # オーバーフローでCFが立つ
    adcq $2, %rax
    ret
    .size main, .-main
