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

void FFMA::allocPages(uint32_t n) {

}
void FFMA::freePages(uint32_t n) {

}

uint32_t FFMA::numFreePases() {
    return 0;
}
