<style type="text/css">
body { counter-reset: chapter 6; }
</style>

# x86-64機械語命令

## x86-64機械語命令の実行方法{#how-to-execute-x86-inst}

### 概要：デバッガ上で実行します

機械語命令を実行しても，単に`a.out`を実行するだけでは
意図通りに実行できたかの確認が難しいです．
(アセンブリコード内から`printf`を呼び出せばいいのですが，
そのコードもうざいので)．
そこで本書では**デバッガを使って**機械語命令の実行と確認を行います．

以下では例として`movq $999, %rax`という機械語命令を実行してみます．
(これらのファイルは[サンプルコード](https://github.com/gondow/linux-x86-64-programming/tree/main/src/asm)から入手できます)．
`movq $999, %rax`は「定数`999`を`%rax`レジスタに格納する」という命令ですので，
実行後，`%rax`レジスタに`999`という値が入っていれば，
うまく実行できたことを確認できます．


```x86asmatt
{{#include asm/movq-4.s}}
```

実行確認のための`gdb`のコマンド列を書いたファイルも用意しています．

<div id="asm/movq-4.txt">

```
# asm/movq-4.txt
{{#include asm/movq-4.txt}}
```
</div>

### デバッガ上で実行：`gdb`コマンドを手入力

`asm/movq-4.txt`中の`gdb`コマンドを
以下のように1行ずつ入力してみて下さい．

```nohighlight
$ gcc -g movq-4.s
$ gdb ./a.out ❶
(gdb) b 7 ❷
Breakpoint 1 at 0x1130: file movq-4.s, line 6.
(gdb) r ❸
Breakpoint 1, main () at movq-4.s:6
6	    ret
(gdb) list 6,6 ❹
5	    movq $999, %rax
(gdb) p $rax ❺
$1 = 999
(gdb) quit
```

- ❶ コンパイルした`a.out`を`gdb`上で実行
- ❷ ブレークポイントを7行目(`movq $999, %rax`の次の行)に設定 (`b`はbreakの略)
- ❸ 実行開始 (`r` は run の略)
- ❹ ソースコードの6行目だけを表示
- ❺ レジスタ`%rax`の値を(10進表記で)表示 (`p`はprintの略)
- [`movq-4.txt`](#asm/movq-4.txt)
  の最後の行 `echo # %raxの値が999なら成功\n`は，
  「どうなると正しく実行できたか」を確認するメッセージを出力するコマンドですので，
  ここでは入力不要です．
  ❺の結果と一致したので「正しい実行」と確認できました．

### デバッガ上で実行：`gdb`コマンドを自動入力 (`-x`オプションを使う)

`gdb`コマンドを手入力して，よく使う`gdb`コマンドを覚えることは良いことです．
とはいえ，手入力は面倒なので，自動入力も使いましょう．

```nohighlight
$ gcc -g movq-4.s
$ gdb ./a.out ❶ -x movq-4.txt
Breakpoint 1, main () at movq-4.s:7
7	    ret
6	 ❷ movq $999, %rax
❸ $1 = 999 
❹ # %raxの値が999なら成功
(gdb) 

```

- ❶ `-x movq-4.txt` というオプションをつけると，指定したファイル(ここでは`movq-4.txt`)の中に書かれている`gdb`コマンドを1行ずつ順番に実行してくれます
-  `list 6,6`を実行した結果，❷6行目の`movq $999, %rax` が表示されています
-  `p $rax`を実行した結果，`%rax`レジスタの値が❸999であると表示されています．
  (`$1`は`gdb`が扱う変数です．ここでは無視して下さい)
-  `echo # %raxの値が999なら成功\n` を`gdb`が実行した結果，
❹ `# %raxの値が999なら成功`というメッセージが表示されています．
このメッセージと❸の実行結果を見比べれば「実行結果が正しい」ことを確認できます．

### デバッガ上で実行：`gdb`コマンドを自動入力 (`source`コマンドを使う)

```nohighlight
$ gcc -g movq-4.s
$ gdb ./a.out
(gdb) ❶ source movq-4.txt
Breakpoint 1, main () at movq-4.s:7
7	    ret
6	    movq $999, %rax
$1 = 999
# %raxの値が999なら成功
```

`gdb`は通常通りに実行開始して，
❶ `source`コマンドを使えば，`movq-4.txt`中の`gdb`コマンドを実行できます．
`-x`オプションと`source`コマンドは好きな方を使って下さい．

## アドレッシングモード (オペランドの表記方法)

### アドレッシングモードの概要

機械語命令は命令(**オペコード**(opcode))と
その引数の**オペランド**(operand)から構成されています．
例えば，`movq $999, %rax`という命令では，
`movq`がオペコードで，`$999`と`%rax`がオペランドです．

<img src="figs/opcode-operand.svg" height="100px" id="fig:opcode-operand">

**アドレッシングモード**とはオペランドの書き方のことです．
(元々は「メモリのアドレスを指定する記法」という意味で「アドレッシングモード」という用語が使われています).
x86-64では大きく，以下の4種類の書き方ができます．

<div class="table-wrapper"><table><thead><tr><th>アドレッシング<br/>モードの種類</th><th>オペランドの値</th><th>例</th></tr></thead>
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
</td><td rowspan="2">定数で指定した<br/>アドレスのメモリ値</td><td><code>movq 0x100, %rax</code></td></tr>
<tr><td><code>movq foo, %rax</code></td></tr>
<tr><td rowspan="3">

[間接メモリ参照](#addr-mode-indirect)
</td><td rowspan="3">レジスタ等で計算した<br/>アドレスのメモリ値</td><td><code>movq (%rsp), %rax</code></td></tr>
<tr><td><code>movq 8(%rsp), %rax</code></td></tr>
<tr><td><code>movq foo(%rip), %rax</code></td></tr>
</tbody></table>
</div>


- `foo`はラベル（その値はアドレス）であり，定数と同じ扱い．(定数を書ける場所にはラベルも書ける)．
- メモリ参照では例えば`-8(%rbp, %rax, 8)`など複雑なオペランドも指定可能．
  参照するメモリのアドレスは`-8+%rbp+%rax*8`になる．
  ([以下](#メモリ参照)を参照)．

### アドレッシングモード：即値（定数）{#addr-mode-imm}

#### 定数 `$999`

**即値**(immediate value，定数)には`$`をつけます．
例えば`$999`は定数`999`を意味します．

```x86asmatt
{{#include asm/movq-4.s}}
```

[`movq-4.s`](./asm/movq-4.s)の6行目の
`movq $999, %rax`は「定数`999`をレジスタ`%rax`に格納する」という意味です．
デバッガで動作を確認します
(デバッガの操作手順は[`movq-4.txt`](./asm/movq-4.txt)にもあります)．

```
$ gcc -g movq-4.s
$ gdb ./a.out
(gdb) b main
Breakpoint 1 at 0x1129: file movq-4.s, line 6.
(gdb) r
Breakpoint 1, main () at movq-4.s:6
6	    movq $999, %rax
(gdb) si
main () at movq-4.s:7
7	    ret
(gdb) p $rax
$1 = 999
```

確かに`%rax`レジスタ中に`999`が格納されていました．

なお，多くの場合，即値は32ビットまでで，オペランドのサイズが64ビットの場合，
32ビットの即値は，64ビットの演算前に
**64ビットに[符号拡張](./4-encoding.md#符号拡張とゼロ拡張)** されます
([ゼロ拡張](./4-encoding.md#符号拡張とゼロ拡張)だと
負の値が大きな正の値になって困るからです)．
64ビットに符号拡張される例は[こちら](x86-list.md#imm-64bit-signed-extended)
を見て下さい．
例外は`movq`命令で，64ビットの即値を扱えます．
実行例は[こちら](x86-list.md#mov-64bit-imm)を見て下さい．

#### ラベル `$main`

定数が書ける場所にはラベル(その値はアドレス)も書けます．
ラベルは関数名やグローバル変数の実体があるメモリの先頭番地を
示すために使われます(それ以外にはジャンプのジャンプ先としても使われます)．
ですので，`main`関数の先頭番地を示す`main`というラベルが
`main`関数をコンパイルしたアセンブリコード中に存在します．

```x86asmatt
{{#include asm/movq-6.s}}
```

[movq-6.s](./asm/movq-6.s)の6行目の`movq $main, %rax`は
「ラベル`main`が表すアドレスを`%rax`レジスタに格納する」という意味です．
`gdb`で確かめます．

```
$ gcc ❶ -no-pie -g movq-6.s
$ gdb ./a.out
(gdb) b main
Breakpoint 1 at ❷ 0x40110a: file movq-6.s, line 7.
(gdb) r
Breakpoint 1, main () at movq-6.s:7
7   ❸  movq $main, %rax
(gdb) ❹ si
main () at movq-6.s:8
8	ret
(gdb) p/x $rax
$1 = ❺ 0x40110a 
```

- まず❶ `-no-pie`オプションをつけてコンパイルして下さい．
  (`-static`オプションを使ってもうまくいくと思います)

<details>
<summary>
なぜ -no-pieオプション
</summary>

`-no-pie`オプションをつけないと以下のエラーが出てしまうからです．

```
$ gcc -g movq-6.s
/usr/bin/ld: /tmp/ccqHsPbg.o: relocation R_X86_64_32S against symbol `main' can not be used when making a PIE object; recompile with -fPIE
/usr/bin/ld: failed to set dynamic section sizes: bad value
collect2: error: ld returned 1 exit status
```

`-no-pie`は「位置独立実行可能ファイル
([PIE](./3-binary.md#ASLR-PIE)，[PIE](./3-binary.md#PIE))を生成しない」
というオプションです．
最近のLinuxの`gcc`では，PIEがデフォルトで有効になっている事が多いです．
[PIC](./3-binary.md#PIC)(位置独立コード)やPIEは「再配置(アドレス調整)無しに
どのメモリ番地に配置しても，そのまま実行可能」という機械語命令列です．
そのため，PIEやPICのメモリ参照では**絶対アドレス**(absolute address)が使えません．

`-no-pie`オプションが無いと，
アセンブラは`movq $main, %rax`という命令中の`main`というラベルを
「絶対アドレスだ」と解釈してエラーにするようです．

<details>
<summary>
絶対アドレス，相対アドレスとは
</summary>

<div id="絶対アドレス・相対アドレス">
<img src="figs/absolute-addr.svg" height="250px" id="fig:absolute-addr">

**絶対アドレス**とは「メモリの先頭0番地から何バイト目か」で示すアドレスです．
上図で青色のメモリ位置の絶対アドレスは`0x1000`番地となります．
一方，**相対アドレス**(relative address)は(0番地ではなく)別の何かを起点とした差分のアドレスです．
x86-64では`%rip`レジスタ(プログラムカウンタ)を起点とすることが多いです．
上図では青色のメモリ位置の相対アドレスは
`%rip`を起点とすると，`-0x500`番地となります(`0x1000 - 0x1500 = -0x500`)．

また，相対アドレスに起点のアドレスを足すと絶対アドレスになります
(`-0x500 + 0x1500 = 0x1000`)．
</div>
</details>

なぜ PICやPIEで絶対アドレスが使えないかと言うと，
機械語命令列を何番地に置くかで，絶対アドレスが変化してしまうからです．

<details>
<summary>
もうちょっと具体的に
</summary>

例えば，`movq $main, %rax`という命令は
`main`関数のアドレスを`%rax`レジスタに格納するわけですが，
このアドレスが絶対アドレスの場合，出力される機械語命令に
絶対アドレスが埋め込まれてしまいます．

```
$ gcc -no-pie -g movq-6.s
$ objdump -d ./a.out
(一部略)
000000000040110a <main>:
  40110a:  48 c7 c0 ❷ 0a 11 40 00    mov ❶$0x40110a,%rax
  401111:  c3                        ret    
```

上の逆アセンブル結果を見ると，確かに`main`関数のアドレス❶ `0x40110a`が
機械語命令列に❷埋め込まれています．
(x86-64は[リトルエンディアン](./3-binary.md#LSB)なので，バイトの並びが逆順に見えることに注意)．

相対アドレスだと大丈夫なことも見てみます．
[`leaq-1.s`](./asm/leaq-1.s)中の
`leaq main(%rip), %rax`は，
「`%rip`を起点とした`main`の相対アドレスと，
 `%rip`の値との和を`%rax`レジスタに格納する」という命令です．
(`lea` は load effective address の略です．effective addressは日本語では**実効アドレス**です)．

```x86asmatt
{{#include asm/leaq-1.s}}
```

```
$ gcc -g leaq-1.s
$ objdump -d ./a.out
(一部略)
0000000000001129 <main>:
 ❶ 1129:  48 8d 05 ❸ f9 ff ff ff    lea    ❷ -0x7(%rip),%rax  # 1129 <main>
 ❹ 1130:  c3                      ret    
```

上のように逆アセンブルすると以下が分かります．

- `main`関数の(ファイル`a.out`中での)アドレスは❶ `0x1129`番地
- `leaq main(%rip), %rax`の `%rip`の値は❸ `0x1130`番地
  (プログラムカウンタ `%rip`は「次に実行する機械語命令のアドレス」を保持しています)．
- 機械語命令に埋め込まれているアドレスは相対アドレスで，
  ❶ `0x1129` - ❸ `0x1130` = ❷ `-0x7` = ❸ `0xFFFFFFF9` です．

❶ `0x1129` や ❹ `0x1130` のアドレスは，
`main`関数がどのアドレスに配置されるかで変化します．
しかし，この相対アドレス❷ `-0x7` は
`main`関数がどのアドレスに配置されても変化しないので，
この機械語命令はPICやPIEとして使えるわけです．

❷ `-0x7` が ❸ `0xFFFFFFF9` として埋め込まれているのは，
[2の補数表現](xxx)だからですね

なお，相対アドレスが固定にならない場合(例えば，`printf`関数のアドレス)もあります．
その場合は[GOTやPLT](./3-binary.md#GOT-PLT)を使います．
`printf`関数のアドレスを機械語命令列(`.text`セクション)に埋め込むのではなく，
別の書込み可能なセクション(例：`got`セクション)に格納し，
そのアドレスを使って**間接コール**(indirect call)するのです．

</details>
</details>

<details>
<summary>
-staticオプションとは
</summary>

`-static`オプションは(動的リンクではなく)
[**静的リンク**](./3-binary.md#静的リンクと動的リンク)
せよという，`gcc`への指示になります．
</details>

- `main`関数の先頭にブレークポイントを設定します．
  `main`関数の先頭アドレスが❷ `0x40110a`と分かります．

- ❸ `movq $main, %rax`の実行直前で止まっているので，
  ❹ `si`で1命令実行を進めます．
- ❺ `%rax`レジスタ中に`main`関数のアドレス❷ `0x40110a`が入っていました．


### アドレッシングモード：レジスタ参照{#addr-mode-reg}

```x86asmatt
{{#include asm/movq-1.s}}
```

[`movq-1.s`](./asm/movq-1.s)中の`movq %rax, %rbx`は
「`%rax`レジスタ中の値を`%rbx`に格納する」という意味です．

```
$ gcc -g movq-1.s
$ gdb ./a.out
(gdb) b main
Breakpoint 1 at 0x1129: file movq-1.s, line 6.
(gdb) r
Breakpoint 1, main () at movq-1.s:6
6	    ❶ movq $999, %rax
(gdb) si
7	    ❷ movq %rax, %rbx
(gdb) si
main () at movq-1.s:8
8	    ret
(gdb) p $rax
$1 = ❸ 999
(gdb) p $rbx
$2 = ❹ 999
```

`gdb`上での実行で，❶ 定数`999`が`%rax`に格納され，
❷ `%rax`中の`999`がさらに`%rbx`に格納されたことを
❸❹確認できました．

### アドレッシングモード：直接メモリ参照{#addr-mode-direct}

**直接メモリ参照**はアクセスするメモリ番地が定数となるメモリ参照です．
以下の例ではラベル`x`を使ってメモリ参照していますが，
これは直接メモリ参照になります．
アセンブル時に(つまり実行する前に)アドレスが具体的に(以下では`0x404028`番地)と決まるからです．


```x86asmatt
{{#include asm/movq-7.s}}
```

```
$ gcc -g -no-pie movq-7.s
$ gdb ./a.out -x movq-7.txt
Breakpoint 1, main () at movq-7.s:10
10	    ret
9	    movq x, %rax
$1 = ❶ 999
# %raxの値が999なら成功
```

以下の図で`0x401106<main>`は「ラベル`main`が示すアドレスは`0x401106`番地」
「ラベル`x`が示すアドレスは`0x404028`番地」であることを示してます．

<img src="figs/label2.svg" height="250px" id="fig:label2">

そして[`movq-7.s`](./asm/movq-7.s)中の以下の3行で，以下は

```x86asmatt
    .data
x:
    .quad 999 
```

「`.data`セクションにサイズが8バイトのデータとして値`999`を配置せよ」
「そのデータの先頭アドレスをラベル`x`として定義せよ」を意味しています
(`quad`が8バイトを意味しています)．
ですので，実行時には上図のように
「`.data`セクションのある場所(上図では`0x404028`番地)に値`999`が入っていて，
ラベル`x`の値は`0x404028`」となっています．

ですので，[`movq-7.s`](./asm/movq-7.s)中の`movq x, %rax`は
「ラベル`x`が表すアドレス(上図では`0x404028`番地)のメモリの中身(上図では`999`)
を`%rax`レジスタにコピーせよ」を意味します．

実行すると`movq x, %rax`の実行で，`x`中の`999`が`%rax`レジスタに
コピーされたことを確認できました❶．

ここで$マークの有無，つまり`x`と`$x`の違いに注意しましょう
([上図](#label2)も参照)．

```x86asmatt
movq x, %rax    # x はメモリの中身を表す
movq $x, %rax   # $x はアドレスを表す
```

以下のように`movq $x, %rax`を実行すると，
`%rax`レジスタにはアドレス(ここでは`0x404028`番地)が
入っていることを確認できました❷．

<details>
<summary>
-8(%rbp)の-8には(定数なのに)$マークが付かない
</summary>

[以下](#addr-mode-indirect)でも説明しますが，
例えば`-8(%rbp)`とオペランドに書いた時，`-8`は($マークが無いのに)
定数として扱われます．
そして，`-8(%rbp)`は，`%rbp - 8`の計算結果をアドレスとするメモリの中身を意味します．　
ちなみにこの`-8`のことは
[Intelのマニュアル](https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html)では**変位** (displacement)と呼ばれています．
つまり「変位は定数だけど$マークはつきません」．
</details>



```x86asmatt
{{#include asm/movq-8.s}}
```

```
$ gcc -g -no-pie movq-8.s
$ gdb ./a.out -x movq-8.txt
Breakpoint 1, main () at movq-8.s:10
10	    ret
9	    movq $x, %rax
$1 = 0x404028 ❷
nm ./a.out | egrep 'd x'
0000000000404028 d x
# %raxの値と nmコマンドによるxのアドレスが一致すれば成功
```

ちなみに，`x`のアドレスが`0x404028`になると分かっていれば，

```x86asmatt
movq x, %rax          # これと
movq 0x404028, %rax   # これは同じ意味
```

上の2行は全く同じ意味(`0x404028`番地のメモリの中身)になります．
しかし，何番地になるか事前に分からないのが普通なので，
通常はラベル(ここでは`x`)を使います．

### アドレッシングモード：間接メモリ参照{#addr-mode-indirect}

**間接メモリ参照**はアクセスするメモリ番地が変数となるメモリ参照です．
アセンブリ言語では変数という概念は無いので，
正確には「実行時に決まるレジスタの値を使って，
参照先のメモリアドレスを計算して決める」という参照方式です．
以下では3つの例が出てきます([以下](#メモリ参照)でより複雑な間接メモリ参照を説明します)．

| 間接メモリ参照 | 計算するアドレス |
|-|-|
| `(%rsp)`       | `%rsp`          |
|`8(%rsp)`       | `%rsp + 8`      |
| `foo(%rip)`    | `%rip + foo`    |

<br/>

<img src="figs/addr-mode-indirect.svg" height="250px" id="fig:addr-mode-indirect">

以下の[movq-9.s](./asm/movq-9.s)を`pushq $777`まで実行すると，
メモリの状態は上図のようになっています．
(`%rsp`が指す`777`のひとつ下のアドレスが`%rsp+8`なのは，
`pushq $777`命令が「サイズが8バイトの値`777`をスタックにプッシュしたから」です)．


```x86asmatt
{{#include asm/movq-9.s}}
```

- `(%rsp)` は「アドレスが `%rsp`の値のメモリ」なので値`777`が入っている部分を参照します
- `8(%rsp)` は「アドレスが `%rsp + 8`の値のメモリ」なので値`888`が入っている部分を参照します
- `foo(%rip)` はちょっと特殊です．この形式は **`%rip`相対アドレッシング** といいます．
この形式の時，ラベル`foo`の値はプログラムカウンタ`%rip`中のアドレスを起点とした
[相対アドレス](#絶対アドレス・相対アドレス)
になります．ですので，`%rip + foo`は`foo`の
[絶対アドレス](#絶対アドレス・相対アドレス)
になるので，
`foo(%rip)`はラベル`foo`のメモリ部分，つまり`999`が入っている部分になります．

<details>
<summary>
gdbでの実行結果
</summary>

```
$ gcc -g movq-9.s
$ gdb ./a.out -x movq-9.txt
Breakpoint 1, main () at movq-9.s:14
14	    ret
11	    movq (%rsp), %rax
12	    movq 8(%rsp), %rbx
13	    movq foo(%rip), %rcx
$1 = 777
$2 = 888
$3 = 999
# 777, 888, 999なら成功
```
</details>

### メモリ参照

[前節](#addr-mode-indirect)では，
 `(%rsp)`，`8(%rsp)`，`foo(%rip)`という間接メモリ参照の例を説明しました．
 ここではメモリ参照の一般形を説明します．
以下がx86-64のメモリ参照の形式です．

| | [AT&T形式](./8-inline.md#att-intel) | [Intel形式](./8-inline.md#att-intel)| 計算されるアドレス | 
|-|-|-|-|
|通常のメモリ参照|disp (base, index, scale)|[base + index * scale + disp]| base + index * scale + disp|
|`%rip`相対参照  | disp (`%rip`) | [rip + disp]| `%rip` + disp |


<details>
<summary>
「segment: メモリ参照」という形式
</summary>

実は「segment: メモリ参照」という形式もあるのですが，
あまり使わないので，ここでは省いて説明します．
興味のある人は[こちら](x86-list.md#segment-override)を参照下さい．
</details>

disp (base, index, scale)
でアクセスするメモリのアドレスは
base + index * scale + disp で計算します．
disp(`%rip`)でアクセスするメモリのアドレスは
disp + `%rip`で計算します．
disp，base，index，scaleとして指定可能なものは次の節で説明します．

### メモリ参照で可能な組み合わせ(64ビットモードの場合)

#### 通常のメモリ参照

通常のメモリ参照では，disp，base，index，scaleに以下を指定できます．

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
> (`abs`はおそらく絶対アドレス absolute address から)．
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

以下がメモリ参照の例です．

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
| `%fs:-4` | `fs:[-4]` | [segment](./x86-list.md#segment-override)とdisp | `%fsのベースレジスタ - 4` |

<details>
<summary>
なんでこんな複雑なアドレッシングモード?
</summary>

x86-64はRISCではなくCISCなので「よく使う1つの命令で複雑な処理が
できれば，それは善」という思想だからです(知らんけど)．
例えば，以下のCコードの配列`array[i]`へのアクセスはアセンブリコードで
`movl (%rdi,%rsi,4), %eax`の1命令で済みます．
(ここでは`sizeof(int)`が`4`なので，scaleが`4`になっています．
配列の先頭アドレスが`array`の，`i`番目の要素のアドレスは，
`array + i * sizeof(int)`で計算できることを思い出しましょう．
なお，`array.s`の出力を得るには，`gcc -S -O2 array.c`として下さい．
私の環境では`-O2`が無いと`gcc`は冗長なコードを吐きましたので)．

```
{{#include asm/array.c}}
```

```
{{#include asm/array.s}}
```
</details>
    
## オペランドの表記方法

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

## x86-64機械語命令：転送など

### `nop`命令: 何もしない

`nop`は転送命令ではありませんが，最も簡単な命令ですので最初に説明します．

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

|[CF](./5-arch.md#status-reg)|[OF](./5-arch.md#status-reg)|[SF](./5-arch.md#status-reg)|[ZF](./5-arch.md#status-reg)|[PF](./5-arch.md#status-reg)|[AF](./5-arch.md#status-reg)|
|-|-|-|-|-|-|
|&nbsp;| | | | | |
</div>

---

- `nop`は何もしない命令です(ただしプログラムカウンタ`%rip`は増加します)．
  フラグも変化しません．
- 機械語命令列の間を(何もせずに)埋めるために使います．
- `nop`の機械語命令は1バイト長です．
  (なのでどんな長さの隙間にも埋められます)．
- `nop` *r/m* という形式の命令は2〜9バイト長の`nop`命令になります．
  1バイト長の`nop`を9個並べるより，
  9バイト長の`nop`を1個並べた方が，実行が早くなります．
- 「複数バイトの`nop`命令がある」という知識は，
  逆アセンブル時に`nopl (%rax)`などを見て「なんじゃこりゃ」とビックリしないために必要です．

### `mov`命令: データの転送（コピー）


<div id="mov-plain">

---
|[記法](./x86-list.md#詳しい記法)|何の略か| 動作 |
|-|-|-|
|**`mov␣`** *op1*, *op2*| move | *op1*の値を*op2*にデータ転送(コピー) |
---

<div class="table-wrapper"><table><thead><tr><th><a href="./x86-list.html#%E8%A9%B3%E3%81%97%E3%81%84%E6%96%87%E6%B3%95">詳しい記法</a></th><th>例</th><th>例の動作</th><th><a href="./6-inst.html#how-to-execute-x86-inst">サンプルコード</a></th></tr></thead><tbody>
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

- `mov`命令は第1オペランドの値を第2オペランドに転送(コピー)します．
  例えば，`movq %rax, %rbx`は「`%rax`の値を`%rbx`にコピー」することを意味します．

<details>
<summary>
movq-1.sの実行例
</summary>

```
$ gcc -g movq-1.s
$ gdb ./a.out -x movq-1.txt
Breakpoint 1, main () at movq-1.s:8
8	    ret
7	    movq %rax, %rbx
# p $rbx
$1 = 999
# %rbxの値が999なら成功
```
</details>

<details>
<summary>
movq-2.sの実行例
</summary>

```
$ gcc -g movq-2.s
$ gdb ./a.out -x movq-2.txt
Breakpoint 1, main () at movq-2.s:8
8	    ret
7	    movq %rax, -8(%rsp)
# x/1gd $rsp-8
0x7fffffffde90:	999
# -8(%rsp)の値が999なら成功
```
</details>

- オペランドには，即値，レジスタ，メモリ参照を組み合わせて指定できますが，
  メモリからメモリへの直接データ転送はできません．
- `␣`には[命令サフィックス](./x86-list.md#命令サフィックス)
  (`q`, `l`, `w`, `b`)を指定します．
  命令サフィックスは転送するデータのサイズを明示します
  (順番に，8バイト，4バイト，2バイト，1バイトを示します)．

  - `movb $0x11, (%rsp)` は値`0x11`を**1バイト**のデータとして`(%rsp)`に書き込む
  - `movw $0x11, (%rsp)` は値`0x11`を**2バイト**のデータとして`(%rsp)`に書き込む
  - `movl $0x11, (%rsp)` は値`0x11`を**4バイト**のデータとして`(%rsp)`に書き込む
  - `movq $0x11, (%rsp)` は値`0x11`を**8バイト**のデータとして`(%rsp)`に書き込む

<div class="tab-wrap">
    <input id="mov1" type="radio" name="TAB" class="tab-switch" checked="checked" />
    <label class="tab-label" for="mov1"><code>movb $0x11, (%rax)</code></label>
    <div class="tab-content">
    	 <img src="figs/mov1.svg" height="300px" id="fig:mov1">
    </div>
    <input id="mov2" type="radio" name="TAB" class="tab-switch" />
    <label class="tab-label" for="mov2"><code>movw $0x11, (%rax)</code></label>
    <div class="tab-content">
    	 <img src="figs/mov2.svg" height="300px" id="fig:mov2">
    </div>
    <input id="mov3" type="radio" name="TAB" class="tab-switch" />
    <label class="tab-label" for="mov3"><code>movl $0x11, (%rax)</code></label>
    <div class="tab-content">
    	 <img src="figs/mov3.svg" height="300px" id="fig:mov3">
    </div>
    <input id="mov4" type="radio" name="TAB" class="tab-switch" />
    <label class="tab-label" for="mov4"><code>movq $0x11, (%rax)</code></label>
    <div class="tab-content">
    	 <img src="figs/mov4.svg" height="300px" id="fig:mov4">
    </div>
</div>

#### 機械語命令のバイト列をアセンブリコードに直書きできる

`movq %rax, %rbx`をコンパイルして逆アセンブルすると，
機械語命令のバイト列は`48 89 C3`となります．
`.byte`というアセンブラ命令を使うと，
アセンブラに指定したバイト列を出力できます．
例えば，次のように`.byte 0x48, 0x89, 0xC3`と書くと，
`.text`セクションに`0x48, 0x89, 0xC3`というバイト列を出力できます．

```x86asmatt
{{#include asm/byte.s}}
```

```
$ gcc -g byte.s
$ objdump -d ./a.out
(中略)
0000000000001129 <main>:
    1129:   ❶48 89 c3     ❸mov    %rax,%rbx
    112c:   ❷48 89 c3     ❹mov    %rax,%rbx
    112f:   c3               ret    
```

コンパイルして逆アセンブルしてみると，
❷`0x48, 0x89, 0xC3`を出力できています．
一方，❶`0x48, 0x89, 0xC3`にも同じバイト列が並んでいます．
これは❸`movq %rax, %rbx`命令の機械語命令バイト列ですね．
さらに❷`0x48, 0x89, 0xC3`の逆アセンブル結果として，
❹`movq %rax, %rbx`とも表示されています．

つまり，アセンブラにとっては，

- `movq %rax, %rbx` というニモニック
- `.byte 0x48, 0x89, 0xC3` というバイト列

は全く同じ意味になるのでした．
ですので，`.text`セクションにニモニックで機械語命令を書く代わりに，
`.byte`を使って直接，機械語命令のバイト列を書くことができます．

#### 異なる機械語のバイト列で，同じ動作の`mov`命令がある

- 質問： `%rax`の値を`%rbx`にコピーしたい時，
  `movq` *r*, *r/m* と `movq` *r/m*, *r* のどちらを使えばいいのでしょう?
- 答え： どちらを使ってもいいです．ただし，異なる機械語命令のバイト列に
  なることがあります．

実は`0x48, 0x89, 0xC3`というバイト列は，
`movq` *r*, *r/m* を使った時のものです．
一方，`movq` *r/m*, *r* という形式を使った場合は，
バイト列は `0x48, 0x8B, 0xD8`になります．確かめてみましょう．

```x86asmatt
{{#include asm/byte2.s}}
```

```
$ gcc -g byte2.s
$ objdump -d ./a.out
(中略)
0000000000001129 <main>:
    1129:    ❶48 89 c3      ❸mov    %rax,%rbx
    112c:    ❷48 8b d8      ❹mov    %rax,%rbx
    112f:      c3             ret    
```

❶`48 89 c3`と❷`48 8b d8`は異なるバイト列ですが
逆アセンブル結果としては
❸`mov %rax,%rbx`と❹`mov %rax,%rbx`と，どちらも同じ結果になりました．

このように同じニモニック命令に対して，複数の機械語のバイト列が存在する時，
アセンブラは「実行が速い方」あるいは「バイト列が短い方」を適当に選んでくれます．
(そして，アセンブラが選ばない方をどうしても使いたい場合は，
`.byte`等を使って機械語のバイト列を直書きするしかありません)．

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

- `xchg`命令は**アトミックに**2つのオペランドの値を交換します．(LOCKプレフィクスをつけなくてもアトミックになります)
- この**アトミック**な動作はロックなどの**同期機構**を作るために使えます．

<details>
<summary>
xchg.sの実行例
</summary>

```
$ gcc -g xchg.s
$ gdb ./a.out -x xchg.txt
Breakpoint 1, main () at xchg.s:9
9	    xchg %rax, (%rsp)
1: /x $rax = 0x99aabbccddeeff00
2: /x *(void **)($rsp) = 0x1122334455667788
10	    xchg (%rsp), %rax
1: /x $rax = 0x1122334455667788
2: /x *(void **)($rsp) = 0x99aabbccddeeff00
11	    popq %rax
1: /x $rax = 0x99aabbccddeeff00
2: /x *(void **)($rsp) = 0x1122334455667788
# 値が入れ替わっていれば成功
```
</details>

<details>
<summary>
機械語1命令の実行はアトミックとは限らない
</summary>

機械語1命令の実行はアトミックとは限りません．
例えば，`inc`命令(オペランドを1増やす命令)は
マニュアルによると「`LOCK`プリフィックスをつければアトミックに実行される」とあります．
`inc`命令に`LOCK`プリフィックスがない場合には(たまたまアトミックに実行されるかも知れませんが)
「常にアトミックである」と期待してはいけないのです(マニュアルで「アトミックだ」と明記されていない限り)．

なお，`inc`は「メモリから読んだ値に1を足して書き戻す」ため
アトミックにならない可能性がありますが，**読むだけ**または**書くだけ**でかつ，
**適切にアラインメント**されていれば，
そのメモリ操作は[アトミックになります](https://stackoverflow.com/questions/36624881/why-is-integer-assignment-on-a-naturally-aligned-variable-atomic-on-x86/36685056#36685056)．
</details>

### `lea`命令: 実効アドレスを計算

---
|[記法](./x86-list.md#詳しい記法)|何の略か| 動作 |
|-|-|-|
|**`lea␣`** *op1*, *op2* | load effective address| *op1* の実効アドレスを *op2* に代入する |
---
|[詳しい記法](./x86-list.md#詳しい記法)| 例 | 例の動作 | [サンプルコード](./6-inst.md#how-to-execute-x86-inst) | 
|-|-|-|-|
|**`lea␣`** *m*, *r* | `leaq -8(%rsp, %rsi, 4), %rax` | `%rax=%rsp+%rsi*4-8`|[leaq-2.s](./asm/leaq-2.s) [leaq-2.txt](./asm/leaq-2.txt)|
---
<div style="font-size: 70%;">

|[CF](./x86-list.md#status-reg)|[OF](./x86-list.md#status-reg)|[SF](./x86-list.md#status-reg)|[ZF](./x86-list.md#status-reg)|[PF](./x86-list.md#status-reg)|[AF](./x86-list.md#status-reg)|
|-|-|-|-|-|-|
|&nbsp;| | | | | |

</div>

- `lea`命令は第1オペランド(常にメモリ参照)の実効アドレスを計算して，
  第2オペランドに格納します．
- `lea`命令はアドレスを計算するだけで，メモリにはアクセスしません．  

<details>
<summary>
leaq-2.sの実行例
</summary>

```
$ gcc -g lea.s
$ gdb ./a.out -x lea.txt
Breakpoint 1, main () at leaq-2.s:8
8	    ret
# p/x $rsp
$1 = 0x7fffffffde98
# p/x $rsi
$2 = 0x8
# p/x $rax
$3 = 0x7fffffffdeb0
# %rax == %rsp + %rsi * 4 なら成功
```
</details>

- **実効アドレス**とは[直接メモリ参照](#addr-mode-direct)や
  [間接メモリ参照](#addr-mode-indirect)で計算したアドレスことです．

<details>
<summary>
実効アドレスとリニアアドレスの違いは?→(ほぼ)同じ
</summary>

<br/>
<img src="figs/effective-addr.svg" height="300px" id="fig:effective-addr">

- **実効アドレス**(effective address)は
  [メモリ参照](./6-inst.md#メモリ参照)で
  disp (base, index, scale) や disp (`%rip`)から計算したアドレスのことです．
- x86-64のアセンブリコード中のアドレスは**論理アドレス** (logical address)といい，
  **セグメント**と**実効アドレス**のペアとなっています．
  このペアをx86-64用語で**farポインタ**とも呼びます．
  (本書ではfarポインタは扱いません)．
- セグメントが示すベースアドレスと実効アドレスを加えたものが
  **リニアアドレス**(linear address)です．
  例えば64ビットアドレス空間だと，リニアアドレスは0番地から2<sup>64</sup>-1番地
  まで一直線に並ぶのでリニアアドレスと呼ばれています．
  リニアアドレスは**仮想アドレス**(virtual address)と等しくなります．
- また，x86-64では[例外](./x86-list.md#segment-override)を除き，
  セグメントが示すベースアドレスが0番地なので，
  **実効アドレスとリニアアドレスは等しくなります**．
- リニアアドレス(仮想アドレス)はCPUのページング機構により，
  物理アドレスに変換されて，最終的なメモリアクセスが行われます．

</details>

- コンパイラは加算・乗算を高速に実行するため`lea`命令を使うことがあります．

例えば，

```x86asmatt
movq $4, %rax
addq %rbx, %rax
shlq $2, %rsi   # 左論理シフト．2ビット左シフトすることで%rsiを4倍にしている
addq %rsi, %rax
```

は，`%rax = %rbx + %rsi * 4 + 4`という計算を4命令でしていますが，
`lea`命令なら以下の1命令で済みます

```x86asmatt
leaq 4(%rbx, %rsi, 4), %rax
```

> 注: 実行時間は命令ごとに異なりますので，命令数だけで
> 実行時間を比較することはできません．

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

<br/>
<div class="tab-wrap">
    <input id="push-pop1" type="radio" name="TAB" class="tab-switch" checked="checked" />
    <label class="tab-label" for="push-pop1"><code>pushq %rax前</code></label>
    <div class="tab-content">
    	 <img src="figs/push-pop1.svg" height="350px" id="fig:push-pop1">
    </div>
    <input id="push-pop2" type="radio" name="TAB" class="tab-switch" />
    <label class="tab-label" for="push-pop2"><code>pushq %rax後</code></label>
    <div class="tab-content">
    	 <img src="figs/push-pop2.svg" height="350px" id="fig:push-pop2">
    </div>
    <input id="push-pop3" type="radio" name="TAB" class="tab-switch" />
    <label class="tab-label" for="push-pop3"><code>popq %rbx後</code></label>
    <div class="tab-content">
    	 <img src="figs/push-pop3.svg" height="350px" id="fig:push-pop3">
    </div>
</div>

- `push`命令はスタックポインタ`%rsp`を**減らしてから**，
  スタックトップ(スタックの一番上)にオペランドの値を格納します．
- `pop`命令はスタックトップの値をオペランドに**格納してから**，
  スタックポインタを増やします．
- 64ビットモードでは，32ビットの`push`と`pop`はできません．
- 抽象データ型のスタックは(スタックトップに対する)プッシュ操作とポップ操作しか
  できませんが，x86-64のスタック操作はスタックトップ以外の部分にも自由にアクセス可能です(例えば，`-8(%rsp)`や`-8(%rbp)`などへのメモリ参照で)．

<details>
<summary>
push1.sの実行例
</summary>

```
$ gcc -g push1.s
$ gdb ./a.out -x push1.txt
Breakpoint 1, main () at push1.s:6
6	    pushq $999
# p/x $rsp
$1 = 0x7fffffffde98
main () at push1.s:7
7	    ret
# p/x $rsp
$2 = 0x7fffffffde90
# x/1gd $rsp
0x7fffffffde90:	999
# %rsp が8減って，(%rsp)の値が999なら成功
```
</details>

<details>
<summary>
push2.sの実行例
</summary>

```
$ gcc -g push2.s
$ gdb ./a.out -x push2.txt
Breakpoint 1, main () at push2.s:6
6	    pushw $999
# p/x $rsp
$1 = 0x7fffffffde98
main () at push2.s:7
7	    ret
# p/x $rsp
$2 = 0x7fffffffde96
# x/1hd $rsp
0x7fffffffde96:	999
# %rsp が2減って，(%rsp)の値が999なら成功
```
</details>

<details>
<summary>
pop2.sの実行例
</summary>

```
$ gcc -g pop2.s
$ gdb ./a.out -x pop2.txt
Breakpoint 1, main () at pop2.s:7
7	    popw %ax
# p/x $rsp
$1 = 0x7fffffffde96
main () at pop2.s:8
8	    ret
# p/x $rsp
$2 = 0x7fffffffde98
# p/d $ax
$3 = 999
# %rsp が2増えて，%axの値が999なら成功
```
</details>

<details>
<summary>
push-pop.sの実行例
</summary>

```
$ gcc -g push-pop.s
$ gdb ./a.out -x push-pop.txt
Breakpoint 1, main () at push-pop.s:8
8	    pushq %rax
# p/x $rsp
$1 = 0x7fffffffde98
main () at push-pop.s:9
9	    popq  %rbx
# p/x $rsp
$2 = 0x7fffffffde90
# x/8bx $rsp
0x7fffffffde90:	0x88	0x77	0x66	0x55	0x44	0x33	0x22	0x11
# %rsp の値が8減って，スタックトップ8バイトが 0x88, 0x77, 0x66, 0x55, 0x44, 0x33, 0x22, 0x11なら成功
```
</details>

## x86-64機械語命令: 算術・論理演算

### 概要とステータスフラグ

ここでは以下の算術・論理演算を説明します．

|演算の種類|主な命令|
|-|-|
|算術|`add`, `sub`, `mul`, `div`, `inc`, `dec`, `not`|
|論理|`and`, `or`, `not`, `xor`|
|シフト|`sal`, `sar`, `shl`, `shr`, `rol`, `ror`, `rcl`, `rcr`|
|比較| `cmp`, `test`|
|変換(拡張)| `movs`, `movz`, `cbtw`, `cqto`|

これらの命令のほとんどが演算の結果として，
[ステータスフラグ](./5-arch.md#本書で扱うフラグ)
の値を変化させます．
本書ではステータスフラグの変化を以下の記法で表します．

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

### `add`命令: 足し算

---
|[記法](./x86-list.md#詳しい記法)|何の略か| 動作 |
|-|-|-|
|**`add␣`** *op1*, *op2* | add | *op1* を *op2* に加える |
|**`adc␣`** *op1*, *op2* | add with carry | *op1* と CF を *op2* に加える |
---
|[詳しい記法](./x86-list.md#詳しい記法)| 例 | 例の動作 | [サンプルコード](./6-inst.md#how-to-execute-x86-inst) | 
|-|-|-|-|
|**`add␣`** *imm*, *r/m* | `addq $999, %rax` | `%rax += 999`|[add-1.s](./asm/add-1.s) [add-1.txt](./asm/add-1.txt)|
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
  両方の結果を正しく計算します．
- `adc`は例えば，多倍長整数(任意の桁数の整数)を実装する時の
  「繰り上がり」の計算に便利です．

<details>
<summary>
add-1.sの実行例
</summary>

```
$ gcc -g add-1.s
$ gdb ./a.out -x add-1.txt
Breakpoint 1, main () at add-1.s:8
8	    ret
# p $rax
$1 = 1000
# %raxが1000なら成功
```

</details>

<details>
<summary>
add-2.sの実行例
</summary>

```
$ gcc -g add-2.s
$ gdb ./a.out -x add-2.txt
Breakpoint 1, main () at add-2.s:10
10	    popq %rbx
# p $rax
$1 = 1001
# x/1gd $rsp
0x7fffffffde90:	1000
# %raxが1001，(%rsp)が1000なら成功
```
</details>

<details>
<summary>
adc-1.sの実行例
</summary>

```
$ gcc -g adc-1.s
$ gdb ./a.out -x adc-1.txt
reakpoint 1, main () at adc-1.s:8
8	    adcq $2, %rax
# p $rax
$1 = 0
# p $eflags
$2 = [ CF PF AF ZF IF ]
main () at adc-1.s:9
9	    ret
# p $rax
$3 = 3
# %rflagsでCFが立っていて，%raxが3なら成功
```
</details>

<details>
<summary>
adc-2.sの実行例
</summary>

```
$ gcc -g adc-2.s
$ gdb ./a.out -x adc-2.txt
Breakpoint 1, main () at adc-2.s:9
9	    adcq $2, (%rsp)
# p $rax
$1 = 0
# p $eflags
$2 = [ CF PF AF ZF IF ]
main () at adc-2.s:10
10	    ret
x/1gd $rsp
0x7fffffffde90:	1002
# %rflagsでCFが立っていて，(%rsp)が1002なら成功
```
</details>

<details>
<summary>
adc-3.sの実行例
</summary>

```
$ gcc -g adc-3.s
$ gdb ./a.out -x adc-3.txt
Breakpoint 1, main () at adc-3.s:9
9	    adcq (%rsp), %rax
# p $rax
$1 = 0
# p $eflags
$2 = [ CF PF AF ZF IF ]
main () at adc-3.s:10
10	    ret
# p $rax
$3 = 1000
# %rflagsでCFが立っていて，%raxが1000なら成功
```
</details>

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
  両方の結果を正しく計算します．

<details>
<summary>
sub-1.sの実行例
</summary>

```
$ gcc -g sub-1.s
$ gdb ./a.out -x sub-1.txt
Breakpoint 1, main () at sub-1.s:8
8	    ret
# p $rax
$1 = 1
# %raxが1なら成功
```
</details>

<details>
<summary>
sub-2.sの実行例
</summary>

```
$ gcc -g sub-2.s
$ gdb ./a.out -x sub-2.txt
Breakpoint 1, main () at sub-2.s:10
10	    popq %rbx
# p $rax
$1 = -997
# x/1gd $rsp
0x7fffffffde90:	998
# %raxが-997，(%rsp)が998なら成功
```
</details>

<details>
<summary>
sbb-1.sの実行例
</summary>

```
$ gcc -g sbb-1.s
$ gdb ./a.out -x sbb-1.txt
Breakpoint 1, main () at sbb-1.s:8
8	    sbbq $2, %rax
# p $rax
$1 = 0
# p $eflags
$2 = [ CF PF AF ZF IF ]
main () at sbb-1.s:9
9	    ret
# p $rax
$3 = -3
# %rflagsでCFが立っていて，%raxが-3なら成功
```
</details>

<details>
<summary>
sbb-2.sの実行例
</summary>

```
$ gcc -g sbb-2.s
$ gdb ./a.out -x sbb-2.txt
Breakpoint 1, main () at sbb-2.s:9
9	    sbbq $2, (%rsp)
# p $rax
$1 = 0
# p $eflags
$2 = [ CF PF AF ZF IF ]
10	    sbbq (%rsp), %rax
main () at sbb-2.s:11
11	    ret
x/1gd $rsp
0x7fffffffde90:	996
# p $rax
$3 = -996
# %rflagsでCFが立っていて，(%rsp)が996，%raxが-996なら成功
```
</details>

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

<br/>
<img src="figs/imul.svg" height="250px" id="fig:imul">

- オペランドが1つの形式では，`%rax`が隠しオペランドになります．
  このため，乗算の前に`%rax`に値をセットしておく必要があります．
  また，8バイト同士の乗算結果は最大で16バイトになるので，
  乗算結果を`%rdx`と`%rax`に分割して格納します
  (16バイトの乗算結果の上位8バイトを`%rdx`に，下位8バイトを`%rax`に格納します)．
  これをここでは`(%rdx:%rax)`という記法で表現しています．
- `imul`だけ例外的に，オペランドが2つの形式と3つの形式があります．
  2つか3つの形式では乗算結果が8バイトを超えた場合，
  越えた分は破棄されます(乗算結果は8バイトのみ)．


<details>
<summary>
mul-1.sの実行例
</summary>

```
$ gcc -g mul-1.s
$ gdb ./a.out -x mul-1.txt
Breakpoint 1, main () at mul-1.s:9
9	    ret
# p $rdx
$1 = 0
# p $rax
$2 = 6
# %rdxが0, %raxが6なら成功
```
</details>

<details>
<summary>
imul-1.sの実行例
</summary>

```
$ gcc -g imul-1.s
$ gdb ./a.out -x imul-1.txt
Breakpoint 1, main () at imul-1.s:9
9	    ret
# p $rdx
$1 = 0xffffffffffffffff
# p $rax
$2 = -6
# %rdxが0xFFFFFFFFFFFFFFFF, %raxが-6なら成功
```
</details>

<details>
<summary>
imul-2.sの実行例
</summary>

```
$ gcc -g imul-2.s
$ gdb ./a.out -x imul-2.txt
Breakpoint 1, main () at imul-2.s:8
8	    imulq $4, %rax
9	    imulq %rbx, %rax
1: $rax = -8
10	    imulq $5, %rbx, %rax
1: $rax = 24
main () at imul-2.s:11
11	    ret
1: $rax = -15
# %raxが-8, 24, -15なら成功
```
</details>

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
  余りが`%rdx`に入ります．
- 隠しオペランドとして`%rdx`と`%rax`が使われるので，
  事前に値を設定しておく必要があります．
  `idiv`を使う場合，もし`%rdx`を使わないのであれば，
  `cqto`命令で`%rax`を`%rdx:%rax`に符号拡張しておくと良いです．

<details>
<summary>
div-1.sの実行例
</summary>

```
$ gcc -g div-1.s
$ gdb ./a.out -x div-1.txt
Breakpoint 1, main () at div-1.s:10
10	    ret
# p $rax
$1 = 33
# p $rdx
$2 = 9
# %raxが33, %rdxが9なら成功
```
</details>

<details>
<summary>
idiv-1.sの実行例
</summary>

```
$ gcc -g idiv-1.s
$ gdb ./a.out -x idiv-1.txt
Breakpoint 1, main () at idiv-1.s:9
9	    idivq %rbx
# p/x $rdx
$1 = 0xffffffffffffffff
main () at idiv-1.s:10
10	    ret
# p $rax
$2 = -33
# p $rdx
$3 = -9
# 最初の%rdxが0xFFFFFFFFFFFFFFFF, %raxが-33, 2番目の%rdxが-9なら成功
```
</details>

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

- `inc`や`dec`はオーバーフローしてもCFが変化しないところがポイントです．

<details>
<summary>
inc-1.sの実行例
</summary>

```
$ gcc -g inc-1.s
$ gdb ./a.out -x inc-1.txt
Breakpoint 1, main () at inc-1.s:8
8	    ret
# p $rax
$1 = 1
# %raxが1なら成功
```
</details>

<details>
<summary>
dec-1.sの実行例
</summary>

```
$ gcc -g dec-1.s
$ gdb ./a.out -x dec-1.txt
reakpoint 1, main () at dec-1.s:8
8	    ret
# p $rax
$1 = -1
# %raxが-1なら成功
```
</details>

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

<details>
<summary>
neg-1.sの実行例
</summary>

```
$ gcc -g neg-1.s
$ gdb ./a.out -x neg-1.txt
Breakpoint 1, main () at neg-1.s:7
7	    neg %rax
1: $rax = 999
8	    neg %rax
1: $rax = -999
main () at neg-1.s:9
9	    ret
1: $rax = 999
# %raxが 999 → -999 → 999 と変化すれば成功
```
</details>


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

<details>
<summary>
not-1.sの実行例
</summary>

```
$ gcc -g not-1.s
$ gdb ./a.out -x not-1.txt
Breakpoint 1, main () at not-1.s:7
7	    not %al
1: /t $al = 11001010
8	    not %al
1: /t $al = 110101
main () at not-1.s:9
9	    ret
1: /t $al = 11001010
# %alが 11001010 → 110101 → 11001010 と変化すれば成功
```
</details>

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

<details>
<summary>
and-1.sの実行例
</summary>

```
$ gcc -g and-1.s
$ gdb ./a.out -x and-1.txt
Breakpoint 1, main () at and-1.s:8
8	    pushq $0B00001111
# p/t $al
$1 = 10001000

Breakpoint 2, main () at and-1.s:12
12	    ret
# x/1bt $rsp
0x7fffffffde90:	00001000
# p/t $al
$2 = 0
# 表示される値が 10001000, 00001000, 0 なら成功
```
</details>

<details>
<summary>
or-1.sの実行例
</summary>

```
$ gcc -g or-1.s
$ gdb ./a.out -x or-1.txt
Breakpoint 1, main () at or-1.s:8
8	    pushq $0B00001111
# p/t $al
$1 = 11101110

Breakpoint 2, main () at or-1.s:12
12	    ret
# x/1bt $rsp
0x7fffffffde90:	11101111
# p/t $al
$2 = 11111111
# 表示される値が 11101110, 11101111, 11111111 なら成功
```
</details>

<details>
<summary>
xor-1.sの実行例
</summary>

```
$ gcc -g xor-1.s
$ gdb ./a.out -x xor-1.txt
Breakpoint 1, main () at xor-1.s:8
8	    pushq $0B00001111
# p/t $al
$1 = 1100110

Breakpoint 2, main () at xor-1.s:12
12	    ret
# x/1bt $rsp
0x7fffffffde90:	01101001
# p/t $al
$2 = 10011110
# 表示される値が 1100110, 01101001, 10011110 なら成功
```
</details>

### `sal`, `sar`, `shl`, `shr`: シフト

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

<details>
<summary>
sal-1.sの実行例
</summary>

```
$ gcc -g sal-1.s
$ gdb ./a.out -x sal-1.txt
Breakpoint 1, main () at sal-1.s:8
8	    salq %rax
1: /t $rax = 11111111
9	    salq $2, %rax
1: /t $rax = 111111110
10	    salq %cl, %rax
1: /t $rax = 11111111000
main () at sal-1.s:11
11	    ret
1: /t $rax = 11111111000000
# 表示される値が 11111111, 111111110, 11111111000, 11111111000000 なら成功
```
</details>

<details>
<summary>
shl-1.sの実行例
</summary>

```
$ gcc -g shl-1.s
$ gdb ./a.out -x shl-1.txt
reakpoint 1, main () at shl-1.s:8
8	    shlq %rax
1: /t $rax = 11111111
9	    shlq $2, %rax
1: /t $rax = 111111110
10	    shlq %cl, %rax
1: /t $rax = 11111111000
main () at shl-1.s:11
11	    ret
1: /t $rax = 11111111000000
# 表示される値が 11111111, 111111110, 11111111000, 11111111000000 なら成功
```
</details>

<details>
<summary>
sar-1.sの実行例
</summary>

```
$ gcc -g sar-1.s
$ gdb ./a.out -x sar-1.txt
Breakpoint 1, main () at sar-1.s:8
8	    sarq %rax
1: /t $rax = 1111111111111111111111111111111111111111111111111111111100000000
9	    sarq $2, %rax
1: /t $rax = 1111111111111111111111111111111111111111111111111111111110000000
10	    sarq %cl, %rax
1: /t $rax = 1111111111111111111111111111111111111111111111111111111111100000
main () at sar-1.s:11
11	    ret
1: /t $rax = 1111111111111111111111111111111111111111111111111111111111111100
# 表示される値が 1111111111111111111111111111111111111111111111111111111100000000, 1111111111111111111111111111111111111111111111111111111110000000, 1111111111111111111111111111111111111111111111111111111111100000, 1111111111111111111111111111111111111111111111111111111111111100 なら成功
```
</details>

<details>
<summary>
shr-1.sの実行例
</summary>

```
$ gcc -g shr-1.s
$ gdb ./a.out -x shr-1.txt
reakpoint 1, main () at shr-1.s:8
8	    shrq %rax
1: /t $rax = 1111111111111111111111111111111111111111111111111111111100000000
9	    shrq $2, %rax
1: /t $rax = 111111111111111111111111111111111111111111111111111111110000000
10	    shrq %cl, %rax
1: /t $rax = 1111111111111111111111111111111111111111111111111111111100000
main () at shr-1.s:11
11	    ret
1: /t $rax = 1111111111111111111111111111111111111111111111111111111100
# 表示される値が 1111111111111111111111111111111111111111111111111111111100000000, 111111111111111111111111111111111111111111111111111111110000000, 1111111111111111111111111111111111111111111111111111111100000, 1111111111111111111111111111111111111111111111111111111100 なら成功
```
</details>

### `rol`, `ror`, `rcl`, `rcr`: ローテート

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


<details>
<summary>
rol-1.sの実行例
</summary>

```
$ gcc -g rol-1.s
$ gdb ./a.out -x rol-1.txt
Breakpoint 1, main () at rol-1.s:8
8	    rolq %rax
1: /t $rax = 11111111
9	    rolq $2, %rax
1: /t $rax = 111111110
10	    rolq %cl, %rax
1: /t $rax = 11111111000
main () at rol-1.s:11
11	    ret
1: /t $rax = 11111111000000
# 表示される値が 11111111, 111111110, 11111111000, 11111111000000 なら成功
```
</details>

<details>
<summary>
rcl-1.sの実行例
</summary>

```
$ gcc -g rcl-1.s
$ gdb ./a.out -x rcl-1.txt
Breakpoint 1, main () at rcl-1.s:10
10	    rclq %rax
1: /t $rax = 11111111
11	    rclq $2, %rax
1: /t $rax = 111111111
12	    rclq %cl, %rax
1: /t $rax = 11111111100
main () at rcl-1.s:13
13	    ret
1: /t $rax = 11111111100000
# 表示される値が 11111111, 111111111, 11111111100, 11111111100000 なら成功
```
</details>

<details>
<summary>
ror.sの実行例
</summary>

```
$ gcc -g ror.s
$ gdb ./a.out -x ror.txt
Breakpoint 1, main () at ror-1.s:8
8	    rorq %rax
1: /t $rax = 11111111
9	    rorq $2, %rax
1: /t $rax = 1000000000000000000000000000000000000000000000000000000001111111
10	    rorq %cl, %rax
1: /t $rax = 1110000000000000000000000000000000000000000000000000000000011111
main () at ror-1.s:11
11	    ret
1: /t $rax = 1111110000000000000000000000000000000000000000000000000000000011
# 表示される値が 11111111, 1000000000000000000000000000000000000000000000000000000001111111, 1110000000000000000000000000000000000000000000000000000000011111, 1111110000000000000000000000000000000000000000000000000000000011 なら成功
```
</details>

<details>
<summary>
rcr-1.sの実行例
</summary>

```
$ gcc -g rcr-1.s
$ gdb ./a.out -x rcr-1.txt
Breakpoint 1, main () at rcr-1.s:10
10	    rcrq %rax
1: /t $rax = 11111010
11	    rcrq $2, %rax
1: /t $rax = 1000000000000000000000000000000000000000000000000000000001111101
12	    rcrq %cl, %rax
1: /t $rax = 1010000000000000000000000000000000000000000000000000000000011111
main () at rcr-1.s:13
13	    ret
1: /t $rax = 1101010000000000000000000000000000000000000000000000000000000011
# 表示される値が 11111010, 1000000000000000000000000000000000000000000000000000000001111101, 1010000000000000000000000000000000000000000000000000000000011111, 1101010000000000000000000000000000000000000000000000000000000011 なら成功
```
</details>

### `cmp`, `test`: 比較
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

<details>
<summary>
cmp-1.sの実行例
</summary>

```
$ gcc -g cmp-1.s
$ gdb ./a.out -x cmp-1.txt
reakpoint 1, main () at cmp-1.s:8
8	    cmpq $1, %rax       # %rax (=0) - 1
9	    cmpq %rax, (%rsp)   # (%rsp) (=1) - %rax (=0)
1: $eflags = [ CF PF AF SF IF ]
10	    cmpq (%rsp), %rax   # %rax (=0) - (%rsp) (=1)
1: $eflags = [ IF ]
main () at cmp-1.s:11
11	    ret
1: $eflags = [ CF PF AF SF IF ]
# 表示されるステータスフラグが以下なら成功
# 1: $eflags = [ CF PF AF SF IF ] (SF==1 → 結果は負)
# 1: $eflags = [ IF ]             (SF==0 → 結果は0か正)
# 1: $eflags = [ CF PF AF SF IF ] (SF==1 → 結果は負)
```
</details>

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

<details>
<summary>
test-1.sの実行例
</summary>

```
$ gcc -g test-1.s
$ gdb ./a.out -x test-1.txt
Breakpoint 1, main () at test-1.s:8
8	    testq $0, %rax       # %rax (=1) & 0
9	    testq %rax, (%rsp)   # (%rsp) (=1) & %rax (=1)
1: $eflags = [ PF ZF IF ]
10	    testq (%rsp), %rax   # %rax (=1) & (%rsp) (=1)
1: $eflags = [ IF ]
main () at test-1.s:11
11	    ret
1: $eflags = [ IF ]
# 表示されるステータスフラグが以下なら成功
# 1: $eflags = [ PF ZF IF ] (ZF==1 → 結果は0)
# 1: $eflags = [ IF ]       (ZF==0 → 結果は非0)
# 1: $eflags = [ IF ]       (ZF==0 → 結果は非0)
```
</details>

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

<details>
<summary>
movs-movz.sの実行例
</summary>

```
$ gcc -g movs-movz.s
$ gdb ./a.out -x movs-movz.txt
Breakpoint 1, main () at movs-movz.s:7
7	    movslq %eax, %rbx
8	    movzwq %ax, %rbx
1: /x $rbx = 0xffffffffffffffff
main () at movs-movz.s:9
9	    ret
1: /x $rbx = 0xffff
# 以下が表示されれば成功
# 1: /x $rbx = 0xffffffffffffffff
# 1: /x $rbx = 0xffff
```
</details>
  
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

<details>
<summary>
cbtw.sの実行例
</summary>

```
$ gcc -g cbtw.s
$ gdb ./a.out -x cbtw.txt
Breakpoint 1, main () at cbtw.s:7
7	    cbtw   # %al -> %ax
9	    cwtl   # %ax -> %eax
$1 = -1
$2 = 0xffff
11	    cwtd   # %ax -> %dx:%ax
$3 = -1
$4 = 0xffffffff
13	    cltd   # %eax -> %edx:%eax
$5 = {-1, -1}
$6 = {0xffff, 0xffff}
15	    cltq   # %eax -> %rax
$7 = {-1, -1}
$8 = {0xffffffff, 0xffffffff}
17	    cqto   # %rax -> %rdx:%rax
$9 = -1
$10 = 0xffffffffffffffff
main () at cbtw.s:19
19	    ret
$11 = {-1, -1}
$12 = {0xffffffffffffffff, 0xffffffffffffffff}
# 以下が表示されれば成功
# $1 = -1
# $2 = 0xffff
# $3 = -1
# $4 = 0xffffffff
# $5 = {-1, -1}
# $6 = {0xffff, 0xffff}
# $7 = {-1, -1}
# $8 = {0xffffffff, 0xffffffff}
# $9 = -1
# $10 = 0xffffffffffffffff
# $11 = {-1, -1}
# $12 = {0xffffffffffffffff, 0xffffffffffffffff}
```
</details>


## ジャンプ命令

### 絶対ジャンプと相対ジャンプ{#abs-rel-jump}

<img src="figs/abs-rel-jump.svg" height="250px" id="fig:abs-rel-jump">

- **絶対ジャンプ** (absolute jump)は**絶対アドレス**，
  つまりメモリの先頭からのオフセットでジャンプ先のアドレスを指定するジャンプです．
  上の例で，AからBにジャンプする時，`jmp 0x1000`は絶対ジャンプになります．
  (プログラムカウンタは「次に実行する命令を指すレジスタ」なので，
  正確には「Aの一つ前の命令からBにジャンプする時」になります)．
- **相対ジャンプ** (relative jump)は
  プログラムカウンタ`%rip`を起点とする**相対アドレス**で
  ジャンプ先のアドレスを指定するジャンプです．
  上の例で，AからBにジャンプする時，`jmp -0x500`は間接ジャンプになります．

### 直接ジャンプと間接ジャンプ{#dir-indir-jump}

<img src="figs/direct-indirect-jump.svg" height="350px" id="fig:direct-indirect-jump">

- **直接ジャンプ** (direct jump)はジャンプ先のアドレスを
  **即値** (**定数**)で指定するジャンプです．
  上の例で一番左の`jmp 0x1000`は直接ジャンプです．
- **間接ジャンプ** (indirect jump)はジャンプ先のアドレスを
  **レジスタ**や**メモリ**で指定して，その中に格納されている値を
  ジャンプ先のアドレスとするジャンプです．

  - 上の例で真ん中の`jmp *%rax`は**レジスタ**を使った間接ジャンプです．
    レジスタ中のアドレス (ここでは`0x1000`番地)にジャンプします．
    (なぜアスタリスク`*`が必要なのかは謎です．GNUアセンブラの記法です．)
  - 上の例で一番右の`jmp *(%rax)`は**メモリ参照**を使った間接ジャンプです．
    メモリ中のアドレス (ここでは`0x1000`番地)にジャンプします．

### `jmp`: 無条件ジャンプ

---
|[記法](./x86-list.md#詳しい記法)|何の略か| 動作 |
|-|-|-|
|**`jmp`** *op1*| jump | *op1*にジャンプ |
---
<!--
|[詳しい記法](./x86-list.md#詳しい記法)| 例 | 例の動作 | [サンプルコード](./6-inst.md#how-to-execute-x86-inst) | 
|-|-|-|-|
|**`jmp`** *rel8*| `jmp 0x1000` | `0x1000`番地に[相対](6-inst.md#abs-rel-jump)・[直接](6-inst.md#dir-indir-jump)ジャンプ|[jmp.s](./asm/jmp.s) [jmp.txt](./asm/jmp.txt)|
|**`jmp`** *rel32*| `jmp foo` | `foo`番地に[相対](6-inst.md#abs-rel-jump)・[直接](6-inst.md#dir-indir-jump)ジャンプ|[jmp.s](./asm/jmp.s) [jmp.txt](./asm/jmp.txt)|
|**`jmp`** *r/m*| `jmp *%rax` | `*%rax`番地に[絶対](6-inst.md#abs-rel-jump)・[間接](6-inst.md#dir-indir-jump)ジャンプ|[jmp.s](./asm/jmp.s) [jmp.txt](./asm/jmp.txt)|
|**`jmp`** *r/m*| `jmp *(%rax)` | `*(%rax)`番地に[絶対](6-inst.md#abs-rel-jump)・[間接](6-inst.md#dir-indir-jump)ジャンプ|[jmp.s](./asm/jmp.s) [jmp.txt](./asm/jmp.txt)|
-->
<div class="table-wrapper"><table><thead><tr><th><a href="./x86-list.html#%E8%A9%B3%E3%81%97%E3%81%84%E8%A8%98%E6%B3%95">詳しい記法</a></th><th>例</th><th>例の動作</th><th><a href="./6-inst.html#how-to-execute-x86-inst">サンプルコード</a></th></tr></thead><tbody>
<tr><td rowspan="2"><strong><code>jmp</code></strong> <em>rel</em></td><td><code>jmp 0x1000</code></td><td><code>0x1000</code>番地に<a href="6-inst.html#abs-rel-jump">相対</a>・<a href="6-inst.html#dir-indir-jump">直接</a>ジャンプ</td><td><a href="./asm/jmp.s">jmp.s</a> <a href="./asm/jmp.txt">jmp.txt</a></td></tr>
<tr><td><code>jmp foo</code></td><td><code>foo</code>番地に<a href="6-inst.html#abs-rel-jump">相対</a>・<a href="6-inst.html#dir-indir-jump">直接</a>ジャンプ</td><td><a href="./asm/jmp.s">jmp.s</a> <a href="./asm/jmp.txt">jmp.txt</a></td></tr>
<tr><td><strong><code>jmp</code></strong> <em>r/m</em></td><td><code>jmp *%rax</code></td><td><code>*%rax</code>番地に<a href="6-inst.html#abs-rel-jump">絶対</a>・<a href="6-inst.html#dir-indir-jump">間接</a>ジャンプ</td><td><a href="./asm/jmp.s">jmp.s</a> <a href="./asm/jmp.txt">jmp.txt</a></td></tr>
<tr><td><strong><code>jmp</code></strong> <em>r/m</em></td><td><code>jmp *(%rax)</code></td><td><code>*(%rax)</code>番地に<a href="6-inst.html#abs-rel-jump">絶対</a>・<a href="6-inst.html#dir-indir-jump">間接</a>ジャンプ</td><td><a href="./asm/jmp.s">jmp.s</a> <a href="./asm/jmp.txt">jmp.txt</a></td></tr>
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

- ニモニックで以下の用語を使い分ける
  - 符号あり整数の大小には less/greater を使う
  - 符号なし整数の大小には above/below を使う

### 条件付きジャンプ: 符号あり整数用

---
|[記法](./x86-list.md#詳しい記法)|何の略か| 動作 | ジャンプ条件 | 
|-|-|-|-|
|**`jg`** *rel*<br/> **`jnle`** *rel*| jump if greater <br/> jump if not less nor equal | *op2*>*op1*なら*rel*にジャンプ <br/> !(*op2*<=*op1*)なら*rel*にジャンプ | `ZF==0&SF==OF`|
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

<!--
### 条件付きジャンプ: カウンタ用
ほぼ使わないので割愛
-->

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
### `enter`, `leave`命令: スタックフレームを作成する，解放する
### `enter`は遅いので使わない
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



## x86-64機械語命令：関数呼び出しとリターン

### `call`

### caller-save/callee-saveレジスタ {#caller-callee-save-regs}
### 引数 {#arg-reg}

