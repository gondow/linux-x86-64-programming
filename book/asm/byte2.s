# asm/byte2.s
    .text
    .globl main
    .type main, @function
main:
    .byte 0x48, 0x89, 0xC3
    .byte 0x48, 0x8B, 0xD8
    ret
    .size main, .-main
