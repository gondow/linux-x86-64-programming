// main2.c
#include <stdio.h>
int add5 (int n);
int main ()
{
    int (*fp) (int n) = add5;
    printf ("%d\n", fp (10));
}
