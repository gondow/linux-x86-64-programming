#include <stdio.h>
int x = 111;
int main ()
{
    static int x = 222;
    {
        int x = 333;
        printf ("hello\n");
    }
}
