# asm/zero-upper32.s
    .text
    .globl main
    .type main, @function
main:
    movq $0x1122334455667788, %rax
    movl $0xAABBCCDD, %eax
    movq $0x1122334455667788, %rax
    movw $0x1122, %ax
    movq $0x1122334455667788, %rax
    movb $0x11, %al
    ret
    .size main, .-main
