# asm/cmp-1.s
    .text
    .globl main
    .type main, @function
main:
    movq $0, %rax
    pushq $1
    cmpq $1, %rax       # %rax (=0) - 1
    cmpq %rax, (%rsp)   # (%rsp) (=1) - %rax (=0)
    cmpq (%rsp), %rax   # %rax (=0) - (%rsp) (=1)
    ret
    .size main, .-main
