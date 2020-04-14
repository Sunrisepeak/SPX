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

        static uint32_t swapfsRead(SwapEntry entry, MMU::Page *page) {

        }
        
        static uint32_t swapfsWrite(SwapEntry entry, MMU::Page *page) {

        }
};

#endif /* !_SWAPFS_HPP */

