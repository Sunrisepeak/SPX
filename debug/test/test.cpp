#include <iostream>

using namespace std;

class A {
    public:
        void f() {
            cout << "123" << endl;
        }

        void test() {
            auto i = (void *)(A::f);

            cout << &A::f) << endl;
            cout << i << endl;
        }

};



int main() {

    
    A a;
    a.test();
    return 0;
}