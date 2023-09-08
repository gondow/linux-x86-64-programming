// foo2.c
#include <stdio.h>
int g1 = 999;
int main ()
{
    printf ("%p， %p\n"， &g1， main);
}
