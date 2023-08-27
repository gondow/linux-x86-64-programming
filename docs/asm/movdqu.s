.globl main
.text
main:
endbr64
pushq $999 # for 16 byte alignment
pushw $0x1111
pushw $0x2222
pushw $0x3333
pushw $0x4444
pushw $0x5555
pushw $0x6666
pushw $0x7777
pushw $0x8888
pushw $0x9999
pushw $0xAAAA
pushw $0xBBBB
pushw $0xCCCC
pushw $0xDDDD
pushw $0xEEEE
pushw $0xFFFF
pushw $0x1122

vmovdqu (%rsp), %ymm0
vmovdqu (%rsp), %xmm0
vmovdqu %xmm0, %xmm1
int3

