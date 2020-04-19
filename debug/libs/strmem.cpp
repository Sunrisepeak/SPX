#include <iostream>

using namespace std;

class S {
    public:
        using TTT = int;

        S(const void *src) {

            s = (char *)src;
            cout << src << endl;
        }

        char & operator[](int i) {
            return s[i];
        }

        void * getAD() {
            return s;
        }

        S & operator=(void *cstr) {             // copy assigment
            s = (char *)cstr;
            return *this;
        }

        S & operator=(S &from) {             // copy assigment
            s = from.s;
            return *this;
        }

    private:
        char *s;
};

void f(S &s) {
    char tt[] = "zzzzz";
    s = tt;
    cout << s[1] << endl;
}

int main() {

    char test[] = "1234567890";
    S s(test);
    cout << sizeof(s) << endl;
    cout << sizeof(S) << endl;

    S::TTT i = 10;

    f(s);

    {
        S ss("666");
        s = ss;
        cout << s[1] << endl;
    }

    s[0] = 'A';

    cout << s.getAD() << endl;
    
    //error
    cout << s[1] << endl;
    return 0;
}