#include <linker.hpp>

template <typename Object>
class Test : public Linker<Object> {

    using typename Linker<Object>::DLNode;

    

    public:
        DLNode node;

        void f() {
        Linker<Object>::insert(nullptr, nullptr);
    }
};

int main() {
    Test<int> t;
    t.node.data = 1;
    t.f();
    return 0;
}