// array2.c
#include <stdlib.h>
int main (int argc, char **argv)
{
   int arr [4] = {0, 10, 20, 30};
   int *p = malloc (sizeof (int) * 4);
   p [0] = 40;
   p [1] = 50;
   p [2] = 60;
   p [3] = 70;
}
