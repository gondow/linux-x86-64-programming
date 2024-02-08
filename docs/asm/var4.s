	.data

	.bss
	.align 4
	.type	x, @object
	.size	x, 4
x:
	.zero	4

	.local	y
	.comm	y,4,4

	.text
	.globl	main
	.type	main, @function
main:
	endbr64
	ret
	.size	main, .-main
