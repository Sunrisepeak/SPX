#include <defs.h>
#include <string.h>
void _Unwind_Resume() {
    int i = 1;
}
void __gxx_personality_v0() {
    int i = 1;
}

int initKernel() {
    _Unwind_Resume();
    __gxx_personality_v0();
    ccstring ccs = "1234";
    String s("4321");
    s.getLength();
    s == s;
    return 0;
}