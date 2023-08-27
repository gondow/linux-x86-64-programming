struct aaa {
   int a1;
   char a2;
   int *a3;
};

struct bbb {
   struct aaa *b1;
   struct aaa b2;
};

union ccc {
   struct aaa c1;
   struct bbb c2;
};

int main ()
{
    struct aaa a = {10, 'a', 0};
    struct bbb b = {&a, a};
    union ccc u = {.c2 = b};
}
