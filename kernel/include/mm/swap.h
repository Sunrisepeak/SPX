#ifndef _SWAP_H_
#define _SWAP_H_

#include <defs.h>
#include <memlayout.h>
#include <phymm.h>
#include <vmm.h>
#include <SwapManager.h>

/* *
 * swap_entryT
 *E-------------------------------------------
 * |         offset        |   reserved   | 0 |
 * --------------------------------------------
 *           24 bits            7 bits    1 bit
 * */

#define MAX_SWAP_OFFSET_LIMIT                   (1 << 24)

// the valid vaddr for check is between 0~CHECK_VALID_VADDR-1
#define CHECK_VALID_VIR_PAGE_NUM 5
#define BEING_CHECK_VALID_VADDR 0X1000
#define CHECK_VALID_VADDR (CHECK_VALID_VIR_PAGE_NUM+1)*0x1000
// the max number of valid physical page for check
#define CHECK_VALID_PHY_PAGE_NUM 4
// the max access seq number
#define MAX_SEQ_NO 10

class Swap {

    public:

        uint32_t swapInit(void);
        
        uint32_t swapInitMm(VMM::MM *mm);
        
        uint32_t swapTickEvent(VMM::MM *mm);
        
        uint32_t swapMapSwappable(VMM::MM *mm, uptr32_t ad, MMU::Page *page, uint32_t swapIn);
        
        uint32_t swapSetUnswappable(VMM::MM *mm, uptr32_t ad);
        
        uint32_t swapOut(VMM::MM *mm, uint32_t n, uint32_t inTick);
        
        uint32_t swapIn(VMM::MM *mm, uptr32_t ad, Linker<MMU::Page>::DLNode **ptrResult);

        bool initOk();

        static void setMaxSwapOffset(uint32_t size);

        void checkSwap();

        void checkContentSet();

        int checkContentAccess();

    private:

        SwapManager *sm;

        static uint32_t maxSwapOffset;

        bool initok { 0 };

        /* ----------check------------*/

        Linker<MMU::Page>::DLNode * check_rp[CHECK_VALID_PHY_PAGE_NUM];
        MMU::PTEntry * check_ptep[CHECK_VALID_PHY_PAGE_NUM];
        uint32_t check_swap_addr[CHECK_VALID_VIR_PAGE_NUM];

        uint32_t swap_in_seq_no[MAX_SEQ_NO], swap_out_seq_no[MAX_SEQ_NO];

};

#endif
