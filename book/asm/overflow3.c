// overflow3.c
#include <stdio.h>
#include <stdint.h>
int main ()
{
    int8_t x = 64;
    x += 64;
    printf ("%d\n", x);
}
