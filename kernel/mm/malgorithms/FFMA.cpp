#include <FFMA.h>
#include <mmu.h>
#include <ostream.h>
#include <kdebug.h>

void FFMA::init() {
    name = "First-Fit Memory Allocation (FFMA) Algorithm";
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
    auto it = freeArea.getNodeIterator();
    List<MMU::Page>::DLNode *pnode;
    // find fit Area
    while((pnode = it.nextLNode()) != nullptr) {
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

void FFMA::freePages(void *base, uint32_t n) {
    auto pnArr = (List<MMU::Page>::DLNode *)base;
    for (uint32_t i = 0; i < n; i++) {          // init page Node info
        pnArr[i].data.status = 0;
        pnArr[i].data.ref = 0;
    }
    
    pnArr[0].data.property = n;                             // set pageNum info of continuous area
    MMU::setPageProperty(pnArr[0].data);                    // enable

    auto it = freeArea.getNodeIterator();
    List<MMU::Page>::DLNode *pnode;

    while((pnode = it.nextLNode()) != nullptr) {           // need merge for area?
        if (pnode + pnode->data.property == pnArr) {        // have free page in front
            pnode->data.property += pnArr->data.property;
            MMU::clearPageProperty(pnArr[0].data);
            freeArea.deleteLNode(pnode);
            pnArr = pnode;                                  // update pnArr address
            break;
        } else if (pnArr + pnArr[0].data.property == pnode) {   // have free page in back [pnArr]
            pnArr[0].data.property += pnode->data.property;
            MMU::clearPageProperty(pnode->data);
            freeArea.deleteLNode(pnode);                     // for union of code 
        } else {
            // do nothing
        }
    }

    it = freeArea.getNodeIterator();
    while ((pnode = it.nextLNode()) != nullptr && pnode < pnArr) { /*  find node  */ }

    // 1: nullptr 2: pnode > pnArr [pnode->pre == nullptr , ...!= nullptr]
    if (pnode == nullptr || pnode->pre == nullptr) {
        freeArea.headInsertLNode(pnArr);
    } else {
        freeArea.insertLNode(pnode->pre, pnArr);
    }
    nfp += n;
}

uint32_t FFMA::numFreePages() {
    return nfp;
}
