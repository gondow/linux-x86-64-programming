# asm/add-2.s
    .text
    .globl main
    .type main, @function
main:
    pushq $999
    movq $1, %rax
    addq %rax, (%rsp)
    addq (%rsp), %rax
    popq %rbx
    ret
    .size main, .-main
