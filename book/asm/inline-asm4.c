// inline-asm4.c
#include <stdio.h>
int main (void)
{
    void *addr;
    asm volatile ("movq %%rsp, %0": "=r"(addr));
    printf ("rsp = %p\n", addr);
}
