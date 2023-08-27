// struct2.c
#include <stdio.h>
#include <stddef.h> // for size_t

struct foo {
   int a1;
   char a2;
   size_t a3;
};

int main ()
{
    struct foo f = {10, 'a', 20};
    printf ("%d\n", f.a1);
}
