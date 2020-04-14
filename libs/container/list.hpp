#ifndef _LIST_HPP
#define _LIST_HPP

#include <defs.h>
#include <linker.hpp>
#include <ostream.h>

template <typename Object>
class List : public Linker<Object> {

    public:

        using typename Linker<Object>::DLNode;

        // List Head Node                                                
        struct LHeadNode {
            DLNode *first, *last;
            uint32_t eNum;
        }__attribute__((packed));

        class NodeIterator {
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
                
                DLNode & operator*() const noexcept {
                    return currentNode;
                }

                // postfix ++
                DLNode & operator++(int nothing) {
                    return *nextLNode();
                }
                

            private:

                DLNode *currentNode { nullptr };
        };

        List();

        bool isEmpty();

        uint32_t length();

        void addLNode(DLNode &node);

        void headInsertLNode(DLNode *node);              // headNode -> [target] -> old-first 

        void insertLNode(DLNode *node1, DLNode *node2);  // node1 -> node2 -> node3(old node2)

        void deleteLNode(DLNode *node);

        Object & locateElement(uint32_t loc);

        List<Object>::NodeIterator getNodeIterator();

    private:

        NodeIterator it;                // only a it for every object

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
uint32_t List<Object>::length() {
    return headNode.eNum;
}

template <typename Object>
void List<Object>::addLNode(DLNode &node) {
    if (isEmpty()) {
        headNode.last = &node;
        headNode.first = &node;
        node.pre = nullptr;
        node.next = nullptr;
    } else {
        DLNode *p = headNode.last;      // get rail Node

        p->next = &node;

        node.pre = p;
        node.next = nullptr;

        headNode.last = &node;           // update 
    }

    headNode.eNum++;
}

template <typename Object>
void List<Object>::headInsertLNode(DLNode *node) {
    if (isEmpty()) {
        addLNode(*node);
    } else {
        node->pre = nullptr;
        node->next = headNode.first;

        headNode.first->pre = node;
        
        headNode.first = node;
        headNode.eNum++;
    }
}

template <typename Object>
void List<Object>::insertLNode(DLNode *node1, DLNode *node2) {

    Linker<Object>::insert(node1, node2);

    headNode.eNum++;

}

template <typename Object>
void List<Object>::deleteLNode(DLNode *node) {
    if (headNode.first == node) {       // is first Node
        headNode.first = node->next;
        if (headNode.first == nullptr) {
            headNode.last = nullptr;
        } else {
            headNode.first->pre = nullptr;
        }
    } else if (headNode.last == node) { // is trail Node[can't only a node]
        headNode.last = node->pre;
        headNode.last->next = nullptr;
    } else {                            // is Mid Node
        Linker<Object>::remove(node);
    }
    
    node->next = node->pre = nullptr;
    
    headNode.eNum--;
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
typename List<Object>::NodeIterator List<Object>::getNodeIterator() {
    it.setCurrentNode(headNode.first);
    return it;
}

#endif