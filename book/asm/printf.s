# asm/printf.s
    .section .rodata
L_fmt:
    .string "%d\n"

    .text
    .globl main
    .type sub, @function
main:
    pushq %rbp
    movq  %rsp, %rbp
    leaq  L_fmt(%rip), %rdi
    movq  $999,  %rsi
#    pushq $888   # ❶このコメントを外すと segmentation fault になることも
    movb  $0, %al # ❷
    call  printf
    leave
    ret
    .size main, .-main
