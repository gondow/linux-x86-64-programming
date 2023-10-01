# asm/rep.s
    .section .rodata
foo:	
    .quad  0x1122334455667788

    .text
    .globl main
    .type main, @function
main:
    leaq foo(%rip), %rsi
    leaq -128(%rsp), %rdi
    movl $4, %ecx
    rep movsb
    ret
    .size main, .-main
