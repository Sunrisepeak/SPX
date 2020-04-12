#include <iostream>

using namespace std;

class A {
    public:
        virtual void f() = 0;
};

class B : public A {
    public:
        void f() {
            cout << " f() " << endl;
        }
        void son() {
            cout << "SON()" << endl;
        }
};

int main() {
    B b;
    A *p = &b;
    p->f();
    //p->ff(); is error
    return 0;
}