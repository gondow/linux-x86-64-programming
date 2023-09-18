// block-stmt.c
int x = 111;
int main ()
{
    {
        x = 222;
        x = 333;
        x = 444;
    }
}
