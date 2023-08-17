# asm/of.s
    .text
    .globl main
    .type main, @function
main:
    movb $0x7F, %al
    addb $1, %al  # オーバーフローでOFが立つ
    ret
    .size main, .-main
