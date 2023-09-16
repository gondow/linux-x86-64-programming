# asm/jo.s
    .text
    .globl main
    .type main, @function
main:
    movb $1, %al
    addb $0x7F, %al # OF=1になる
    jo foo1         # OF==1
    ud2             # 実行されないはず
foo1:
    addb $1, %al    # OF=0になる
    jno foo2        # OF==0
    ud2             # 実行されないはず
foo2:
    ret
    .size main, .-main
