#include <trap.h>
#include <ostream.h>

void Trap::trap() {
    OStream out("interrupt...\n", "blue");
}