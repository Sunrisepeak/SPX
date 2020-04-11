#include <vmm.h>
#include <global.h>
#include <assert.h>
#include <kdebug.h>
#include <list.hpp>

void VMM::init() {
    checkVmm();
}

List<VMM::VMA>::DLNode * VMM::findVma(List<MM>::DLNode *mm, uptr32_t addr) {

    #ifdef VMM_DEBUG
        DEBUGPRINT("VMM::findVma");
    #endif
    
    List<VMA>::DLNode *vma = nullptr;

    if (mm != nullptr) {
        vma = mm->data.mmap_cache;
        if (!(vma != nullptr && vma->data.vm_start <= addr && vma->data.vm_end > addr)) {
                bool found = 0;
                auto it = mm->data.vmaList.getNodeIterator();
                while ((vma = it.nextLNode()) != nullptr) {

                    #ifdef VMM_DEBUG
                        out.write("\ntarget = ");
                        out.writeValue(addr);
                        out.write(" now = ");
                        out.writeValue(vma->data.vm_start);
                        out.flush();
                    #endif
                    
                    if (vma->data.vm_start <= addr && addr < vma->data.vm_end) {
                        
                        #ifdef VMM_DEBUG
                            DEBUGPRINT("VMM::findVma::vma->data.vm_start <= addr && addr < vma->data.vm_end");
                        #endif
                        
                        found = 1;
                        break;
                    }
                }
                if (!found) {
                    vma = nullptr;
                }
        }
        if (vma != nullptr) {
            mm->data.mmap_cache = vma;
        }
    }

    return vma;

}

List<VMM::VMA>::DLNode * VMM::vmaCreate(uptr32_t vmStart, uptr32_t vmEnd, uint32_t vmFlags) {
    DEBUGPRINT("VMM::vmaCreate");
    auto vma = (List<VMA>::DLNode *)(kernel::pmm.kmalloc(sizeof(List<VMA>::DLNode)));
    
    if (vma != nullptr) {
        OStream out("", "blue");
        out.writeValue((uint32_t)vma);
        out.flush();

        vma->data.vm_start = vmStart;
        vma->data.vm_end = vmEnd;
        vma->data.vm_flags = vmFlags;
    }
    
    return vma;
}

void VMM::insertVma(List<MM>::DLNode *mm, List<VMA>::DLNode *vma) {
    OStream out("\n[new] vma: vm_start = ", "blue");
    out.writeValue(vma->data.vm_start);
    
    assert(vma->data.vm_start < vma->data.vm_end);
    
    auto it = mm->data.vmaList.getNodeIterator();

    decltype(vma) vmaNode, preVma = nullptr;
    while ((vmaNode = it.nextLNode()) != nullptr) {
        //out.write("\nold = ");
        //out.writeValue(vmaNode->data.vm_start);
        if (vmaNode->data.vm_start > vma->data.vm_start) {
            break;
        }
        //DEBUGPRINT("VMM::insertVma --> while ");
        preVma = vmaNode;
    }

    /* check overlap */
    if (preVma != nullptr) {    // pre-note
        checkVamOverlap(preVma, vma);
    }

    if (vmaNode != nullptr) {   // back-note
        checkVamOverlap(vma, vmaNode);
    }

    vma->data.vm_mm = mm;       // pointer father-MM

    if (preVma == nullptr) {
        mm->data.vmaList.headInsertLNode(vma);
    } else {
        DEBUGPRINT("Inert-->mid");
        mm->data.vmaList.insertLNode(preVma, vma);
    }
    out.write("\nnodeNum: ");
    out.writeValue((mm->data.vmaList.length()));
}

List<VMM::MM>::DLNode * VMM::mmCreate() {
    DEBUGPRINT(" VMM::mmCreate()");
    auto mm = (List<MM>::DLNode *)(kernel::pmm.kmalloc(sizeof(List<MM>::DLNode)));

    if (mm != nullptr) {
        mm->next = mm->pre = nullptr;
        mm->data.mmap_cache = nullptr;
        mm->data.pgdir = nullptr;
        //mm->data.map_count = 0;

        if (false) while(1);//swap_init_mm(mm);
        else mm->data.sm_priv = nullptr;
    }
    return mm;
}

