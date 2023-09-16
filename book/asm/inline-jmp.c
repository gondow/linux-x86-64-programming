// inline-jmp.c
#include <stdio.h>
int add (unsigned char arg1, unsigned char arg2)
{
    asm goto ("addb %1, %0; jc %l[overflow]"
              : "+rm" (arg2)
              : "rm" (arg1)
              :
              : overflow);
    return arg2;
overflow:
    printf ("overflow: arg1 = %d, arg2 = %d\n", arg1, arg2);
    return arg2;
}

int main (void)
{
    printf ("result = %d\n", add (254, 1));
    printf ("result = %d\n", add (255, 1));
}
