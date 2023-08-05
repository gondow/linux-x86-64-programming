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
- ❷ ブレークポイントを7行目(`movq $999, %rax`の次の行)に設定
- ❸ 実行開始
- ❹ ソースコードの6行目だけを表示
- ❺ レジスタ`%rax`の値を(10進表記で)表示
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

[メモリ参照<br/>(直接アドレス指定)](#addr-mode-direct)
</td><td rowspan="2">定数で指定した<br/>アドレスのメモリ値</td><td><code>movq 0x100, %rax</code></td></tr>
<tr><td><code>movq foo, %rax</code></td></tr>
<tr><td rowspan="3">

[メモリ参照<br/>(間接アドレス指定)](#addr-mode-indirect)
</td><td rowspan="3">レジスタ等で計算した<br/>アドレスのメモリ値</td><td><code>movq (%rsp), %rax</code></td></tr>
<tr><td><code>movq -8(%rsp), %rax</code></td></tr>
<tr><td><code>movq foo(%rsp), %rax</code></td></tr>
</tbody></table>
</div>


- `foo`はラベルであり，定数と同じ扱い．(定数を書ける場所にはラベルも書ける)．
- メモリ参照では例えば`-8(%rbp, %rax, 8)`など複雑なオペランドも指定可能．
  参照するメモリのアドレスは`-8+%rbp+%rax*8`になる．
  ([以下](#メモリ参照)を参照)．

#### アドレッシングモード：即値（定数）{#addr-mode-imm}

##### 定数 `$999`

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

##### ラベル `$main`

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

<img src="figs/absolute-addr.svg" height="250px" id="fig:absolute-addr">

**絶対アドレス**とは「メモリの先頭0番地から何バイト目か」で示すアドレスです．
上図で青色のメモリ位置の絶対アドレスは`0x1000`番地となります．
一方，**相対アドレス**(relative address)は(0番地ではなく)別の何かを起点とした差分のアドレスです．
x86-64では`%rip`レジスタ(プログラムカウンタ)を起点とすることが多いです．
上図では青色のメモリ位置の相対アドレスは
`%rip`を起点とすると，`-0x500`番地となります(`0x1000 - 0x1500 = -0x500`)．
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
 ❶ 1129:  48 8d 05 f9 ff ff ff    lea    ❷ -0x7(%rip),%rax  # 1129 <main>
 ❸ 1130:  c3                      ret    
```

上のように逆アセンブルすると以下が分かります．

- `main`関数の(ファイル`a.out`中での)アドレスは❶ `0x1129`番地
- `leaq main(%rip), %rax`の `%rip`の値は❸ `0x1130`番地
  (プログラムカウンタ `%rip`は「次に実行する機械語命令のアドレス」を保持しています)．
- 機械語命令に埋め込まれているアドレスは相対アドレスで，
  ❶ `0x1129` - ❸ `0x1130` = ❷ `-0x7` です．

❶ `0x1129` や ❸ `0x1130` のアドレスは，
`main`関数がどのアドレスに配置されるかで変化します．
しかし，この相対アドレス❷ `-0x7` は
`main`関数がどのアドレスに配置されても変化しないので，
この機械語命令はPICやPIEとして使えるわけです．

なお，相対アドレスが固定にならない場合(例えば，`printf`関数のアドレス)もあります．
その場合は[GOTやPLT](./3-binary.md#GOT-PLT)を使います．
`printf`関数のアドレスを機械語命令列(`.text`セクション)に埋め込むのではなく，
`.data`セクションなどに格納し，
そのアドレスを使って**間接コール**(indirect call)するのです．

</details>
</details>

- `main`関数の先頭にブレークポイントを設定します．
  `main`関数の先頭アドレスが❷ `0x40110a`と分かります．

- ❸ `movq $main, %rax`の実行直前で止まっているので，
  ❹ `si`で1命令実行を進めます．
- ❺ `%rax`レジスタ中に`main`関数のアドレス❷ `0x40110a`が入っていました．


#### アドレッシングモード：レジスタ参照{#addr-mode-reg}

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

#### アドレッシングモード：直接メモリ参照{#addr-mode-direct}

#### アドレッシングモード：間接メモリ参照{#addr-mode-indirect}

RIP相対とラベル

### メモリ参照

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

## x86-64機械語命令 (関数呼び出しとリターン)

### `call`
