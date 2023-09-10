# file1.s
    .text
    .global foo
foo:
    .globl main
    .type main, @function
main:
    ret
    .size main, .-main
