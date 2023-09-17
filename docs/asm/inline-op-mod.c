int main ()
{
    int x = 111;
    asm volatile ("inc %q0":"+r" (x));
}
