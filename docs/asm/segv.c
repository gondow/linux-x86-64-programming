// segv.c
#include <stdio.h>
int main ()
{
    int *p = (int *)0xDEADBEEF; // アクセスNGそうなアドレスを代入
    printf ("%d\n", *p); 
}
