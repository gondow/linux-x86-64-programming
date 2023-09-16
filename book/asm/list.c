// list.c
#include <stdio.h>
struct list {
    int data;
    struct list *next;
};

int main ()
{
    struct list n1 = {10, NULL};
    struct list n2 = {20, &n1};
    struct list n3 = {30, &n2};
    struct list *p = &n3;
}
