// inline-asm2.c
#include <stdio.h>
int main (void)
{
    void *addr;
    asm volatile ("movq %%rsp, %0": "=m"(addr));
    printf ("rsp = %p\n", addr);
}
