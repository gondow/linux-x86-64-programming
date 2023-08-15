# asm/push-pop.s
    .text
    .globl main
    .type main, @function
main:
#    pushq $0x1122334455667788  # こう書けない(push命令は64ビット即値を扱えない)ので次の2命令に分けて書く
    movq $0x1122334455667788, %rax
    pushq %rax
    popq  %rbx
    ret
    .size main, .-main
