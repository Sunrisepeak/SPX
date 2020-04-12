#include <iostream>
#include <harddisk.h>
#include <vdieomemory.h>
#include <console.h>
#include <string.h>

typedef int *T;

int main() {
    HardDisk h;
    printf("test");
    VideoMemory vm;
    Console csl;
    Console::Char c;

    const char *pt = "4321";

    int t3 = 8;
    const T i = &t3;
    
    int p;
    int addr = (int)(&p);
    //printf("%x\n", addr);
    sizeof(p);

    return 0;
}
