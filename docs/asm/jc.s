# asm/jc.s
    .text
    .globl main
    .type main, @function
main:
    movb $1, %al
    addb $0xFF, %al # CF=1になる
    jc foo1         # CF==1
    ud2             # 実行されないはず
foo1:
    addb $1, %al    # CF=0になる
    jnc foo2        # CF==0
    ud2             # 実行されないはず
foo2:
    ret
    .size main, .-main
