	.intel_syntax noprefix
	.text
	.globl	add5
	.type	add5, @function
add5:
	push	rbp
	mov	rbp, rsp
	mov	DWORD PTR -4[rbp], edi
	mov	eax, DWORD PTR -4[rbp]
	add	eax, 5
	pop	rbp
	ret
	.size	add5, .-add5
