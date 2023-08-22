<style type="text/css">
body { counter-reset: chapter 10; }
</style>

# デバッガ`gdb`の使い方

## デバッガの概要
### なぜデバッガ?

<img src="figs/debugger-why.svg" height="200px" id="fig:debugger-why">

- `gdb`などのデバッガの使用をお薦めする理由は「プログラムのデバッグ」を**とても楽にしてくれる**からです！！
- デバッグが難しいのは実行中のプログラムの中身（実行状態）が外からでは見えにくいからです．
  `printf`を埋め込むことでも変数の値や実行パスを調べられますが，
  デバッガを使うともっと効率的に調べることができます．
- デバッガは「簡単に習得できて，効果も高いお得な開発ツール」です．
  慣れることが大事です．
- デバッガはつまみ食いOKです．
  最初は「自分が使いたい機能，使える機能」だけを使えばいいのです．
  デバッガを使うために「デバッガの全て」を学ぶ必要はありません．

### デバッガとは

<img src="figs/debugger-what.svg" height="200px" id="fig:debugger-what">

デバッガは主に以下の機能を組み合わせて，プログラムの実行状態を調べることで，
バグの原因を探します．

- ① プログラム実行の一時停止:
     「実行を止めたい場所(**ブレークポイント**)」や止めたい条件を設定できます．
     ブレークポイントには関数名や行番号やアドレスなどを指定できます．
- ② **ステップ実行**:
     ①でプログラムの実行を一時停止した後，
     ステップ実行の機能を使って，ちょっとずつ実行を進めます．
- ③ 実行状態の表示:
     変数の値，現在の行番号，スタックトレース(バックトレース)などを表示できます．
- ④ 実行状態の変更:
     変数に別の値を代入したり，関数を呼び出したりして，
     「ここでこう実行したら」を試せます．

### `gdb`とは

