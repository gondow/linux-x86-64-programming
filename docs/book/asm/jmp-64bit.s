# asm/jmp-64bit.s
    .text
    .globl main
    .type main, @function
main:
#    jmp 0x1122334455667788           # NG
    movq $0x1122334455667788, %rax
    jmp *%rax
    ret
    .size main, .-main
