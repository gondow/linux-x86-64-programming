int main ()
{
    asm ("movl $999, %%ebx" :::"%ebx");
}

