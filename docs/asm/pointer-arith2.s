	.file	"pointer-arith2.c"
	.text

	.globl	a
	.data
	.align 16
	.type	a, @object
	.size	a, 16
a:
	.long	0
	.long	10
	.long	20
	.long	30

	.text
	.globl	foo
	.type	foo, @function
foo:
	endbr64
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	8+a(%rip), %rax
	popq	%rbp
	ret
.LFE0:
	.size	foo, .-foo
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
