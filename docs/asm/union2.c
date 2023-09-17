// union2.c
#include <stdio.h>
union foo {
    char x1 [5];
    int  x2;
};
union foo f = {.x1[0] = 'a'};

int main ()
{
    f.x2 = 999;
    return f.x2;
}
