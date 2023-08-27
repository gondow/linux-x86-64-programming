// union.c
#include <stdio.h>

union foo {
    int  u1;
    float u2;
};

int main ()
{
    union foo f;
    f.u1 = 999;
    f.u2 = 123.456;
}
