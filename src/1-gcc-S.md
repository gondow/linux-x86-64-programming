# アセンブリ言語の概要
## Cコードからアセンブリコードを出力してみる



まず以下の簡単なCのプログラム`add5.c`を用意して下さい．

```C
int add5 (int n)
{
    return n + 5;
}
```

以下のコマンドを実行して，`add5.s`を作成して下さい．
これで「アセンブリ言語で書かれたプログラム（アセンブリコード）」がどんなものかを見れます．

```bash
$ gcc -S add5.c
$ ls
add5.c  add5.s
```

<!-- ![gcc-S](figs/gcc-S.svg) -->
<img src="figs/gcc-S.svg" height="50px">


`-S`オプションをつけてコンパイルすると，
`gcc`はCのプログラム(`add5.c`)からアセンブリコード(`add5.s`)を生成します．
`add5.s`の中身は以下の通りです．

> 注意：
> gccのバージョンの違いにより，同じLinuxでも`add5.s`の中身が以下と異なることがあります．

以下では表示が長いので省略しています．
全てを表示するには<i class="fa fa-eye"></i>ボタンを押して下さい．
（ここでは`add5.s`の中身は理解できなくてOKです）．

```bash
$ cat add5.s
	.file	"add5.c"
	.text
	.globl	add5
	.type	add5, @function
add5:
.LFB0:
	.cfi_startproc
	endbr64
	pushq	%rbp
~	.cfi_def_cfa_offset 16
~	.cfi_offset 6, -16
~	movq	%rsp, %rbp
~	.cfi_def_cfa_register 6
~	movl	%edi, -4(%rbp)
~	movl	-4(%rbp), %eax
~	addl	$5, %eax
~	popq	%rbp
~	.cfi_def_cfa 7, 8
~	ret
~	.cfi_endproc
~.LFE0:
~	.size	add5, .-add5
~	.ident	"GCC: (Ubuntu 9.4.0-1ubuntu1~20.04.1) 9.4.0"
~	.section	.note.GNU-stack,"",@progbits
~	.section	.note.gnu.property,"a"
~	.align 8
~	.long	 1f - 0f
~	.long	 4f - 1f
~	.long	 5
~0:
~	.string	 "GNU"
~1:
~	.align 8
~	.long	 0xc0000002
~	.long	 3f - 2f
~2:
~	.long	 0x3
~3:
~	.align 8
~4:
```

```x86asmatt
~1: # コメント
        .text
        .globl  add5
        .type   add5, @function
add5:
	endbr64
        pushq   %rbp
        movq    %rsp, %rbp
        movl    %fs:%edi, -4(%rbp)
        movl    -4(%rbp), %eax
        movl    +4(%rbp), %eax
        movl    4(%rbp), %eax
        movl    add5(%rbp), %eax
        addl    $5, %eax
        addl    $-5, %eax
        addl    -8(%rbp), %eax
        popq    %rbp
	jmp add5
        jmp 1f
        ret
.data
.ascii "hello, world\n"
.byte '\n'
.byte '\\'
.byte '\n'
.byte '\''
.byte '\x4a'
.long 74
.long 0112
.long 0x4a
.long 0b01001010

```

```x86asm
        .text
        .globl  add5
        .type   add5, @function
add5:
        endbr64
        push    rbp
        mov     rbp, rsp
        mov     DWORD PTR -4[rbp], edi
        mov     eax, DWORD PTR -4[rbp]
        add     eax, 5
        pop     rbp
        ret
        .size   add5, .-add5
```
