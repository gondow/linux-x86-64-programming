<style type="text/css">
body { counter-reset: chapter 9; }
</style>

# GCCが生成したアセンブリコードを読む

この章では単純なCのプログラムをGCCがどのようなアセンブリコードに変換するかを見ていきます．
これより以前の章で学んだ知識を使えば，C言語のコードが意外に簡単にアセンブリコードに変換できることが分かると思います．
(実際にコンパイラの授業で構文解析の手法を学び，
最適化器を実装しなければ，コンパイラは学部生でも十分簡単に作れます)．

## 制御文

### if文

```
{{#include asm/if.c}}
```

<img src="figs/if.svg" height="250px" id="fig:if">

- ifの条件式`x > 100`は反転して「`x <= 100`なら，then部分をスキップして，thenの直後(ラベル`.L2`)にジャンプする」というコードを出力しています．
  (反転する必然性はありません．`x > 0`を評価してその結果が`0`に等しければ，`.L2`にジャンプするコードでも(実行速度を除けば)同じ動作になります)
- then部分では「`x`に1を加える」コードを出力しています．

<details>
<summary>
なぜGCCはinc命令を使わないの?
</summary>

`incl x(%rip)`なら1命令で済みますよね．
もし`-O`や`-O2`などの最適化オプションを付ければ，
GCCは`inc`を使うかも知れませんが，
そうしてしまうと，(最適化が賢すぎて)元のif文の構造がガラリと変わってしまう可能性があるため避けています．
この章では全て「最適化オプションを付けていないので，GCCは無駄なコードを出力することがある」と考えて下さい．
</details>

### if-else文

```
{{#include asm/if-else.c}}
```

<img src="figs/if-else.svg" height="330px" id="fig:if-else">

- ifの条件式`x > 100`は反転して「`x <= 100`なら，then部分をスキップして，thenの直後(ラベル`.L2`)にジャンプする」というコードを出力しています．
- then部分では「`x`に1を加える．次にelse部分をスキップするために`.L3`にジャンプする」コードを出力しています．
- else部分では「`x`から1減らす」コードを出力しています．

### while文

```
{{#include asm/while.c}}
```

<img src="figs/while.svg" height="330px" id="fig:while">

- while条件判定はwhileボディのコードの後に置かれています(これは必然ではありません)．
  最初にwhileループに入る時，`.L2`にジャンプします．
- whileの条件式`x > 100`が成り立つ間は，`.L3`に繰り返しジャンプします．
- 「whileボディ」実行後に必ず「while条件判定」が必要になるので，これでうまくいきます．

### for文

```
{{#include asm/for.c}}
```

<img src="figs/for.svg" height="330px" id="fig:for">

- ほぼwhile文と同じです．違いは「for初期化」 (`int i = 0`)があることと，
  「forボディ」の直後に「for更新」(`i++`)があることだけです．
- GCCが条件判定のコードを，
  `i < 10` (`cmpl $10, -4(%rbp); jl .L3`)ではなく，
  `i <= 9` (`compl $9, -4(%rbp); jl .l3`)としています．
  どちらも同じなのですが，なぜこうしたのか，GCCの気持ちは分かりません．

### switch文 (単純比較)

```
{{#include asm/switch.c}}
```

<img src="figs/switch.svg" height="500px" id="fig:switch">

- ジャンプテーブルを使わない，単純に比較するコード生成です．
  例えば，`case 1:`は，`if (x == 1)`と同様のコード生成になっています．
- この方法ではcaseが\\(n\\)個あると，\\(n\\)回比較する必要があるので，
  \\(O(n)\\)の時間がかかってしまいます．

### switch文 (ジャンプテーブル) {#switch-jump-table}


```
{{#include asm/switch2.c}}
```

```
{{#include asm/switch3.c}}
```

<img src="figs/switch2.svg" height="1000px" id="fig:switch2">

