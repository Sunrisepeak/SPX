#include <mmu.h>

MMU::MMU() {

}

void MMU::setSegDesc(uint32_t type,uint32_t base, uint32_t lim, uint32_t dpl) {
    segdesc.sd_lim_15_0 = lim & 0xffff;
    segdesc.sd_base_15_0 = (base) & 0xffff;
    segdesc.sd_base_23_16 =((base) >> 16) & 0xff;
    segdesc.sd_type = type;
    segdesc.sd_s = 1;
    segdesc.sd_dpl = dpl;
    segdesc.sd_p = 1;
    segdesc.sd_lim_19_16 = (uint16_t)(lim >> 16);
    segdesc.sd_avl = 0;
    segdesc.sd_l = 0;
    segdesc.sd_db = 1;
    segdesc.sd_g = 1;
    segdesc.sd_base_31_24 = (uint16_t)(base >> 24);
}

void MMU::setGateDesc(GateDesc &gate, uint32_t istrap, uint32_t sel, uint32_t off, uint32_t dpl) {
    gate.gd_off_15_0 = (uint32_t)(off) & 0xffff;        
    gate.gd_ss = (sel);
    gate.gd_args = 0;                                    
    gate.gd_rsv1 = 0;                                    
    gate.gd_type = (istrap) ? STS_TG32 : STS_IG32;    
    gate.gd_s = 0;                                    
    gate.gd_dpl = (dpl);                               
    gate.gd_p = 1;                                    
    gate.gd_off_31_16 = (uint32_t)(off) >> 16;        
}

void MMU::setCallGate(GateDesc &gate, uint32_t ss, uint32_t off, uint32_t dpl) {
    gate.gd_off_15_0 = (uint32_t)(off) & 0xffff;        
    gate.gd_ss = (ss);                                
    gate.gd_args = 0;                                  
    gate.gd_rsv1 = 0;                                  
    gate.gd_type = STS_CG32;                          
    gate.gd_s = 0;                                   
    gate.gd_dpl = (dpl);                              
    gate.gd_p = 1;                                  
    gate.gd_off_31_16 = (uint32_t)(off) >> 16;     
}

void MMU::setTCB() {

}

void MMU::SetPageReserved(Page *p) {
    p->status |= 0x1;
}