#include <FFMA.h>
#include <mmu.h>
#include <ostream.h>

void FFMA::init() {
    //name = "First-Fit Memory Allocation (FFMA) Algorithm";
}

void FFMA::initMemMap(List<MMU::Page>::DLNode *pArr, uint32_t num) {
    OStream out("\n\ninitMemMap:\n\n firstAd = ", "red");
    out.writeValue((uint32_t)pArr);
    out.write("\n num = ");
    out.writeValue(num);
    out.write("\n");
    out.flush();

    for (uint32_t i = 0; i < num; i++) {    // init Page struct for the mem-area
        pArr[i].data.ref = 0;
        pArr[i].data.status = 0;
        pArr[i].data.property = 0;
    }

    pArr[0].data.property = num;
    MMU::setPageProperty(pArr[0].data);

    nfp += num;
    
    freeArea.addLNode(*pArr);
}

List<MMU::Page>::DLNode * FFMA::allocPages(uint32_t n) {
    if (n > nfp) {                                 // if n great than  number of free-page
        return nullptr;
    }
    auto it = freeArea.getIterator();
    List<MMU::Page>::DLNode *pnode;
    // find Node
    while((pnode = it->nextLNode()) != nullptr) {
        if (pnode->data.property >= n) {            // current continuous area[page num] is Ok
            break;
        }
    }
    if (pnode != nullptr) {
        if (pnode->data.property > n) {             // need resolve continuous area ?
            List<MMU::Page>::DLNode *newNode = pnode + n;
            newNode->data.property = pnode->data.property - n;
            MMU::setPageProperty(newNode->data);
            freeArea.insertLNode(pnode, newNode);   // insert new pageNode
        }
        freeArea.deleteLNode(pnode);
        nfp -= n;
        MMU::clearPageProperty(pnode->data);
    }
    return pnode;
}

void FFMA::freePages(uint32_t n) {

}

uint32_t FFMA::numFreePases() {
    return 0;
}
