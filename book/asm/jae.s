# asm/jae.s
    .text
    .globl main
    .type main, @function
main:
    movq $10, %rax
    cmpq $0, %rax
    jae foo1         # %rax >= 0
    ud2            # 実行されないはず
foo1:
    cmpq $0, %rax
    jnb foo2       # !(%rax < 0)
    ud2            # 実行されないはず
foo2:
    ret
    .size main, .-main
