#include <iostream>

uisng namespace std;

class T {
    public:
        struct Node {
            int data;
        };
        
        class Iterator {
            void set(Node *node) {

            }
            private:
                int currentNode;
        };

    private:
        Iterator *it;
        Node *head;
};

int main () {
    return 0;
}