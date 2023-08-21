# asm/test-1.s
    .text
    .globl main
    .type main, @function
main:
    movq $1, %rax
    pushq $1
    testq $0, %rax       # %rax (=1) & 0
    testq %rax, (%rsp)   # (%rsp) (=1) & %rax (=1)
    testq (%rsp), %rax   # %rax (=1) & (%rsp) (=1)
    ret
    .size main, .-main
