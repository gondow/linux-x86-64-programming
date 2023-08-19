# asm/cf.s
    .text
    .globl main
    .type main, @function
main:
    movb $0xFF, %al
    addb $1, %al  # オーバーフローでCFが立つ
    ret
    .size main, .-main
