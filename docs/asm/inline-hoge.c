// inline-hoge.c
#include <stdio.h>
long x = 111;
long y = 222;   
int main ()
{
    asm volatile ("hogehoge %1, %0": "+rm" (y): "rm" (x));
    printf ("x = %ld, y = %ld\n", x, y);
}
