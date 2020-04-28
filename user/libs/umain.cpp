#include <slib>

int spx();

extern "C" void umain() {
    int ret = spx();
    slib::exit(ret);
}

