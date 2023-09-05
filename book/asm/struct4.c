// asm/struct4.c
#include <stdio.h>
struct foo2 {
    int x2;
    char x1;
};
struct foo2 f = {10, 20};
int main ()
{
    printf ("%ld\n", sizeof (struct foo2));
}
