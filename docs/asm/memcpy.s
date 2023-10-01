	.file	"memcpy.c"
	.text
	.section	.text.startup,"ax",@progbits
	.p2align 4
	.globl	main
	.type	main, @function
main:
.LFB35:
	.cfi_startproc
	endbr64
	movdqa	src(%rip), %xmm0
	movdqa	16+src(%rip), %xmm1
	xorl	%eax, %eax
	movdqa	32+src(%rip), %xmm2
	movdqa	48+src(%rip), %xmm3
	movaps	%xmm0, dst(%rip)
	movaps	%xmm1, 16+dst(%rip)
	movaps	%xmm2, 32+dst(%rip)
	movaps	%xmm3, 48+dst(%rip)
	ret
	.cfi_endproc
.LFE35:
	.size	main, .-main
	.globl	dst
	.bss
	.align 32
	.type	dst, @object
	.size	dst, 4096
dst:
	.zero	4096
	.globl	src
	.align 32
	.type	src, @object
	.size	src, 4096
src:
	.zero	4096
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
