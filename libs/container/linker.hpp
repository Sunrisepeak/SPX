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

        void remove(DLNode *node);

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

template <typename T>
void Linker<T>::remove(DLNode *node) {
    
    if (node->pre != nullptr && node->next != nullptr) {
        
        node->pre->next = node->next;
        node->next->pre = node->pre;

    } else if (node->pre != nullptr && node->next == nullptr) {
        
        node->pre->next = nullptr;

    } else if (node->pre == nullptr && node->next != nullptr) {

        node->next->pre = nullptr;

    } else {
        // do nothing
    }

    node->pre = node->next = nullptr;

}

#endif