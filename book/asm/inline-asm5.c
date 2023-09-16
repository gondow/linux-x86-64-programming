// inline-asm5.c
#include <stdio.h>
int main (void)
{
    int x = 111, y = 222, z;
    // z = x + y;
    asm volatile ("movl %1, %%eax; addl %2, %%eax; movl %%eax, %0"
                  : "=rm" (z)
                  : "rm" (x), "rm" (y)
                  : "%eax" );
    printf ("x = %d, y = %d, z = %d\n", x, y, z);
}
