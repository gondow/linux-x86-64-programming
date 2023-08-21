# asm/call2.s
    .text

    .type foo, @function
foo:
    ret
    .size foo, .-foo

    .globl main
    .type main, @function
main:
    call foo
    ret
    .size main, .-main
