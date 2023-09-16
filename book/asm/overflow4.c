// overflow4.c
#include <stdio.h>
#include <stdint.h>
int main ()
{
    int32_t x1 = 10 * 10000 * 10000; // 10億
    int32_t x2 = 15 * 10000 * 10000; // 15億
    int32_t x3 = x1 + x2; // オーバーフロー
    printf ("%d\n", x3); // -1794967296
}
