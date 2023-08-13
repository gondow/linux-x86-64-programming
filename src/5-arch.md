<style type="text/css">
body { counter-reset: chapter 5; }
</style>

# アーキテクチャ

## 一般的なコンピュータの構成要素



## レジスタ
### 汎用レジスタ

<img src="figs/gp-regs.svg" height="350px" id="fig:gp-regs">

- 上記16個のレジスタが**汎用レジスタ**(general-purpose register)です．
  原則として，プログラマが自由に使えます．
- ただし，`%rsp`は**スタックポインタ**，`%rbp`は**ベースポインタ**と呼び，
  [一番上のスタックフレームの上下を指す](./2-asm-intro.md#stack-rsp-rbp)
  という役割があります．
  (ただし，[-fomit-frame-pointer](./2-asm-intro.md#-fomit-frame-pointer)
  オプションでコンパイルされた`a.out`中では，`%rbp`はベースポインタとしてではなく，
  汎用レジスタとして使われています)．

#### [caller-save/callee-saveレジスタ](./6-inst.md#caller-callee-save-regs)

| | 汎用レジスタ |
|-|-|
|caller-saveレジスタ| `%rax`, `%rcx`, `%rdx`, `%rsi`, `%rdi`, `%r8`〜`%r11`|
|callee-saveレジスタ| `%rbx`, `%rbp`, `%rsp`, `%r12`〜`%r15`|

#### [引数](./6-inst.md#arg-reg)

|引数|レジスタ|
|-|-|
|第1引数 | `%rdi` |
|第2引数 | `%rsi` |
|第3引数 | `%rdx` |
|第4引数 | `%rcx` |
|第5引数 | `%r8` |
|第6引数 | `%r9` |

### プログラムカウンタ（命令ポインタ）

<img src="figs/rip.svg" height="100px" id="fig:rip">

### [ステータスレジスタ（フラグレジスタ）](./6-inst.md#status-reg)

<img src="figs/rflags.svg" height="100px" id="fig:rflags">

#### 本書で扱うフラグ

ステータスレジスタのうち，本書は以下の6つのフラグを扱います．

|フラグ|名前|説明|
|-|-|-|
|`CF`|キャリーフラグ |算術演算で結果の最上位ビットにキャリーかボローが生じるとセット．それ以外はクリア．符号**なし**整数演算でのオーバーフロー状態を表す．|
|`OF`|オーバーフローフラグ |符号ビット(MSB)を除いて，整数の演算結果が大きすぎるか小さすぎるかするとセット．それ以外はクリア．2の補数表現での符号**あり**整数演算のオーバーフロー状態を表す．|
|`ZF`|ゼロフラグ |結果がゼロの時にセット．それ以外はクリア．|
|`SF`|符号フラグ |符号あり整数の符号ビット(MSB)と同じ値をセット．(0は正の数，1は負の数であることを表す)|
|`PF`|パリティフラグ |結果の最下位バイトの値1のビットが偶数個あればセット，奇数個であればクリア．|
|`AF`|調整フラグ |算術演算で，結果のビット3にキャリーかボローが生じるとセット．それ以外はクリア．BCD演算で使用する(本書ではほとんど使いません)．|


#### ステータスフラグの変化の記法

x86-64命令を実行すると，ステータスフラグが変化する命令と
変化しない命令があります．
ステータスフラグの変化は以下の記法で表します．

|[CF](#status-reg)|[OF](#status-reg)|[SF](#status-reg)|[ZF](#status-reg)|[PF](#status-reg)|[AF](#status-reg)|
|-|-|-|-|-|-|
|&nbsp;|!|?|0|1| |

記法の意味は以下の通りです．

<div id="status-reg">

| 記法 | 意味 |
|-|-|
|空白|フラグ値に変化なし|
|!|フラグ値に変化あり|
|?|フラグ値は未定義(参照禁止)|
|0|フラグ値はクリア(0になる)|
|1|フラグ値はセット(1になる)|

</div>

### レジスタの別名

#### `%rax`レジスタの別名 (`%rbx`, `%rcx`, `%rdx`も同様)

<img src="figs/reg-alias1.svg" height="150px" id="fig:reg-alias1">

- `%rax`の下位32ビットは`%eax`としてアクセス可能
- `%eax`の下位16ビットは`%ax`としてアクセス可能
- `%ax`の上位8ビットは`%ah`としてアクセス可能
- `%ax`の下位8ビットは`%al`としてアクセス可能

#### `%rbp`レジスタの別名 (`%rsp`, `%rdi`, `%rsi`も同様)

<img src="figs/reg-alias2.svg" height="150px" id="fig:reg-alias2">

- `%rbp`の下位32ビットは`%ebp`としてアクセス可能
- `%ebp`の下位16ビットは`%bp`としてアクセス可能
- `%bp`の下位8ビットは`%bpl`としてアクセス可能

#### `%r8`レジスタの別名 (`%r9`〜`%r15`も同様)

<img src="figs/reg-alias3.svg" height="150px" id="fig:reg-alias3">

- `%r8`の下位32ビットは`%r8d`としてアクセス可能
- `%r8d`の下位16ビットは`%r8w`としてアクセス可能
- `%r8w`の下位8ビットは`%r8b`としてアクセス可能

#### 同時に使えない制限

- 一部のレジスタは`%ah`, `%bh`, `%ch`, `%dh`と一緒には使えない．
- 例：`movb %ah, (%r8)` や `movb %ah, %bpl`はエラーになる．
- 正確には`REX`プレフィックス付きの命令では，`%ah`, `%bh`, `%ch`, `%dh`を使えない．

### 32ビットレジスタ上の演算は64ビットレジスタの上位32ビットをゼロにする

- 例:`movl $0xAABBCCDD, %eax`を実行すると`%rax`の上位32ビットが全てゼロになる
- 例: `movw $0x1122, %ax`や`movb $0x11, %al`では上位をゼロにすることはない

<details>
<summary>
上位32ビットをゼロにする実行例
</summary>

<img src="figs/zero-upper32.svg" height="250px" id="fig:zero-upper32">

```x86asmatt
{{#include asm/zero-upper32.s}}
```

```
$ gcc -g zero-upper32.s
$ gdb ./a.out -x zero-upper32.txt
Breakpoint 1, main () at zero-upper32.s:7
7	    movl $0xAABBCCDD, %eax
6	    movq $0x1122334455667788, %rax
7	    movl $0xAABBCCDD, %eax
$1 = 0x1122334455667788
8	    movq $0x1122334455667788, %rax
$2 = 0xaabbccdd
# 以下が出力されれば成功
# $1 = 0x1122334455667788
# $2 = 0xaabbccdd
```
</details>
