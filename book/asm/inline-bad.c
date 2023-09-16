// inline-bad.c
#include <stdio.h>
long x = 111;
long y = 222;   
int main ()
{
    asm ("movq x(%rip), %rax; addq %rax, y(%rip)");
    printf ("x = %ld, y = %ld\n", x, y);
}