void VMM::mmDestroy(List<MM>::DLNode *mm) {
    auto it = mm->data.vmaList.getNodeIterator();
    List<VMA>::DLNode *vma;
    while ((vma = it.nextLNode()) != nullptr) {
        mm->data.vmaList.deleteLNode(vma);
        kernel::pmm.kfree(vma, sizeof(List<VMA>::DLNode));  //kfree vma        
    }
    kernel::pmm.kfree(mm, sizeof(List<MM>::DLNode));        //kfree mm
    mm = nullptr;
}

uint32_t VMM::doPageFault(List<MM>::DLNode *mm, uint32_t errorCode, uptr32_t addr) {
    return 0;
}


void VMM::checkVmm() {
    DEBUGPRINT("VMM::checkVmm");
    uint32_t nr_free_pages_store = kernel::pmm.numFreePages();

    OStream out("\ncheckVMM : ", "blue");
    out.writeValue(nr_free_pages_store);
    out.flush();
    
    checkVma();
    //check_pgfault();
    
    assert(nr_free_pages_store == kernel::pmm.numFreePages());

    //cprintf("check_vmm() succeeded.\n");
}

void VMM::checkVma() {
    DEBUGPRINT("VMM::checkVma");

    uint32_t nr_free_pages_store = kernel::pmm.numFreePages();

    auto mm = mmCreate();
    assert(mm != nullptr);

    uint32_t step1 = 10, step2 = step1 * 10;

    // test 10 times for less than for vma-being
    for (uint32_t i = step1; i >= 1; i--) {
        auto *vma = vmaCreate(i * 5, i * 5 + 2, 0);
        assert(vma != nullptr);
        insertVma(mm, vma);
    }
    // test 90 times for great than for vma-being
    for (uint32_t i = step1 + 1; i <= step2; i++) {
        auto *vma = vmaCreate(i * 5, i * 5 + 2, 0);
        assert(vma != nullptr);
        insertVma(mm, vma);
    }

    auto it = mm->data.vmaList.getNodeIterator();
    auto vmaNode = it.nextLNode();

    for (uint32_t i = 1; i <= step2; i++) {

        assert(vmaNode != nullptr);
        assert(vmaNode->data.vm_start == i * 5 && vmaNode->data.vm_end == i * 5 + 2);

        vmaNode = it.nextLNode();
    }

    // check vma by address and test size if normal.
    for (uint32_t i = 5; i <= 5 * step2; i += 5) {      // 5 ~ 500
        // test exist
        auto vma1 = findVma(mm, i);
        assert(vma1 != nullptr);
        auto vma2 = findVma(mm, i + 1);
        assert(vma2 != nullptr);
        
        // test not exist
        auto vma3 = findVma(mm, i + 2);
        assert(vma3 == nullptr);
        auto vma4 = findVma(mm, i + 3);
        assert(vma4 == nullptr);
        auto vma5 = findVma(mm, i + 4);
        assert(vma5 == nullptr);

        // test size
        assert(vma1->data.vm_start == i  && vma1->data.vm_end == i  + 2);
        assert(vma2->data.vm_start == i  && vma2->data.vm_end == i  + 2);
    }

    OStream out("", "blue");
    out.write("\ncheckVma(): vmaBelow5 [i, start, end]\n");
    for (uint32_t i = 4; i >= 0; i--) {
        auto *vma_below_5= findVma(mm,i);
        if (vma_below_5 != nullptr ) {
           out.writeValue(i);
           out.write(", ");
           out.writeValue(vma_below_5->data.vm_start);
           out.write(", ");
           out.writeValue(vma_below_5->data.vm_end);
           out.write("\n");
           out.flush();
        }
        assert(vma_below_5 == nullptr);
    }

    mmDestroy(mm);

    assert(nr_free_pages_store == kernel::pmm.numFreePages());

    out.write("check_vma_struct() succeeded!\n");

    BREAKPOINT("IIIIII");
}

// check if vma1 overlaps vma2 ?
void VMM::checkVamOverlap(List<VMA>::DLNode *prev, List<VMA>::DLNode *next) {
    assert(prev->data.vm_start < prev->data.vm_end);
    assert(prev->data.vm_end <= next->data.vm_start);
    assert(next->data.vm_start < next->data.vm_end);
}