# asm/byte.s
    .text
    .globl main
    .type main, @function
main:
    movq %rax, %rbx          # これと
    .byte 0x48, 0x89, 0xC3   # これは同じ意味
    ret
    .size main, .-main
