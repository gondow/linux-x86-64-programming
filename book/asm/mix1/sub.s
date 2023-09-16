# asm/mix1/sub.s
    .text
    .globl sub
    .type sub, @function
sub:
    pushq %rbp
    movq  %rsp, %rbp
    subq  %rsi, %rdi
    movq  %rdi, %rax
    leave
    ret
    .size sub, .-sub
