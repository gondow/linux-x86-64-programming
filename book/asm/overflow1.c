// overflow1.c
#include <stdio.h>
#include <stdint.h>
int main ()
{
    uint8_t x = 255;    
    x++;
    printf ("%d\n", x);
}
