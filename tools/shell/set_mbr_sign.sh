<<!
/*
 * @Author: SPeak Shen 
 * @Date: 2020-03-19 21:14:30 
 * @Last Modified by: SPeak Shen
 * @Last Modified time: 2020-03-19 21:16:10
 */
!

cp $1 bin/mbr_block
echo "00001FE: 55AA" | xxd -r - bin/mbr_block