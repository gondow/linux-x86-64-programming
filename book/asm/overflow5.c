// overflow5.c
#include <stdio.h>
#include <stdint.h>
int main ()
{
    int8_t  x1 = -128;
    int16_t x2 = -32768;
    int32_t x3 = -2147483648;
    x1 = -x1;
    x2 = -x2;
    x3 = -x3;
    printf ("%d, %d, %d\n", x1, x2, x3);
}
