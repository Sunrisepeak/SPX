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
        };

        // List Head Node                                                
        struct LHeadNode {
            DLNode *head, *trail;
            uint32_t eNum;
        };

        List();

        bool isEmpty();

        DLNode & nextLNode(const DLNode &node);

        void addLNode(DLNode &node);

        Object & locateElement(uint32_t loc);

    private:

        LHeadNode lHNode;
};

template <typename Object>
List<Object>::List() {
    lHNode.head = nullptr;
    lHNode.trail = nullptr;
    lHNode.eNum = 0;
}

template <typename Object>
bool List<Object>::isEmpty() {
    return (lHNode.eNum == 0 && lHNode.trail == nullptr);
}

template <typename Object>
typename List<Object>::DLNode & List<Object>::nextLNode(const DLNode &node) {
    return *(node.next);
}

template <typename Object>
void List<Object>::addLNode(DLNode &node) {
    if (isEmpty()) {
        lHNode.trail = &node;
        lHNode.head = &node;
        lHNode.eNum = 1;
        node.pre = nullptr;
        node.next = nullptr;
    } else {
        DLNode *p = lHNode.head;      // get rail Node
        
        node.pre = p;
        p->next = &node;
        node.next = nullptr;

        lHNode.head = &node;           // update 
        lHNode.eNum++;
    }
}

template <typename Object>
Object & List<Object>::locateElement(const uint32_t loc) {
    uint32_t index = 1;
    DLNode *p = lHNode.head;
    while (index < loc) {
        p = p->next;
    }
    return p->data;
}


#endif