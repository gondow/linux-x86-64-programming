<style type="text/css">
body { counter-reset: chapter 9; }
</style>

# ABI: アプリケーション・バイナリ・インタフェース{#ABI}

## アラインメント制約 {#alignment}

|型|アラインメント制約|
|-|-|
|1バイト整数 | 1の倍数のアドレス |
|2バイト整数 | 2の倍数のアドレス |
|4バイト整数 | 4の倍数のアドレス |
|8バイト整数 | 8の倍数のアドレス |
|ポインタ(8バイト長) | 8の倍数のアドレス |
|16バイト整数 | 16の倍数のアドレス |

[System V ABI (AMD64)](https://www.uclibc.org/docs/psABI-x86_64.pdf)
が定めるアラインメント
