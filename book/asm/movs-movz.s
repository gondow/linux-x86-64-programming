# asm/movs-movz.s
    .text
    .globl main
    .type main, @function
main:
    movl  $0xFFFFFFFF, %eax
    movslq %eax, %rbx
    movzwq %ax, %rbx
    ret
    .size main, .-main
