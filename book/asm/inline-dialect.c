int main ()
{
    asm volatile ("{movslq %%eax, %%rbx | movsxd rbx,eax}":);
}
