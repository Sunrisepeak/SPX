#include <stdio.h>
struct T {
    int i;
};

int main() {
    struct T t;
    t.i = 1;  
    int p = *(int *)(&t);
    printf("%d\n", p);
    return 0;
}