# asm/int3.s
    .text
    .globl main
    .type main, @function
main:
    movq $111, %rax
    int3
    movq $222, %rax
    int3
    movq $333, %rax
    int3
    ret
    .size main, .-main
