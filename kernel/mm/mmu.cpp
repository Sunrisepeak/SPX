#include <mmu.h>
#include <kdebug.h>
#include <ostream.h>

MMU::MMU() {

}

MMU::SegDesc MMU::setSegDesc(uint32_t type,uint32_t base, uint32_t lim, uint32_t dpl) {
    SegDesc sd;
    sd.sd_lim_15_0 = lim & 0xffff;
    sd.sd_base_15_0 = (base) & 0xffff;
    sd.sd_base_23_16 = ((base) >> 16) & 0xff;
    sd.sd_type = type;
    sd.sd_s = 1;
    sd.sd_dpl = dpl;
    sd.sd_p = 1;
    sd.sd_lim_19_16 = (uint16_t)(lim >> 16);
    sd.sd_avl = 0;
    sd.sd_l = 0;
    sd.sd_db = 1;
    sd.sd_g = 1;
    sd.sd_base_31_24 = (uint16_t)(base >> 24);
    OStream out("\nsetGDT-->Desc type ", "red");
    out.writeValue(type);
    return sd;
}

MMU::SegDesc MMU::setTssDesc(uint32_t type,uint32_t base, uint32_t lim, uint32_t dpl) {
    SegDesc td;
    td.sd_lim_15_0 = lim & 0xffff;
    td.sd_base_15_0 = (base) & 0xffff;
    td.sd_base_23_16 = ((base) >> 16) & 0xff;
    td.sd_type = type;
    td.sd_s = 0;
    td.sd_dpl = dpl;
    td.sd_p = 1;
    td.sd_lim_19_16 = (uint16_t)(lim >> 16);
    td.sd_avl = 0;
    td.sd_l = 0;
    td.sd_db = 1;
    td.sd_g = 0;
    td.sd_base_31_24 = (uint16_t)(base >> 24);
    return td;                                      
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

void MMU::setPageReserved(Page &p) {
    p.status |= 0x1;
}

void MMU::setPageProperty(Page &p) {
    p.status |= 0x2;
}

void MMU::clearPageProperty(Page &p) {
    p.status &= ~(0x2);                 // clear 2-bits to 0
}
