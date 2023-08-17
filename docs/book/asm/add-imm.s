# asm/add-imm.s
    .text
    .globl main
    .type main, @function
main:
    movq $0, %rax
    addl $0xFFFFFFFF, %eax          # OK (0xFFFFFFFF = -1)
#    addq $0xFFFFFFFF, %rax         # NG (0x7FFFFFFFを超えている)
    addq $0xFFFFFFFFFFFFFFFF, %rax  # OK (0xFFFFFFFFFFFFFFFF = -1)
    addq $0x7FFFFFFF, %rax          # OK
    addq $-0x80000000, %rax         # OK
    addq $0xFFFFFFFF80000000, %rax  # OK (0xFFFFFFFF80000000 = -0x80000000)
    ret
    .size main, .-main
