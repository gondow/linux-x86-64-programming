# sym-main.s
	.text
	.globl	main
	.type	main, @function
main:
	movl	x(%rip), %eax # ラベル x の参照
	ret
	.size	main, .-main
