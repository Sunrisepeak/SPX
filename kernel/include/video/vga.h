/*
 * @Author: SPeak Shen 
 * @Date: 2020-03-21 17:54:25 
 * @Last Modified by: SPeak Shen
 * @Last Modified time: 2020-03-26 13:26:56
 */

#ifndef _VGA_H
#define _VGA_H

#define VGA_BUFF_ADDR               (0xB8000)       //  first address
#define VGA_BUFF_SIZE               80 * 25 * 2     //  by byte

/*      port     */
#define VGA_INDEX_PORT              (0x3D4)

#define VGA_CURSOR_PORT_H           (0x0E)
#define VGA_CURSOR_PORT_D           (0x0F)

#define VGA_DATA_PORT               (0x3D5)

#endif