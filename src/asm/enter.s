# asm/enter.s
    .text
    .globl main
    .type main, @function
main:
    enter $0x20, $0
    # 本来はここに関数本体の機械語列が来る
    leave
    ret
    .size main, .-main
