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

};

#endif