// switch3.c
int x = 111;
int main ()
{
    void *jump_table [] = {&&L2, &&L8, &&L7, &&L6, &&L5, &&L3} ; // ❶
    goto *jump_table [x]; // ❷

L8: // case 1:
    x++;   goto L9;
L7: // case 2:
    x--;   goto L9;
L6: // case 3:
    x = 3; goto L9;
L5: // case 4:
    x = 4; goto L9;
L3: // case 5:
    x = 5; goto L9;
L2: // default:
    x = 0; goto L9;
L9:
}
