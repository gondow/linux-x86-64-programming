# asm/sbb-1.s
    .text
    .globl main
    .type main, @function
main:
    movq $0xFFFFFFFFFFFFFFFF, %rax
    addq $1, %rax  # オーバーフローでCFが立つ
    sbbq $2, %rax
    ret
    .size main, .-main
