#include <stdio.h>
void B ()
{
    printf ("B\n");
}
void A ()
{
    B ();
    printf ("A\n");
}
int main ()
{
    A ();
    printf ("main\n");
}

