#ifndef _LIST_HPP
#define _LIST_HPP

#include <defs.h>

template <typename Object>
class List {
    public:                                          
        // Double List Node                                     
        struct DLNode {
            Object data;  
            DLNode *pre, *next;                                               
        }__attribute__((packed));

        // List Head Node                                                
        struct LHeadNode {
            DLNode *first, *last;
            uint32_t eNum;
        }__attribute__((packed));

        List();

        bool isEmpty();

        DLNode & nextLNode(const DLNode &node);

        void addLNode(DLNode &node);

        Object & locateElement(uint32_t loc);

    private:

        LHeadNode headNode;
};

template <typename Object>
List<Object>::List() {
    headNode.first = nullptr;
    headNode.last = nullptr;
    headNode.eNum = 0;
}

template <typename Object>
bool List<Object>::isEmpty() {
    return (headNode.eNum == 0 && headNode.last == nullptr);
}

template <typename Object>
typename List<Object>::DLNode & List<Object>::nextLNode(const DLNode &node) {
    return *(node.next);
}

template <typename Object>
void List<Object>::addLNode(DLNode &node) {
    if (isEmpty()) {
        headNode.last = &node;
        headNode.first = &node;
        headNode.eNum = 1;
        node.pre = nullptr;
        node.next = nullptr;
    } else {
        DLNode *p = headNode.first;      // get rail Node
        
        node.pre = p;
        p->next = &node;
        node.next = nullptr;

        headNode.first = &node;           // update 
        headNode.eNum++;
    }
}

template <typename Object>
Object & List<Object>::locateElement(const uint32_t loc) {
    uint32_t index = 1;
    DLNode *p = headNode.first;
    while (index < loc) {
        p = p->next;
    }
    return p->data;
}


#endif