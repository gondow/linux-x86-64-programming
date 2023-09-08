# asm/jmp.s
    .text
    .globl main
    .type main, @function
foo2:
    jmp main3
.skip 1024
foo1:
    jmp main2
main:
    jmp foo1
main2:
    jmp foo2
main3:
    movq $main4, %rax
    jmp *%rax
main4:
    pushq $main5
    jmp *(%rsp)
main5:
    ret
    .size main, .-main
