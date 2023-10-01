# asm/repnz.s
    .section .rodata
foo1:	
    .string  "xxxxxA\n"
foo2:	
    .string  "yyyyyA\n"

    .text
    .globl main
    .type main, @function
main:
    leaq foo1(%rip), %rsi
    leaq foo2(%rip), %rdi
    movl $10, %ecx
    repnz cmpsb
    ret
    .size main, .-main
