#ifndef _HASH_LIST_HPP
#define _HASH_LIST_HPP

#include <defs.h>
#include <linker.hpp>
#include <utils.hpp>
#include <list.hpp>

#define HASH_SHIFT          10
#define HASH_LIST_SIZE      (1 << HASH_SHIFT)

/* 2^31 + 2^29 - 2^25 + 2^22 - 2^19 - 2^16 + 1 */
#define GOLDEN_RATIO_PRIME_32       0x9e370001UL

template <typename Object>
class HashList {
    
    public:

        struct KeyValue {
            Object value;
            uint32_t key;
        };

        using HashNode = typename Linker<KeyValue>::DLNode;

        // can't insert when iterate
        class HashListIterator {
            public:
                void setCurrentNode(void *arr, uint32_t num) {
                    
                    index = 0;
                    size = num;
                    array = (List<KeyValue> *)arr;

                    currentNode = array[0].getNodeIterator().nextLNode();
                    count = 1;
                    
                    if (currentNode == nullptr) {
                        moveIndex();
                    }
                }

                bool hasNext() {
                    return currentNode != nullptr && count <= size &&index < HASH_LIST_SIZE;
                }

                HashNode * nextHashNode() {

                    if (!hasNext()) {
                        return nullptr;
                    }

                    HashNode *node = currentNode;
                    currentNode = currentNode->next;

                    if (currentNode == nullptr) {
                        moveIndex();
                    }

                    count++;
                    
                    return node;
                }
                
            private:

                uint32_t index { 0 };
                uint32_t count { 0 };
                uint32_t size { 0 };
                HashNode *currentNode { nullptr };

                List<KeyValue> *array { nullptr };

                void moveIndex() {

                    do {
                        index++;
                        if (index >= HASH_LIST_SIZE || count > size) {
                            index = HASH_LIST_SIZE;
                            return;
                        }
                        currentNode = array[index].getNodeIterator().nextLNode();
                    } while (currentNode == nullptr && index < HASH_LIST_SIZE);
                
                }
        };

        uint32_t hashFunc(uint32_t key);

        uint32_t size();

        bool isExist(uint32_t key);

        void add(uint32_t key, HashNode *node);

        void remove(uint32_t key, HashNode *node);

        HashNode * find(uint32_t key);

        HashListIterator & getHashListIterator();

    private:

        List<KeyValue> hashList[HASH_LIST_SIZE];
        uint32_t num { 0 };

        uint32_t hash32(uint32_t val, uint32_t bits);

        HashListIterator it;

        
};

template <typename Object>
uint32_t HashList<Object>::hashFunc(uint32_t key) {
    return hash32(key, HASH_SHIFT);
}

template <typename Object>
uint32_t HashList<Object>::size() {
    return num;
}

template <typename Object>
bool HashList<Object>::isExist(uint32_t key) {
    
    uint32_t index = hash32(key, HASH_SHIFT);

    auto it = hashList[index].getNodeIterator();
    HashNode *node;

    while ((node = it.nextLNode()) != nullptr) {
        if (node->data.key == key) {
            return true;
        }
    }
    
    return false;
}

template <typename Object>
void HashList<Object>::add(uint32_t key, HashNode *node) {

    node->data.key = key;
    
    uint32_t index = hash32(key, HASH_SHIFT);
    hashList[index].addLNode(*node);
    
    num++;
}

template <typename Object>
void HashList<Object>::remove(uint32_t key, HashNode *value) {
    uint32_t index = hashFunc(key);
    if (!(hashList[index].isEmpty())) {
        hashList[index].deleteLNode(value);
    }
}

template <typename Object>
typename HashList<Object>::HashNode * HashList<Object>::find(uint32_t key) {
    uint32_t index = hashFunc(key);

    auto it = hashList[index].getNodeIterator();
    HashNode *node;

    while ((node = it.nextLNode()) != nullptr) {
        if (node->data.key == key) {
            return node;
        }
    }

    return nullptr;
}

template <typename Object>
typename HashList<Object>::HashListIterator & HashList<Object>::getHashListIterator() {
    it.setCurrentNode(hashList, num);
    return it;
}

/*  private member  */

template <typename Object>
uint32_t HashList<Object>::hash32(uint32_t val, uint32_t bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
    return (hash >> (32 - bits));
}

#endif