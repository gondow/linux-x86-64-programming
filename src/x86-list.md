<style type="text/css">
body { counter-reset: chapter 11; }
</style>

# x86-64 命令一覧

## 概要と記号
## 命令サフィックス
## レジスタ
## ステータスレジスタ
## プログラムカウンタ
## セグメントレジスタ
## レジスタの別名
## アドレッシングモード(オペランドの記法)
### アドレッシングモードの種類
### メモリ参照の形式
### メモリ参照の例
### メモリ参照で可能な組み合わせ (indexに%rspは指定不可(xxx))
## 「詳しい文法」欄で用いるオペランドの記法と注意

## データ転送(コピー)

### データ転送(コピー)：基本

---
|文法|何の略か| 動作 |
|-|-|-|
|**`mov␣`** *op1*, *op2*| move | *op1*の値を*op2*にデータ転送(コピー) |
---
|詳しい文法| 例 | 例の動作 | [サンプルコード](./6-inst.md#how-to-execute-x86-inst) | 
|-|-|-|-|
|**`mov␣`** *r*, *r/m*| `movq %rax, %rbx` | `%rbx = %rax` |[movq-1.s](./asm/movq-1.s) [movq-1.txt](./asm/movq-1.txt)|
|| `movq %rax, -8(%rsp)` | `*(%rsp - 8) = %rax` |[movq-2.s](./asm/movq-2.s) [movq-2.txt](./asm/movq-2.txt)|
|**`mov␣`** *r/m*, *r*| `movq -8(%rsp), %rax` | `%rax = *(%rsp - 8)` |[movq-3.s](./asm/movq-3.s) [movq-3.txt](./asm/movq-3.txt)|
|**`mov␣`** *imm*, *r*| `movq $999, %rax` | `%rax = 999` | [movq-4.s](./asm/movq-4.s) [movq-4.txt](./asm/movq-4.txt)|
|**`mov␣`** *imm*, *r/m*| `movq $999, -8(%rsp)` | `*(%rsp - 8) = 999` |[movq-5.s](./asm/movq-5.s) [movq-5.txt](./asm/movq-5.txt)||
---
<span style="font-size: 70%;">

|[CF](#ステータスレジスタ)|[OF](#ステータスレジスタ)|[SF](#ステータスレジスタ)|[ZF](#ステータスレジスタ)|[PF](#ステータスレジスタ)|[AF](#ステータスレジスタ)|
|-|-|-|-|-|-|
|&nbsp;| | | | | |


</span>

---


- `␣`は[命令サフィックス](#命令サフィックス)
- `mov`命令(および他のほとんどのデータ転送命令)はステータスフラグの値を変更しない
- `mov`命令はメモリからメモリへの直接データ転送はできない
