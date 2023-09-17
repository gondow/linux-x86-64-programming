// clobber-mem.c
#include <stdio.h>
int x = 111, y = 222;
int main ()
{
    y = x;
//    asm volatile ("":::"memory");
    return x;
}

