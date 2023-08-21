# asm/mix2/main.s
    .text
    .globl main
    .type sub, @function
main:
    pushq %rbp
    movq %rsp, %rbp
    movq $23,  %rdi
    movq $7,   %rsi
    call sub
    leave
    ret
    .size main, .-main
