# asm/movq-9.s
    .data
foo:
    .quad 999 
    .text
    .globl main
    .type main, @function
main:
    pushq $888
    pushq $777
    movq (%rsp), %rax
    movq 8(%rsp), %rbx
    movq foo(%rip), %rcx
    ret
    .size main, .-main
