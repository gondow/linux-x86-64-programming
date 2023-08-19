# asm/xchg.s
    .text
    .globl main
    .type main, @function
main:
    movq $0x1122334455667788, %rax
    pushq %rax
    movq $0x99AABBCCDDEEFF00, %rax
    xchg %rax, (%rsp)
    xchg (%rsp), %rax
    popq %rax
    ret
    .size main, .-main
