# asm/reg.s
    .text
    .globl main
    .type main, @function
main:
    movq $0x1122334455667788, %rax # ❶
    ret
    .size main, .-main
