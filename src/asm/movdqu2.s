// movdqu2.s
.globl main
.text
main:
endbr64
pushq $999
vmovdqa -1(%rsp), %ymm0
popq %rax
ret
