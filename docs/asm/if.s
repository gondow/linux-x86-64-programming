	.file	"if.c"
	.text
	.section	.text.startup,"ax",@progbits
	.p2align 4
	.globl	main
	.type	main, @function
main:
.LFB0:
	.cfi_startproc
	endbr64
	movl	x(%rip), %eax
	cmpl	$100, %eax
	jle	.L2
	addl	$1, %eax
	movl	%eax, x(%rip)
.L2:
	xorl	%eax, %eax
	ret
	.cfi_endproc
.LFE0:
	.size	main, .-main
	.globl	x
	.data
	.align 4
	.type	x, @object
	.size	x, 4
x:
	.long	111
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
