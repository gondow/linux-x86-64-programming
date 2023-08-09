<style type="text/css">
body { counter-reset: chapter 6; }
</style>

# x86-64機械語命令

## x86-64機械語命令の実行方法{#how-to-execute-x86-inst}

### 概要

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
  「どうなると正しく実行できたか」を確認するメッセージですので，
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


- `foo`はラベルであり，定数と同じ扱い．(定数を書ける場所にはラベルも書ける)．
- メモリ参照では例えば`-8(%rbp, %rax, 8)`など複雑なオペランドも指定可能．
  参照するメモリのアドレスは`-8+%rbp+%rax*8`になる．
  ([以下](#メモリ参照)を参照)．

### アドレッシングモード：即値（定数）{#addr-mode-imm}

#### 定数 `$999`

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

#### ラベル `$main`

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

<img src="figs/label2.svg" height="250px" id="fig:label2">

まず[`movq-7.s`](./asm/movq-7.s)中の以下の3行で，

```x86asmatt
    .data
x:
    .quad 999 
```

「`.data`セクションにサイズが8バイトのデータとして値`999を配置せよ」
「そのデータの先頭アドレスをラベル`x`として定義せよ」を意味しています．
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

RIP相対とラベル

セグメントレジスタを使った参照(スレッドローカルストレージ)

## x86-64機械語命令 (転送など)
## x86-64機械語命令 (算術論理演算)
### 四則演算
### インクリメント，デクリメント，符号反転
### ビット論理演算
### シフト演算
### ローテート演算
## x86-64機械語命令 (比較とジャンプ)
### 比較
### 無条件ジャンプ
### 条件付きジャンプ

#### ステータスレジスタ {#status-reg}
### その他の命令

endbr64, bnd, int3 など
rdtsc


## x86-64機械語命令 (関数呼び出しとリターン)

### `call`

### caller-save/callee-saveレジスタ {#caller-callee-save-regs}
### 引数 {#arg-reg}

