// pointer-arith.c
#include <stdio.h>
int a [] = {0, 10, 20, 30};
int main ()
{
    printf ("%p, %p\n", a, &a[0]);     // 同じ
    printf ("%p, %p, %p\n", &a[2], a + 2, 2 + a); // 同じ
    printf ("%p, %p\n", a, &a[2] - 2); // 同じ
    printf ("%ld\n", &a[2] - &a[0]);
    // printf ("%p\n", &a[2] + &a[0]);    // コンパイルエラー
    // printf ("%p\n", 2 - &a[2]);        // コンパイルエラー
}
