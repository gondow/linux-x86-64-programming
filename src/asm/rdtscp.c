// rdtscp.c
#include <stdio.h>
#include <stdint.h>

uint64_t rdtscp (void) {
    uint64_t hi, lo;
    uint32_t aux;
    asm volatile ("rdtscp":"=a"(lo), "=d"(hi), "=c"(aux));
    printf ("processor ID = %d\n", aux);
    return ((hi << 32) | lo);
}

int main (void) {
    printf ("%lu\n", rdtscp ());
}
