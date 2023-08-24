// find.c
#include <stdio.h>
int arr [1000];

int main ()
{
    arr [500] = 0xDEADBEEF;
    printf ("%p\n", &arr [500]);
}
