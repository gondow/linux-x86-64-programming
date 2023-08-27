// inf-loop2.c
#include <stdio.h>
#include <time.h>
int main ()
{
    int n = 0;
    while (time (NULL)) {
        n++;
    }
    printf ("hello, world\n");
}
