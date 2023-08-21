# asm/jge.s
    .text
    .globl main
    .type main, @function
main:
    movq $0, %rax
    cmpq $0, %rax
    jge foo1         # %rax >= 0
    ud2            # 実行されないはず
foo1:
    cmpq $0, %rax
    jnl foo2       # !(%rax < 0)
    ud2            # 実行されないはず
foo2:
    ret
    .size main, .-main
