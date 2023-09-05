# asm/shl-1.s
    .text
    .globl main
    .type main, @function
main:
    movq $0B11111111, %rax
    movb $3, %cl
    shlq %rax
    shlq $2, %rax
    shlq %cl, %rax
    ret
    .size main, .-main
