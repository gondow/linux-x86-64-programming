# asm/jbe.s
    .text
    .globl main
    .type main, @function
main:
    movq $0, %rax
    cmpq $10, %rax
    jbe foo1         # %rax <= 10
    ud2            # 実行されないはず
foo1:
    cmpq $10, %rax
    jna foo2       # !(%rax > 10)
    ud2            # 実行されないはず
foo2:
    ret
    .size main, .-main
