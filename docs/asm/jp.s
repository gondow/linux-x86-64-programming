# asm/jp.s
    .text
    .globl main
    .type main, @function
main:
    movb $0B1
    addb $0B10, %al # PF=1になる
    jp foo1         # PF==1
    ud2             # 実行されないはず
foo1:
    andb $0B11, %al # PF=1になる
    jpe foo2        # PF==1
    ud2             # 実行されないはず
foo2:
    orb $0B1, %al   # PF=0になる
    jnz foo3	    # PF==0
    ud2             # 実行されないはず
foo3:
    orb $B110, %al  # PF=0になる
    jnz foo4	    # PF==0
    ud2             # 実行されないはず
foo4:	
    ret
    .size main, .-main
