# asm/call.s
    .text

    .type foo, @function
foo:
    ret
    .size foo, .-foo

    .globl main
    .type main, @function
main:
    call foo
    leaq foo(%rip), %rax  # %rax に関数fooの先頭アドレスが入る
    call *%rax
    pushq %rax            # (%rsp) に関数fooの先頭アドレスが入る
    call *(%rsp)
    popq %rax
    ret
    .size main, .-main
