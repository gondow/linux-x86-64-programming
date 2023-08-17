#include <stdio.h>
#include <asm/prctl.h>
#include <sys/prctl.h>
__thread int x = 0xdeadbeef;
_Thread_local int y = 999;
int main ()
{
    unsigned long ptr;
    asm ("RDFSBASE %rax");
    arch_prctl (ARCH_GET_FS,  &ptr);
    printf ("ptr=%lx, x=%x, y=%d\n", ptr, x);
}
