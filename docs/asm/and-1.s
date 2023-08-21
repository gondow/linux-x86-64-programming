# asm/and-1.s
    .text
    .globl main
    .type main, @function
main:
    movq $0B11001010, %rax
    andq $0B10101100, %rax
    pushq $0B00001111
    andq %rax, (%rsp)
    movq $0B11110111, %rax
    andq (%rsp), %rax
    ret
    .size main, .-main
