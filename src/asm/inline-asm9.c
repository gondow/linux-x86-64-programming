// inline-asm9.c
#include <stdio.h>
int main (void)
{
    long in = 111, out = 222;
    asm volatile ("addq %1, %0": "=rm"(out): "rm" (in), "0" (out)); // out += in;
    printf ("in = %ld, out = %ld\n", in, out);
}
