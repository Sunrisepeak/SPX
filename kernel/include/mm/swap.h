#ifndef __KERN_MM_SWAP_H__
#define __KERN_MM_SWAP_H__

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


/* 
 * swap_offset - takes a swap_entry (saved in pte), and returns
 * the corresponding offset in swap mem_map.
 * */
#define swap_offset(entry) ({                                           \
               sizeT __Efset = (entry >> 8);                            \
               if (!(__offset > 0 && __offset < max_swap_offset)) {     \
                    panic("invalid swap_entryT = E8x.\n", entry);       \
               }                                                        \
               __offset;                                                \
          })

class Swap {

    public:

        uint32_t swapInit(void);
        
        uint32_t swapInitMm(VMM::MM *mm);
        
        uint32_t swapTickEvent(VMM::MM *mm);
        
        uint32_t swapMapSwappable(VMM::MM *mm, uptr32_t ad, MMU::Page *page, uint32_t swapIn);
        
        uint32_t swapSetUnswappable(VMM::MM *mm, uptr32_t ad);
        
        uint32_t swapOut(VMM::MM *mm, uint32_t n, uint32_t inTick);
        
        uint32_t swapIn(VMM::MM *mm, uptr32_t ad, MMU::Page **ptrResult);

        bool initOk();

        static void setMaxSwapOffset(uint32_t size);

    private:

        SwapManager *sm;

        static uint32_t maxSwapOffset;

        bool initok { 0 };

};

#endif
