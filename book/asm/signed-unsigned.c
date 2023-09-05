// signed-unsigned.c
#include <stdio.h>
#include <stdint.h>
int main ()
{
    int32_t x1 = -1;
    uint32_t x2 = 0;
    printf ("%d\n", x1 < x2); // 0
}
