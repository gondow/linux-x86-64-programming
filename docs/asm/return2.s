	.text
	.p2align 4
	.globl	func
	.type	func, @function
func:
	endbr64
	movq	8+f(%rip), %rdx
	movq	f(%rip), %rax
	ret

	.globl	f
	.data
	.align 16
	.type	f, @object
	.size	f, 16
f:
	.byte	65
	.zero	7
	.quad	1234605616436508552
