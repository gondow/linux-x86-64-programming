# add5.s
    .text
    .globl add5
    .type add5, @function
add5:
    pushq %rbp
    movq  %rsp, %rbp
    movl  %edi, -4(%rbp)
    movl  -4(%rbp), %eax
    addl  $5, %eax
    popq  %rbp
    ret
    .size  add5, .-add5

