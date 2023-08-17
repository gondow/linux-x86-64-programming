# asm/movqabs-1.s
    .text
    .globl main
    .type main, @function
main:
    movq $0x1122334455667788, %rax
    movabsq $0x99AABBCCDDEEFF00, %rax
    ret
    .size main, .-main
