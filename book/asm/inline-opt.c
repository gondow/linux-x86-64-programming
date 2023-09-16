// inline-opt.c
#include <stdio.h>
#include <unistd.h>

static int x = 111, y;
int main ()
{
    while (1) {
        asm volatile ("hogehoge":"=rm" (y):"rm" (x));
        sleep (1);
    }
}
