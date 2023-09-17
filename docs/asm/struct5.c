// struct5.c
struct foo {
    char x1;
    int x2;
};
struct foo f = {10, 20};
int main ()
{
    return f.x2;
}
