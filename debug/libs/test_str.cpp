#include <cstdio>
#include <defs.h>
#include <string.h>

//Note: variable of const-area not modify in Memory when cstring = const char *

int main() {
    cstring p = "1234";

    for (auto it = p; *it != '\0'; it++) {
        printf("%c", *it);
    }
    //error
    //char &c = p[1];
    char *cp = (char *)p;
    //error
    //cp[1] = 4;
    printf("\n%s\n", p);
    printf("%s\n", cp);

    char *p2 = "4321";
    //error
    //p2[1] = 'A';
    char &p3 = p2[1];
    //error
    //p3 = 'A';

    uint8_t *t = (uint8_t *)"1111";
    printf("%c\n", t[2]);
    //error
    //t[2] = 3;

    //error
    //char a[4] = (char[4])cp;
    
    char* c = (char *)(t + 2);
    //ERORO
    //*c = 'A';
    printf("%s\n", p);

    // cstring = char[]
    //cstring strArr = "6666";
    //ok
    //strArr[2] = 'A';
    //printf("%s\n", strArr);

    char* arr[] = {"123", "234"};
    //arr[0][2] = 'A';
    printf("%s\n", arr[0]);

    //uint32_t *p = ((uint32_t *)4);
    //p[0] = 100;
    //printf("%%d\n", *p);

    String ss = "I'm new String class.";

    printf("New String : %s\n", ss.cStr());
    return 0;
}