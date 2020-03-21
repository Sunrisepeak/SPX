/*
 * @Author: SPeak Shen 
 * @Date: 2020-03-20 15:35:03 
 * @Last Modified by: SPeak Shen
 * @Last Modified time: 2020-03-20 16:47:31
 */

#ifndef _BOOT_ASM_H
#define _BOOT_ASM_H

/*  set segment descriptor  */
#define SEG_DESC_NULL                                               \
    .word 0, 0;                                                     \
    .word 0, 0;

// G = 1, D/B = 1, P = 1, DPL = 0, S = 1
#define SEG_DESC(type,base,lim)                                     \
    .word ((lim) & 0xffff), ((base) & 0xffff);                      \
    .byte (((base) >> 16) & 0xff), (0x90 | (type));                 \
    .byte (0xC0 | (((lim) >> 16) & 0xf)), (((base) >> 24) & 0xff)

/*  type of segment descriptor   */

// data segment
#define STA_R           0x0
#define STA_RW          0x2
#define STA_R_DOWN      0x4
#define STA_RW_DOWN     0x6

// code segment
#define STA_E           0x8
#define STA_E_R         0xA
#define STA_E_FOLLOW    0xC
#define STA_ER_FOLLOW   0xE

#endif

