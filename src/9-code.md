<style type="text/css">
body { counter-reset: chapter 9; }
</style>

# GCCが生成したアセンブリコードを読む

この章では単純なCのプログラムをGCCがどのようなアセンブリコードに変換するかを見ていきます．
これより以前の章で学んだ知識を使えば，C言語のコードが意外に簡単にアセンブリコードに変換できることが分かると思います．
実際にコンパイラの授業で構文解析の手法を学べば，
(そして最適化器の実装を諦めれば)コンパイラは学部生でも十分簡単に作れます．

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

<img src="figs/array4.svg" height="200px" id="fig:array4">

以下で使う`int a[3]`の配列のメモリレイアウトは上の図のようになってます．
このため，`a[2]`を参照する時はアドレス`a+8`のメモリを読み，
`a[i]`を参照する時はアドレス`a+i*4`のメモリを読む必要があります．


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

`a[i]`の場合のコンパイル結果は例えば以下のとおりです．
`a[i]`の値を読むために，`a+i*4`の計算をする必要があり，
少し複雑になっています．

```
{{#include asm/array4.c}}
```

```x86asmatt
    .globl  a
    .data
    .align 8
    .type   a, @object
    .size   a, 12
a:
    .long   111
    .long   222
    .long   333
    .globl  i
    .align 4
    .type   i, @object
    .size   i, 4
i:
    .long   1

    .text
    .globl  main
    .type   main, @function
main:
    endbr64
    pushq   %rbp
    movq    %rsp, %rbp
    movl    i(%rip), %eax      # iの値を %eax に代入
    cltq                       # %eax を %rax に符号拡張
    leaq    0(,%rax,4), %rdx   # i*4 を %rdx に代入
    leaq    a(%rip), %rax      # aの絶対アドレスを %rax に代入
    movl    (%rdx,%rax), %eax  # アドレス a+i*4 の値(4バイト，これがa[i])を %eax に代入
    popq    %rbp
    ret
    .size   main, .-main
```

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
- [System V ABI (AMD64)](https://gitlab.com/x86-psABIs/x86-64-ABI/-/jobs/artifacts/master/raw/x86-64-ABI/abi.pdf?job=build)
  により
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

```
{{#include asm/op-addr.c}}
```

```x86asmatt
    .globl  x
    .data
    .align 4
    .type   x, @object
    .size   x, 4
x:
    .long   111

    .globl  p
    .bss
    .align 8
    .type   p, @object
    .size   p, 8
p:
    .zero   8

    .text
    .globl  main
    .type   main, @function
main:
    endbr64
    pushq   %rbp
    movq    %rsp, %rbp
❶  leaq    x(%rip), %rax
    movq    %rax, p(%rip)
❷  movq    p(%rip), %rax
❸  movl    (%rax), %eax
    popq    %rbp
    ret
```

- アドレス演算子`&x`には変数`x`のアドレスを計算すれば良いので，`leaq`命令を使います．
  具体的には❶`leaq x(%rip), %rax`で，`x`の絶対アドレスを`%rax`に格納しています．
- 逆参照演算子`*p`にはメモリ参照を使います．
  まず❷`movq p(%rip), %rax`で変数`p`の中身を`%rax`に格納し，
  ❸`movl (%rax), %eax`とすれば，メモリ参照`(%rax)`で`p`が指す先の値を得られます．

### 比較演算子

```
{{#include asm/pred.c}}
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
❶  cmpl    $100, %eax
❷  setg    %al
❸  movzbl  %al, %eax
    popq    %rbp
    ret
```

- `>`などの比較演算子には[`set␣`](./x86-list.md#set)命令を使います．
- 例えば，`x > 100`の場合，
  - ❶`cmpl`命令で比較を行い，
  - ❷`setg`を使って「より大きい」という条件が成り立っているかどうかを`%al`に格納し
  - ❸`movzbl`を使って，必要なサイズ(ここでは4バイト)にゼロ拡張しています
	

### 論理ANDと論理OR，「左から右への評価」

```
{{#include asm/land.c}}
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
    cmpl    $50, %eax
❶  jle     .L2             # if x <= 50 goto .L2
    movl    x(%rip), %eax
    cmpl    $199, %eax
❷  jg      .L2             # if x > 199 goto .L2
    movl    $1, %eax        # 結果に1をセット
    jmp     .L4
.L2:
    movl    $0, %eax        # 結果に0をセット
.L4:
    popq    %rbp
    ret
```

- 多くの二項演算子では「両方のオペランドを計算してから，その二項演算子 (例えば加算)を行う」というコードを生成すればOKです．
- しかし，論理AND (`&&`) や論理OR (`||`)ではそのやり方ではNGです．
  論理ANDと論理ORは**左から右への評価** (left-to-right evaluation)を
  行う必要があるからです．				
  - 論理ANDでは，まず左オペランドを計算し，その結果が真の時だけ，
    右オペランドを計算します．(左オペランドが偽ならば，右オペランドを計算せず，全体の結果を偽とする)
  - 論理OR では，まず左オペランドを計算し，その結果が偽の時だけ，
    右オペランドを計算します．(左オペランドが真ならば，右オペランドを計算せず，全体の結果を真とする)
  - 要するに左オペランドだけで結果が決まる時は，右オペランドを計算してはいけないのです．
    このおかげで，以下のようなコードが記述可能になります．
    (右オペランド `*p > 100`が評価されるのは`p`が`NULL`ではない場合のみになります)

    ```
    int *p;
    if (p != NULL && *p > 100) { ...
    ```

- このため，上のコード例でも❶左オペランドが真の場合だけ，
  ❷右オペランドが計算されています．
    

### 代入 {#assignment}

```
{{#include asm/assign.c}}
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
❶  movl    $100, x(%rip)
❷  movl    x(%rip), %eax
    popq    %rbp
    ret
```

- 代入式は単純に❶`mov`命令を使えばOKです．
- 代入式には(代入するという副作用以外に)「代入した値そのものを
  その代入式の評価結果とする」という役割もあります．
　そのため❷で，`return`で返す値を`%eax`に格納しています．

## 文 (statement)

### 式文

```
{{#include asm/exp-stmt.c}}
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
❶  movl    $222, x(%rip)
    movl    $0, %eax
    popq    %rbp
    ret

```

- 復習: 式にセミコロン`;`を付けたものが**式文**です．
- `x = 222;`という式文(代入文)は，[代入式](./9-code.md#assignment)の
  ❶ `mov`命令をそのまま出力すればOKです．
  - 式文中の式の計算にスタックを使った場合は，スタック上の値を捨てる必要があることがあります
- `333;`は文法的に正しい式文なのですが，意味がないのでGCCはこの式文を無視しました

### ブロック文

```
{{#include asm/block-stmt.c}}
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
❶  movl    $222, x(%rip)  # 文1
❷  movl    $333, x(%rip)  # 文2
❸  movl    $444, x(%rip)  # 文3
    movl    $0, %eax
    popq    %rbp
    ret
```

- 復習: **ブロック文** (あるいは**複合文** (compound statement))は，
  複数の文が並んだ文です．
- ブロック文のコード出力は簡単で，文の並びの順番に，それぞれの
  アセンブリコード❶❷❸を出力するだけです．

### goto文とラベル文

```
{{#include asm/goto.c}}
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
.L2:
    movl    $222, x(%rip)
    jmp     .L2
```

- C言語のラベル`foo`はアセンブリコードでは`.L2`になっていますが，
  (名前の重複に気をつければ)ラベルとして出力すればOKです
- `goto`文もそのまま無条件ジャンプ`jmp`にすればOKです

### return文 (`int`を返す)


```
{{#include asm/return.c}}
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
❶  movl    x(%rip), %eax
❷  popq    %rbp
❸  ret
```

- `int`などの整数型を返す`return`文は簡単です．
  ❶返す値を`%rax`レジスタに格納し，❷スタックフレームの後始末をしてから，
  ❸`ret`命令で，リターンアドレスに制御を移せばOKです．

### return文 (構造体を返す)

```
{{#include asm/return2.c}}
```

```x86asmatt
    .globl  f
    .data
    .align 16
    .type   f, @object
    .size   f, 16
f:
    .byte   65
    .zero   7
    .quad   1234605616436508552

    .text
    .p2align 4
    .globl  func
    .type   func, @function
func:
    endbr64
❶  movq    8+f(%rip), %rdx
❷  movq    f(%rip), %rax
    ret
```

- 復習: C言語では，配列や関数を，関数の引数に渡したり，関数から返すことはできません (配列へのポインタや，関数へのポインタなら可能ですが)．
  一方，構造体や共用体は，関数の引数に渡したり，関数から返すことができます．

- 8バイトより大きい構造体や共用体を関数引数や返り値にする場合，
  通常のレジスタ以外のレジスタやスタックを使ってやりとりをします．
  具体的な方法は
  [System V ABI (AMD64)](https://gitlab.com/x86-psABIs/x86-64-ABI/-/jobs/artifacts/master/raw/x86-64-ABI/abi.pdf?job=build)
  が定めています．
- 上の例では`%rax`と`%rdx`を使って，構造体`f`を関数からリターンしています．
  (コードが簡単になるように，ここでは`gcc -O2 -S`の出力を載せています)

## 関数

### 関数定義

```
{{#include asm/add5.c}}
```

```x86asmatt
    .text
    .globl  add5
    .type   add5, @function
❷ add5:                      # 関数名のラベル定義
    endbr64
    pushq   %rbp              # スタックフレーム作成
    movq    %rsp, %rbp        # スタックフレーム作成
❶  movl    %edi, -4(%rbp)    # 関数本体
❶  movl    -4(%rbp), %eax    # 関数本体
❶  addl    $5, %eax          # 関数本体
    popq    %rbp              # スタックフレーム破棄
    ret                       # リターン
    .size   add5, .-add5
```

- 関数を定義するには関数本体のアセンブリコード❶の前に**関数プロローグ**，
  後に**関数エピローグ**のコードを出力します．
  また，関数の先頭で❷関数名のラベル(`add5;`)を定義します．
- 関数プロローグはスタックフレームの作成や，callee-saveレジスタの退避などを行います．
- 関数エピローグはcallee-saveレジスタの回復や，スタックフレームの破棄などを行い，`ret`でリターンします．

### 関数コール

```
{{#include asm/main.c}}
```

```x86asmatt
    .section        .rodata
.LC0:
    .string "%d\n"

    .text
    .globl  main
    .type   main, @function
main:
    endbr64
    pushq   %rbp
    movq    %rsp, %rbp
❶  movl    $10, %edi
❷  call    add5@PLT
❸  movl    %eax, %esi
    leaq    .LC0(%rip), %rax
    movq    %rax, %rdi
    movl    $0, %eax
    call    printf@PLT
    movl    $0, %eax
    popq    %rbp
    ret
```

- 関数コールをするには，`call`命令の前に引数をレジスタやスタック上に格納してから，
  `call`命令を実行します．その後，`%rax`に入っている返り値を引き取ります．
- 上の例では，
  - ❶で `10`を第1引数として`%edi`レジスタにセットしてから，
  - ❷で `call`を実行して，制御を`add5`関数に移します
  - ❸で`add5`の返り値 (`%eax`)を引き取っています
- デフォルトの動的リンクを前提としたコンパイルなので，
  関数名が`add5`ではなく❷`add5@PLT`となっています
  ([PLTについてはこちら](./3-binary.md#GOT-PLT)を参照)

### 関数コール(関数ポインタ)

```
```
```x86asmatt
    .section        .rodata
.LC0:
    .string "%d\n"

    .text
    .globl  main
    .type   main, @function
main:
    endbr64
    pushq   %rbp
    movq    %rsp, %rbp
    subq    $16, %rsp
❶  movq    add5@GOTPCREL(%rip), %rax # GOT領域のadd5のエントリ(中身はadd5の絶対アドレス)
    movq    %rax, -8(%rbp)
    movq    -8(%rbp), %rax
❷  movl    $10, %edi
❸  call    *%rax
    movl    %eax, %esi
    leaq    .LC0(%rip), %rax
    movq    %rax, %rdi
    movl    $0, %eax
    call    printf@PLT
    movl    $0, %eax
    leave
    ret
```

- 上のコード例では`add5`を変数`fp`に代入して，
  `fp`中の関数ポインタを使って，`add5`を呼び出しています．
- これをアセンブリコードにすると❶ `movq add5@GOTPCREL(%rip), %rax`になります．
  `add5@GOTPCREL`はGOT領域の`add5`のエントリなので，
  メモリ参照`add5@GOTPCREL(%rip)`で，`add5`の絶対アドレスを取得できます
  ([GOT領域についてはこちら](./3-binary.md#GOT-PLT)を参照)
- ❷で第1引数(`10`)を`%edi`に渡して
- ❸`call *%rax`で`%rax`中の関数ポインタを間接コールしています

### ライブラリ関数コール

```
{{#include asm/main.c}}
```

```x86asmatt
    .section        .rodata
.LC0:
    .string "%d\n"

    .text
    .globl  main
    .type   main, @function
main:
    endbr64
    pushq   %rbp
    movq    %rsp, %rbp
    movl    $10, %edi
    call    add5@PLT
❷  movl    %eax, %esi
❶  leaq    .LC0(%rip), %rax
❶  movq    %rax, %rdi
❸  movl    $0, %eax
❹  call    printf@PLT
    movl    $0, %eax
    popq    %rbp
    ret
```

- ここではライブラリ関数代表として，`printf`を呼び出すコードを見てみます．
  - ❶で`printf`の第1引数である文字列`"%d\n"`の先頭アドレス
    (`.LC0(%rip)`)を第1引数のレジスタ`%rdi`に格納します
  - ❷は`add5`が返した値を，第2引数のレジスタ`%esi`に格納します
  - ❸で`%eax`に`0`を格納しています．
    - `%al`は`printf`などの可変長引数を持つ関数の**隠し引数**です
    - `%al`にはベクタレジスタを使って渡す浮動小数点数の引数の数をセットします
    - これは[System V ABI (AMD64)](https://gitlab.com/x86-psABIs/x86-64-ABI/-/jobs/artifacts/master/raw/x86-64-ABI/abi.pdf?job=build)が定めています
  - ❹で`printf`をコールしています
    
### システムコール

```
{{#include asm/syscall-exit.c}}
```

```x86asmatt
    .text
    .globl  main
    .type   main, @function
main:
    endbr64
    pushq   %rbp
    movq    %rsp, %rbp
    movl    $0, %edi
❶  call    _exit@PLT
```

- `exit`はライブラリ関数なので，ここではシステムコールである`_exit`を呼び出しています．
- が，`_exit`もただの**ラッパ関数**で，
  `_exit`の中で実際のシステムコールを呼び出します．
  このため，❶を見れば分かる通り，`_exit`の呼び出しは
  ライブラリ関数の呼び出し方と同じになります．

```bash
$ objdump -d /lib/x86_64-linux-gnu/libc.so.6 | less
(中略)
00000000000eac70 <_exit>:
   eac70:       f3 0f 1e fa             endbr64 
   eac74:       4c 8b 05 95 e1 12 00    mov    0x12e195(%rip),%r8        # 218e10 <_DYNAMIC+0x250>
   eac7b:       be e7 00 00 00          mov    $0xe7,%esi
   eac80:       ba 3c 00 00 00          mov    $0x3c,%edx
   eac85:       eb 16                   jmp    eac9d <_exit+0x2d>
   eac87:       66 0f 1f 84 00 00 00    nopw   0x0(%rax,%rax,1)
   eac8e:       00 00 
   eac90:       89 d0                   mov    %edx,%eax
   eac92:       0f 05                ❶ syscall 
   eac94:       48 3d 00 f0 ff ff       cmp    $0xfffffffffffff000,%rax
   eac9a:       77 1c                   ja     eacb8 <_exit+0x48>
   eac9c:       f4                      hlt    
   eac9d:       89 f0                   mov    %esi,%eax
   eac9f:       0f 05                ❶ syscall 
~   eaca1:       48 3d 00 f0 ff ff       cmp    $0xfffffffffffff000,%rax
~   eaca7:       76 e7                   jbe    eac90 <_exit+0x20>
~   eaca9:       f7 d8                   neg    %eax
~   eacab:       64 41 89 00             mov    %eax,%fs:(%r8)
~   eacaf:       eb df                   jmp    eac90 <_exit+0x20>
~   eacb1:       0f 1f 80 00 00 00 00    nopl   0x0(%rax)
~   eacb8:       f7 d8                   neg    %eax
~   eacba:       64 41 89 00             mov    %eax,%fs:(%r8)
~   eacbe:       eb dc                   jmp    eac9c <_exit+0x2c>
```

- `_exit`関数の中身を逆アセンブルしてみると，
  ❶`syscall`命令を使ってシステムコールを呼び出している部分を見つけられます．
  (お作法を正しく守れば，`_exit`を使わず，直接，`syscall`でシステムコールを呼び出すこともできます)

### `memcpy`と最適化

- ライブラリ関数`memcpy`の呼び出しは，最適化の有無により例えば次の3パターンになります:
  - `call memcpy`  (通常の関数コール)
  - `movdqa src(%rip), %xmm0; movaps  %xmm0, dst(%rip)` (SSE/AVX命令)
  - `rep movsq` (ストリング命令)

- 最適化無しの場合

```
{{#include asm/memcpy.c}}
```

```
$ gcc -S memcpy.c
$ cat memcpy.s
main:
    pushq   %rbp
    movq    %rsp, %rbp
    movl    $64, %edx
    leaq    src(%rip), %rax
    movq    %rax, %rsi
    leaq    dst(%rip), %rax
    movq    %rax, %rdi
    call    memcpy@PLT    # 普通の call命令でライブラリ関数memcpyを呼ぶ
```

- 最適化した場合

  ```
  $ gcc -S -O2 memcpy.c
  $ cat memcpy.s
  main:
      movdqa  src(%rip), %xmm0     # 16バイト長の%xmm0レジスタに16バイトコピー
      movdqa  16+src(%rip), %xmm1
      xorl    %eax, %eax
      movdqa  32+src(%rip), %xmm2
      movdqa  48+src(%rip), %xmm3
      movaps  %xmm0, dst(%rip)     # %xmm0レジスタからメモリに16バイトコピー
      movaps  %xmm1, 16+dst(%rip)
      movaps  %xmm2, 32+dst(%rip)
      movaps  %xmm3, 48+dst(%rip)
  ```

  - `memcpy.c`を`-O2`でコンパイルすると，`movdqa`と`movaps`命令を使うコードを出力しました．アラインメントなどの条件が合うと，こうなります．
  - `%xmm0`〜`%xmm3`はSSE拡張で導入された16バイト長のレジスタです．

- サイズを増やして最適化した場合

```
{{#include asm/memcpy2.c}}
```

  ```
  $ gcc -S -O2 memcpy2.c
  $ cat memcpy.s
  main:
      leaq    dst(%rip), %rax
      leaq    src(%rip), %rsi
      movl    $128, %ecx
      movq    %rax, %rdi
      xorl    %eax, %eax
      rep movsq
  ```

  - サイズを増やすと，`rep movsq`という[ストリング命令](./x86-list.md#string-insn)を出力しました．
  - `rep movsq`は，`%ecx`回の繰り返しを行います．
    各繰り返しでは，メモリ`(%rsi)`の値を`(%rdi)`に8バイトコピーし，
    `%rsi`と`%rdi`の値を8増やします．
    (DFフラグが1の場合は8減らしますが，ABIが「関数の出入り口で(DF=1にしていたら)DF=0に戻せ」と定めているので，ここではDF=0です)


<details>
<summary>
%rsiと%rdiの名前の由来
</summary>

`%rsi`は source index，`%rdi`は destination index が名前の由来です．
</details>
