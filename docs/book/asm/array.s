	.text
	.p2align 4
	.globl	foo
	.type	foo, @function
foo:
	endbr64
	movslq	%esi, %rsi
	movl	(%rdi,%rsi,4), %eax
	ret
	.size	foo, .-foo