- `switch2.c`をジャンプテーブルを使って書き換えたのが`switch3.c`です．
  ❶と❷の部分はGCC拡張機能で「ラベルの値を配列変数に格納し❶」，
  「`goto`で格納したラベルにジャンプ❷」することができます．
- 変数`x`の値をジャンプテーブル(配列)のインデックスとして，
  ジャンプ先アドレスを取得し，間接ジャンプしています．
  - `movl %eax, %eax`はレジスタ`%rax`の上位32ビットをゼロクリアしています．
  - `notrack`はIntel CET (control-flow enforcement technology)による拡張命令です．
    `notrack`付きの場合，間接ジャンプ先が`endbr64`ではなくても例外は発生しなくなります．
- ジャンプテーブルを使うと，\\(O(1)\\)でcase文を選択できます．
  ただし，ジャンプテーブルが使えるのはcaseが指定する範囲がある程度，
  密な場合に限ります(巨大な配列を使えば，疎な場合でも扱えますが…)．

## 定数

### 整数定数

```
{{#include asm/const-int.c}}
```

```x86asmatt
main:
    endbr64
    pushq   %rbp
    movq    %rsp, %rbp
    movl ❶ $999, %eax
    popq    %rbp
    ret
```

- 整数定数 `999` は❶即値 (`$999`)としてコード生成されています

### 文字定数

```
{{#include asm/const-char.c}}
```

```x86asmatt
main:
    endbr64
    pushq   %rbp
    movq    %rsp, %rbp
    movl ❶ $65, %eax
    popq    %rbp
    ret
```

- 文字定数は❶即値 (`$65`, 65は文字`A`のASCIIコード)としてコード生成されています

### 文字列定数

```
{{#include asm/const-string.c}}
```

```x86asmatt
❶  .section  .rodata
❷ .LC0:
❸  .string "hello\n"

    .text
    .globl  main
    .type   main, @function
main:
    endbr64
    pushq   %rbp
    movq    %rsp, %rbp
    leaq ❹ .LC0(%rip), %rax
    movq    %rax, %rdi
    call    puts@PLT
    movl    $0, %eax
    popq    %rbp
    ret
```



- 文字列定数 `"hello\n"`の実体は❶`.rodata`セクションに置かれます．
  ❸`.string`命令で`"hello\n"`のバイナリ値を配置し，
  その先頭アドレスを❷ラベル`.LC0:`と定義しています．
- 式中の`"hello\n"`の値は「その文字列の先頭アドレス」ですので，
  ❹ `.LC0(%rip)`と参照しています(ここでは文字列の先頭アドレスが`%rax`に格納されます)

### 配列

```
{{#include asm/array3.c}}
```

```x86asmatt
    .globl  a
    .data
    .align 8
    .type   a, @object
    .size   a, 12
❶ a:
❷  .long   111
❷  .long   222
❷  .long   333

    .text
    .globl  main
    .type   main, @function
main:
    endbr64
    pushq   %rbp
    movq    %rsp, %rbp
    movl ❸ 8+a(%rip), %eax
    popq    %rbp
    ret
```

- 配列はメモリ上で連続する領域に配置されます．
  この場合は❷ `.long`命令で4バイトずつ，`111`, `222`, `333`の2進数を隙間なく配置しています．個人的には `.long 111, 222, 333`と１行で書いてくれる方が嬉しいのですが…
  (なお，配列とは異なり，構造体の場合はメンバー間や最後にパディング(隙間)が入ることがあります)
- 配列の先頭アドレスを❶ラベル`a:`と定義しています．
- `a[2]`の参照は❸ `8+a(%rip)`という`%rip`相対のメモリ参照になっています．
  指定したインデックスが定数(`2`)だったため，変位が `8+a`になっています．
  (`a[i]`などとインデックスが変数の場合はアセンブラの足し算は使えません)．

### 構造体

```
{{#include asm/struct5.c}}
```

