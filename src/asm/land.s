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
	movl	x(%rip), %eax
	cmpl	$50, %eax
	jle	.L2
	movl	x(%rip), %eax
	cmpl	$199, %eax
	jg	.L2
	movl	$1, %eax
	jmp	.L4
.L2:
	movl	$0, %eax
.L4:
	popq	%rbp
	ret
