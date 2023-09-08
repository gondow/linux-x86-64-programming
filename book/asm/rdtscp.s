# asm/rdtscp.s
    .text
    .globl main
    .type main, @function
main:
    rdtscp
    movl %eax, %ebx
    rdtscp
    subl %ebx, %eax
    ret
    .size main, .-main
