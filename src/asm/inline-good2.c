// inline-good2.c
#include <stdio.h>
long x = 111;
long y = 222;   
int main ()
{
    asm volatile ("movq %[x], %%rax; addq %%rax, %[y]"
                  : [y] "+rm" (y) // 変数yのアセンブリコードを%[y]で展開
                  : [x] "rm" (x)  // 変数xのアセンブリコードを%[x]で展開
                  : "%rax"    // レジスタ%raxの破壊をコンパイラに伝達
        );
    printf ("x = %ld, y = %ld\n", x, y);
}
