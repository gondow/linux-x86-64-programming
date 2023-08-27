#include <stdio.h>
#include <signal.h>
#include <unistd.h>

void handler (int n)
{
    fprintf (stderr, "SIGINT handler\n");
}

int main ()
{
    signal (SIGINT, handler);
    while (1) {
        sleep (1);
        fprintf (stderr, ".");
    }
}
