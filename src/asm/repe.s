# asm/repe.s
    .section .rodata
foo1:	
    .string  "HelloA\n"
foo2:	
    .string  "HelloB\n"

    .text
    .globl main
    .type main, @function
main:
    leaq foo1(%rip), %rsi
    leaq foo2(%rip), %rdi
    movl $10, %ecx
    repe cmpsb
    ret
    .size main, .-main
