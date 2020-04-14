#ifndef _QUEUE_HPP
#define _QUEUE_HPP

#include <defs.h>
#include <linker.hpp>

template <typename Object>
class Queue : public Linker<Object> {

    public:

        using typename Linker<Object>::DLNode;

        bool isEmpty();

        void enqueue(DLNode *node);

        DLNode * dequeue();

    private:

        DLNode *front { nullptr }, *rear { nullptr };

        uint32_t num { 0 } ;

};

template <typename Object>
bool Queue<Object>::isEmpty() {

    return front == rear && num == 0;

}

template <typename Object>
void Queue<Object>::enqueue(DLNode *node) {

    if (isEmpty()) {
        front = rear = node;
        node->next = node;
        node->pre = node;
    } else {
        Linker<Object>::insert(rear, node);
        rear = node;
    }
    
    num++;
}

template <typename Object>
typename Linker<Object>::DLNode * Queue<Object>::dequeue() {
    auto temp = front;
    if (temp->next == temp) {
        front = rear = nullptr;
    } else {
        front = temp->next;
    }

    Linker<Object>::remove(temp);

    num--;

    return temp;

}

#endif