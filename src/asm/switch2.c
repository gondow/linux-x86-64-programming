// switch2.c
int x = 111;
int main ()
{
    switch (x) {
    case 1:  x++;   break;
    case 2:  x--;   break;
    case 3:  x = 3; break;
    case 4:  x = 4; break;
    case 5:  x = 5; break;
    default: x = 0; break;
    }
}
