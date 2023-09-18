// return2.c
struct foo {
    char x1;
    long x2;
};
struct foo f = {'A', 0x1122334455667788};
struct foo func ()
{
    return f;
}
