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
	movl	$100, x(%rip)
	movl	x(%rip), %eax
	popq	%rbp
	ret