- **Linux**上で使える代表的で高性能なデバッガです．
- C/C++/**アセンブリ言語**/Objective-C/Rustなど，多くの言語をサポートしています．
- **Linux/x86-64**を含む，多くのOSやプロセッサに対応しています．
- オープンソースで無料で使えます (GNU GPLライセンス)．
- 一次情報: [GDB: The GNU Project Debugger](https://www.sourceware.org/gdb/)

## `gdb`の実行例 (C言語編)

### 起動 `run` と終了 `quit`

```
{{#include asm/hello.c}}
```

```
$ gcc ❶ -g hello.c
$ ./a.out
hello
$ ❷ gdb ./a.out
❸(gdb) ❹ run
hello
(gdb) ❺ quit
A debugging session is active.
	Inferior 1 [process 20186] will be killed.
Quit anyway? (y or n)  ❻ y
$
```

- `gdb`でデバッグする前に，`gcc`のコンパイルに❶`-g`オプションを付けます．
  `-g`は`a.out`に[デバッグ情報](./3-binary.md#デバッグ情報)を付加します．
  デバッグ情報がなくてもデバッグは可能ですが，
  ファイル名や行番号などの情報が表示されなくなり不便です．

<details>
<summary>
gcc -g -Og オプションがベスト
</summary>

`gdb`のマニュアルに以下の記述があります．

- `-O2`などの最適化オプションを付けてコンパイルしたプログラムでも`gdb`で
   デバッグできるが，行番号がずれたりする．なので可能なら
   最適化オプションを付けない方が良い．
- `gdb`でデバッグするベストな最適化オプションは`-Og`であり，
  `-Og`は`-O0`よりも良い．

ですので，デバッグ時には `gcc -g -Og`オプションがベストなようです．
</details>

-  ❷ `gdb ./a.out` と，引数にデバッグ対象のバイナリ(ここでは`./a.out`)を指定して`gdb`を起動します．

<details>
<summary>
gdb起動メッセージの抑制
</summary>

デフォルトで`gdb`を起動すると以下のような長い起動メッセージが出ます．

```bash
$ gdb ./a.out 
GNU gdb (Ubuntu 12.1-0ubuntu1~22.04) 12.1
Copyright (C) 2022 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
~There is NO WARRANTY, to the extent permitted by law.
~Type "show copying" and "show warranty" for details.
~This GDB was configured as "x86_64-linux-gnu".
~Type "show configuration" for configuration details.
~For bug reporting instructions, please see:
~<https://www.gnu.org/software/gdb/bugs/>.
~Find the GDB manual and other documentation resources online at:
~    <http://www.gnu.org/software/gdb/documentation/>.
~
~For help, type "help".
~Type "apropos word" to search for commands related to "word"...
~Reading symbols from ./a.out...
~(gdb) 
```

これを抑制するには，`gdb -q`オプションを付けるか，
`~/.gdbearlyinit`ファイルに以下を指定します．

```
set startup-quietly on
```
</details>

- ❸ `(gdb)` は｀gdb`のプロンプトです．`gdb`のコマンドが入力可能なことを示します．
- ❹ `run`は`gdb`上で**プログラムの実行を開始**します．
  ここではブレークポイントを指定していないため，そのまま`hello`を出力して
  プログラムは終了しました．
- ❺ `quit`は`gdb`を終了させます．
  (ここではすでにデバッグ対象のプログラムの実行は終了していますが)
  デバッグ対象のプログラムが終了しておらず，
  「本当に終了して良いか?」と聞かれたら，❻ `y`と答えて終了させます．

<details>
<summary>
コマンドの省略名
</summary>

`gdb`のコマンドは(区別できる範囲で)短く省略できます．
例えば，`run`は`r`，`quit`は`q`，それぞれ1文字でコマンドを指定できます．
慣れてきたらコマンドの省略名を使いましょう．
</details>

### コマンドライン引数`argv`を指定して実行

```
{{#include asm/argv.c}}
```

```
$ gcc -g argv.c
$ gdb ./a.out
Reading symbols from ./a.out...
(gdb) ❶ run a b c d
argv[0]=/mnt/hgfs/gondow/project/linux-x86-64-programming/src/asm/a.out
argv[1]=a
argv[2]=b
argv[3]=c
argv[4]=d
[Inferior 1 (process 20303) exited normally]
(gdb) 
```

- コマンドライン引数を与えてデバッグしたい場合は，
  `run`コマンドに続けて引数を与えます(ここでは`a b c d`)．

### 標準入出力を切り替えて実行

```
{{#include asm/cat.c}}
```

```
$ gcc -g cat.c
$ cat foo.txt
hello
byebye
$ gdb ./a.out
(gdb) run ❶ < foo.txt ❷ > out.txt
(gdb) quit
$ cat out.txt
hello
byebye
```

- 標準入出力をリダイレクトして(切り替えて)実行したい場合は，
  通常のシェルのときと同様に`run`コマンドの後で，
  ❶ `<` や❷ `>`を使って行います．

### segmentation fault (あるいは bus error)の原因を探る

```
{{#include asm/segv.c}}
```

```
$ gcc -g segv.c
$ ./a.out
❶ Segmentation fault (core dumped)
$ gdb ./a.out
(gdb) r
Program received signal SIGSEGV, ❷ Segmentation fault.
0x0000555555555162 in ❸ main () at ❹ segv.c:6
6	 ❺ printf ("%d\n", *p); 
(gdb) ❻ print/x p
$1 = ❼ 0xdeadbeef
(gdb) ❽ print/x *p
❾ Cannot access memory at address 0xdeadbeef
(gdb) quit
```

- `segv.c`をコンパイルして実行すると❶ segmentation fault が起きました．
  segumentation fault や bus error は正しくないポインタを使用して
  メモリにアクセスすると発生します．
- `gdb`上で`a.out`を実行すると，`gdb`上でも ❷ segmentation fault が起きました．
  発生場所は ❹ ファイル`segv.c`の`6行目`，❸ `main`関数内と表示されています．
  また，6行目のソースコード ❺ `printf ("%d\n", *p);`も表示されています．
- 変数`p`が怪しいので，❻ `print/x p`コマンドで変数`p`の値を表示させます．
  `/x`は「16進数で表示」を指示するオプションです．
  怪しそうな`0xDEADBEEF`という値が表示されました．
  (`print`コマンドは`p`と省略可能です)．

<details>
<summary>
怪しいアドレスとは
</summary>

まず，8の倍数ではないアドレスは怪しいです(正しいアドレスのこともあります)．
特に奇数のアドレスは怪しいです(正しいこともありますが)．
[アラインメント制約](./9-abi.md#alignment)を守るため，
多くのデータが4の倍数や8の倍数のアドレスに配置されるからです．

また慣れてくると，例えば「`0x7ffde9a98000`はスタックのアドレスっぽい」と
感じるようになります．
「これ，どこのメモリだろう」と思ったら
[メモリマップ](./3-binary.md#メモリマップを見る)を見て調べるのが良いです．
</details>

- 念のため，`print`コマンドで`*p`を表示させると
  (❽ `print/x *p`)，
  この番地にはアクセスできないことが確認できました
  (❾ `Cannot access memory at address 0xdeadbeef`)．

### 短縮コマンド (ちょっと寄り道)

## `gdb`の実行例 (アセンブリ言語編)

## お便利機能

### `help`コマンド
### `apropos`コマンド
### 補完とヒストリ機能
### TUI

## ブレークポイントの設定
### 条件付きブレークポイント

## ステップ実行
## 実行状態の表示

### 型を調べる

## `gdb` の主なコマンドの一覧

### 起動・終了

|コマンド|省略名| 説明 |
|-|-|-|
|`gdb ./a.out`||`gdb`の起動|
|`run`|`r`| 実行開始 |
|`quit`|`q`|`gdb`の終了|

### ブレークポイント・ウォッチポイント

|コマンド|省略名| 説明 |
|-|-|-|
|`break` 場所|`b`|ブレークポイントの設定|
|`watch` 場所|`wa`|ウォッチポイント(書き込み)の設定|
|`rwatch` 場所|`rw`|ウォッチポイント(読み込み)の設定|
|`awatch` 場所|`aw`|ウォッチポイント(読み書き)の設定|
|`info break` | `i b` |ブレークポイント・ウォッチポイント一覧表示|
|`break` 場所 `if` 条件|`b`|条件付きブレークポイントの設定|
|`condition` 番号 条件|`cond`|ブレークポイントに条件を設定|
|`delete` 番号 | `d` | ブレークポイントの削除 |
|`clear` |`cl`|全ブレークポイントの解除|

</br>

|場所の指定方法 | 例 | 
|-|-|
|関数名| `main` |
|行番号| `6` |
|ファイル名:行番号| `main.c:6` |
|ファイル名:関数名| `main.c:main` |
|`*`アドレス| `*0x55551290` |

### ステップ実行

|コマンド|省略名| 説明 |
|-|-|-|
|`step`|`s`|次の行までステップ実行(関数コールには入る)|
|`next`|`n`|次の行までステップ実行(関数コールはまたぐ)|
|`finish`|`fin`|今の関数を終了するまで実行|
|`continue`|`c`|ブレークポイントに当たるまで実行|
|`stepi`|`si`|次の機械語命令を1つだけ実行して停止(関数コールには入る)|
|`nexti`|`ni`|次の機械語命令を1つだけ実行して停止(関数コールはまたぐ)|

### 式，変数，レジスタ，メモリの表示

|コマンド|省略名| 説明 |
|-|-|-|
|`print`/フォーマット &emsp; 式|`p`|式を実行して値を表示|
|`display`/フォーマット &emsp; 式|`disp`|実行停止毎に`print`する|
|`info display` | `i di` | `display`の設定一覧表示 |
|`undisplay`  &emsp; 番号|`und`|`display`の設定解除|
|`x`/*NFU*   &emsp;アドレス |`x` | メモリの内容を表示 (examine)|

- 表示する「式」は副作用があっても良い．
  代入式でも良いし，副作用のある関数呼び出しやライブラリ関数呼び出しでも良い．
  (例: `p x = 999`，`p printf ("hello\n")`)．
  このため`printf`コマンドは単なる「実行状態の表示コマンド」ではなく
  「実行状態の変更」も可能 (このために`gdb`は裏で結構すごいことやってる)．

|式|説明|
|-|-|
|`$`レジスタ名|レジスタ参照|
|アドレス`@`要素数 | 配列「アドレス[要素数]」として処理|

- *N* は表示個数(デフォルト1)，*F*はフォーマット，*U*は単位サイズを指定する．
  *F*と*U*の順番は逆でも良い． 
  (例: `4gx` は「8バイトデータを16進数表記で4個表示」を意味する)

|フォーマット *F*|説明|
|:-:|-|
|`x`| 16進数 (hexadecimal) |
|`d`| 符号あり10進数 (decimal)|
|`u`| 符号なし10進数 (unsigned)|
|`t`|  2進数 (two)|
|`c`| 文字 (char)|
|`s`| 文字列 (string)|
|`i`| 機械語命令 (instruction)|

<br/>

|単位サイズ *U*|説明|
|:-:|-|
|`b`|1バイト (byte)|
|`h`|2バイト (half-word)|
|`w`|4バイト (word)|
|`g`|8バイト (giant)|

### スタック表示

|コマンド|省略名| 説明 |
|-|-|-|
|`backtrace`|`bt`, `ba`|コールスタックを表示する|
|`where`|`whe` | `backtrace`と同じ|
|`backtrace full`|`bt f`, `ba f`|コールスタックと全局所変数を表示する|

backtrace, where, bt, w
backtrace full
info locals

### プログラム表示

list
disassemble

### TUI
     
## advanced topics

- ウォッチポイント
  - watch, rwatch, awatch
- catchpoint
  - catch syscall, catch signal
- tracepoint
  - trace, collect, tfind
- attach
- record/reply
- core を使ったデバッグ
- 最適化されたコードのデバッグ p.193
  - インライン関数，末尾コール最適化，
- GDBのPythonプラグイン
- GDB/MI machine interface
- 遠隔デバッグ

## 悩みどころ

- 簡単なドリル問題があったほうが良い
- コマンドの短縮形と長い名前(なれるまでは長い名前が理解しやすい)

## メモ

- コマンド名，別名が多い，bt, where, stack
- until 要らない?
- help, apropos, マニュアル
- show と info の違い
  - info break, registers, locals, arg, stack, frame
  - info proc map
- set
  - レジスタを書き換える set $rax = 2
  - メモリを書き換える set {int}0x0x1234 = 42
- find メモリ検索  find start-from,value

- layout
- whatis, ptype
- ctrl-C
- awatch -l  これ使えるかも!!
- データを調べる例
  - 変数
  - ポインタの先を調べる
  - 配列の中身を調べる p *array@len
  - リスト
  - 構造体・共用体の中身を調べる
- 同じキーを入れたら前のコマンド入力になる話