```x86asmatt
    .globl  f
    .data
    .align 8
    .type   f, @object
    .size   f, 8
❶ f:
❷  .byte   10 # x1
❸  .zero   3  # 3バイトのパディング
❹  .long   20 # x2

    .text
    .globl  main
    .type   main, @function
main:
    endbr64
    pushq   %rbp
    movq    %rsp, %rbp
    movl ❺ 4+f(%rip), %eax
    popq    %rbp
    ret
```

- 構造体`foo`がメモリ上に配置される際，アラインメント制約を満たすために
  [パディング](./4-data.md#alignment-padding)が入ることがあります．
- ここでは，メンバー❷`x1`と❹`x2`の間に❸3バイトのパディングが入っています．
- 構造体メンバーの参照 `foo.x2`は
  ❺`4+f(%rip)`という`%rip`相対のメモリ参照になっています．

### 共用体

```
{{#include asm/union2.c}}
```

```x86asmatt
    .globl  f
    .data
    .align 8
    .type   f, @object
❶  .size   f, 8
❷ f:
❸  .byte   97
❹  .zero   4
❺  .zero   3

    .text
    .globl  main
    .type   main, @function
main:
    endbr64
    pushq   %rbp
    movq    %rsp, %rbp
    movl    $999, ❻ f(%rip)
    movl ❼ f(%rip), %eax
    popq    %rbp
    ret
```

- 共用体は以下を除き，構造体と一緒です
  - 同時に1つのメンバーにしか代入できない
  - 全てのメンバーはオフセット0でアクセスする
  - 共用体のサイズは最大サイズを持つメンバ＋パディングのサイズになる
    - 上の例では最大サイズのメンバ `char x1 [5]`に3バイトのパディングがついて，
      共用体 `f`のサイズは8バイトになってます
- 上の例では**指示付き初期化子**(designated initializer)の記法
  (`union foo f = {.x1[0] = 'a'};`)を使って，メンバ`x1`を初期化しています．
  ❸`'a'`の値が`.byte`で配置され，残りの7バイトは❹❺`0`で初期化されています．
- 共用体`f`への代入や参照はメモリ参照❻❼`f(%rip)`でアクセスされています．
  
## 変数

### 初期化済みの静的変数

```
{{#include asm/var-init-static.c}}
```

```x86asmatt
    .globl  x
❶  .data
    .align 4
    .type   x, @object
    .size   x, 4
❷ x:
❸  .long   999

    .text
    .globl  main
    .type   main, @function
main:
    endbr64
    pushq   %rbp
    movq    %rsp, %rbp
    movl ❹ x(%rip), %eax
    popq    %rbp
    ret
```

- 初期化済みの静的変数の実体は❶`.data`セクションに配置されます．
  初期値 (`999`)を(この場合は`int`型なので)`.long`命令で
  `999`のバイナリ値を配置し，その先頭アドレスをラベル`x:`と定義しています．
- 変数`x`の参照は❹`x(%rip)`という`%rip`相対のメモリ参照です．  
  
### 未初期化の静的変数

```
{{#include asm/var-uninit-static.c}}
```

```x86asmatt
    .globl  x
❶  .bss
    .align 4
    .type   x, @object
    .size   x, 4
❷ x:
❸  .zero   4

    .text
    .globl  main
    .type   main, @function
main:
    endbr64
    pushq   %rbp
    movq    %rsp, %rbp
    movl    $999, ❹ x(%rip)
    movl    ❺ x(%rip), %eax
    popq    %rbp
    ret
```

- 未初期化の静的変数の実体は❶ `.bss`セクションに配置されます．
  `.bss`セクション中の変数は❸ゼロで初期化されます．
  初期化した4バイトの先頭アドレスをラベル❷ `x:`と定義しています．
  - ただし`.bss`セクションが実際にゼロで初期化されるのは実行直前です
- 変数`x`の参照は，メモリ参照❹❺ `x(%rip)`でアクセスされています．

### 自動変数 (`static`無しの局所変数)

```
{{#include asm/var-auto.c}}
```

```x86asmatt
    .text
    .globl  main
    .type   main, @function
main:
    endbr64
    pushq   %rbp
    movq    %rsp, %rbp
    movl    $999, ❶ -4(%rbp)
    movl ❷ -4(%rbp), %eax
    popq    %rbp
    ret
```

<img src="figs/stack-layout3.svg" height="300px" id="fig:stack-layout3">

- 自動変数は実行時にスタック上にその実体が配置されます．
  上の例では変数`x`は❶❷`-4(%rbp)`から始まる4バイトに割り当てられ，
  アクセスされています．
  (この変数`x`は[レッドゾーン](./2-asm-intro.md#redzone)に配置されています)

### 実引数

```
{{#include asm/arg.c}}
```

```x86asmatt
    .text
    .globl  main
    .type   main, @function
main:
    endbr64
    pushq   %rbp
    movq    %rsp, %rbp
❹  subq    $8, %rsp    # パディング
❷  pushq   $70         # 第7引数
❶  movl    $60, %r9d   # 第6引数
❶  movl    $50, %r8d   # 第5引数
❶  movl    $40, %ecx   # 第4引数
❶  movl    $30, %edx   # 第3引数
❶  movl    $20, %esi   # 第2引数
❶  movl    $10, %edi   # 第1引数
❸  call    foo@PLT
❺  addq    $16, %rsp   # 第7引数とパディングを捨てる
    movl    $0, %eax
    leave
    ret
```

<img src="figs/arg.svg" height="200px" id="fig:arg">

- 第6引数までは❶[レジスタ渡し](./6-inst.md#arg-reg)になります．
  第7引数以降は❷スタックに積んでから関数を呼び出します．
- [System V ABI (AMD64)](https://www.uclibc.org/docs/psABI-x86_64.pdf)により
  ❸`call`命令実行時には`%rsp`の値は16の倍数である必要があります．
  そのため，❹で8バイトのパディングをスタックに置いています．
- 関数からリターン後は❷でスタックに積んだ引数と❹パディングを❸スタック上から取り除きます．

### 仮引数

```
{{#include asm/parameter.c}}
```

```x86asmatt
    .text
    .section .rodata
.LC0:
    .string "%ld\n"
    .text
    .globl  foo
    .type   foo, @function
foo:
    endbr64
    pushq   %rbp
    movq    %rsp, %rbp
    subq    $48, %rsp
    movq ❶ %rdi, -8(%rbp)   # 第1引数
    movq ❶ %rsi, -16(%rbp)  # 第2引数
    movq ❶ %rdx, -24(%rbp)  # 第3引数
    movq ❶ %rcx, -32(%rbp)  # 第4引数
    movq ❶ %r8, -40(%rbp)   # 第5引数
    movq ❶ %r9, -48(%rbp)   # 第6引数
    movq    -8(%rbp), %rdx  
    movq ❷ 16(%rbp), %rax   # 第7引数
    addq    %rdx, %rax
    movq    %rax, %rsi
    leaq    .LC0(%rip), %rax
    movq    %rax, %rdi
    movl    $0, %eax
    call    printf@PLT
    nop
    leave
    ret
```

<img src="figs/parameter.svg" height="400px" id="fig:parameter">

- GCCはレジスタで受け取った第1〜第6引数をスタック上に❶置いています．
  一方，第7引数はスタック渡しで，その場所は❻`16(%rbp)`でした．

## 式 (expression)

### 単項演算子 (unary operator)

```
{{#include asm/unary.c}}
```

```x86asmatt
    .text
    .globl  x
    .data
    .align 4
    .type   x, @object
    .size   x, 4
x:
    .long   111
    .text
    .globl  main
    .type   main, @function
main:
    endbr64
    pushq   %rbp
    movq    %rsp, %rbp
    movl    x(%rip), %eax
❶  negl    %eax
    popq    %rbp
    ret
```

- 単項演算は対応する命令，ここでは❶ `negl`を使うだけです．

### 二項演算子(単純な加算)

```
{{#include asm/binop-add.c}}
```

```x86asmatt
    .globl  x
    .data
    .align 4
    .type   x, @object
    .size   x, 4
x:
    .long   111

    .text
    .globl  main
    .type   main, @function
main:
    endbr64
    pushq   %rbp
    movq    %rsp, %rbp
    movl    x(%rip), %eax
❶  addl    $89, %eax
    popq    %rbp
        ret
```

- 基本的に二項演算子も対応する命令 (ここでは❷`addl`)を使うだけです．

### 二項演算子(割り算)

```
{{#include asm/binop-div.c}}
```

```x86asmatt
    .globl  x
    .data
    .align 4
    .type   x, @object
    .size   x, 4
x:
    .long   111

    .globl  y
    .align 4
    .type   y, @object
    .size   y, 4
y:
    .long   9

    .text
    .globl  main
    .type   main, @function
main:
    endbr64
    pushq   %rbp
    movq    %rsp, %rbp
    movl    x(%rip), %eax
    movl    y(%rip), %ecx
❷  cltd
❶  idivl   %ecx
    popq    %rbp
    ret
```

- 割り算はちょっと注意が必要です．
- 例えば，32ビット符号ありの割り算を❶`idivl`命令で行う場合，
  `%edx:%eax`を第1オペランドで割った商が`%eax` に入ります．
- このため，`idivl`を使う前に❷`cltd`命令等を使って，
  `%eax`を符号拡張した値を`%edx`に設定しておく必要があります
  (`%edx`の値の設定を忘れるて`%idivl`を実行すると，割り算の結果がおかしくなります)

### 二項演算(ポインタ演算)

- 復習: C言語のポインタ演算 (オペランドがポインタの場合の演算)は普通の加減算と意味が異なります．ポインタが指す先のサイズを使って計算する必要があります．


| 演算 | 意味 (`int i, *p, *q`の場合) |
|-|-|
|`p + i`| `p + (i * sizeof (*p))`|
|`i + q`| `p + (i * sizeof (*p))`|
|`p + q`| コンパイルエラー |
|`p - i`| `p - (i * sizeof (*p))`|
|`i - q`| コンパイルエラー |
|`p - q`| `(p - q) / sizeof (*p)`|

```
{{#include asm/pointer-arith.c}}
```
 
```
$ gcc -g -no-pie pointer-arith.c
$ ./a.out
0x404030, 0x404030
0x404038, 0x404038, 0x404038
0x404030, 0x404030
2
```

<img src="figs/array3.svg" height="400px" id="fig:array3">

- 復習: 式中で配列名(`a`)はその配列の先頭要素のアドレス(`&a[0]`)を意味します．
- 復習: 式中で配列要素へのアクセス `a[i]`は，
  `*(a+i)`や`*(i+a)`と書いても同じ意味です．
- 例えば，上の例で`a+2`は，配列の要素が`int`型で，`sizeof(int)`が4なので，
  \\(0x404030 + 2\times 4 = 0x404038\\) という計算になります．
  このため，`a+2`は`&a[2]`と同じ値になります．

```
{{#include asm/pointer-arith2.c}}
```

```x86asmatt
    .globl  a
    .data
    .align 16
    .type   a, @object
    .size   a, 16
a:
    .long   0
    .long   10
    .long   20
    .long   30

    .text
    .globl  foo
    .type   foo, @function
foo:
    endbr64
    pushq   %rbp
    movq    %rsp, %rbp
    leaq ❷ 8+a(%rip), %rax
    popq    %rbp
    ret
```

- 上の例でCコード中の❶`a+2`は，アセンブリコード中では❷`8+a`になっています．
  配列要素のサイズ4をかけ算して，\\(a + 2\times 4\\)という計算をするからです．

### アドレス演算子`&`と逆参照演算子`*`
### 述語演算子
### left-to-right evaluation
### 代入
- スタック上に値を残す   

## 文 (statement)

### 式文
- スタック上の値を削除する
### ブロック文
### goto文とラベル文
### return文

## 関数

### 関数定義
### 関数コール
### 関数コール(関数ポインタ)
### ライブラリ関数コール
### システムコール
