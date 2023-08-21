# asm/rdtsc.s
    .text
    .globl main
    .type main, @function
main:
    rdtsc
    movl %eax, %ebx
    rdtsc
    subl %ebx, %eax
    ret
    .size main, .-main
