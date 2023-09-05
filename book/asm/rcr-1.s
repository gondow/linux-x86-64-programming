# asm/rcr-1.s
    .text
    .globl main
    .type main, @function
main:
    movq $0B11111010, %rax
    movb $3, %cl
    movq $0xFFFFFFFFFFFFFFFF, %rbx
    addq $1, %rbx  # オーバーフローでCFが立つ
    rcrq %rax
    rcrq $2, %rax
    rcrq %cl, %rax
    ret
    .size main, .-main
