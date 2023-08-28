# asm/js.s
    .text
    .globl main
    .type main, @function
main:
    movb $1, %al
    addb $-2, %al   # SF=1になる
    js foo1         # SF==1
    ud2             # 実行されないはず
foo1:
    addb $2, %al    # SF=0になる
    jns foo2        # SF==0
    ud2             # 実行されないはず
foo2:
    ret
    .size main, .-main
