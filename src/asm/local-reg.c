// local-reg.c
#include <stdio.h>
int main ()
{
    register long foo asm ("%r15") = 999;
    printf ("%ld\n", foo);
}
