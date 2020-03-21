/*
 * @Author: SPeak Shen 
 * @Date: 2020-03-21 17:54:25 
 * @Last Modified by:   SPeak Shen 
 * @Last Modified time: 2020-03-21 17:54:25 
 */

#ifndef _LIBS_VAG_H
#define _LIBS_VAG_H

#define VAG_BUFF_ADDR               (0xB8000)       //  first address
#define VAG_BUFF_SIZE               80 * 25 * 2     //  by byte

/*      port     */
#define VAG_INDEX_PORT              (0x3D4)

#define VAG_CURSOR_PORT_H           (0x0E)
#define VAG_CURSOR_PORT_D           (0x0F)

#define VAG_DATA_PORT               (0x3D5)

#endif