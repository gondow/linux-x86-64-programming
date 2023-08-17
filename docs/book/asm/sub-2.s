# asm/sub-2.s
    .text
    .globl main
    .type main, @function
main:
    pushq $999
    movq $1, %rax
    subq %rax, (%rsp)
    subq (%rsp), %rax
    popq %rbx
    ret
    .size main, .-main
