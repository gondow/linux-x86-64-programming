       int x1 = 10;     // コンパイル時に.dataセクションに確保
       int x2;          // コンパイル時に.bssセクションに確保
static int x3 = 10;     // コンパイル時に.dataセクションに確保
static int x4;          // コンパイル時に.bssセクションに確保
extern int x5;          // 何も確保しない

int main (void)
{
    int y1 = 10;        // 実行時にスタック上に確保
    int y2;             // 実行時にスタック上に確保
    static int y3 = 10; // コンパイル時に.dataセクションに確保
    static int y4;      // コンパイル時に.bssセクションに確保
    extern int y5;      // 何も確保しない
}
