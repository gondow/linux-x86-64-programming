// inline-asm3.c
#include <stdio.h>
int main (void)
{
    void *addr;
    asm volatile ("movq %%rsp, %[addr]": [addr] "=m"(addr));
    printf ("rsp = %p\n", addr);
}
