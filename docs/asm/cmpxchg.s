# asm/cmpxchg.s
    .text
    .globl main
    .type main, @function
main:
    movq $999, %rax
    movq $1000, %rbx
    pushq %rax
    lock cmpxchg %rbx, (%rsp)  # 成功
    movq $1001, %rbx
    lock cmpxchg %rbx, (%rsp)  # 失敗
    popq %rbx 
    ret
    .size main, .-main
