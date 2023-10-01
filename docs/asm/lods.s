# asm/lods.s
    .section .rodata
foo:	
    .quad  0x1122334455667788

    .text
    .globl main
    .type main, @function
main:
    leaq foo(%rip), %rsi
    movl $4, %ecx
    rep lodsb
    ret
    .size main, .-main
