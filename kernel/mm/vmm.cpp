#include <vmm.h>
#include <list.hpp>

void VMM::vmmInit() {

}

List<VMM::VMA>::DLNode * VMM::findVma(List<MM>::DLNode *mm, uptr32_t addr) {
/*
    List<VMA>::DLNode *vma = nullptr;
    if (mm != nullptr) {
        vma = mm->mmap_cache;
        if (!(vma != nullptr && vma->data.vm_start <= addr && vma->data.vm_end > addr)) {
                bool found = 0;
                list_entry_t *list = &(mm->mmap_list), *le = list;
                while ((le = list_next(le)) != list) {
                    vma = le2vma(le, list_link);
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
                        found = 1;
                        break;
                    }
                }
                if (!found) {
                    vma = nullptr;
                }
        }
        if (vma != nullptr) {
            mm->mmap_cache = vma;
        }
    }
    return vma;
*/
}

List<VMM::VMA>::DLNode * VMM::vmaCreate(uptr32_t vmStart, uptr32_t vmEnd, uint32_t vmFlags) {

}

void VMM::insertVma(List<MM>::DLNode *mm, List<VMA>::DLNode *vma) {

}

List<VMM::MM>::DLNode * VMM::mmCreate() {
/*
    List<MM>::DLNode *mm = PhyMM::kmalloc(sizeof(List<MM>::DLNode));

    if (mm != NULL) {
        list_init(&(mm->mmap_list));
        mm->mmap_cache = NULL;
        mm->pgdir = NULL;
        mm->map_count = 0;

        if (swap_init_ok) swap_init_mm(mm);
        else mm->sm_priv = NULL;
    }
    return mm;
*/
}

void VMM::mmDestroy(List<MM>::DLNode *mm) {

}

uint32_t VMM::doPageFault(List<MM>::DLNode *mm, uint32_t errorCode, uptr32_t addr) {

}