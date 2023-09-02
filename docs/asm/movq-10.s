# asm/movq-10.s
    .text
    .globl main
    .type main, @function
main:
    movq %r8, %rax
    movq %r8, (%rax)
    movq %r8, 8(%rax)
    movq %r8, 1000(%rax)
    .size main, .-main
