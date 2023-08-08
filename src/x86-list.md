<style type="text/css">
body { counter-reset: chapter 11; }
</style>

# x86-64 命令一覧

## 概要と記号
## 命令サフィックス
## 即値(定数)

整数，文字，文字列

32ビットまでだけど，mov命令は例外で64ビットの即値を扱える．
32ビットの即値は，64ビットの演算前に64ビットに符号拡張される．

## レジスタ
### 汎用レジスタ
### ステータスレジスタ
### プログラムカウンタ
### セグメントレジスタ
### レジスタの別名

同時に使えない制限あり

## アドレッシングモード(オペランドの記法)
### アドレッシングモードの種類

<div class="table-wrapper"><table><thead><tr><th>アドレッシング<br/>モードの種類</th><th>オペランドの値</th><th>例</th><th>計算するアドレス</th></tr></thead>
<tbody>
<tr><td rowspan="2">

[即値(定数)](#addr-mode-imm)
</td><td rowspan="2">定数の値</td><td><code>movq $0x100, %rax</code></td></tr>
<tr><td><code>movq $foo, %rax</code></td></tr>
<tr><td>

[レジスタ参照](#addr-mode-reg)
<br/></td><td>レジスタの値</td><td><code>movq %rbx, %rax</code></td></tr>
<tr><td rowspan="2">

[直接メモリ参照](#addr-mode-direct)
</td><td rowspan="2">定数で指定した<br/>アドレスのメモリ値</td><td><code>movq 0x100, %rax</code></td><td><code>0x100</code></td></tr>
<tr><td><code>movq foo, %rax</code></td><td><code>foo</code></td></tr>
<tr><td rowspan="3">

[間接メモリ参照](#addr-mode-indirect)
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

| | [AT&T形式](./8-inline.md#att-intel) | [Intel形式](./8-inline.md#att-intel)| 計算されるアドレス | 
|-|-|-|-|
|通常のメモリ参照|disp (base, index, scale)|[base + index * scale + disp]| base + index * scale + disp|
|`%rip`相対参照  | disp (%rip) | [rip + disp]| rip + disp |

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
x86-64では`%cs`，`%ds`，`%ss`，`%es`は使われていません．
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

- disp には符号あり定数を指定する．ただし「64ビット定数]は無いことに注意．
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

| [AT&T形式](./8-inline.md#att-intel) | [Intel形式](./8-inline.md#att-intel) | 指定したもの | 計算するアドレス |
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
    

## 「文法」「詳しい文法」欄で用いるオペランドの記法と注意{#詳しい文法}

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
- 一部例外を除き，x86-64では64ビットの即値を書けません．

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

- 記法のおかしな点
  - 直接ジャンプ先の指定*rel*は，定数なのに`$`をつけてはいけない
  - 間接ジャンプ先の指定*\*r/m64*は，
    (他の*r/m*オペランドでは不要だったのに) `*`をつけなくてはいけない
  - 相対アドレスで`rel8`か`rel32`をプログラマは選べない
    (`jmp`命令に命令サフィックス`b`や`l`をつけると怒られる．アセンブラにお任せするしか無い)

- `*%rax`と`*(%rax)`の違いに注意(以下の図を参照)

<img src="figs/indirect-jmp.svg" height="200px" id="fig:indirect-jmp">

## データ転送(コピー)

### データ転送(コピー)：基本

<div id="mov-plain">

---
|[文法](#詳しい文法)|何の略か| 動作 |
|-|-|-|
|**`mov␣`** *op1*, *op2*| move | *op1*の値を*op2*にデータ転送(コピー) |
---
|[詳しい文法](#詳しい文法)| 例 | 例の動作 | [サンプルコード](./6-inst.md#how-to-execute-x86-inst) | 
|-|-|-|-|
|**`mov␣`** *r*, *r/m*| `movq %rax, %rbx` | `%rbx = %rax` |[movq-1.s](./asm/movq-1.s) [movq-1.txt](./asm/movq-1.txt)|
|| `movq %rax, -8(%rsp)` | `*(%rsp - 8) = %rax` |[movq-2.s](./asm/movq-2.s) [movq-2.txt](./asm/movq-2.txt)|
|**`mov␣`** *r/m*, *r*| `movq -8(%rsp), %rax` | `%rax = *(%rsp - 8)` |[movq-3.s](./asm/movq-3.s) [movq-3.txt](./asm/movq-3.txt)|
|**`mov␣`** *imm*, *r*| `movq $999, %rax` | `%rax = 999` | [movq-4.s](./asm/movq-4.s) [movq-4.txt](./asm/movq-4.txt)|
|**`mov␣`** *imm*, *r/m*| `movq $999, -8(%rsp)` | `*(%rsp - 8) = 999` |[movq-5.s](./asm/movq-5.s) [movq-5.txt](./asm/movq-5.txt)||
---
<div style="font-size: 70%;">

|[CF](#ステータスレジスタ)|[OF](#ステータスレジスタ)|[SF](#ステータスレジスタ)|[ZF](#ステータスレジスタ)|[PF](#ステータスレジスタ)|[AF](#ステータスレジスタ)|
|-|-|-|-|-|-|
|&nbsp;| | | | | |


</span>

---
</div>


- `␣`は[命令サフィックス](#命令サフィックス)
- `mov`命令(および他のほとんどのデータ転送命令)はステータスフラグの値を変更しない
- `mov`命令はメモリからメモリへの直接データ転送はできない
