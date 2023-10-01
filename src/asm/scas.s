# asm/scas.s
    .section .rodata
foo1:	
    .string  "HelloA\n"

    .text
    .globl main
    .type main, @function
main:
    leaq foo1(%rip), %rdi
    movb $'A', %al
    movl $10, %ecx
    repne scasb
    ret
    .size main, .-main
