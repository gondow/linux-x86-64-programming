# asm/sbb-2.s
    .text
    .globl main
    .type main, @function
main:
    movq $0xFFFFFFFFFFFFFFFF, %rax
    pushq $999
    addq $1, %rax # オーバーフローでCFが立つ
    sbbq $2, (%rsp)
    sbbq (%rsp), %rax
    ret
    .size main, .-main
