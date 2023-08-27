#include <stdio.h>
#include <signal.h>
#include <unistd.h>

void handler (int n)
{
    fprintf (stderr, "I am handler\n");
}

int main (void)
{
    signal (SIGUSR1, handler);
    while (1) {
        fprintf (stderr, ".");
        sleep (1);
    }
}
