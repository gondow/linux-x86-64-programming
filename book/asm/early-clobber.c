// early-clobber.c
#include <stdio.h>
int main (void)
{
    int a = 20, b;
    asm volatile ("movl $10, %0; addl %1, %0"
                  : "=r"(b) : "r"(a)); // b = 10; b += a;
    printf ("b = %d\n", b);
}
