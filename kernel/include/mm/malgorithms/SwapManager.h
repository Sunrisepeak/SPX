/*
 * @Author: SPeak Shen 
 * @Date: 2020-04-14 10:28:55 
 * @Last Modified by: SPeak Shen
 * @Last Modified time: 2020-04-14 22:36:26
 */

#ifndef _SWAPMANAGER_H_
#define _SWAPMANAGER_H_

#include <defs.h>
#include <mmu.h>
#include <vmm.h>

class SwapManager {

     public:
          
          /* Global initialization for the swap manager */
          virtual int init() = 0;
          
          /* Called when tick interrupt occured */
          virtual int tickEvent(VMM::MM *mm) = 0;
          
          /* Called when map a swappable page into the mm_struct */
          virtual int mapSwappable(VMM::MM *mm, uptr32_t addr, Linker<MMU::Page>::DLNode *pnode, uint32_t swapIn) = 0;
          /* When a page is marked as shared, this routine is called to
          delete the addr entry from the swap manager */
          virtual int setUnswappable(VMM::MM *mm, uptr32_t addr) = 0;
          
          /* Try to swap out a page, return then victim */
          virtual int swapOutVictim(VMM::MM *mm, Linker<MMU::Page>::DLNode **ptrPage, uint32_t inTick) = 0;

};


#endif
