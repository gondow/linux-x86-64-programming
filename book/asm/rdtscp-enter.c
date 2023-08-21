#include <stdio.h>
#include <stdint.h>
#define MAX (10000)

uint64_t rdtscp (void) {
    uint64_t hi, lo;
    uint32_t aux;
    asm volatile ("rdtscp":"=a"(lo), "=d"(hi), "=c"(aux));
    printf ("processor ID = %d\n", aux);
    return ((hi << 32) | lo);
}

int main (void) {
    uint64_t t1, t2, t3; int i;
    t1 = rdtscp ();
    for (i = 0; i < MAX; i++) {
        asm volatile ("enter $0, $0; leave");
    }
    t2 = rdtscp ();
    for (i = 0; i < MAX; i++) {
        asm volatile ( "pushq %rbp; movq %rsp, %rbp;"
                       "subq $32, %rsp; leave");
    }
    t3 = rdtscp ();
    printf ("%lu\n%lu\n", t2-t1, t3-t2);
}
