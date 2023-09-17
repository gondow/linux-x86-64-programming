// switch.c
int x = 111;
int main ()
{
    switch (x) {
    case 1:
        x++;
        break;
    case 111:
        x--;
        break;
    default:
        x = 0;
        break;
    }
}
