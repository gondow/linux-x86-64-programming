// goto.c
int x = 111;
int main ()
{
foo:
    x = 222;
    goto foo;
}
