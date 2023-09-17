// inline-good.c
#include <stdio.h>
long x = 111;
long y = 222;   
int main ()
{
    asm volatile ("movq %1, %%rax; addq %%rax, %0"
                  : "+rm" (y) // 変数yのアセンブリコードを%0で展開
                  : "rm" (x)  // 変数xのアセンブリコードを%1で展開
                  : "%rax"    // レジスタ%raxの破壊の存在をコンパイラに伝達
        );
    printf ("x = %ld, y = %ld\n", x, y);
}
