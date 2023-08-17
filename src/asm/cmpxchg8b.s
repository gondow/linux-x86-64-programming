# asm/cmpxchg8b.s
    .text
    .globl main
    .type main, @function
main:
    movl $111, %eax
    movl $222, %edx
    movl $333, %ecx
    movl $444, %ebx
    movl %edx, 4(%rsp)
    movl %eax, 0(%rsp)
    lock cmpxchg8b (%rsp)  # 成功
    movl $555, %ecx
    movl $666, %ebx
    lock cmpxchg8b (%rsp)  # 失敗
    popq %rbx 
    ret
    .size main, .-main
