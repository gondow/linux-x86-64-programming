# asm/rcl-1.s
    .text
    .globl main
    .type main, @function
main:
    movq $0B11111111, %rax
    movb $3, %cl
    movq $0xFFFFFFFFFFFFFFFF, %rbx
    addq $1, %rbx  # オーバーフローでCFが立つ
    rclq %rax
    rclq $2, %rax
    rclq %cl, %rax
    ret
    .size main, .-main
