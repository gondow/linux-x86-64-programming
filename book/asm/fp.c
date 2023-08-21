// asm/fp.c
int add5 (int n)
{
    return n + 5;
}

int main ()
{
    int (*fp)(int n);
    fp = add5;
    return fp (10);
}
