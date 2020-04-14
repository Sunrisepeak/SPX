#ifndef _LINKER_HPP
#define _LINKER_HPP

template <typename T>
class Linker {
    
    public:

        struct SLNode {
            T data;
            SLNode *next;
        } __attribute__((packed));
        
        struct DLNode {
            T data;
            DLNode *pre, *next;
        } __attribute__((packed));


        void insert(DLNode *node1, DLNode *node2);

};

template <typename T>
void Linker<T>::insert(DLNode *node1, DLNode *node2) {

    node2->pre = node1;
    node2->next = node1->next;

    if (node1->next != nullptr) {
        node1->next->pre = node2;
    }
    node1->next = node2;

}

#endif