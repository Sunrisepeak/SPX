#ifndef _LIST_HPP
#define _LIST_HPP

#include <defs.h>
#include <ostream.h>

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

        class ListIterator {
            public:
                void setCurrentNode(DLNode *node) {
                    currentNode = node;
                }

                bool hasNext() {
                    return currentNode != nullptr;
                }

                DLNode * nextLNode() {
                    if (!hasNext()) {
                        return nullptr;
                    }
                    DLNode *node = currentNode;
                    currentNode = currentNode->next;
                    return node;
                }

            private:
                struct DLNode *currentNode { nullptr };
        };

        List();

        bool isEmpty();

        void addLNode(DLNode &node);

        void insertLNode(DLNode *node1, DLNode *node2);  // node1 -> node2 -> node3(old node2)

        void deleteLNode(DLNode *node);

        Object & locateElement(uint32_t loc);

        List<Object>::ListIterator * getIterator();

    private:

        ListIterator it;                // only a it for every object

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
void List<Object>::addLNode(DLNode &node) {
    if (isEmpty()) {
        headNode.last = &node;
        headNode.first = &node;
        node.pre = nullptr;
        node.next = nullptr;
    } else {
        DLNode *p = headNode.first;      // get rail Node
        
        node.pre = p;
        p->next = &node;
        node.next = nullptr;

        headNode.last = &node;           // update 
    }

    headNode.eNum++;
}

template <typename Object>
void List<Object>::insertLNode(DLNode *node1, DLNode *node2) {
    if (node1->next == nullptr) {
        addLNode(*node2);
    } else {
        node2->pre = node1;
        node2->next = node1->next;

        node1->next->pre = node2;
        node1->next = node2;
    }
}

template <typename Object>
void List<Object>::deleteLNode(DLNode *node) {
    if (headNode.first == node) {       // is first Node
        headNode.first = node->next;
    } else if (headNode.last == node) { // is second Node
        headNode.last = node->pre;
        headNode.last->next = nullptr;
    } else {                            // is Mid Node
        node->next->pre = node->pre;
        node->pre->next = node->next;
    }
    node->next = node->pre = nullptr;
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

template <typename Object>
typename List<Object>::ListIterator * List<Object>::getIterator() {
    it.setCurrentNode(headNode.first);
    return &it;
}

#endif