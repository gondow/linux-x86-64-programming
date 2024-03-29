<style type="text/css">
body { counter-reset: chapter 12; }
</style>

# x86-64 命令一覧

## 概要と記号

[`add5.c`](./asm/add5.c)を`gcc -S add5.c`でコンパイルした結果
[`add5.s`](./asm/add5.s)(余計なものの削除後)を用いて，
x86-64アセンブリ言語の概要と記号を説明します．

<img src="figs/add5.svg" height="300px" id="fig:add5">

- `$ gcc -S add5.c`を実行(コンパイル)すると，アセンブリコード`add5.s`が生成されます．(結果は環境依存なので，`add5.s`の中身が違ってても気にしなくてOK)
- ドット記号 `.` で始まるのは**アセンブラ命令**(assembler directive)です．
- コロン記号 `:` で終わるのは**ラベル定義**です．
- シャープ記号 `#` から行末までと，`/*`と`*/`で囲まれた範囲(複数行可)は**コメント**です．
- `movq %rsp, %rbp` は**機械語命令**(2進数)の記号表現(**ニモニック**(mnemonic))です．`movq`が命令で**オペコード**(opcode)，`%rsp`と`%rbp`は引数で**オペランド**(operand)と呼ばれます．
- ドル記号 `$` で始まるのは**即値**(immediate value，定数)です．
- パーセント記号 `%`で始まるのは**レジスタ**です．
- `-4(%rbp)`は[間接メモリ参照](./6-inst.md#addr-mode-indirect)です．この場合は「`%rbp-4`の計算結果」をアドレスとするメモリの内容にアクセスすることを意味します．

## 命令サフィックス

| AT&T形式の<br/>サイズ指定 | Intel形式の<br/>サイズ指定 | メモリオペランドの<br/>サイズ | AT&T形式での例 | Intel形式での例 |
|:-:|-|-|-|-|
|`b`|`BYTE PTR`|1バイト(8ビット)|`movb $10, -8(%rbp)` | `mov BYTE PTR [rbp-8], 10` |
|`w`|`WORD PTR`|2バイト(16ビット)|`movw $10, -8(%rbp)` | `mov WORD PTR [rbp-8], 10` |
|`l`|`DWORD PTR`|4バイト(32ビット)|`movl $10, -8(%rbp)` | `mov DWORD PTR [rbp-8], 10` |
|`q`|`QWORD PTR`|8バイト(64ビット)|`movq $10, -8(%rbp)` | `mov QWORD PTR [rbp-8], 10` |

- [間接メモリ参照](./6-inst.md#addr-mode-indirect)ではサイズ指定が必要です
  (「何バイト読み書きするのか」が決まらないから)
- AT&T形式では**命令サフィックス**(instruction suffix)でサイズを指定します．
  例えば`movq $10, -8(%rbp)`の`q`は，
  「メモリ参照`-8(%rbp)`への書き込みサイズが8バイト」であることを意味します．

<details>
<summary>
サフィックスとプリフィックス
</summary>

サフィックス(suffix)は**接尾語**(後ろに付けるもの)，
プリフィックス(prefix)は**接頭語**(前に付けるもの)という意味です．
</details>

- Intel形式ではメモリ参照の前に，`BYTE PTR`などと指定します．
- 他のオペランドからサイズが決まる場合は命令サフィックスを省略可能です．
  例えば，`movq %rax, -8(%rsp)`は`mov %rax, -8(%rsp)`にできます．
  `mov`命令の2つのオペランドはサイズが同じで
  `%rax`レジスタのサイズが8バイトだからです．

## 即値(定数)

<!--
| 種類 | 説明 | 例 |
|-|-|-|
|10進数定数|`0`で始まらない| `pushq $74`|
|16進数定数|`0x`か`0X`で始まる|`pushq $0x4A`|
|8進数定数|`0`で始まる|`pushq $0112`|
|2進数定数|`0b`か`0B`で始まる|`pushq $0b01001010`|
|文字定数|`'`(クオート)で始まる| `pushq $'J`|
|文字定数|`'`(クオート)で囲む| `pushq $'J'`|
|文字定数|`\`バックスラッシュ<br/>でエスケープ可|`pushq $'\n`|
-->

<div class="table-wrapper"><table><thead><tr><th>種類</th><th>説明</th><th>例</th></tr></thead><tbody>
<tr><td>10進数定数</td><td><code>0</code>で始まらない</td><td><code>pushq $74</code></td></tr>
<tr><td>16進数定数</td><td><code>0x</code>か<code>0X</code>で始まる</td><td><code>pushq $0x4A</code></td></tr>
<tr><td>8進数定数</td><td><code>0</code>で始まる</td><td><code>pushq $0112</code></td></tr>
<tr><td>2進数定数</td><td><code>0b</code>か<code>0B</code>で始まる</td><td><code>pushq $0b01001010</code></td></tr>
<tr><td rowspan="3">文字定数</td><td><code>'</code>(クオート)で始まる</td><td><code>pushq $'J</code></td></tr>
<tr><td><code>'</code>(クオート)で囲む</td><td><code>pushq $'J'</code></td></tr>
<tr><td><code>\</code>バックスラッシュ<br/>でエスケープ可</td
><td><code>pushq $'\n</code></td></tr>
</tbody></table>
</div>  

- **即値**(immediate value，定数)には`$`をつけます
- 上の例の定数は最後以外は全部，値が同じです
- GNUアセンブラでは文字定数の値は[ASCIIコード](./4-data.md#ASCII)です．
  上の例では，文字`'J'`の値は`74`です．
- バックスラッシュでエスケープできる文字は，
  `\b`, `\f`, `\n`, `\r`, `\t`,  `\"`, `\\` です．
  また`\123`は8進数，`\x4F`は16進数で指定した文字コードになります．
- 多くの場合，即値は32ビットまでで，
  オペランドのサイズが64ビットの場合，
  32ビットの即値は，64ビットの演算前に
  **64ビットに[符号拡張](./4-data.md#符号拡張)** されます
  ([ゼロ拡張](./4-data.md#ゼロ拡張)だと
	負の値が大きな正の値になって困るから)

<details>
<summary>
64ビットに符号拡張される例(1)
</summary>

<div id="imm-64bit-signed-extended">

```x86asmatt
{{#include asm/add-imm2.s}}
```

上の`addq $-1, %rax`命令の即値`$-1`は
32ビット(以下の場合もあります)の符号あり整数`$0xFFFFFFFF`として
機械語命令に埋め込まれます．
`addq`命令が実行される時は，
この`$0xFFFFFFFF`が64ビットに符号拡張されて`$0xFFFFFFFFFFFFFFFF`となります．
以下の実行例でもこれが確認できました．

```
0 + 0xFFFFFFFFFFFFFFFF = 0xFFFFFFFFFFFFFFFF
```

```
$ gcc -g add-imm2.s
$ gdb ./a.out -x add-imm2.txt
Breakpoint 1, main () at add-imm2.s:8
8	    ret
7	    addq $-1, %rax
$1 = 0xffffffffffffffff
# 0xffffffffffffffff が表示されていれば成功
```

</div>

</details>

<details>
<summary>
64ビットに符号拡張される例(2)
</summary>

32ビットの即値が，64ビットの演算前に64ビットに符号拡張されることを見てみます．
32ビット符号あり整数が表現できる範囲は`-0x80000000`から`0x7FFFFFFF`です．

```x86asmatt
{{#include asm/add-imm.s}}
```

- 7行目の`$0xFFFFFFFF`は32ビット符号あり整数として`-1`，
  つまり32ビット符号あり整数が表現できる範囲内なのでOKです．
- 一方，8行目の`$0xFFFFFFFF`は
  64ビット符号あり整数として`$0x7FFFFFFF`を超えてるのでNGです．
  (アセンブルするとエラーになります)
- 9行目の`$0xFFFFFFFFFFFFFFFF`は一見NGですが，
  64ビット符号あり整数としての値は`-1`なので，
  GNUアセンブラはこの即値を`-1`として機械語命令に埋め込みます．
- いちばん大事なのは最後の2つの`addq`命令です．
  `addq $-0x80000000, %rax`の
  即値`$-0x80000000`は(機械語命令中では32ビットで埋め込まれますが)
  足し算を実行する前に64ビットに符号拡張されるので，
  `$0xFFFFFFFF80000000`という値で足し算されます．
  (つまり，`$0x80000000`を引きます)．
  以下の実行例を見ると，その通りの実行結果になっています．
  
  - `❶ 0x17ffffffd - $0x80000000 = ❷ 0xfffffffd`
  - `❷ 0xfffffffd - $0x80000000 = ❸ 0x7ffffffd`

  一方，もし `$-0x80000000`を(符号拡張ではなく)
  **[ゼロ拡張](4-data.md#ゼロ拡張)** すると，
  `$0x0000000080000000`となるので，
  `$0x80000000`を(引くのではなく)足すことになってしまいます．
  

```
$ gcc -g add-imm.s
$ gdb ./a.out -x add-imm.txt
Breakpoint 1, main () at add-imm.s:7
7	    addl $0xFFFFFFFF, %eax          # OK (0xFFFFFFFF = -0x1)
9	    addq $0xFFFFFFFFFFFFFFFF, %rax  # OK (0xFFFFFFFFFFFFFFFF = -0x1)
1: /x $rax = 0xffffffff
10	    addq $0x7FFFFFFF, %rax          # OK
1: /x $rax = 0xfffffffe
11	    addq $-0x80000000, %rax         # OK
1: /x $rax = ❶ 0x17ffffffd
12	    addq $0xFFFFFFFF80000000, %rax  # OK (0xFFFFFFFF80000000 = -0x80000000)
1: /x $rax = ❷ 0xfffffffd
main () at add-imm.s:13
13	    ret
1: /x $rax = ❸ 0x7ffffffd
#以下が表示されていれば成功
#1: /x $rax = 0xffffffff
#1: /x $rax = 0xfffffffe
#1: /x $rax = 0x17ffffffd
#1: /x $rax = 0xfffffffd
#1: /x $rax = 0x7ffffffd
```

以下の通り，逆アセンブルすると，
32ビット以下の即値として機械語命令中に埋め込まれていることが分かります．

```
$ gcc -g add-imm.s
$ objdump -d ./a.out
0000000000001129 <main>:
    1129:	48 c7 c0 00 00 00 00 	mov    $0x0,%rax
    1130:	83 c0 ff             	add    $0xffffffff,%eax
    1133:	48 83 c0 ff          	add    $0xffffffffffffffff,%rax
    1137:	48 05 ff ff ff 7f    	add    $0x7fffffff,%rax
    113d:	48 05 00 00 00 80    	add    $0xffffffff80000000,%rax
    1143:	48 05 00 00 00 80    	add    $0xffffffff80000000,%rax
    1149:	c3                   	ret    
```


</details>

- `mov`命令は例外で64ビットの即値を扱えます

<details>
<summary>
64ビットの即値を扱う例
</summary>

<div id="mov-64bit-imm">

```x86asmatt
{{#include asm/movqabs-1.s}}
```

```
$ gcc -g movqabs-1.s
$ gdb ./a.out -x movqabs-1.txt
Breakpoint 1, main () at movqabs-1.s:6
6	    movq $0x1122334455667788, %rax
7	    movabsq $0x99AABBCCDDEEFF00, %rax
1: /x $rax = 0x1122334455667788
main () at movqabs-1.s:8
8	    ret
1: /x $rax = 0x99aabbccddeeff00
# 以下が表示されれば成功
# 1: /x $rax = 0x1122334455667788
# 1: /x $rax = 0x99aabbccddeeff00
```

</div>

</details>


- ジャンプでは64ビットの相対ジャンプができないので，
  間接ジャンプを使う必要がある

<details>
<summary>
64ビットの相対ジャンプの代わりに間接ジャンプを使う例
</summary>

```x86asmatt
{{#include asm/jmp-64bit.s}}
```

`0x1122334455667788`はいい加減なアドレスなので，
コンパイルは可能ですが，実行すると segmentation fault になります．
</details>

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

- 第7引数以降はレジスタではなくスタックを介して渡します

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

<!--
### セグメントレジスタ
-->

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
- 正確には[`REX`プリフィクス](./4-data.md#REX-prefix)付きの命令では，`%ah`, `%bh`, `%ch`, `%dh`を使えない．

### 32ビットレジスタ上の演算は64ビットレジスタの上位32ビットをゼロにする{#zero-upper32}

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
$2 = 0x00000000aabbccdd
# 以下が出力されれば成功
# $1 = 0x1122334455667788 (%raxは8バイトの値を保持)
# $2 = 0x00000000aabbccdd (%raxの上位4バイトがゼロになった)
```
</details>

## アドレッシングモード(オペランドの記法)
### アドレッシングモードの種類

<div class="table-wrapper"><table><thead><tr><th>アドレッシング<br/>モードの種類</th><th>オペランドの値</th><th>例</th><th>計算するアドレス</th></tr></thead>
<tbody>
<tr><td rowspan="2">

[即値(定数)](./6-inst.md#addr-mode-imm)
</td><td rowspan="2">定数の値</td><td><code>movq $0x100, %rax</code></td></tr>
<tr><td><code>movq $foo, %rax</code></td></tr>
<tr><td>

[レジスタ参照](./6-inst.md#addr-mode-reg)
<br/></td><td>レジスタの値</td><td><code>movq %rbx, %rax</code></td></tr>
<tr><td rowspan="2">

[直接メモリ参照](./6-inst.md#addr-mode-direct)
</td><td rowspan="2">定数で指定した<br/>アドレスのメモリ値</td><td><code>movq 0x100, %rax</code></td><td><code>0x100</code></td></tr>
<tr><td><code>movq foo, %rax</code></td><td><code>foo</code></td></tr>
<tr><td rowspan="3">

[間接メモリ参照](./6-inst.md#addr-mode-indirect)
</td><td rowspan="3">レジスタ等で計算した<br/>アドレスのメモリ値</td><td><code>movq (%rsp), %rax</code></td><td><code>%rsp</code></td></tr>
<tr><td><code>movq 8(%rsp), %rax</code></td><td><code>%rsp+8</code></td></tr>
<tr><td><code>movq foo(%rip), %rax</code></td><td><code>%rip+foo</code></td></tr>
</tbody></table>
</div>

- `foo`はラベルであり，定数と同じ扱い．(定数を書ける場所にはラベルも書ける)．
- メモリ参照では例えば`-8(%rbp, %rax, 8)`など複雑なオペランドも指定可能．
  参照するメモリのアドレスは`-8+%rbp+%rax*8`になる．
  ([以下](#メモリ参照)を参照)．

### メモリ参照の形式

| | [AT&T形式](./7-asm.md#att-intel) | [Intel形式](./7-asm.md#att-intel)| 計算されるアドレス | 
|-|-|-|-|
|通常のメモリ参照|disp (base, index, scale)|[base + index * scale + disp]| base + index * scale + disp|
|`%rip`相対参照  | disp (`%rip`) | [rip + disp]| `%rip` + disp |

> 注：
> Intelのマニュアルには「segment: メモリ参照」という形式もあるとありますが，
> segment: はほとんど使わないので，省いて説明します．

<details>
<summary>
segmentは使わないの?(いえ，ちょっと使います)
</summary>

<div id="segment-override">
segment(正確にはsegment-override)はx86-64ではほとんど使いません．
が，segmentを使ったメモリ参照をする場合があります．
例えば，`%fs:0xfffffffffffffffc`がその例です．

`%fs`は**セグメントレジスタ**と呼ばれる16ビット長のレジスタで，
他には`%cs`，`%ds`，`%ss`，`%es`，`%gs`があります．
x86-64では`%cs`，`%ds`，`%ss`，`%es`は常にベースアドレスが0と扱われます．
`%fs:`という記法が使われた時は，
「`%fs`レジスタが示す**ベースアドレス**をアクセスするアドレスに加える」
ことを意味します．

`%fs`のベースレジスタの値を得るには次の方法があります．

- `arch_prctl()`システムコールを使う (ここでは説明しません)．
- `gdb`で`p/x $fs_base`を実行する．
  (なお，`p/x $fs`を実行すると`0`が返りますがこの値は嘘です)
- `rdfsbase`命令を使う．

<details>
<summary>
rdfsbase命令はCPUとOSの設定に依存
</summary>

`rdfsbase`命令が使えるかどうかは，CPUとOSの設定に依存します．
`/proc/cpuinfo`の`flags`の表示に`fsgsbase`があれば，`rdfsbase`命令は使えます．
(以下の出力例では`fsgsbase`が入っています)．

```
$ less /proc/cpuinfo
processor       : 0
cpu family      : 6
model name      : Intel(R) Core(TM) i9-9880H CPU @ 2.30GHz
(一部略)
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 ss syscall nx pdpe1gb rdtscp lm constant_tsc arch_perfmon nopl xtopology tsc_reliable nonstop_tsc cpuid tsc_known_freq pni pclmulqdq ssse3 fma cx16 pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand hypervisor lahf_lm abm 3dnowprefetch cpuid_fault invpcid_single ssbd ibrs ibpb stibp ibrs_enhanced fsgsbase tsc_adjust bmi1 avx2 smep bmi2 invpcid rdseed adx smap clflushopt xsaveopt xsavec xgetbv1 xsaves arat md_clear flush_l1d arch_capabilities
```
</details>

Linuxでは`%fs:`や`%gs:`を使って
**スレッドローカルストレージ**(TLS)を実現しています．
スレッドローカルストレージとは「スレッドごとの(一種の)グローバル変数」です．
マルチスレッドはスレッド同士がメモリ空間を共有しているので，
普通にグローバル変数を使うと，他のスレッドに内容が破壊される可能性があります．
スレッドローカルストレージを使えば，他のスレッドに破壊される心配がなくなります．
スレッドごとに`%fs`レジスタの値を変えて，
（プログラム上では同じ変数に見えても）スレッドごとに別のアドレスを
参照させて実現しているのでしょう．
(CPUがスレッドの実行を停止・再開するたびに，
スレッドが使用しているレジスタの値も退避・回復するので，
見た目上，「スレッドはそれぞれ独自のレジスタセットを持っている」ように動作します)．

C11からは`_Thread_local`，`gcc`では`__thread`というキーワードで，
スレッドローカルな変数を宣言できます．

```
// tls.c
#include <stdio.h>
❶ __thread int x = 0xdeadbeef;
int main ()
{
    printf ("x=%x\n", x);
}
```

```
$ gcc -g tls.c
$ ./a.out
x=deadbeef
$ objdump -d ./a.out | less
0000000000001149 <main>:
    1149:  f3 0f 1e fa             endbr64 
    114d:  55                      push   %rbp
    114e:  48 89 e5                mov    %rsp,%rbp
    1151:  64 8b 04 25 fc ff ff    mov  ❷ %fs:0xfffffffffffffffc,%eax
    1158:  ff 
    1159:  89 c6                   mov    %eax,%esi
```

```
$ gdb ./a.out
(gdb) b main
Breakpoint 1 at 0x1151: file tls.c, line 5.
(gdb) r
Breakpoint 1, main () at tls.c:5
5	    printf ("x=%x\n", x);
(gdb) p/x x
$1 = 0xdeadbeef
(gdb) ❸ p/x $fs_base
$2 = ❹ 0x7ffff7fa9740
(gdb) x/1wx $fs_base - 4
0x7ffff7fa973c:	❺ 0xdeadbeef
```

- ❶ `__thread`キーワードを使って，変数`x`をスレッドローカルにします．
- コンパイルした`a.out`を逆アセンブルすると，
  ❷ `%fs:0xfffffffffffffffc`というメモリ参照があります．
  これがスレッドローカルな変数`x`の実体の場所で，
  「`%fsのベースレジスタ - 4`」が`x`のアドレスになります．
- ❸ `p/x $fs_base`を使って，`%fsのベースレジスタ`の値を調べると
  ❹  `0x7ffff7fa9740`と分かりました．
- アドレス`$fs_base - 4`のメモリの中身(4バイト)を調べると，
  変数`x`の値である❺ `0xDEADBEEF`が入っていました．

<!--
leaq $fs:-4, %rax とすると，アセンブラに怒られる．
gccは  movq %fs:0, %rax で，アドレスを入手している．
つまり，%fs:0番地に%fsのベースレジスタの値が書き込まれていることが前提になっている．
-->

<details>
<summary>
0xDEADBEEFとは
</summary>

バイナリ上でデバッグする際，「ありそうもない値」を使うと便利なことがあります．
`1`や`2`だと偶然の一致がありますが，「ありそうもない値」を使うと
「高い確率でこれは私が書き込んだ値だよね」と分かるからです．
`0xDEADBEEF`は正しい16進数でありながら，英単語としても読めるので，
「ありそうもない値」として便利です．
他には`CAFEBABE`もよく使われます．
`0xDEADBEEF`や`0xCAFEBABE`はバイナリを識別するマジックナンバーとしても使われます．
</details>

<details>
<summary>
%fs:はスタック保護でも使われる
</summary>

```
$ gcc -S -fstack-protector-all add5.c
```

[`add5.c`](./asm/add5.c)を`-fstack-protector-all`オプションで
スタック保護機能をオンにしてコンパイルします．
(最近のLinuxの`gcc`のデフォルトでは，`-fstack-protector-strong`が有効に
なっています．これはバッファを使用する関数のみにスタック保護機能を加えます．
ここでは`-fstack-protector-all`を使って全関数にスタック保護機能を加えました)．

```x86asmatt
    .text
    .globl  add5
    .type   add5, @function
add5:
    endbr64
    pushq   %rbp
    movq    %rsp, %rbp
    subq    $32, %rsp
    movl    %edi, -20(%rbp)
    movq ❶ %fs:40, %rax
    movq ❷ %rax, -8(%rbp)
    xorl    %eax, %eax
    movl    -20(%rbp), %eax
    addl    $5, %eax
    movq ❸ -8(%rbp), %rdx
    subq ❹ %fs:40, %rdx
    je      .L3
    call ❺ __stack_chk_fail@PLT
.L3:
    leave   
    ret     
    .size   add5, .-add5
```

-  関数の最初の方で，スレッドローカルストレージの❶ `%fs:40`の値を，
   (`%rax`経由で)スタック上の`-8(%rbp)`に書き込みます．
- 関数の終わりの方で，❸`-8(%rbp)`の値を`%rdx`レジスタにコピーし，
  ❹ `%fs:40`の値を引き算しています．
- もし，引き算の結果がゼロでなければ(つまり❸と❹の値が異なれば)，
「バッファオーバーフローが起きた」と判断して，
 ❺ `__stack_chk_fail@PLT`を呼び出して
 プロセスを強制終了させます(つまりバッファオーバーフロー攻撃を防げたことになります)．

<!--
> 注:「`-8(%rbp)`を飛び越してバッファオーバーフローを起こせたら，
> あるいは偶然，❸と❹の値が同じになってしまったら，
> バッファオーバーフローを検知できないのでは?」と思った方，正解です．
-->
</details>

<!--
TLSの話はここが詳しい．
https://fasterthanli.me/series/making-our-own-executable-packer/part-13
https://www.kernel.org/doc/html/v5.9/x86/x86_64/fsgs.html

C11から，_Thread_local
GCC拡張 __thread
-->
</div>
</details>


### メモリ参照で可能な組み合わせ(64ビットモードの場合)

#### 通常のメモリ参照

<img src="figs/memory-ref.svg" height="250px" id="fig:memory-ref">

- disp には符号あり定数を指定する．ただし「64ビット定数」は無いことに注意．
  アドレス計算時に64ビット長に符号拡張される．
  dispは変位(displacement)を意味する．
- base には上記のいずれかのレジスタを指定可能．省略も可．
- index には上記のいずれかのレジスタを指定可能．省略も可．
  `%rsp`を指定できないことに注意．
- scale を省略すると `1` と同じ

> 注: dispの例外．
> `mov␣`命令のみ，64ビットのdispを指定可能．
> この場合，`movabs␣`というニモニックを使用可能．
> メモリ参照はdispのみで，base，index，scaleは指定不可．
> 他方のオペランドは`%rax`のみ指定可能．
>
> ```
> movq     0x1122334455667788, %rax
> movabsq  0x1122334455667788, %rax
> movq     %rax, 0x1122334455667788
> movabsq  %rax, 0x1122334455667788
> ```

#### `%rip`相対参照

<img src="figs/rip-relative.svg" height="120px" id="fig:rip-relative">

`%rip`相対参照では32ビットのdispと`%rip`レジスタのみが指定可能です．

### メモリ参照の例

| [AT&T形式](./7-asm.md#att-intel) | [Intel形式](./7-asm.md#att-intel) | 指定したもの | 計算するアドレス |
|-|-|-|-|
|`8`|`[8]`|disp | `8` |
|`foo`|`[foo]`|disp | `foo`|
|`(%rbp)`|`[rbp]` |base | `%rbp` |
| `8(%rbp)`|`[rbp+8]`|dispとbase | `%rbp + 8`|
| `foo(%rbp)`|`[rbp+foo]`|dispとbase | `%rbp + foo`|
| `8(%rbp,%rax)`|`[rbp+rax+8]`|dispとbaseとindex | `%rbp + %rax + 8`|
| `8(%rbp,%rax, 2)`|`[rbp+rax*2+8]`|dispとbaseとindexとscale | `%rbp + %rax*2 + 8`|
|`(%rip)`|`[rip]` |base | `%rip` |
| `8(%rip)`|`[rip+8]`|dispとbase | `%rip + 8`|
| `foo(%rip)`|`[rip+foo]`|dispとbase | `%rip + foo`|
| `%fs:-4` | `fs:[-4]` | [segment](#segment-override)とdisp | `%fsのベースレジスタ - 4` |

- メモリに読み書きするサイズの指定方法 (先頭アドレスだけだと，何バイト読み書きすればいいのか不明):
  - AT&T形式では[命令サフィックス](#命令サフィックス) (`q`, `l`, `w`, `b`)で指定する．例: `movq $4, 8(%rbp)`

  - Intel形式では，メモリ参照の前に
    `QWORD PTR`, `DWORD PTR`, `WORD PTR`, `BYTE PTR`を付加する
    (順番に，8バイト，4バイト，2バイト，1バイトを意味する)．
    例: `mov QWORD PTR [rbp+8], 4
    

## 「記法」「詳しい記法」欄で用いるオペランドの記法と注意{#詳しい記法}

以下の機械語命令の説明で使う記法を説明します．
この記法はその命令に許されるオペランドの形式を表します．

### オペランド，即値(定数)

<!--
| 記法 | 例 | 説明 |
|-|-|-|
|*op1*|  | 第1オペランド |
|*op2*|  | 第2オペランド |
|*imm*| `$100` |  *imm8*, *imm16*, *imm32*のどれか |
|*imm8*| `$100` | 8ビットの即値(定数) |
|*imm16*| `$100` | 16ビットの即値(定数) |
|*imm32*| `$100` | 32ビットの即値(定数) |
-->

<div class="table-wrapper"><table><thead><tr><th>記法</th><th>例</th><th>説明</th></tr></thead><tbody>
<tr><td><em>op1</em></td><td></td><td>第1オペランド</td></tr>
<tr><td><em>op2</em></td><td></td><td>第2オペランド</td></tr>
<tr><td rowspan="2"><em>imm</em></td><td><code>$100</code></td><td rowspan="2"><em>imm8</em>, <em>imm16</em>, <em>imm32</em>のどれか</td></tr>
<tr><td><code>$foo</code></td></tr>
<tr><td><em>imm8</em></td><td><code>$100</code></td><td>8ビットの即値(定数)</td></tr> 
<tr><td><em>imm16</em></td><td><code>$100</code></td><td>16ビットの即値(定数)</td></tr>
<tr><td><em>imm32</em></td><td><code>$100</code></td><td>32ビットの即値(定数)</td></tr>
</tbody></table>
</div>

- 多くの場合，サイズを省略して単に*imm*と書きます．
  特にサイズに注意が必要な時だけ，*imm32*などとサイズを明記します．
- [一部例外を除き](./x86-list.md#mov-64bit-imm)，
  x86-64では64ビットの即値を書けません(32ビットまでです)．


### 汎用レジスタ

| 記法 | 例 | 説明 |
|-|-|-|
|*r*  | `%rax`|  *r8*, *r16*, *r32*, *r64*のどれか |
|*r8* | `%al` | 8ビットの汎用レジスタ |
|*r16*| `%ax` | 16ビットの汎用レジスタ |
|*r32*| `%eax`| 32ビットの汎用レジスタ |
|*r64*| `%rax`| 64ビットの汎用レジスタ |

### メモリ参照

<!--
| 記法 | 例 | 説明 |
|-|-|-|
|*r/m*  | `-8(%rbp)` |  *r/m8*, *r/m16*, *r/m32*, *r/m64*のどれか |
|*r/m8* | `-8(%rbp)` | *r8*  または 8ビットのメモリ参照 |
|*r/m16*| `-8(%rbp)` | *r16* または16ビットのメモリ参照 |
|*r/m32*| `-8(%rbp)` | *r32* または32ビットのメモリ参照 |
|*r/m64*| `-8(%rbp)` | *r64* または64ビットのメモリ参照 |
-->
 
<div class="table-wrapper"><table><thead><tr><th>記法</th><th>例</th><th>説明</th></tr></thead><tbody>
<tr><td rowspan="4"><em>r/m</em></td><td><code>%rbp</code></td><td rowspan="4"><em>r/m8</em>, <em>r/m16</em>, <em>r/m32</em>, <em>r/m32</em>, <em>r/m64</em>のどれか</td></tr>
<tr><td><code>100</code></td></tr>
<tr><td><code>-8(%rbp)</code></td></tr>
<tr><td><code>foo(%rbp)</code></td></tr>

<tr><td><em>r/m8</em></td><td><code>-8(%rbp)</code></td><td><em>r8</em>  または 8ビットのメモリ参照</td></tr>
<tr><td><em>r/m16</em></td><td><code>-8(%rbp)</code></td><td><em>r16</em> また
は16ビットのメモリ参照</td></tr>
<tr><td><em>r/m32</em></td><td><code>-8(%rbp)</code></td><td><em>r32</em> また
は32ビットのメモリ参照</td></tr>
<tr><td><em>r/m64</em></td><td><code>-8(%rbp)</code></td><td><em>r64</em> また
は64ビットのメモリ参照</td></tr>
<tr><td><em>m</em></td><td><code>-8(%rbp)</code></td><td> メモリ参照</td></tr>
</tbody></table>
</div>

### ジャンプ・コール用のオペランド

<!--
| 記法 | 例 | 説明 |
|-|-|-|
|*rel*  | `0x100` |  *rel8*, *rel32*のどちらか |
|*rel8* | `0x100` |  8ビット相対アドレス(直接ジャンプ，定数だが$は不要)|
|*rel32*| `0x1000` |  32ビット相対アドレス(直接ジャンプ，定数だが$は不要)|
|*\*r/m64*| `*-8(%rbp)` | *r64* または64ビットのメモリ参照による<br/>絶対・間接ジャンプ (`*`を前につける) |
-->

<div class="table-wrapper"><table><thead><tr><th>記法</th><th>例</th><th>説明</th></tr></thead><tbody>
<tr><td rowspan="2"><em>rel</em></td><td><code>0x100</code></td><td rowspan="2"><em>rel8</em>, <em>rel32</em>のどちらか</td></tr>
<tr><td><code>foo</code></td></tr>
<tr><td><em>rel8</em></td><td><code>0x100</code></td><td>8ビット相対アドレス(直接ジャンプ，定数だが<code>$</code>は不要)</td></tr>
<tr><td><em>rel32</em></td><td><code>0x1000</code></td><td>32ビット相対アドレス(直接ジャンプ，定数だが<code>$</code>は不要)</td></tr>
<tr><td rowspan="3"><em>*r/m64</em></td><td><code>*%rax</code></td><td rowspan="3"><em>r64</em> または64ビットのメモリ参照による絶対アドレス<br/>(間接ジャンプ，<code>*</code>が前に必要)</td></tr>
<tr><td><code>*(%rax)</code></td></tr>
<tr><td><code>*-8(%rax)</code></td></tr>
</tbody></table>
</div>

- GNUアセンブラの記法のおかしな点
  - 直接ジャンプ先の指定*rel*は，定数なのに`$`をつけてはいけない
  - 間接ジャンプ先の指定*\*r/m64*は，
    (他の*r/m*オペランドでは不要だったのに) `*`をつけなくてはいけない
  - 相対アドレスで`rel8`か`rel32`をプログラマは選べない
    (`jmp`命令に命令サフィックス`b`や`l`をつけると怒られる．アセンブラにお任せするしか無い)

- `*%rax`と`*(%rax)`の違いに注意(以下の図を参照)

<img src="figs/indirect-jmp.svg" height="200px" id="fig:indirect-jmp">

## データ転送(コピー)系の命令

### `mov`命令: データの転送（コピー）

<div id="mov-plain">

---
|[記法](./x86-list.md#詳しい記法)|何の略か| 動作 |
|-|-|-|
|**`mov␣`** *op1*, *op2*| move | *op1*の値を*op2*にデータ転送(コピー) |
---

<!--
|[詳しい記法](./x86-list.md#詳しい記法)| 例 | 例の動作 | [サンプルコード](./6-inst.md#how-to-execute-x86-inst) | 
|-|-|-|-|
|**`mov␣`** *r*, *r/m*| `movq %rax, %rbx` | `%rbx = %rax` |[movq-1.s](./asm/movq-1.s) [movq-1.txt](./asm/movq-1.txt)|
|| `movq %rax, -8(%rsp)` | `*(%rsp - 8) = %rax` |[movq-2.s](./asm/movq-2.s) [movq-2.txt](./asm/movq-2.txt)|
|**`mov␣`** *r/m*, *r*| `movq -8(%rsp), %rax` | `%rax = *(%rsp - 8)` |[movq-3.s](./asm/movq-3.s) [movq-3.txt](./asm/movq-3.txt)|
|**`mov␣`** *imm*, *r*| `movq $999, %rax` | `%rax = 999` | [movq-4.s](./asm/movq-4.s) [movq-4.txt](./asm/movq-4.txt)|
|**`mov␣`** *imm*, *r/m*| `movq $999, -8(%rsp)` | `*(%rsp - 8) = 999` |[movq-5.s](./asm/movq-5.s) [movq-5.txt](./asm/movq-5.txt)||
-->

<div class="table-wrapper"><table><thead><tr><th><a href="./x86-list.html#詳しい記法">詳しい記法</a></th><th>例</th><th>例の動作</th><th><a href="./6-inst.html#how-to-execute-x86-inst">サンプルコード</a></th></tr></thead><tbody>
<tr><td rowspan="2"><strong><code>mov␣</code></strong> <em>r</em>, <em>r/m</em></td><td><code>movq %rax, %rbx</code></td><td><code>%rbx = %rax</code></td><td><a href="./asm/movq-1.s">movq-1.s</a> <a href="./asm/movq-1.txt">movq-1.txt</a></td></tr>
<tr><td><code>movq %rax, -8(%rsp)</code></td><td><code>*(%rsp - 8) = %rax</code></td><td><a href="./asm/movq-2.s">movq-2.s</a> <a href="./asm/movq-2.txt">movq-2.txt</a></td></tr>
<tr><td><strong><code>mov␣</code></strong> <em>r/m</em>, <em>r</em></td><td><code>movq -8(%rsp), %rax</code></td><td><code>%rax = *(%rsp - 8)</code></td><td><a href="./asm/movq-3.s">movq-3.s</a> <a href="./asm/movq-3.txt">movq-3.txt</a></td></tr>
<tr><td><strong><code>mov␣</code></strong> <em>imm</em>, <em>r</em></td><td><code>movq $999, %rax</code></td><td><code>%rax = 999</code></td><td><a href="./asm/movq-4.s">movq-4.s</a> <a href="./asm/movq-4.txt">movq-4.txt</a></td></tr>
<tr><td><strong><code>mov␣</code></strong> <em>imm</em>, <em>r/m</em></td><td><code>movq $999, -8(%rsp)</code></td><td><code>*(%rsp - 8) = 999</code></td><td><a href="./asm/movq-5.s">movq-5.s</a> <a href="./asm/movq-5.txt">movq-5.txt</a></td></tr>
</tbody></table>
</div>

---
<div style="font-size: 70%;">

|[CF](./x86-list.md#status-reg)|[OF](./x86-list.md#status-reg)|[SF](./x86-list.md#status-reg)|[ZF](./x86-list.md#status-reg)|[PF](./x86-list.md#status-reg)|[AF](./x86-list.md#status-reg)|
|-|-|-|-|-|-|
|&nbsp;| | | | | |


</div>

---
</div>


- `␣`は[命令サフィックス](#命令サフィックス)
- `mov`命令(および他のほとんどのデータ転送命令)はステータスフラグの値を変更しない
- `mov`命令はメモリからメモリへの直接データ転送はできない

### `xchg`命令: オペランドの値を交換

---
|[記法](./x86-list.md#詳しい記法)|何の略か| 動作 |
|-|-|-|
|**`xchg`** *op1*, *op2* | exchange| *op1* と *op2* の値を交換する |
---
|[詳しい記法](./x86-list.md#詳しい記法)| 例 | 例の動作 | [サンプルコード](./6-inst.md#how-to-execute-x86-inst) | 
|-|-|-|-|
|**`xchg`** *r*, *r/m* | `xchg %rax, (%rsp)` | `%rax`と`(%rsp)`の値を交換する|[xchg.s](./asm/xchg.s) [xchg.txt](./asm/xchg.txt)|
|**`xchg`** *r/m*, *r* | `xchg (%rsp), %rax` | `(%rsp)`と`%rax`の値を交換する|[xchg.s](./asm/xchg.s) [xchg.txt](./asm/xchg.txt)|
---
<div style="font-size: 70%;">

|[CF](./x86-list.md#status-reg)|[OF](./x86-list.md#status-reg)|[SF](./x86-list.md#status-reg)|[ZF](./x86-list.md#status-reg)|[PF](./x86-list.md#status-reg)|[AF](./x86-list.md#status-reg)|
|-|-|-|-|-|-|
|&nbsp;| | | | | |

</div>

- `xchg`命令は**アトミックに**2つのオペランドの値を交換します．(LOCKプリフィクスをつけなくてもアトミックになります)
- この**アトミック**な動作はロックなどの**同期機構**を作るために使えます．

### `lea`命令: 実効アドレスを計算

---
|[記法](./x86-list.md#詳しい記法)|何の略か| 動作 |
|-|-|-|
|**`lea␣`** *op1*, *op2* | load effective address| *op1* の実効アドレスを *op2* に代入する |
---
|[詳しい記法](./x86-list.md#詳しい記法)| 例 | 例の動作 | [サンプルコード](./6-inst.md#how-to-execute-x86-inst) | 
|-|-|-|-|
|**`lea␣`** *m*, *r* | `leaq -8(%rsp, %rsi, 4), %rax` | `%rax=%rsp+%rsi*4-8`|[lea.s](./asm/lea.s) [lea.txt](./asm/lea.txt)|
---
<div style="font-size: 70%;">

|[CF](./x86-list.md#status-reg)|[OF](./x86-list.md#status-reg)|[SF](./x86-list.md#status-reg)|[ZF](./x86-list.md#status-reg)|[PF](./x86-list.md#status-reg)|[AF](./x86-list.md#status-reg)|
|-|-|-|-|-|-|
|&nbsp;| | | | | |

</div>

### `push`と`pop`命令: スタックとデータ転送

---
|[記法](./x86-list.md#詳しい記法)|何の略か| 動作 |
|-|-|-|
|**`push␣`** *op1* | push | *op1* をスタックにプッシュ|
|**`pop␣`** *op1* | pop | スタックから *op1* にポップ|
---
|[詳しい記法](./x86-list.md#詳しい記法)| 例 | 例の動作 | [サンプルコード](./6-inst.md#how-to-execute-x86-inst) | 
|-|-|-|-|
|**`push␣`** *imm* | `pushq $999` | `%rsp-=8; *(%rsp)=999`|[push1.s](./asm/push1.s) [push1.txt](./asm/push1.txt)|
|**`push␣`** *r/m16* | `pushw %ax` | `%rsp-=2; *(%rsp)=%ax`|[push2.s](./asm/push2.s) [push2.txt](./asm/push2.txt)|
|**`push␣`** *r/m64* | `pushq %rax` | `%rsp-=8; *(%rsp)=%rax`|[push-pop.s](./asm/push-pop.s) [push-pop.txt](./asm/push-pop.txt)|
|**`pop␣`** *r/m16* | `popw %ax` | `*(%rsp)=%ax; %rsp += 2`|[pop2.s](./asm/pop2.s) [pop2.txt](./asm/pop2.txt)|
|**`pop␣`** *r/m64* | `popq %rbx` | `%rbx=*(%rsp); %rsp += 8`|[push-pop.s](./asm/push-pop.s) [push-pop.txt](./asm/push-pop.txt)|
---
<div style="font-size: 70%;">

|[CF](./x86-list.md#status-reg)|[OF](./x86-list.md#status-reg)|[SF](./x86-list.md#status-reg)|[ZF](./x86-list.md#status-reg)|[PF](./x86-list.md#status-reg)|[AF](./x86-list.md#status-reg)|
|-|-|-|-|-|-|
|&nbsp;| | | | | |

</div>

## 四則演算・論理演算の命令

### `add`, `adc`命令: 足し算

---
|[記法](./x86-list.md#詳しい記法)|何の略か| 動作 |
|-|-|-|
|**`add␣`** *op1*, *op2* | add | *op1* を *op2* に加える |
|**`adc␣`** *op1*, *op2* | add with carry | *op1* と CF を *op2* に加える |
---
|[詳しい記法](./x86-list.md#詳しい記法)| 例 | 例の動作 | [サンプルコード](./6-inst.md#how-to-execute-x86-inst) | 
|-|-|-|-|
|**`add␣`** *imm*, *r/m* | `addq $999, %rax` | `%rax += 999`|[sub-1.s](./asm/sub-1.s) [sub-1.txt](./asm/sub-1.txt)|
|**`add␣`** *r*, *r/m* | `addq %rax, (%rsp)` | `*(%rsp) += %rax`|[add-2.s](./asm/add-2.s) [add-2.txt](./asm/add-2.txt)|
|**`add␣`** *r/m*, *r* | `addq (%rsp), %rax` | `%rax += *(%rsp)`|[add-2.s](./asm/add-2.s) [add-2.txt](./asm/add-2.txt)|
|**`adc␣`** *imm*, *r/m* | `adcq $999, %rax` | `%rax += 999 + CF`|[adc-1.s](./asm/adc-1.s) [adc-1.txt](./asm/adc-1.txt)|
|**`adc␣`** *r*, *r/m* | `adcq %rax, (%rsp)` | `*(%rsp) += %rax + CF`|[adc-2.s](./asm/adc-2.s) [adc-2.txt](./asm/adc-2.txt)|
|**`adc␣`** *r/m*, *r* | `adcq (%rsp), %rax` | `%rax += *(%rsp) + CF`|[adc-3.s](./asm/adc-3.s) [adc-3.txt](./asm/adc-3.txt)|
---
<div style="font-size: 70%;">

|[CF](./x86-list.md#status-reg)|[OF](./x86-list.md#status-reg)|[SF](./x86-list.md#status-reg)|[ZF](./x86-list.md#status-reg)|[PF](./x86-list.md#status-reg)|[AF](./x86-list.md#status-reg)|
|-|-|-|-|-|-|
|!|!|!|!|!|!|

</div>

- `add`と`adc`はオペランドが符号**あり**整数か符号**なし**整数かを区別せず，
両方の結果を正しく計算する．

### `sub`, `sbb`命令: 引き算

---
|[記法](./x86-list.md#詳しい記法)|何の略か| 動作 |
|-|-|-|
|**`sub␣`** *op1*, *op2* | subtract  | *op1* を *op2* から引く |
|**`sbb␣`** *op1*, *op2* | subtract with borrow | *op1* と CF を *op2* から引く |
---
|[詳しい記法](./x86-list.md#詳しい記法)| 例 | 例の動作 | [サンプルコード](./6-inst.md#how-to-execute-x86-inst) | 
|-|-|-|-|
|**`sub␣`** *imm*, *r/m* | `subq $999, %rax` | `%rax -= 999`|[sub-1.s](./asm/sub-1.s) [sub-1.txt](./asm/sub-1.txt)|
|**`sub␣`** *r*, *r/m* | `subq %rax, (%rsp)` | `*(%rsp) -= %rax`|[sub-2.s](./asm/sub-2.s) [sub-2.txt](./asm/sub-2.txt)|
|**`sub␣`** *r/m*, *r* | `subq (%rsp), %rax` | `%rax -= *(%rsp)`|[sub-2.s](./asm/sub-2.s) [sub-2.txt](./asm/sub-2.txt)|
|**`sbb␣`** *imm*, *r/m* | `sbbq $999, %rax` | `%rax -= 999 + CF`|[sbb-1.s](./asm/sbb-1.s) [sbb-1.txt](./asm/sbb-1.txt)|
|**`sbb␣`** *r*, *r/m* | `sbbq %rax, (%rsp)` | `*(%rsp) -= %rax + CF`|[sbb-2.s](./asm/sbb-2.s) [sbb-2.txt](./asm/sbb-2.txt)|
|**`sbb␣`** *r/m*, *r* | `sbbq (%rsp), %rax` | `%rax -= *(%rsp) + CF`|[sbb-2.s](./asm/sbb-2.s) [sbb-2.txt](./asm/sbb-2.txt)|
---
<div style="font-size: 70%;">

|[CF](./x86-list.md#status-reg)|[OF](./x86-list.md#status-reg)|[SF](./x86-list.md#status-reg)|[ZF](./x86-list.md#status-reg)|[PF](./x86-list.md#status-reg)|[AF](./x86-list.md#status-reg)|
|-|-|-|-|-|-|
|!|!|!|!|!|!|

</div>

- `add`と同様に，`sub`と`sbb`は
  オペランドが符号**あり**整数か符号**なし**整数かを区別せず，
  両方の結果を正しく計算する．

### `mul`, `imul`命令: かけ算

---
|[記法](./x86-list.md#詳しい記法)|何の略か| 動作 |
|-|-|-|
|**`mul␣`** *op1*  | unsigned multiply| 符号なし乗算．`(%rdx:%rax) = %rax` * *op1* |
|**`imul␣`** *op1* | signed multiply |  符号あり乗算．`(%rdx:%rax) = %rax` * *op1* |
|**`imul␣`** *op1*, *op2* | signed multiply |  符号あり乗算．*op2* *= *op1*|
|**`imul␣`** *op1*, *op2*, *op3* | signed multiply |  符号あり乗算．*op3* = *op1* * *op2*|
---
|[詳しい記法](./x86-list.md#詳しい記法)| 例 | 例の動作 | [サンプルコード](./6-inst.md#how-to-execute-x86-inst) | 
|-|-|-|-|
|**`mul␣`** *r/m* | `mulq %rbx` | `(%rdx:%rax) = %rax * %rbx`|[mul-1.s](./asm/mul-1.s) [mul-1.txt](./asm/mul-1.txt)|
|**`imul␣`** *r/m* | `imulq %rbx` | `(%rdx:%rax) = %rax * %rbx`|[imul-1.s](./asm/imul-1.s) [imul-1.txt](./asm/imul-1.txt)|
|**`imul␣`** *imm*, *r* | `imulq $4, %rax` | `%rax *= 4`|[imul-2.s](./asm/imul-2.s) [imul-2.txt](./asm/imul-2.txt)|
|**`imul␣`** *r/m*, *r* | `imulq %rbx, %rax` | `%rax *= %rbx`|[imul-2.s](./asm/imul-2.s) [imul-2.txt](./asm/imul-2.txt)|
|**`imul␣`** *imm*, *r/m*, *r* | `imulq $4, %rbx, %rax` | `%rax = %rbx * 4`|[imul-2.s](./asm/imul-2.s) [imul-2.txt](./asm/imul-2.txt)|
---
<div style="font-size: 70%;">

|[CF](./x86-list.md#status-reg)|[OF](./x86-list.md#status-reg)|[SF](./x86-list.md#status-reg)|[ZF](./x86-list.md#status-reg)|[PF](./x86-list.md#status-reg)|[AF](./x86-list.md#status-reg)|
|-|-|-|-|-|-|
|!|!|?|?|?|?|

</div>

- オペランドが1つの形式では，`%rax`が隠しオペランドになる．
  このため，乗算の前に`%rax`に値をセットしておく必要がある．
  また，8バイト同士の乗算結果は最大で16バイトになるので，
  乗算結果を`%rdx`と`%rax`に分割して格納する
  (16バイトの乗算結果の上位8バイトを`%rdx`に，下位8バイトを`%rax`に格納する)．
  これをここでは`(%rdx:%rax)`という記法で表現している．
- `imul`だけ例外的に，オペランドが2つの形式と3つの形式がある．
  2つか3つの形式では乗算結果が64ビットを超えた場合，
  越えた分は破棄される(乗算結果は8バイトのみ)．

### `div`, `idiv`命令: 割り算，余り

---
|[記法](./x86-list.md#詳しい記法)|何の略か| 動作 |
|-|-|-|
|**`div␣`** *op1*  | unsigned divide| 符号なし除算と余り<br/> `%rax = (%rdx:%rax)` / *op1*  <br/> `%rdx = (%rdx:%rax)` % *op1* |
|**`idiv␣`** *op1* | signed divide |  符号あり除算と余り<br/> `%rax = (%rdx:%rax)` / *op1*  <br/> `%rdx = (%rdx:%rax)` % *op1* |


---
|[詳しい記法](./x86-list.md#詳しい記法)| 例 | 例の動作 | [サンプルコード](./6-inst.md#how-to-execute-x86-inst) | 
|-|-|-|-|
|**`div␣`** *r/m* | `divq %rbx` | `%rax = (%rdx:%rax) / %rbx` <br/> `%rdx = (%rdx:%rax) % %rbx` |[div-1.s](./asm/div-1.s) [div-1.txt](./asm/div-1.txt)|
|**`idiv␣`** *r/m* | `idivq %rbx` | `%rax = (%rdx:%rax) / %rbx` <br/> `%rdx = (%rdx:%rax) % %rbx` |[idiv-1.s](./asm/idiv-1.s) [idiv-1.txt](./asm/idiv-1.txt)|
---

<div style="font-size: 70%;">

|[CF](./x86-list.md#status-reg)|[OF](./x86-list.md#status-reg)|[SF](./x86-list.md#status-reg)|[ZF](./x86-list.md#status-reg)|[PF](./x86-list.md#status-reg)|[AF](./x86-list.md#status-reg)|
|-|-|-|-|-|-|
|?|?|?|?|?|?|

</div>

- 16バイトの値 `%rdx:%rax` を第1オペランドで割った商が`%rax`に入り，
  余りが`%rdx`に入る．
- 隠しオペランドとして`%rdx`と`%rax`が使われるので，事前に値を設定しておく必要がある．
  `idiv`を使う場合，もし`%rdx`を使わないのであれば，
  `cqto`命令で`%rax`を`%rdx:%rax`に符号拡張しておくと良い．

### `inc`, `dec`命令: インクリメント，デクリメント

---
|[記法](./x86-list.md#詳しい記法)|何の略か| 動作 |
|-|-|-|
|**`inc␣`** *op1*  | increment | *op1*の値を1つ増加 |
|**`dec␣`** *op1*  | decrement | *op1*の値を1つ減少 |

---
|[詳しい記法](./x86-list.md#詳しい記法)| 例 | 例の動作 | [サンプルコード](./6-inst.md#how-to-execute-x86-inst) | 
|-|-|-|-|
|**`inc␣`** *r/m* | `inc %rax` | `%rax`++|[inc-1.s](./asm/inc-1.s) [inc-1.txt](./asm/inc-1.txt)|
|**`dec␣`** *r/m* | `dec %rax` | `%rax`--|[dec-1.s](./asm/dec-1.s) [dec-1.txt](./asm/dec-1.txt)|
---

<div style="font-size: 70%;">

|[CF](./x86-list.md#status-reg)|[OF](./x86-list.md#status-reg)|[SF](./x86-list.md#status-reg)|[ZF](./x86-list.md#status-reg)|[PF](./x86-list.md#status-reg)|[AF](./x86-list.md#status-reg)|
|-|-|-|-|-|-|
| |?|?|?|?|?|

</div>

- `inc`や`dec`はオーバーフローしてもCFが変化しないところがポイント．

### `neg`命令: 符号反転

---
|[記法](./x86-list.md#詳しい記法)|何の略か| 動作 |
|-|-|-|
|**`neg␣`** *op1*  | negation | 2の補数による*op1*の符号反転 |

---
|[詳しい記法](./x86-list.md#詳しい記法)| 例 | 例の動作 | [サンプルコード](./6-inst.md#how-to-execute-x86-inst) | 
|-|-|-|-|
|**`neg␣`** *r/m* | `neg %rax` | `%rax = -%rax`|[neg-1.s](./asm/neg-1.s) [neg-1.txt](./asm/neg-1.txt)|
---

<div style="font-size: 70%;">

|[CF](./x86-list.md#status-reg)|[OF](./x86-list.md#status-reg)|[SF](./x86-list.md#status-reg)|[ZF](./x86-list.md#status-reg)|[PF](./x86-list.md#status-reg)|[AF](./x86-list.md#status-reg)|
|-|-|-|-|-|-|
|!|!|!|!|!|!|

</div>

### `not`命令: ビット論理演算 (1)

---
|[記法](./x86-list.md#詳しい記法)|何の略か| 動作 |
|-|-|-|
|**`not␣`** *op1*  | bitwise not | *op1*の各ビットの反転 (NOT)|

---
|[詳しい記法](./x86-list.md#詳しい記法)| 例 | 例の動作 | [サンプルコード](./6-inst.md#how-to-execute-x86-inst) | 
|-|-|-|-|
|**`not␣`** *r/m* | `notq %rax` | `%rax = ~%rax`|[not-1.s](./asm/not-1.s) [not-1.txt](./asm/not-1.txt)|
---

<div style="font-size: 70%;">

|[CF](./x86-list.md#status-reg)|[OF](./x86-list.md#status-reg)|[SF](./x86-list.md#status-reg)|[ZF](./x86-list.md#status-reg)|[PF](./x86-list.md#status-reg)|[AF](./x86-list.md#status-reg)|
|-|-|-|-|-|-|
|&nbsp;| | | | | |

</div>

### `and`, `or`, `xor`命令: ビット論理演算 (2)

---
|[記法](./x86-list.md#詳しい記法)|何の略か| 動作 |
|-|-|-|
|**`and␣`** *op1*, *op2*  | bitwise and | *op1*と*op2*の各ビットごとの論理積(AND)|
|**`or␣`** *op1*, *op2*  | bitwise or | *op1*と*op2*の各ビットごとの論理和(OR)|
|**`xor␣`** *op1*, *op2*  | bitwise xor | *op1*と*op2*の各ビットごとの排他的論理和(XOR)|

---
|[詳しい記法](./x86-list.md#詳しい記法)| 例 | 例の動作 | [サンプルコード](./6-inst.md#how-to-execute-x86-inst) | 
|-|-|-|-|
|**`and␣`** *imm*, *r/m* | `andq $0x0FFF, %rax` | `%rax &= 0x0FFF`|[and-1.s](./asm/and-1.s) [and-1.txt](./asm/and-1.txt)|
|**`and␣`** *r*, *r/m* | `andq %rax, (%rsp)` | `*(%rsp) &= %rax`|[and-1.s](./asm/and-1.s) [and-1.txt](./asm/and-1.txt)|
|**`and␣`** *r/m*, *r* | `andq (%rsp), %rax` | `%rax &= *(%rsp)`|[and-1.s](./asm/and-1.s) [and-1.txt](./asm/and-1.txt)|
|**`or␣`** *imm*, *r/m* | `orq $0x0FFF, %rax` | <code>%rax &#124;= 0x0FFF </code> |[or-1.s](./asm/or-1.s) [or-1.txt](./asm/or-1.txt)|
|**`or␣`** *r*, *r/m* | `orq %rax, (%rsp)` | <code>*(%rsp) &#124;= %rax</code> |[or-1.s](./asm/or-1.s) [or-1.txt](./asm/or-1.txt)|
|**`or␣`** *r/m*, *r* | `orq (%rsp), %rax` | <code>%rax &#124;= *(%rsp)</code> |[or-1.s](./asm/or-1.s) [or-1.txt](./asm/or-1.txt)|
|**`xor␣`** *imm*, *r/m* | `xorq $0x0FFF, %rax` | `%rax ^= 0x0FFF`|[xor-1.s](./asm/xor-1.s) [xor-1.txt](./asm/xor-1.txt)|
|**`xor␣`** *r*, *r/m* | `xorq %rax, (%rsp)` | `*(%rsp) ^= %rax`|[xor-1.s](./asm/xor-1.s) [xor-1.txt](./asm/xor-1.txt)|
|**`xor␣`** *r/m*, *r* | `xorq (%rsp), %rax` | `%rax ^= *(%rsp)`|[xor-1.s](./asm/xor-1.s) [xor-1.txt](./asm/xor-1.txt)|
---

<div style="font-size: 70%;">


|[CF](./x86-list.md#status-reg)|[OF](./x86-list.md#status-reg)|[SF](./x86-list.md#status-reg)|[ZF](./x86-list.md#status-reg)|[PF](./x86-list.md#status-reg)|[AF](./x86-list.md#status-reg)|
|-|-|-|-|-|-|
|0|0|!|!|!|?|

</br>

|*x*|*y*|*x* & *y*|*x* &#124; *y*|*x* ^ *y*|
|:-:|:-:|:-:|:-:|:-:|
|0|0|0|0|0|
|0|1|0|1|1|
|1|0|0|1|1|
|1|1|1|1|0|
</div>

- `&`, `|`, `^`はC言語で，それぞれ，ビットごとの論理積，論理和，排他的論理積です
  (忘れた人はC言語を復習しましょう)．

### `sal`, `sar`, `shl`, `shr`命令: シフト


---
|[記法](./x86-list.md#詳しい記法)|何の略か| 動作 |
|-|-|-|
|**`sal␣`** *op1*[, *op2*]  | shift arithmetic left |算術左シフト|
|**`shl␣`** *op1*[, *op2*]  | shift logical left    |論理左シフト|
|**`sar␣`** *op1*[, *op2*]  | shift arithmetic right|算術右シフト|
|**`shr␣`** *op1*[, *op2*]  | shift logical right   |論理右シフト|
---
|[詳しい記法](./x86-list.md#詳しい記法)| 例 | 例の動作 | [サンプルコード](./6-inst.md#how-to-execute-x86-inst) | 
|-|-|-|-|
|**`sal␣`** *r/m* | `salq %rax` | `%rax`を1ビット算術左シフト|[sal-1.s](./asm/sal-1.s) [sal-1.txt](./asm/sal-1.txt)|
|**`sal␣`** *imm8*, *r/m* | `salq $2, %rax` | `%rax`を2ビット算術左シフト|[sal-1.s](./asm/sal-1.s) [sal-1.txt](./asm/sal-1.txt)|
|**`sal␣`** `%cl`, *r/m* | `salq %cl, %rax` | `%rax`を`%cl`ビット算術左シフト|[sal-1.s](./asm/sal-1.s) [sal-1.txt](./asm/sal-1.txt)|
|**`shl␣`** *r/m* | `shlq %rax` | `%rax`を1ビット論理左シフト|[shl-1.s](./asm/shl-1.s) [shl-1.txt](./asm/shl-1.txt)|
|**`shl␣`** *imm8*, *r/m* | `shlq $2, %rax` | `%rax`を2ビット論理左シフト|[shl-1.s](./asm/shl-1.s) [shl-1.txt](./asm/shl-1.txt)|
|**`shl␣`** `%cl`, *r/m* | `shlq %cl, %rax` | `%rax`を`%cl`ビット論理左シフト|[shl-1.s](./asm/shl-1.s) [shl-1.txt](./asm/shl-1.txt)|
|**`sar␣`** *r/m* | `sarq %rax` | `%rax`を1ビット算術右シフト|[sar-1.s](./asm/sar-1.s) [sar-1.txt](./asm/sar-1.txt)|
|**`sar␣`** *imm8*, *r/m* | `sarq $2, %rax` | `%rax`を2ビット算術右シフト|[sar-1.s](./asm/sar-1.s) [sar-1.txt](./asm/sar-1.txt)|
|**`sar␣`** `%cl`, *r/m* | `sarq %cl, %rax` | `%rax`を`%cl`ビット算術右シフト|[sar-1.s](./asm/sar-1.s) [sar-1.txt](./asm/sar-1.txt)|
|**`shr␣`** *r/m* | `shrq %rax` | `%rax`を1ビット論理右シフト|[shr-1.s](./asm/shr-1.s) [shr-1.txt](./asm/shr-1.txt)|
|**`shr␣`** *imm8*, *r/m* | `shrq $2, %rax` | `%rax`を2ビット論理右シフト|[shr-1.s](./asm/shr-1.s) [shr-1.txt](./asm/shr-1.txt)|
|**`shr␣`** `%cl`, *r/m* | `shrq %cl, %rax` | `%rax`を`%cl`ビット論理右シフト|[shr-1.s](./asm/shr-1.s) [shr-1.txt](./asm/shr-1.txt)|
---

<div style="font-size: 70%;">


|[CF](./x86-list.md#status-reg)|[OF](./x86-list.md#status-reg)|[SF](./x86-list.md#status-reg)|[ZF](./x86-list.md#status-reg)|[PF](./x86-list.md#status-reg)|[AF](./x86-list.md#status-reg)|
|-|-|-|-|-|-|
|!|!|!|!|!|?|

</div>

<img src="figs/shift.svg" height="300px" id="fig:shift">

- *op1*[, *op2*] という記法は「*op2*は指定してもしなくても良い」という意味です．
- **シフト**とは(指定したビット数だけ)右か左にビット列をずらすことを意味します．
  *op2*がなければ「1ビットシフト」を意味します．
- **論理シフト**とは「空いた場所に**0を入れる**」，
  **算術シフト**とは「空いた場所に**符号ビットを入れる**」ことを意味します．
- 左シフトの場合は(符号ビットを入れても意味がないので)，論理シフトでも算術シフトでも，0を入れます．その結果，算術左シフト`sal`と論理左シフト`shl`は全く同じ動作になります．
- C言語の符号あり整数に対する右シフト(>>)は算術シフトか論理シフトかは
  決まっていません(実装依存です)．
  C言語で，ビット演算は符号なし整数に対してのみ行うようにしましょう．

### `rol`, `ror`, `rcl`, `rcr`命令: ローテート

---
|[記法](./x86-list.md#詳しい記法)|何の略か| 動作 |
|-|-|-|
|**`rol␣`** *op1*[, *op2*]  | rotate left |左ローテート|
|**`rcl␣`** *op1*[, *op2*]  | rotate left through carry |CFを含めて左ローテート|
|**`ror␣`** *op1*[, *op2*]  | rotate right|右ローテート|
|**`rcr␣`** *op1*[, *op2*]  | rotate right through carry |CFを含めて右ローテート|
---
|[詳しい記法](./x86-list.md#詳しい記法)| 例 | 例の動作 | [サンプルコード](./6-inst.md#how-to-execute-x86-inst) | 
|-|-|-|-|
|**`rol␣`** *r/m* | `rolq %rax` | `%rax`を1ビット左ローテート|[rol-1.s](./asm/rol-1.s) [rol-1.txt](./asm/rol-1.txt)|
|**`rol␣`** *imm8*, *r/m* | `rolq $2, %rax` | `%rax`を2ビット左ローテート|[rol-1.s](./asm/rol-1.s) [rol-1.txt](./asm/rol-1.txt)|
|**`rol␣`** `%cl`, *r/m* | `rolq %cl, %rax` | `%rax`を`%cl`ビット左ローテート|[rol-1.s](./asm/rol-1.s) [rol-1.txt](./asm/rol-1.txt)|
|**`rcl␣`** *r/m* | `rclq %rax` | `%rax`を1ビットCFを含めて左ローテート|[rcl-1.s](./asm/rcl-1.s) [rcl-1.txt](./asm/rcl-1.txt)|
|**`rcl␣`** *imm8*, *r/m* | `rclq $2, %rax` | `%rax`を2ビットCFを含めて左ローテート|[rcl-1.s](./asm/rcl-1.s) [rcl-1.txt](./asm/rcl-1.txt)|
|**`rcl␣`** `%cl`, *r/m* | `rclq %cl, %rax` | `%rax`を`%cl`ビットCFを含めて左ローテート|[rcl-1.s](./asm/rcl-1.s) [rcl-1.txt](./asm/rcl-1.txt)|
|**`ror␣`** *r/m* | `rorq %rax` | `%rax`を1ビット右ローテート|[ror-1.s](./asm/ror-1.s) [ror-1.txt](./asm/ror-1.txt)|
|**`ror␣`** *imm8*, *r/m* | `rorq $2, %rax` | `%rax`を2ビット右ローテート|[ror-1.s](./asm/ror-1.s) [ror-1.txt](./asm/ror-1.txt)|
|**`ror␣`** `%cl`, *r/m* | `rorq %cl, %rax` | `%rax`を`%cl`ビット右ローテート|[ror-1.s](./asm/ror-1.s) [ror-1.txt](./asm/ror-1.txt)|
|**`rcr␣`** *r/m* | `rcrq %rax` | `%rax`を1ビットCFを含めて右ローテート|[rcr-1.s](./asm/rcr-1.s) [rcr-1.txt](./asm/rcr-1.txt)|
|**`rcr␣`** *imm8*, *r/m* | `rcrq $2, %rax` | `%rax`を2ビットCFを含めて右ローテート|[rcr-1.s](./asm/rcr-1.s) [rcr-1.txt](./asm/rcr-1.txt)|
|**`rcr␣`** `%cl`, *r/m* | `rcrq %cl, %rax` | `%rax`を`%cl`ビットCFを含めて右ローテート|[rcr-1.s](./asm/rcr-1.s) [rcr-1.txt](./asm/rcr-1.txt)|
---

<div style="font-size: 70%;">


|[CF](./x86-list.md#status-reg)|[OF](./x86-list.md#status-reg)|[SF](./x86-list.md#status-reg)|[ZF](./x86-list.md#status-reg)|[PF](./x86-list.md#status-reg)|[AF](./x86-list.md#status-reg)|
|-|-|-|-|-|-|
|!|!| | | | |

</div>

<img src="figs/rotate.svg" height="330px" id="fig:rotate">

- *op1*[, *op2*] という記法は「*op2*は指定してもしなくても良い」という意味です．
- ローテートは，シフトではみ出したビットを空いた場所に入れます．
- ローテートする方向(右か左)，CFを含めるか否かで，4パターンの命令が存在します．

### `cmp`, `test`命令: 比較

#### `cmp`命令

---
|[記法](./x86-list.md#詳しい記法)|何の略か| 動作 |
|-|-|-|
|**`cmp␣`** *op1*[, *op2*]  | compare |*op1*と*op2*の比較結果をフラグに格納(比較は`sub`命令を使用)|
---
|[詳しい記法](./x86-list.md#詳しい記法)| 例 | 例の動作 | [サンプルコード](./6-inst.md#how-to-execute-x86-inst) | 
|-|-|-|-|
|**`cmp␣`** *imm*, *r/m* | `cmpq $999, %rax` | `subq $999, %rax`のフラグ変化のみ計算．オペランドは変更なし |[cmp-1.s](./asm/cmp-1.s) [cmp-1.txt](./asm/cmp-1.txt)|
|**`cmp␣`** *r*, *r/m* | `cmpq %rax, (%rsp)` | `subq %rax, (%rsp)`のフラグ変化のみ計算．オペランドは変更なし |[cmp-1.s](./asm/cmp-1.s) [cmp-1.txt](./asm/cmp-1.txt)|
|**`cmp␣`** *r/m*, *r* | `cmpq (%rsp), %rax` | `subq (%rsp), %rax`のフラグ変化のみ計算．オペランドは変更なし |[cmp-1.s](./asm/cmp-1.s) [cmp-1.txt](./asm/cmp-1.txt)|
---

<div style="font-size: 70%;">


|[CF](./x86-list.md#status-reg)|[OF](./x86-list.md#status-reg)|[SF](./x86-list.md#status-reg)|[ZF](./x86-list.md#status-reg)|[PF](./x86-list.md#status-reg)|[AF](./x86-list.md#status-reg)|
|-|-|-|-|-|-|
|!|!|!|!|!|!|

</div>

- `cmp`命令はフラグ計算だけを行います．
  (レジスタやメモリは変化しません)．
- `cmp`命令は[条件付きジャンプ命令](x86-list.md#ジャンプ命令)と一緒に使うことが多いです．
  例えば以下の2命令で「`%rax`が(符号あり整数として)1より大きければジャンプする」という意味になります．

```x86asmatt
cmpq $1, %rax
jg L2
```

#### `test`命令

---
|[記法](./x86-list.md#詳しい記法)|何の略か| 動作 |
|-|-|-|
|**`test␣`** *op1*[, *op2*]  | logical compare |*op1*と*op2*の比較結果をフラグに格納(比較は`and`命令を使用)|
---
|[詳しい記法](./x86-list.md#詳しい記法)| 例 | 例の動作 | [サンプルコード](./6-inst.md#how-to-execute-x86-inst) | 
|-|-|-|-|
|**`test␣`** *imm*, *r/m* | `testq $999, %rax` | `andq $999, %rax`のフラグ変化のみ計算．オペランドは変更なし |[test-1.s](./asm/test-1.s) [test-1.txt](./asm/test-1.txt)|
|**`test␣`** *r*, *r/m* | `testq %rax, (%rsp)` | `andq %rax, (%rsp)`のフラグ変化のみ計算．オペランドは変更なし |[test-1.s](./asm/test-1.s) [test-1.txt](./asm/test-1.txt)|
|**`test␣`** *r/m*, *r* | `testq (%rsp), %rax` | `andq (%rsp), %rax`のフラグ変化のみ計算．オペランドは変更なし |[test-1.s](./asm/test-1.s) [test-1.txt](./asm/test-1.txt)|
---

<div style="font-size: 70%;">


|[CF](./x86-list.md#status-reg)|[OF](./x86-list.md#status-reg)|[SF](./x86-list.md#status-reg)|[ZF](./x86-list.md#status-reg)|[PF](./x86-list.md#status-reg)|[AF](./x86-list.md#status-reg)|
|-|-|-|-|-|-|
|0|0|!|!|!|?|

</div>

- `cmp`命令と同様に，`test`命令はフラグ計算だけを行います．
  (レジスタやメモリは変化しません)．
- `cmp`命令と同様に，`test`命令は[条件付きジャンプ命令](x86-list.md#ジャンプ命令)と一緒に使うことが多いです．
  例えば以下の2命令で「`%rax`が0ならジャンプする」という意味になります．

```x86asmatt
testq %rax, %rax
jz L2
```

- 例えば`%rax`が0かどうかを知りたい場合，
  `cmpq $0, %rax`と`testq %rax, %rax`のどちらでも調べることができます．
  どちらの場合も，ZF==1なら，`%rax`が0と分かります
  (`testq %rax, %rax`はビットごとのANDのフラグ変化を計算するので，
  `%rax`がゼロの時だけ，ZF==1となります)．
  コンパイラは`testq %rax, %rax`を使うことが多いです．
  `testq %rax, %rax`の方が命令長が短くなるからです．

### `movs`, `movz`, `cbtw`, `cqto`命令: 符号拡張とゼロ拡張

#### `movs`, `movz`命令

---
|[記法(AT&T形式)](./x86-list.md#詳しい記法)|記法(Intel形式)|何の略か| 動作 |
|-|-|-|-|
|**`movs␣␣`** *op1*, *op2* | `movsx` *op2*, *op1* </br> `movsxd` *op2*, *op1*| move with sign-extention |*op1*を符号拡張した値を*op2*に格納|
|**`movz␣␣`** *op1*, *op2* | `movzx` *op2*, *op1* | move with zero-extention |*op1*をゼロ拡張した値を*op2*に格納|
---
|[詳しい記法](./x86-list.md#詳しい記法)| 例 | 例の動作 | [サンプルコード](./6-inst.md#how-to-execute-x86-inst) | 
|-|-|-|-|
|**`movs␣␣`** *r/m*, *r* | `movslq %eax, %rbx` | `%rbx` = `%eax`を8バイトに符号拡張した値 |[movs-movz.s](./asm/movs-movz.s) [movs-movz.txt](./asm/movs-movz.txt)|
|**`movz␣␣`** *r/m*, *r* | `movzwq %ax, %rbx` | `%rbx` = `%ax`を8バイトにゼロ拡張した値 |[movs-movz.s](./asm/movs-movz.s) [movs-movz.txt](./asm/movs-movz.txt)|
---
| `␣␣`に入るもの | 何の略か | 意味 |
|-|-|-|
|`bw`| byte to word | 1バイト→2バイトの拡張|
|`bl`| byte to long | 1バイト→4バイトの拡張|
|`bq`| byte to quad | 1バイト→8バイトの拡張|
|`wl`| word to long | 2バイト→4バイトの拡張|
|`wq`| word to quad | 2バイト→8バイトの拡張|
|`lq`| long to quad | 4バイト→8バイトの拡張|
---

<div style="font-size: 70%;">


|[CF](./x86-list.md#status-reg)|[OF](./x86-list.md#status-reg)|[SF](./x86-list.md#status-reg)|[ZF](./x86-list.md#status-reg)|[PF](./x86-list.md#status-reg)|[AF](./x86-list.md#status-reg)|
|-|-|-|-|-|-|
|&nbsp;||||||
</div>

- `movs`, `movz`命令はAT&T形式とIntel形式でニモニックが異なるので注意です．
- GNUアセンブラではAT&T形式でも実は`movsx`, `movzx`のニモニックが使用できます．
  ただし逆アセンブルすると，`movslq`, `movzwq`などのニモニックが表示されるので，
  `movslq`, `movzwq`などを使う方が良いでしょう．
- `movzlq` (Intel形式では`movzxd`)はありません．例えば，`%eax`に値を入れると，
  `%rax`の上位32ビットは[クリア](./x86-list.md#zero-upper32)されるので，
  `movzlq`は不要だからです．
- Intel形式では，4バイト→8バイトの拡張の時だけ，
  (`movsx`ではなく)`movsxd`を使います．
  

#### `cbtw`, `cqto`命令

---
|[記法(AT&T形式)](./x86-list.md#詳しい記法)|記法(Intel形式)|何の略か| 動作 |
|-|-|-|-|
|**`c␣t␣`| `c␣␣␣` | convert ␣ to ␣ |`%rax` (または`%eax`, `%ax`, `%al`)を符号拡張|
---
|[詳しい記法](./x86-list.md#詳しい記法)<br/>(AT&T形式)| 詳しい記法<br/>(Intel形式)| 例 | 例の動作 | [サンプルコード](./6-inst.md#how-to-execute-x86-inst) | 
|-|-|-|-|-|
|**`cbtw`** | `cbw`| `cbtw` | `%al`(byte)を`%ax`(word)に符号拡張|[cbtw.s](./asm/cbtw.s) [cbtw.txt](./asm/cbtw.txt)|
|**`cwtl`** | `cwde`| `cwtl` | `%ax`(word)を`%eax`(long)に符号拡張|[cbtw.s](./asm/cbtw.s) [cbtw.txt](./asm/cbtw.txt)|
|**`cwtd`** | `cwd`| `cwtd` | `%ax`(word)を`%dx:%ax`(double word)に符号拡張|[cbtw.s](./asm/cbtw.s) [cbtw.txt](./asm/cbtw.txt)|
|**`cltd`** | `cdq`| `cltd` | `%eax`(long)を`%edx:%eax`(doube long, quad)に符号拡張|[cbtw.s](./asm/cbtw.s) [cbtw.txt](./asm/cbtw.txt)|
|**`cltq`** | `cdqe`| `cltd` | `%eax`(long)を`%rax`(quad)に符号拡張|[cbtw.s](./asm/cbtw.s) [cbtw.txt](./asm/cbtw.txt)|
|**`cqto`** | `cqo`| `cqto` | `%rax`(quad)を`%rdx:%rax`(octuple)に符号拡張|[cbtw.s](./asm/cbtw.s) [cbtw.txt](./asm/cbtw.txt)|
---
<div style="font-size: 70%;">

|[CF](./x86-list.md#status-reg)|[OF](./x86-list.md#status-reg)|[SF](./x86-list.md#status-reg)|[ZF](./x86-list.md#status-reg)|[PF](./x86-list.md#status-reg)|[AF](./x86-list.md#status-reg)|
|-|-|-|-|-|-|
|&nbsp;||||||
</div>


- `cqto`などは`idiv`で割り算する前に使うと便利(`%rdx:%rax`が`idiv`の隠しオペランドなので)．
- GNUアセンブラはIntel形式のニモニックも受け付ける．

## ジャンプ命令

### `jmp`: 無条件ジャンプ

---
|[記法](./x86-list.md#詳しい記法)|何の略か| 動作 |
|-|-|-|
|**`jmp`** *op1*| jump | *op1*にジャンプ |
---
<!--
|[詳しい記法](./x86-list.md#詳しい記法)| 例 | 例の動作 | [サンプルコード](./6-inst.md#how-to-execute-x86-inst) | 
|-|-|-|-|
|**`jmp`** *rel8*| `jmp 0x1000` | `0x1000`番地に[相対](6-inst.md#abs-rel-jump)・[直接](6-inst.md#dir-indir-jump)ジャンプ (`%rip += 0x1000`)|[jmp.s](./asm/jmp.s) [jmp.txt](./asm/jmp.txt)|
|**`jmp`** *rel32*| `jmp foo` | `foo`番地に[相対](6-inst.md#abs-rel-jump)・[直接](6-inst.md#dir-indir-jump)ジャンプ (`%rip += foo`)|[jmp.s](./asm/jmp.s) [jmp.txt](./asm/jmp.txt)|
|**`jmp`** *r/m*| `jmp *%rax` | `*%rax`番地に[絶対](6-inst.md#abs-rel-jump)・[間接](6-inst.md#dir-indir-jump)ジャンプ (`%rip = *rax`)|[jmp.s](./asm/jmp.s) [jmp.txt](./asm/jmp.txt)|
|**`jmp`** *r/m*| `jmp *(%rax)` | `*(%rax)`番地に[絶対](6-inst.md#abs-rel-jump)・[間接](6-inst.md#dir-indir-jump)ジャンプ (`%rip = *(%rax)`|[jmp.s](./asm/jmp.s) [jmp.txt](./asm/jmp.txt)|
-->
<div class="table-wrapper"><table><thead><tr><th><a href="./x86-list.html#%E8%A9%B3%E3%81%97%E3%81%84%E8%A8%98%E6%B3%95">詳しい記法</a></th><th>例</th><th>例の動作</th><th><a href="./6-inst.html#how-to-execute-x86-inst">サンプルコード</a></th></tr></thead><tbody>
<tr><td rowspan="2"><strong><code>jmp</code></strong> <em>rel</em></td><td><code>jmp 0x1000</code></td><td><code>0x1000</code>番地に<a href="6-inst.html#abs-rel-jump">相対</a>・<a href="6-inst.html#dir-indir-jump">直接</a>ジャンプ (<code>%rip += 0x1000</code>)</td><td><a href="./asm/jmp.s">jmp.s</a> <a href="./asm/jmp.txt">jmp.txt</a></td></tr>
<tr><td><code>jmp foo</code></td><td><code>foo</code>番地に<a href="6-inst.html#abs-rel-jump">相対</a>・<a href="6-inst.html#dir-indir-jump">直接</a>ジャンプ (<code>%rip += foo</code>)</td><td><a href="./asm/jmp.s">jmp.s</a> <a href="./asm/jmp.txt">jmp.txt</a></td></tr>
<tr><td><strong><code>jmp</code></strong> <em>r/m</em></td><td><code>jmp *%rax</code></td><td><code>*%rax</code>番地に<a href="6-inst.html#abs-rel-jump">絶対</a>・<a href="6-inst.html#dir-indir-jump">間接</a>ジャンプ (<code>%rip = *%rax)</code>)</td><td><a href="./asm/jmp.s">jmp.s</a> <a href="./asm/jmp.txt">jmp.txt</a></td></tr>
<tr><td><strong><code>jmp</code></strong> <em>r/m</em></td><td><code>jmp *(%rax)</code></td><td><code>*(%rax)</code>番地に<a href="6-inst.html#abs-rel-jump">絶対</a>・<a href="6-inst.html#dir-indir-jump">間接</a>ジャンプ (<code>%rip = *(%rax)</code>)</td><td><a href="./asm/jmp.s">jmp.s</a> <a href="./asm/jmp.txt">jmp.txt</a></td></tr>
</tbody></table>
</div>
---
<div style="font-size: 70%;">

|[CF](./x86-list.md#status-reg)|[OF](./x86-list.md#status-reg)|[SF](./x86-list.md#status-reg)|[ZF](./x86-list.md#status-reg)|[PF](./x86-list.md#status-reg)|[AF](./x86-list.md#status-reg)|
|-|-|-|-|-|-|
|&nbsp;| | | | | |
</div>

- x86-64では，相対・直接と絶対・間接の組み合わせしかありません．
 (つまり，相対・間接ジャンプや絶対・直接ジャンプはありません．
 なお，ここで紹介していないfarジャンプでは絶対・直接もあります)．
- 相対・直接ジャンプでは符号ありの8ビット(*rel8*)か
  32ビット(*rel32*)の整数定数で相対アドレスを指定します．
  (64ビットの相対アドレスは指定できません．64ビットのジャンプをしたい時は
  絶対・間接ジャンプ命令を使います)．
- *rel8*か*rel32*かはアセンブラが勝手に選んでくれます．
  逆に`jmpb`や`jmpl`などとサフィックスをつけて指定することはできません．
- なぜか，定数なのに*rel8*や*rel32*にはドルマーク`$`をつけません．
  逆に*r/m*の前にはアスタリスク`*`が必要です．
  GNUアセンブラのこの部分は一貫性がないので要注意です．


### 条件付きジャンプの概要

- 条件付きジャンプ命令 `j␣`は
　ステータスフラグ (CF, OF, PF, SF, ZF)をチェックして，
  条件が成り立てばジャンプします．
- 条件付きジャンプは比較命令と一緒に使うことが多いです．
  例えば以下の2命令で「`%rax`が(符号あり整数として)1より大きければジャンプする」という意味になります．

```x86asmatt
cmpq $1, %rax
jg L2
```

- 条件付きジャンプ命令のニモニックでは次の用語を使い分けます
  - 符号あり整数の大小には less/greater を使う
  - 符号なし整数の大小には above/below を使う

### 条件付きジャンプ: 符号あり整数用

---
|[記法](./x86-list.md#詳しい記法)|何の略か| 動作 | ジャンプ条件 | 
|-|-|-|-|
|**`jg`** *rel*<br/> **`jnle`** *rel*| jump if greater <br/> jump if not less nor equal | *op2*>*op1*なら*rel*にジャンプ <br/> !(*op2*<=*op1*)なら*rel*にジャンプ | `ZF==0&&SF==OF`|
|**`jge`** *rel*<br/> **`jnl`** *rel*| jump if greater or equal <br/> jump if not less | *op2*>=*op1*なら*rel*にジャンプ <br/> !(*op2*<*op1*)なら*rel*にジャンプ | `SF==OF`|
|**`jle`** *rel*<br/> **`jng`** *rel*| jump if less or equal <br/> jump if not greater | *op2*<=*op1*なら*rel*にジャンプ <br/> !(*op2*>*op1*)なら*rel*にジャンプ | <code>ZF==1&#124;&#124;SF!=OF</code> |
|**`jl`** *rel*<br/> **`jnge`** *rel*| jump if less <br/> jump if not greater nor equal | *op2*<*op1*なら*rel*にジャンプ <br/> !(*op2*>=*op1*)なら*rel*にジャンプ | `SF!=OF`|

---
|[詳しい記法](./x86-list.md#詳しい記法)| 例 | 例の動作 | [サンプルコード](./6-inst.md#how-to-execute-x86-inst) | 
|-|-|-|-|
|**`jg`** *rel* | `cmpq $0, %rax`<br/>`jg foo` | if (`%rax`>0) goto foo |[jg.s](./asm/jg.s) [jg.txt](./asm/jg.txt)|
|**`jnle`** *rel* | `cmpq $0, %rax`<br/>`jnle foo` | if (!(`%rax`<=0)) goto foo |[jg.s](./asm/jg.s) [jg.txt](./asm/jg.txt)|
|**`jge`** *rel* | `cmpq $0, %rax`<br/>`jge foo` | if (`%rax`>=0) goto foo |[jge.s](./asm/jge.s) [jge.txt](./asm/jge.txt)|
|**`jnl`** *rel* | `cmpq $0, %rax`<br/>`jnl foo` | if (!(`%rax`<0)) goto foo |[jge.s](./asm/jge.s) [jge.txt](./asm/jge.txt)|
|**`jle`** *rel* | `cmpq $0, %rax`<br/>`jle foo` | if (`%rax`<=0) goto foo |[jle.s](./asm/jle.s) [jle.txt](./asm/jle.txt)|
|**`jng`** *rel* | `cmpq $0, %rax`<br/>`jng foo` | if (!(`%rax`>0)) goto foo |[jle.s](./asm/jle.s) [jle.txt](./asm/jle.txt)|
|**`jl`** *rel* | `cmpq $0, %rax`<br/>`jl foo` | if (`%rax`<0) goto foo |[jl.s](./asm/jl.s) [jl.txt](./asm/jl.txt)|
|**`jnge`** *rel* | `cmpq $0, %rax`<br/>`jnge foo` | if (!(`%rax`>=0)) goto foo |[jl.s](./asm/jl.s) [jl.txt](./asm/jl.txt)|
---
<div style="font-size: 70%;">

|[CF](./x86-list.md#status-reg)|[OF](./x86-list.md#status-reg)|[SF](./x86-list.md#status-reg)|[ZF](./x86-list.md#status-reg)|[PF](./x86-list.md#status-reg)|[AF](./x86-list.md#status-reg)|
|-|-|-|-|-|-|
|&nbsp;||||||
</div>

- *op1* と *op2* は条件付きジャンプ命令の直前で使用した`cmp`命令のオペランドを表します．
- `jg`と`jnle`は異なるニモニックですが動作は同じです．
  その証拠にジャンプ条件は`ZF==0&&SF==OF`と共通です．
  他の3つのペア，`jge`と`jnl`，`jle`と`jng`，`jl`と`jnge`も同様です．

### 条件付きジャンプ: 符号なし整数用

---
|[記法](./x86-list.md#詳しい記法)|何の略か| 動作 | ジャンプ条件 | 
|-|-|-|-|
|**`ja`** *rel*<br/> **`jnbe`** *rel*| jump if above <br/> jump if not below nor equal | *op2*>*op1*なら*rel*にジャンプ <br/> !(*op2*<=*op1*)なら*rel*にジャンプ | `CF==0&ZF==0`|
|**`jae`** *rel*<br/> **`jnb`** *rel*| jump if above or equal <br/> jump if not below | *op2*>=*op1*なら*rel*にジャンプ <br/> !(*op2*<*op1*)なら*rel*にジャンプ | `CF==0`|
|**`jbe`** *rel*<br/> **`jna`** *rel*| jump if below or equal <br/> jump if not above | *op2*<=*op1*なら*rel*にジャンプ <br/> !(*op2*>*op1*)なら*rel*にジャンプ |  `CF==1&&ZF==1`|
|**`jb`** *rel*<br/> **`jnae`** *rel*| jump if below <br/> jump if not above nor equal | *op2*<*op1*なら*rel*にジャンプ <br/> !(*op2*>=*op1*)なら*rel*にジャンプ | `CF==1`|

---
|[詳しい記法](./x86-list.md#詳しい記法)| 例 | 例の動作 | [サンプルコード](./6-inst.md#how-to-execute-x86-inst) | 
|-|-|-|-|
|**`ja`** *rel* | `cmpq $0, %rax`<br/>`ja foo` | if (`%rax`>0) goto foo |[ja.s](./asm/ja.s) [ja.txt](./asm/ja.txt)|
|**`jnbe`** *rel* | `cmpq $0, %rax`<br/>`jnbe foo` | if (!(`%rax`<=0)) goto foo |[ja.s](./asm/ja.s) [ja.txt](./asm/ja.txt)|
|**`jae`** *rel* | `cmpq $0, %rax`<br/>`jae foo` | if (`%rax`>=0) goto foo |[jae.s](./asm/jae.s) [jae.txt](./asm/jae.txt)|
|**`jnb`** *rel* | `cmpq $0, %rax`<br/>`jnb foo` | if (!(`%rax`<0)) goto foo |[jae.s](./asm/jae.s) [jae.txt](./asm/jae.txt)|
|**`jbe`** *rel* | `cmpq $0, %rax`<br/>`jbe foo` | if (`%rax`<=0) goto foo |[jbe.s](./asm/jbe.s) [jbe.txt](./asm/jbe.txt)|
|**`jna`** *rel* | `cmpq $0, %rax`<br/>`jna foo` | if (!(`%rax`>0)) goto foo |[jbe.s](./asm/jbe.s) [jbe.txt](./asm/jbe.txt)|
|**`jb`** *rel* | `cmpq $0, %rax`<br/>`jb foo` | if (`%rax`<0) goto foo |[jb.s](./asm/jb.s) [jb.txt](./asm/jb.txt)|
|**`jnae`** *rel* | `cmpq $0, %rax`<br/>`jnae foo` | if (!(`%rax`>=0)) goto foo |[jb.s](./asm/jb.s) [jb.txt](./asm/jb.txt)|
---
<div style="font-size: 70%;">

|[CF](./x86-list.md#status-reg)|[OF](./x86-list.md#status-reg)|[SF](./x86-list.md#status-reg)|[ZF](./x86-list.md#status-reg)|[PF](./x86-list.md#status-reg)|[AF](./x86-list.md#status-reg)|
|-|-|-|-|-|-|
|&nbsp;||||||
</div>

- *op1* と *op2* は条件付きジャンプ命令の直前で使用した`cmp`命令のオペランドを表します．
- `ja`と`jnbe`は異なるニモニックですが動作は同じです．
  その証拠にジャンプ条件は`CF==0&&ZF==0`と共通です．
  他の3つのペア，`jae`と`jnb`，`jbe`と`jna`，`jb`と`jnae`も同様です．

### 条件付きジャンプ: フラグ用

---
|[記法](./x86-list.md#詳しい記法)|何の略か| 動作 | ジャンプ条件 | 
|-|-|-|-|
|**`jc`** *rel*| jump if carry | `CF==1`なら*rel*にジャンプ | `CF==1`|
|**`jnc`** *rel*| jump if not carry | `CF==0`なら*rel*にジャンプ | `CF==0`|
|**`jo`** *rel*| jump if overflow | `OF==1`なら*rel*にジャンプ | `OF==1`|
|**`jno`** *rel*| jump if not overflow | `OF==0`なら*rel*にジャンプ | `OF==0`|
|**`js`** *rel*| jump if sign | `SF==1`なら*rel*にジャンプ | `SF==1`|
|**`jns`** *rel*| jump if not sign | `SF==0`なら*rel*にジャンプ | `SF==0`|
|**`jz`** *rel* <br/> **`je`** *rel*| jump if zero <br/> jump if equal | `ZF==1`なら*rel*にジャンプ <br/> *op2*==*op1*なら*rel*にジャンプ| `ZF==1`|
|**`jnz`** *rel* <br/> **`jne`** *rel*| jump if not zero <br/> jump if not equal | `ZF==0`なら*rel*にジャンプ <br/> *op2*!=*op1*なら*rel*にジャンプ| `ZF==0`|
|**`jp`** *rel* <br/> **`jpe`** *rel*| jump if parity <br/> jump if parity even| `PF==1`なら*rel*にジャンプ | `PF==1`|
|**`jnp`** *rel* <br/> **`jpo`** *rel*| jump if not parity <br/> jump if parity odd| `PF==0`なら*rel*にジャンプ | `PF==0`|

---
|[詳しい記法](./x86-list.md#詳しい記法)| 例 | 例の動作 | [サンプルコード](./6-inst.md#how-to-execute-x86-inst) | 
|-|-|-|-|
|**`jc`** *rel* | `jc foo` | if (`CF==1`) goto foo |[jc.s](./asm/jc.s) [jc.txt](./asm/jc.txt)|
|**`jnc`** *rel* | `jnc foo` | if (`CF==0`) goto foo |[jc.s](./asm/jc.s) [jc.txt](./asm/jc.txt)|
|**`jo`** *rel* | `jo foo` | if (`OF==1`) goto foo |[jo.s](./asm/jo.s) [jo.txt](./asm/jo.txt)|
|**`jno`** *rel* | `jno foo` | if (`OF==0`) goto foo |[jo.s](./asm/jo.s) [jo.txt](./asm/jo.txt)|
|**`js`** *rel* | `js foo` | if (`SF==1`) goto foo |[js.s](./asm/js.s) [js.txt](./asm/js.txt)|
|**`jns`** *rel* | `jns foo` | if (`SF==0`) goto foo |[js.s](./asm/js.s) [js.txt](./asm/js.txt)|
|**`jz`** *rel* | `jz foo` | if (`ZF==1`) goto foo |[jz.s](./asm/jz.s) [jz.txt](./asm/jz.txt)|
|**`je`** *rel* | `cmpq $0, %rax`<br/>`je foo` | if (`%rax==0`) goto foo |[jz.s](./asm/jz.s) [jz.txt](./asm/jz.txt)|
|**`jnz`** *rel* | `jnz foo` | if (`ZF==0`) goto foo |[jz.s](./asm/jz.s) [jz.txt](./asm/jz.txt)|
|**`jne`** *rel* | `cmpq $0, %rax`<br/>`jne foo` | if (`%rax!=0`) goto foo |[jz.s](./asm/jz.s) [jz.txt](./asm/jz.txt)|
|**`jp`** *rel* | `jp foo` | if (`PF==1`) goto foo |[jp.s](./asm/jp.s) [jp.txt](./asm/jp.txt)|
|**`jpe`** *rel* | `jpe foo` | if (`PF==1`) goto foo |[jp.s](./asm/jp.s) [jp.txt](./asm/jp.txt)|
|**`jnp`** *rel* | `jnp foo` | if (`PF==0`) goto foo |[jp.s](./asm/jp.s) [jp.txt](./asm/jp.txt)|
|**`jpo`** *rel* | `jpo foo` | if (`PF==0`) goto foo |[jp.s](./asm/jp.s) [jp.txt](./asm/jp.txt)|
---
<div style="font-size: 70%;">

|[CF](./x86-list.md#status-reg)|[OF](./x86-list.md#status-reg)|[SF](./x86-list.md#status-reg)|[ZF](./x86-list.md#status-reg)|[PF](./x86-list.md#status-reg)|[AF](./x86-list.md#status-reg)|
|-|-|-|-|-|-|
|&nbsp;||||||
</div>

- *op1* と *op2* は条件付きジャンプ命令の直前で使用した`cmp`命令のオペランドを表します．
- `jz`と`je`は異なるニモニックですが動作は同じです．
  その証拠にジャンプ条件は`ZF==1`と共通です．
  他の3つのペア，`jnz`と`jne`，`jp`と`jpe`，`jnp`と`jpo`も同様です．
- AFフラグのための条件付きジャンプ命令は存在しません．

## 関数呼び出し(コール命令)

### `call`, `ret`命令: 関数を呼び出す，リターンする

---
|[記法](./x86-list.md#詳しい記法)|何の略か| 動作 |
|-|-|-|
|**`call`** *op1*| call procedure | `%rip`をスタックにプッシュしてから *op1*にジャンプする<br/> (`pushq %rip; %rip` = *op1*)|
|**`ret`** | return from procedure | スタックからポップしたアドレスにジャンプする <br/> (`popq %rip`)|
---
|[詳しい記法](./x86-list.md#詳しい記法)| 例 | 例の動作 | [サンプルコード](./6-inst.md#how-to-execute-x86-inst) | 
|-|-|-|-|
|**`call`** *rel* | `call foo` | 相対・直接の関数コール|[call.s](./asm/call.s) [call.txt](./asm/call.txt)|
|**`call`** *r/m* | `call *%rax` | 絶対・間接の関数コール|[call.s](./asm/call.s) [call.txt](./asm/call.txt)|
|**`ret`** | `ret` | 関数からリターン |[call.s](./asm/call.s) [call.txt](./asm/call.txt)|
---
<div style="font-size: 70%;">

|[CF](./x86-list.md#status-reg)|[OF](./x86-list.md#status-reg)|[SF](./x86-list.md#status-reg)|[ZF](./x86-list.md#status-reg)|[PF](./x86-list.md#status-reg)|[AF](./x86-list.md#status-reg)|
|-|-|-|-|-|-|
|&nbsp;||||||
</div>

### `enter`, `leave`命令: スタックフレームを作成する，破棄する

---
|[記法](./x86-list.md#詳しい記法)|何の略か| 動作 |
|-|-|-|
|**`enter`** *op1*, *op2*| make stack frame | サイズ*op1*のスタックフレームを作成する|
|**`leave`**| discard stack frame | 今のスタックフレームを破棄する|
---
|[詳しい記法](./x86-list.md#詳しい記法)| 例 | 例の動作 | [サンプルコード](./6-inst.md#how-to-execute-x86-inst) | 
|-|-|-|-|
|**`enter`** *imm16*, *imm8* | `enter $0x20, $0` | `pushq %rbp`<br/>`movq %rsp, %rbp`<br/>`subq $0x20, %rsp`|[enter.s](./asm/enter.s) [enter.txt](./asm/enter.txt)|
|**`leave`** | `leave` | `movq %rbp, %rsp`<br/>`popq %rbp`|[enter.s](./asm/enter.s) [enter.txt](./asm/enter.txt)|
---
<div style="font-size: 70%;">

|[CF](./x86-list.md#status-reg)|[OF](./x86-list.md#status-reg)|[SF](./x86-list.md#status-reg)|[ZF](./x86-list.md#status-reg)|[PF](./x86-list.md#status-reg)|[AF](./x86-list.md#status-reg)|
|-|-|-|-|-|-|
|&nbsp;||||||
</div>

- `enter`命令の*op2*には関数のネストレベルを指定するのですが，
  C言語では入れ子の関数がない(つまりネストレベルは常にゼロ)なので
  常にゼロを指定します．
- ただし，`enter`は遅いので通常は使いません．
  代わりに同等の動作をする`pushq %rbp; movq %rsp, %rbp; subq $`*n*`, %rsp`を使います．


<!--
### calleeとcaller
### レジスタ退避と回復
### caller-saveレジスタとcallee-saveレジスタ
### スタックフレーム
    図
### スタックレイアウト
### 関数呼び出し規約 (calling convention)
### 引数の渡し方
### 関数プロローグとエピローグ
### レッドゾーン (redzone)
### Cコードからアセンブリコードを呼び出す
### アセンブリコードからCコードを呼び出す
### アセンブリコードから`printf`を呼び出す
-->

## その他

### `nop`命令 {#insn-nop}

---
|[記法](./x86-list.md#詳しい記法)|何の略か| 動作 |
|-|-|-|
|**`nop`**      | no operation | 何もしない(プログラムカウンタのみ増加) |
|**`nop`** *op1*| no operation | 何もしない(プログラムカウンタのみ増加) |
---
|[詳しい記法](./x86-list.md#詳しい記法)| 例 | 例の動作 | [サンプルコード](./6-inst.md#how-to-execute-x86-inst) | 
|-|-|-|-|
|**`nop`** | `nop` | 何もしない |[nop.s](./asm/nop.s) [nop.txt](./asm/nop.txt)|
|**`nop`** *r/m* | `nopl (%rax)` | 何もしない |[nop2.s](./asm/nop2.s) [nop2.txt](./asm/nop2.txt)|
---
<div style="font-size: 70%;">

|[CF](./x86-list.md#status-reg)|[OF](./x86-list.md#status-reg)|[SF](./x86-list.md#status-reg)|[ZF](./x86-list.md#status-reg)|[PF](./x86-list.md#status-reg)|[AF](./x86-list.md#status-reg)|
|-|-|-|-|-|-|
|&nbsp;| | | | | |
</div>

- `nop`は何もしない命令です(ただしプログラムカウンタ`%rip`は増加します)．
- 機械語命令列の間を(何もせずに)埋めるために使います．
- `nop`の機械語命令は1バイト長です．
- `nop` *r/m* という形式の命令は2〜9バイト長の`nop`命令になります．
  1バイト長の`nop`を9個並べるより，
  9バイト長の`nop`を1個並べた方が，実行が早くなります．
- 「複数バイトの`nop`命令がある」という知識は，
  逆アセンブル時に`nopl (%rax)`などを見てビックリしないために必要です．

### `cmpxchg`, `cmpxchg8b`, `cmpxchg16b`命令: CAS (compare-and-swap)命令

#### `cmpxchg`命令

---
|[記法](./x86-list.md#詳しい記法)|何の略か| 動作 |
|-|-|-|
|**`cmpxchg`** *op1*, *op2* | compare and exchange| `%rax`と*op2*を比較し，同じなら*op2*=*op1*，異なれば `%rax`=*op2*|
---
|[詳しい記法](./x86-list.md#詳しい記法)| 例 | 例の動作 | [サンプルコード](./6-inst.md#how-to-execute-x86-inst) | 
|-|-|-|-|
|**`cmpxchg`** *r*, *r/m*| `cmpxchg %rbx, (%rsp)`|if (`*(%rsp)==%rax`) `*(%rsp)=%rbx`;<br/> else `%rax=*(%rsp)`;| [cmpxchg.s](./asm/cmpxchg.s) [cmpxchg.txt](./asm/cmpxchg.txt)|
---
<div style="font-size: 70%;">

|[CF](./x86-list.md#status-reg)|[OF](./x86-list.md#status-reg)|[SF](./x86-list.md#status-reg)|[ZF](./x86-list.md#status-reg)|[PF](./x86-list.md#status-reg)|[AF](./x86-list.md#status-reg)|
|-|-|-|-|-|-|
|!|!|!|!|!|!|
</div>

<!--
特定のメモリの値が指定した値と等しい時だけ，別に指定した値で書き換える．
-->

- `cmpxchg`命令などのCAS命令は，lock-free，つまりロックを使わず
  同期機構を実現するために使われます．
  アトミックに実行する必要があるため，通常，LOCKプリフィックスをつけて使います．
- 気持ち:
  - あるメモリにある*op2*を新しい値*op1*で書き換えたい．
  - ただし，代入前の*op2*の値は`%rax`と同じはずで，
    もし(割り込まれて)知らない間に別の値になっていたら，この代入は失敗させる．
  - 代入が失敗したことを知るために，
    (他の誰かが更新した最新の)*op2*の値を`%rax`に入れる．
    `cmpxchg`実行後に`%rax`の値を調べれば，無事に*op1*への代入ができたかどうかが分かる．
    
#### `cmpxchg8b`, `cmpxchg16b`命令

---
|[記法](./x86-list.md#詳しい記法)|何の略か| 動作 |
|-|-|-|
|**`cmpxchg8b`** *op1*| compare and exchange bytes| `%edx:%eax`と*op1*を比較し，同じなら*op1*=`%ecx:%ebx`，異なれば `%edx:%eax`=*op1*|
|**`cmpxchg16b`** *op1*| compare and exchange bytes| `%rdx:%rax`と*op1*を比較し，同じなら*op1*=`%rcx:%rbx`，異なれば `%rdx:%rax`=*op1*|
---
|[詳しい記法](./x86-list.md#詳しい記法)| 例 | 例の動作 | [サンプルコード](./6-inst.md#how-to-execute-x86-inst) | 
|-|-|-|-|
|**`cmpxchg8b`** *m64*| `cmpxchg8b (%rsp)`|if (`*(%rsp)==%edx:%eax`) `*(%rsp)=%ecx:%ebx`;<br/> else `%edx:%eax=*(%rsp)`;| [cmpxchg8b.s](./asm/cmpxchg8.s) [cmpxchg8.txt](./asm/cmpxchg8.txt)|
|**`cmpxchg16b`** *m128*| `cmpxchg16b (%rsp)`|if (`*(%rsp)==%rdx:%rax`) `*(%rsp)=%rcx:%rbx`;<br/> else `%rdx:%rax=*(%rsp)`;| [cmpxchg16b.s](./asm/cmpxchg16.s) [cmpxchg16.txt](./asm/cmpxchg16.txt)|
---
<div style="font-size: 70%;">

|[CF](./x86-list.md#status-reg)|[OF](./x86-list.md#status-reg)|[SF](./x86-list.md#status-reg)|[ZF](./x86-list.md#status-reg)|[PF](./x86-list.md#status-reg)|[AF](./x86-list.md#status-reg)|
|-|-|-|-|-|-|
| | | |!| | |
</div>

- `cmpxchg8b`, `cmpxchg16b`もCAS命令の一種ですが，
  `cmpxchg`とステータスフラグの変化が異なるので，分けて書いています．
- `cmpxchg16b`命令が参照するメモリは16バイト境界のアラインメントが必要です．
  (つまりメモリアドレスが16の倍数である必要があります)．

### `rdtsc`, `rdtscp`命令: タイムスタンプを読む {#rdtscp}

---
|[記法](./x86-list.md#詳しい記法)|何の略か| 動作 |
|-|-|-|
|**`rdtsc`** | read time-stamp counter| `%edx:%eax` = 64ビットタイムスタンプカウンタ|
|**`rdtscp`** | read time-stamp counter and processor ID| `%edx:%eax` = 64ビットタイムスタンプカウンタ <br/> `%ecx` = 32ビットプロセッサID|
---
|[詳しい記法](./x86-list.md#詳しい記法)| 例 | 例の動作 | [サンプルコード](./6-inst.md#how-to-execute-x86-inst) | 
|-|-|-|-|
|**`rdtsc`**| `rdtsc`| `%edx:%eax` = 64ビットタイムスタンプカウンタ| [rdtsc.s](./asm/rdtsc.s) [rdtsc.txt](./asm/rdtsc.txt)|
|**`rdtscp`**| `rdtscp`| `%edx:%eax` = 64ビットタイムスタンプカウンタ <br/> `%ecx` = 32ビットプロセッサID| [rdtscp.s](./asm/rdtscp.s) [rdtscp.txt](./asm/rdtscp.txt)|
---
<div style="font-size: 70%;">

|[CF](./x86-list.md#status-reg)|[OF](./x86-list.md#status-reg)|[SF](./x86-list.md#status-reg)|[ZF](./x86-list.md#status-reg)|[PF](./x86-list.md#status-reg)|[AF](./x86-list.md#status-reg)|
|-|-|-|-|-|-|
|&nbsp;| | | | | |
</div>

- x86-64は64ビットの**タイムスタンプカウンタ**
  (TSC: time stamp counter)を備えており，
  リセット後のCPUのサイクル数を数えています．
  原理的には「サイクル数の差分をCPUのクロック周波数で割れば実行時間が得られる」
  はずですが，実際にはout-of-order実行や，
  内部クロックの変化などを考慮する必要があります．
  詳しくは[How to Benchmark Code Execution Times on Intel® IA-32 and IA-64 Instruction Set Architectures](https://github.com/tpn/pdfs/blob/master/How%20to%20Benchmark%20Code%20Execution%20Times%20on%20Intel%20IA-32%20and%20IA-64%20Instruction%20Set%20Architectures%20-%20September%2C%202010%20(324264-001).pdf)
  を参照して下さい．
- `rdtscp`命令を使うと，プロセッサIDも取得できます．
  `rdtsc`と`rdtscp`ではシリアライズ処理が異なるため，得られるサイクル数も異なります．
  詳しくは
  [x86-64のマニュアルSDM](https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html)
  を参照して下さい．

### `int3`命令

---
|[記法](./x86-list.md#詳しい記法)|何の略か| 動作 |
|-|-|-|
|**`int3`** | call to interrupt procedure| ブレークポイントトラップを発生|
---
|[詳しい記法](./x86-list.md#詳しい記法)| 例 | 例の動作 | [サンプルコード](./6-inst.md#how-to-execute-x86-inst) | 
|-|-|-|-|
|**`int3`**| `int3`| ブレークポイントトラップを発生| [int3.s](./asm/int3.s) [int3.txt](./asm/int3.txt)|
---
<div style="font-size: 70%;">

|[CF](./x86-list.md#status-reg)|[OF](./x86-list.md#status-reg)|[SF](./x86-list.md#status-reg)|[ZF](./x86-list.md#status-reg)|[PF](./x86-list.md#status-reg)|[AF](./x86-list.md#status-reg)|
|-|-|-|-|-|-|
|&nbsp;| | | | | |
</div>

- `int3`命令はブレークポイントトラップ(ソフトウェア割り込みの一種)を発生させます．
 通常実行では`int3`を実行した時点でプロセスは強制終了となりますが，
 デバッガ上ではその時点でブレークします．continueコマンドでその後の実行も継続できます．ブレークしたい場所が分かっている場合は，
 Cコード中に`asm ("int3");`と書くことでデバッガ上でブレークさせることができます．

### `ud2`命令

---
|[記法](./x86-list.md#詳しい記法)|何の略か| 動作 |
|-|-|-|
|**`ud2`** | undefined instruction | 無効オペコード例外を発生させる|
---
|[詳しい記法](./x86-list.md#詳しい記法)| 例 | 例の動作 | [サンプルコード](./6-inst.md#how-to-execute-x86-inst) | 
|-|-|-|-|
|**`ud2`**| `ud2`| 無効オペコード例外を発生させる| [ud2.s](./asm/ud2.s) [ud2.txt](./asm/ud2.txt)|
---
<div style="font-size: 70%;">

|[CF](./x86-list.md#status-reg)|[OF](./x86-list.md#status-reg)|[SF](./x86-list.md#status-reg)|[ZF](./x86-list.md#status-reg)|[PF](./x86-list.md#status-reg)|[AF](./x86-list.md#status-reg)|
|-|-|-|-|-|-|
|&nbsp;| | | | | |
</div>

- `ud2`命令は無効オペコード例外を発生させます．
 通常実行では`ud2`を実行した時点でプロセスは，
 シグナル`SIGILL` (illegal instruction)を受け取り，強制終了となります
 デバッガ上でも，
 `Program received signal SIGILL, Illegal instruction.`
 というメッセージが出て，プロセスは終了になります．
 本書では「実行が通るはずがない場所が本当かどうか」の確認のため
 `ud2`を使います．(通るはずがない場所に`ud2`を置いて，`SIGILL`が発生しなければOKです)

<details>
<summary>
例外 (exception)とは
</summary>

**例外**(exception)はCPUが発生させる割り込み(ソフトウェア割り込み)です．
Intel用語で，例外はさらに**フォールト**(fault)，**トラップ**(trap)，
**アボート**(abort)に分類されます．
例えばゼロ割はフォールト，ブレークポイントはトラップです．
マイOS作りたい人は頑張って[勉強](https://wiki.osdev.org/Exceptions)して下さい．
</details>

### `endbr64`命令

---
|[記法](./x86-list.md#詳しい記法)|何の略か| 動作 |
|-|-|-|
|**`endbr64`** | end branch 64 bit |間接ジャンプ先として許す|
---
|[詳しい記法](./x86-list.md#詳しい記法)| 例 | 例の動作 | [サンプルコード](./6-inst.md#how-to-execute-x86-inst) | 
|-|-|-|-|
|**`endbr64`**| `endbr64`| 間接ジャンプ先として許す| [endbr64.s](./asm/endbr64.s) [endbr64.txt](./asm/endbr64.txt)|
---
<div style="font-size: 70%;">

|[CF](./x86-list.md#status-reg)|[OF](./x86-list.md#status-reg)|[SF](./x86-list.md#status-reg)|[ZF](./x86-list.md#status-reg)|[PF](./x86-list.md#status-reg)|[AF](./x86-list.md#status-reg)|
|-|-|-|-|-|-|
|&nbsp;| | | | | |
</div>

- Intel CET IBT技術に対応したCPUの場合，
  間接ジャンプ後のジャンプ先が`endbr64`以外だった場合，
  例外が発生してプログラムは強制終了となります．
- Intel CET IBT技術に未対応のCPUの場合は，`nop`命令として動作します．
- 逆アセンブルして`endbr64`を見てもビックリしないためにこの説明を書いています．  
- 私のPCが古すぎて，Intel CET未対応だったため，2023/8/17現在，クラッシュが発生するサンプルコードを作れていません．

### `bnd`プリフィクス

Intel MPX (Memory Protection Extensions)の機能の一部で，
制御命令 (ジャンプ命令やリターン命令など)に指定できます．
`BND0`から`BND3`レジスタに指定した境界に対して境界チェックを行います．
この機能をサポートしてないCPUでは`nop`として動作します．

- 逆アセンブルして`bnd`を見てもビックリしないためにこの説明を書いています．  
  以下のようにPLTセクションを見ると❶`bnd`が使われています．


```
$ objdump -d /bin/ls | less
(中略)
Disassembly of section .plt:

0000000000004030 <.plt>:
    4030:       ff 35 2a dc 01 00       push   0x1dc2a(%rip)        # 21c60 <_ob
stack_memory_used@@Base+0x114b0>
    4036:       f2 ff 25 2b dc 01 00 ❶ bnd jmp *0x1dc2b(%rip)        # 21c68 <_obstack_memory_used@@Base+0x114b8>
    403d:       0f 1f 00                nopl   (%rax)
```

### `set␣`命令: ステータスフラグの値を取得 {#set}

---
|[記法](./x86-list.md#詳しい記法)|何の略か| 動作 |
|-|-|-|
|**`set␣`** *op1*| set byte on condition| if (条件␣が成立) *op1*=1; else *op1*=0;|
---

<!--
|[詳しい記法](./x86-list.md#詳しい記法)| 例 | 例の動作 | [サンプルコード](./6-inst.md#how-to-execute-x86-inst) | 
|-|-|-|-|
|**`set␣`** *r/m8*| `setz %al`| `%al` = ZF | [setz.s](./asm/setz.s) [setz.txt](./asm/setz.txt)|
|**`set␣`** *r/m8*| `setg %al`| `%al` = より大きい(greater)条件が成立なら1，違えば0 | [setg.s](./asm/setg.s) [setg.txt](./asm/setg.txt)|
-->

<div class="table-wrapper"><table><thead><tr><th><a href="./x86-list.html#%E8%A9%B3%E3%81%97%E3%81%84%E8%A8%98%E6%B3%95">詳しい記法</a></th><th>例</th><th>例の動作</th><th><a href="./6-inst.html#how-to-execute-x86-inst">サンプルコード</a></th></tr></thead><tbody>
<tr><td rowspan="2"><strong><code>set␣</code></strong> <em>r/m8</em></td><td><code>setz %al</code></td><td><code>%al</code> = ZF</td><td><a href="./asm/setz.s">setz.s</a> <a href="./asm/setz.txt">setz.txt</a></td></tr>
<tr><td><code>setg %al</code></td><td> より大きい(greater)条件が成立なら<code>%al</code> =1，違えば<code>%al</code> =0</td><td><a href="./asm/setg.s">setg.s</a> <a href="./asm/setg.txt">setg.txt</a></td></tr>
</tbody></table>
</div>

---
<div style="font-size: 70%;">

|[CF](./x86-list.md#status-reg)|[OF](./x86-list.md#status-reg)|[SF](./x86-list.md#status-reg)|[ZF](./x86-list.md#status-reg)|[PF](./x86-list.md#status-reg)|[AF](./x86-list.md#status-reg)|
|-|-|-|-|-|-|
|&nbsp;| | | | | |
</div>

- `set␣`命令はステータスフラグの値を取得します．
  `␣`には条件付きジャンプ命令`j␣`の`␣`と同じものをすべて入れられます．


### ストリング命令 {#string-insn}

`movs`などのストリング命令はREPプリフィクスと組み合わせて使います．

- REPプリフィクス

---

<!--
|[記法](./x86-list.md#詳しい記法)|何の略か| 動作 |
|-|-|-|
|**`rep`** *insn*| repeat | `%ecx==0`まで命令*insn*と`%ecx--`を繰り返し実行|
|**`repe`** *insn*| repeat while equal| `%ecx==0`またはフラグZF==0まで命令*insn*と`%ecx--`を繰り返し実行|
|**`repz`** *insn*| repeat while zero | `%ecx==0`またはフラグZF==0まで命令*insn*と`%ecx--`を繰り返し実行|
|**`repne`** *insn*| repeat while not equal| `%ecx==0`またはフラグZF==1まで命令*insn*と`%ecx--`を繰り返し実行|
|**`repnz`** *insn*| repeat while not zero | `%ecx==0`またはフラグZF==1まで命令*insn*と`%ecx--`を繰り返し実行|
-->

<div class="table-wrapper"><table><thead><tr><th><a href="./x86-list.html#%E8%A9%B3%E3%81%97%E3%81%84%E8%A8%98%E6%B3%95">記法</a></th><th>何の略か</th><th>動作</th></tr></thead><tbody>
<tr><td><strong><code>rep</code></strong> <em>insn</em></td><td>repeat</td><td><code>%ecx==0</code>になるまで<br/>命令<em>insn</em>と<code>%ecx--</code>を繰り返し実行</td></tr>
<tr><td><strong><code>repe</code></strong> <em>insn</em></td><td>repeat while equal</td><td rowspan=2><code>%ecx==0</code>またはフラグZF==0になるまで<br/>命令<em>insn</em>と<code>%ecx--</code>を繰り返し実行</td></tr>
<tr><td><strong><code>repz</code></strong> <em>insn</em></td><td>repeat while zero</td></tr>
<tr><td><strong><code>repne</code></strong> <em>insn</em></td><td>repeat while not equal</td><td rowspan=2><code>%ecx==0</code>またはフラグZF==1になるまで<br/>命令<em>insn</em>と<code>%ecx--</code>を繰り返し実行</td></tr>
<tr><td><strong><code>repnz</code></strong> <em>insn</em></td><td>repeat while not zero</td></tr>
</tbody></table>
</div>

---

|[詳しい記法](./x86-list.md#詳しい記法)| 例 | 例の動作 | [サンプルコード](./6-inst.md#how-to-execute-x86-inst) | 
|-|-|-|-|
|**`rep`** *insn*| `rep movsb`| `while (%ecx-- > 0) (*%rdi++) = (*%rsi++);` <br/> # 1バイトずつコピー | [rep.s](./asm/rep.s) [rep.txt](./asm/rep.txt)|
|**`repe`** *insn* <br/> **`repz`** *insn* | `repe cmpsb` <br/> `repz cmpsb`| `while (%ecx-- > 0 && (*%rdi++ == *%rsi++)); ` <br/> # 1バイトずつ比較 | [repe.s](./asm/repe.s) [repe.txt](./asm/repe.txt) <br/> [repz.s](./asm/repz.s) [repz.txt](./asm/repz.txt) |
|**`repne`** *insn* <br/> **`repnz`** *insn* | `repne cmpsb` <br/> `repnz cmpsb`| `while (%ecx-- > 0 && (*%rdi++ != *%rsi++)); ` <br/> # 1バイトずつ比較 | [repne.s](./asm/repne.s) [repne.txt](./asm/repne.txt) <br/> [repnz.s](./asm/repnz.s) [repnz.txt](./asm/repnz.txt) |

---

> 注意: DFフラグ(direction flag)が0の場合，`%rsi`と`%rdi`を増やす．DFが1の場合は減らす．上記の説明はDF==0を仮定．

> 注意: ストリング命令はセグメントレジスタ`%ds`と`%es`を使って，`%ds:(%rsi)`と`%es:(%rdi)`にアクセスします．が，x86-64では`%ds`も`%es`もベースレジスタをゼロと扱うので，`%ds`と`%es`は無視して構いません．

<img src="figs/rep-combi.svg" height="250px" id="fig:rep-combi">

- ストリング命令

  |[記法](./x86-list.md#詳しい記法)|何の略か| 動作 |
  |-|-|-|
  |**`movs␣`**| move string | `(%rsi)`を`(%rdi)`に*n*バイト転送; `%rsi` += *n*; `%rdi` += *n*; |
  |**`lods␣`**| load string | `(%rsi)`を`%rax`に*n*バイト転送; `%rsi` += *n*; |
  |**`stos␣`**| store string | `%rax`を`(%rdi)`に*n*バイト転送; `%rdi` += *n*; |
  |**`ins␣`**| input string | I/Oポート`%dx`から`(%rdi)`に*n*バイト転送; `%rdi` += *n*; |
  |**`outs␣`**| output string | `(%rsi)`からI/Oポート`%dx`に*n*バイト転送; `%rsi` += *n*; |
  |**`cmps␣`**| compare string | `(%rsi)`と`(%rdi)`を*n*バイト比較; `%rsi` += *n*; `%rdi` += *n*; |
  |**`scas␣`**| scan string | `%rax`と`(%rdi)`を*n*バイト比較; `%rdi` += *n*; |

  |[詳しい記法](./x86-list.md#詳しい記法)| 例 | 例の動作 | [サンプルコード](./6-inst.md#how-to-execute-x86-inst) | 
  |-|-|-|-|
  |`rep movsb` | `rep movsb`| `while (%ecx-- > 0) (*%rdi++) = (*%rsi++);` <br/> # 1バイトずつコピー | [rep.s](./asm/rep.s) [rep.txt](./asm/rep.txt)|
  |`rep lodsb` | `rep lodsb`| `while (%ecx-- > 0) %al = (*%rsi++);` <br/> # 1バイトずつコピー | [lods.s](./asm/lods.s) [lods.txt](./asm/lods.txt)|
  |`rep stosq` | `rep stosq`| `while (%ecx-- > 0) {(*%rdi) = %rax; %rdi+=8; }` <br/> # 8バイトずつコピー | [stos.s](./asm/stos.s) [stos.txt](./asm/stos.txt)|
  |`repe cmpsb` | `repe cmpsb`| `while (%ecx-- > 0 && (*%rdi++) == (*%rsi++);` <br/> # 1バイトずつ比較 | [repe.s](./asm/repe.s) [repe.txt](./asm/repe.txt)|
  |`repne scasb` | `repne scasb`| `while (%ecx-- > 0 && (*%rdi++) != %rax);` <br/> # 1バイトずつ比較 | [scas.s](./asm/scas.s) [scas.txt](./asm/scas.txt)|

  - `␣`には`b`，`w`，`l`，`q`が入り，それぞれ，
    メモリ参照のサイズ(上では*n*と表記)が1バイト，2バイト，4バイト，8バイトになる．
    (ただし，`ins`と`outs`は`b`，`w`，`l`のみ指定可能)．
  - `%rax`はオペランドサイズにより，`%rax`，`%eax`，`%ax`，`%al`のいずれかになる．
  - `ins␣`と`out␣`の実例はここでは無し．

- DFフラグ(方向フラグ)と`cld`命令・`std`命令

  |[記法](./x86-list.md#詳しい記法)|何の略か| 動作 |
  |-|-|-|
  |**`cld`**| clear direction flag| DF=0 |
  |**`std`**| set direction flag| DF=1 |

  |[詳しい記法](./x86-list.md#詳しい記法)| 例 | 例の動作 | [サンプルコード](./6-inst.md#how-to-execute-x86-inst) | 
  |-|-|-|-|
  |`cld` | `cld`| DF=0 | [cld.s](./asm/cld.s) [cld.txt](./asm/cld.txt)|
  |`std` | `std`| DF=1 | [cld.s](./asm/cld.s) [cld.txt](./asm/cld.txt)|

  - DFフラグはストリング命令で，`%rsi`と`%rdi`を増減する方向を決めます．
    - DF=0 の時は`%rsi`と`%rdi`を増やします
    - DF=1 の時は`%rsi`と`%rdi`を減らします
  - DFフラグの変更は`cld`や`std`で行います
    (一般的にフラグレジスタの値を変更する場合，`pushf`でフラグレジスタの値を保存し，
    `popf`で元に戻すのが安全です)．
  - [Linux AMD64のABI](https://gitlab.com/x86-psABIs/x86-64-ABI/-/jobs/artifacts/master/raw/x86-64-ABI/abi.pdf?job=build)により，
    関数の出入り口ではDF=0に戻す必要があります．このお約束のため，
    自分で`std`していなければ，必ずDF==0となります(わざわざ`cld`する必要はありません)．

