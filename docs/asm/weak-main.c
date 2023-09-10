// weak-main.c
#include <stdio.h>
__attribute__((weak)) void foo ()
{
    printf ("I am weak foo\n");
}
int main ()
{
    foo ();
}
