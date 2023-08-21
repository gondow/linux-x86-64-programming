# asm/jz.s
    .text
    .globl main
    .type main, @function
main:
    movb $-1, %al
    addb $1, %al    # ZF=1になる
    jz foo1         # ZF==1
    ud2             # 実行されないはず
foo1:
    cmpb $0, %al    # ZF=1になる
    je foo2         # ZF==1
    ud2             # 実行されないはず
foo2:
    addb $1, %al    # ZF=0になる
    jnz foo3	    # ZF==0
    ud2             # 実行されないはず
foo3:
    cmpb $9, %al    # ZF=0になる
    jnz foo4	    # ZF==0
    ud2             # 実行されないはず
foo4:	
    ret
    .size main, .-main
