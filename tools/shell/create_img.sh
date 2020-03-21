<<!
/*
 * @Author: SPeak Shen 
 * @Date: 2020-03-19 21:14:30 
 * @Last Modified by: SPeak Shen
 * @Last Modified time: 2020-03-19 21:15:36
 */
!
dd if=/dev/zero of=$1 count=10000
dd if=$2 of=$1 conv=notrunc
dd if=$3 of=$1 seek=1 conv=notrunc