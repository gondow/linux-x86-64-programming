# asm/stack-frame.s
    .text
    .type foo, @function
foo:
    pushq %rbp
    movq %rsp, %rbp	
    subq $32, %rsp
    # 本来はここにfoo関数本体の機械語列が来る
    leave # movq %rbp, %rsp; pop %rbp と同じ
    ret

    .globl main
    .type main, @function
main:
    call foo
    ret
    .size main, .-main
