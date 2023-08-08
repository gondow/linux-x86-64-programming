#include <stdio.h>
__thread int x = 0xDEADBEEF;
int main ()
{
    printf ("x=%x\n", x);
}
