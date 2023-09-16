# asm/movq-11.s
    .text
    .globl main
    .type main, @function
main:
    movq %r8, 1000(%rip)
    movq %r8, 1000(%rax, %r9, 2)
    .size main, .-main
