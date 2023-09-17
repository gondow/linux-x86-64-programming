	.file	"binop-div.c"
	.text

	.globl	x
	.data
	.align 4
	.type	x, @object
	.size	x, 4
x:
	.long	111
	.globl	y
	.align 4
	.type	y, @object
	.size	y, 4
y:
	.long	9

	.text
	.globl	main
	.type	main, @function
main:
	endbr64
	pushq	%rbp
	movq	%rsp, %rbp
	movl	x(%rip), %eax
	movl	y(%rip), %ecx
	cltd
	idivl	%ecx
	popq	%rbp
	ret
.LFE0:
	.size	main, .-main
	.ident	"GCC: (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0"
	.section	.note.GNU-stack,"",@progbits
	.section	.note.gnu.property,"a"
	.align 8
	.long	1f - 0f
	.long	4f - 1f
	.long	5
0:
	.string	"GNU"
1:
	.align 8
	.long	0xc0000002
	.long	3f - 2f
2:
	.long	0x3
3:
	.align 8
4:
