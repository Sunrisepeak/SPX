#ifndef _SWAPFS_HPP
#define _SWAPFS_HPP

#include <defs.h>
#include <memlayout.h>
#include <global.h>
#include <assert.h>
#include <kdebug.h>
#include <swap.h>
#include <ide.h>
#include <fs.h>

class SwapFs {

    public:
    
        static void swapfsInit() {
            static_assert((PGSIZE % SECTSIZE) == 0);
            if (!IDE::isValid(SWAP_DEV_NO)) {
                BREAKPOINT("swap fs isn't available.\n");
            }
            Swap::setMaxSwapOffset(IDE::devSize(SWAP_DEV_NO) / (PGSIZE / SECTSIZE));
        }

        static uint32_t swapfsRead(SwapEntry entry, Linker<MMU::Page>::DLNode *pnode) {
            return IDE::readSecs(
                SWAP_DEV_NO,
                (entry.getSwapEntry()) * PAGE_NSECT,
                kernel::pmm.pnodeToPageLAD(pnode),
                PAGE_NSECT
            );
        }
        
        static uint32_t swapfsWrite(SwapEntry entry, Linker<MMU::Page>::DLNode *pnode) {

            return IDE::writeSecs(
                SWAP_DEV_NO,
                (entry.getSwapEntry()) * PAGE_NSECT,
                kernel::pmm.pnodeToPageLAD(pnode),
                PAGE_NSECT
            );
        }
};

#endif /* !_SWAPFS_HPP */

