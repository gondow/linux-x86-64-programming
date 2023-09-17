	.file	"clobber-mem.c"
	.text
	.section	.text.startup,"ax",@progbits
	.p2align 4
	.globl	main
	.type	main, @function
main:
.LFB23:
	.cfi_startproc
	endbr64
	movl	x(%rip), %eax
	movl	%eax, y(%rip)
	ret
	.cfi_endproc
.LFE23:
	.size	main, .-main
	.globl	y
	.data
	.align 4
	.type	y, @object
	.size	y, 4
y:
	.long	222
	.globl	x
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
