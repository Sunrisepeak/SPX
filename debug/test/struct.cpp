#include <iostream>
using namespace std;

struct  Node
{
    int a;
    int b;
};

static Node getNode(int a, int b) {
    Node n;
    n.a = a;
    n.b = b;
    //while(1);
    return n;
}

static Node t[] = {
    [0] = getNode(1, 1),
    [1] = getNode(2, 2)
};

class T {
    private:
        static Node t[];
};

// page table entry        
struct PTEntry {
    uint32_t p_p : 1;                       // present bits
    uint32_t p_rw : 1;                      // R/W bits
    uint32_t p_us : 1;                      // user
    uint32_t p_pwt : 1;
    uint32_t p_pcd : 1;
    uint32_t p_a : 1;
    uint32_t p_d : 1; 
    uint32_t p_pat : 1;
    uint32_t p_g : 1;
    uint32_t p_avl : 3;
    uint32_t p_ppn : 20;                    // physical page[frame] No

    bool isEmpty() {
        cout << "[1]this->p_ppn: " << this->p_ppn << " *this " << *(uint32_t *)(this) <<endl;
        return *(uint32_t *)(this) == 0;
    }

    void setPermission(uint32_t perm) {
                auto &temp = (*(uint32_t *)(this));
                temp |= perm;
                cout << "[2]this->p_ppn: " << this->p_ppn << " *this " << *(uint32_t *)(this) <<endl;
    }

}__attribute__((packed));

int main() {
    PTEntry pte;
    auto p = &pte;
    p->p_p = 1;
    p->p_ppn = 0;
    p->setPermission(6);
    
    if (p->isEmpty()) {
        cout << "test" << endl;
        cout << sizeof(PTEntry) << endl;
    }
    return 0;
}
