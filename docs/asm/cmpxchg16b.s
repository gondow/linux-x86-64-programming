# asm/cmpxchg16b.s
    .text
    .globl main
    .type main, @function
main:
    pushq %rbp       # cmpxchg16b実行時に%rspを16バイトアライメントにするために必要
    movq $111, %rax
    movq $222, %rdx
    movq $333, %rcx
    movq $444, %rbx
    pushq %rdx
    pushq %rax
    lock cmpxchg16b (%rsp)  # 成功
    movq $555, %rcx
    movq $666, %rbx
    lock cmpxchg16b (%rsp)  # 失敗
    popq %rbx 
    popq %rbx 
    popq %rbp
    ret
    .size main, .-main
