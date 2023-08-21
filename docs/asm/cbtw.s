# asm/cbtw.s
    .text
    .globl main
    .type main, @function
main:
    movb $-1, %al
    cbtw   # %al -> %ax
    #cbw
    cwtl   # %ax -> %eax
    #cwde
    cwtd   # %ax -> %dx:%ax
    #cwd
    cltd   # %eax -> %edx:%eax
    #cdq
    cltq   # %eax -> %rax
    #cdqe
    cqto   # %rax -> %rdx:%rax
    #cqo
    ret
    .size main, .-main
