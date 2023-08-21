# asm/not-1.s
    .text
    .globl main
    .type main, @function
main:
    movb $0B11001010, %al
    not %al
    not %al
    ret
    .size main, .-main
