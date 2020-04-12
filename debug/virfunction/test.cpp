#include <B.h>

int main() {
    A *a;
    B b;
    a = &b;
    a->f();
    return 0;
}