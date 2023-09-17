	.file	"switch3.c"
	.text
	.globl	x
	.data
	.align 4
	.type	x, @object
	.size	x, 4
x:
	.long	111
	.text
	.globl	main
	.type	main, @function
main:
	endbr64
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$64, %rsp
	movq	%fs:40, %rax
	movq	%rax, -8(%rbp)
	xorl	%eax, %eax
	leaq	.L2(%rip), %rax
	movq	%rax, -64(%rbp)
	leaq	.L3(%rip), %rax
	movq	%rax, -56(%rbp)
	leaq	.L4(%rip), %rax
	movq	%rax, -48(%rbp)
	leaq	.L5(%rip), %rax
	movq	%rax, -40(%rbp)
	leaq	.L6(%rip), %rax
	movq	%rax, -32(%rbp)
	leaq	.L7(%rip), %rax
	movq	%rax, -24(%rbp)
	movl	x(%rip), %eax
	cltq
	movq	-64(%rbp,%rax,8), %rax
	nop
	jmp	*%rax
.L3:
	endbr64
	movl	x(%rip), %eax
	addl	$1, %eax
	movl	%eax, x(%rip)
	jmp	.L9
.L4:
	endbr64
	movl	x(%rip), %eax
	subl	$1, %eax
	movl	%eax, x(%rip)
	jmp	.L9
.L5:
	endbr64
	movl	$3, x(%rip)
	jmp	.L9
.L6:
	endbr64
	movl	$4, x(%rip)
	jmp	.L9
.L7:
	endbr64
	movl	$5, x(%rip)
	jmp	.L9
.L2:
	endbr64
	movl	$0, x(%rip)
	nop
.L9:
	movl	$0, %eax
	movq	-8(%rbp), %rdx
	subq	%fs:40, %rdx
	je	.L11
	call	__stack_chk_fail@PLT
.L11:
	leave
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
