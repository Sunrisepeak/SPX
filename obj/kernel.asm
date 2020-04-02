
bin/kernel:     file format elf32-i386


Disassembly of section .text:

00100000 <initKernel>:
#include <ostream.h>
#include <interrupt.h>
#include <gstatic.h>   

/*  kernel entry point  */
extern "C" void initKernel() {
  100000:	55                   	push   %ebp
  100001:	89 e5                	mov    %esp,%ebp
  100003:	57                   	push   %edi
  100004:	56                   	push   %esi
  100005:	53                   	push   %ebx
  100006:	e8 5a 00 00 00       	call   100065 <__x86.get_pc_thunk.bx>
  10000b:	81 c3 01 a4 00 00    	add    $0xa401,%ebx
  100011:	83 ec 68             	sub    $0x68,%esp
    Console cons;
  100014:	8d 7d a8             	lea    -0x58(%ebp),%edi
  100017:	57                   	push   %edi
    cons.clear();
    cons.setBackground("white");
  100018:	8d 75 a0             	lea    -0x60(%ebp),%esi
    Console cons;
  10001b:	e8 4a 00 00 00       	call   10006a <_ZN7ConsoleC1Ev>
    cons.clear();
  100020:	89 3c 24             	mov    %edi,(%esp)
  100023:	e8 04 01 00 00       	call   10012c <_ZN7Console5clearEv>
    cons.setBackground("white");
  100028:	58                   	pop    %eax
  100029:	8d 83 e7 70 ff ff    	lea    -0x8f19(%ebx),%eax
  10002f:	5a                   	pop    %edx
  100030:	50                   	push   %eax
  100031:	56                   	push   %esi
  100032:	e8 77 09 00 00       	call   1009ae <_ZN6StringC1EPKc>
  100037:	59                   	pop    %ecx
  100038:	58                   	pop    %eax
  100039:	56                   	push   %esi
  10003a:	57                   	push   %edi
  10003b:	e8 6a 01 00 00       	call   1001aa <_ZN7Console13setBackgroundE6String>
  100040:	89 34 24             	mov    %esi,(%esp)
  100043:	e8 80 09 00 00       	call   1009c8 <_ZN6StringD1Ev>

    Interrupt inter;
  100048:	89 34 24             	mov    %esi,(%esp)
  10004b:	e8 e4 03 00 00       	call   100434 <_ZN9InterruptC1Ev>
    inter.init();
  100050:	89 34 24             	mov    %esi,(%esp)
  100053:	e8 5a 04 00 00       	call   1004b2 <_ZN9Interrupt4initEv>
    inter.enable();
  100058:	89 34 24             	mov    %esi,(%esp)
  10005b:	e8 9c 04 00 00       	call   1004fc <_ZN9Interrupt6enableEv>
  100060:	83 c4 10             	add    $0x10,%esp
  100063:	eb fe                	jmp    100063 <initKernel+0x63>

00100065 <__x86.get_pc_thunk.bx>:
  100065:	8b 1c 24             	mov    (%esp),%ebx
  100068:	c3                   	ret    
  100069:	90                   	nop

0010006a <_ZN7ConsoleC1Ev>:
 * @Last Modified time: 2020-03-28 18:44:43
 */

#include <console.h>

Console::Console() {
  10006a:	55                   	push   %ebp
  10006b:	89 e5                	mov    %esp,%ebp
  10006d:	56                   	push   %esi
  10006e:	8b 75 08             	mov    0x8(%ebp),%esi
  100071:	53                   	push   %ebx
  100072:	e8 ee ff ff ff       	call   100065 <__x86.get_pc_thunk.bx>
  100077:	81 c3 95 a3 00 00    	add    $0xa395,%ebx
  10007d:	83 ec 0c             	sub    $0xc,%esp
  100080:	56                   	push   %esi
  100081:	e8 80 05 00 00       	call   100606 <_ZN11VideoMemoryC1Ev>
  100086:	58                   	pop    %eax
  100087:	8d 83 ed 70 ff ff    	lea    -0x8f13(%ebx),%eax
  10008d:	5a                   	pop    %edx
  10008e:	50                   	push   %eax
  10008f:	8d 46 08             	lea    0x8(%esi),%eax
  100092:	50                   	push   %eax
  100093:	e8 16 09 00 00       	call   1009ae <_ZN6StringC1EPKc>
  100098:	59                   	pop    %ecx
  100099:	58                   	pop    %eax
  10009a:	8d 83 f1 70 ff ff    	lea    -0x8f0f(%ebx),%eax
  1000a0:	50                   	push   %eax
  1000a1:	8d 46 10             	lea    0x10(%esi),%eax
  1000a4:	50                   	push   %eax
  1000a5:	e8 04 09 00 00       	call   1009ae <_ZN6StringC1EPKc>
  1000aa:	58                   	pop    %eax
  1000ab:	8d 83 e7 70 ff ff    	lea    -0x8f19(%ebx),%eax
  1000b1:	5a                   	pop    %edx
  1000b2:	50                   	push   %eax
  1000b3:	8d 46 18             	lea    0x18(%esi),%eax
  1000b6:	50                   	push   %eax
  1000b7:	e8 f2 08 00 00       	call   1009ae <_ZN6StringC1EPKc>
  1000bc:	59                   	pop    %ecx
  1000bd:	58                   	pop    %eax
  1000be:	8d 83 f7 70 ff ff    	lea    -0x8f09(%ebx),%eax
  1000c4:	50                   	push   %eax
  1000c5:	8d 46 20             	lea    0x20(%esi),%eax
  1000c8:	50                   	push   %eax
  1000c9:	e8 e0 08 00 00       	call   1009ae <_ZN6StringC1EPKc>
    // set l and w
    length = 80;
    wide = 25;
    
    // get Video Memory buffer
    screen = (Char *)(VideoMemory::vmBuffer);
  1000ce:	8b 06                	mov    (%esi),%eax
Console::Console() {
  1000d0:	c7 46 28 04 00 07 01 	movl   $0x1070004,0x28(%esi)
    length = 80;
  1000d7:	c7 46 30 50 00 00 00 	movl   $0x50,0x30(%esi)
    wide = 25;
  1000de:	c7 46 34 19 00 00 00 	movl   $0x19,0x34(%esi)
    screen = (Char *)(VideoMemory::vmBuffer);
  1000e5:	89 46 2c             	mov    %eax,0x2c(%esi)

    // get cursor position
    cPos.x = VideoMemory::getCursorPos() / length;
  1000e8:	89 34 24             	mov    %esi,(%esp)
  1000eb:	e8 42 05 00 00       	call   100632 <_ZN11VideoMemory12getCursorPosEv>
  1000f0:	31 d2                	xor    %edx,%edx
  1000f2:	0f b7 c0             	movzwl %ax,%eax
  1000f5:	f7 76 30             	divl   0x30(%esi)
  1000f8:	88 46 38             	mov    %al,0x38(%esi)
    cPos.y = VideoMemory::getCursorPos() % length;
  1000fb:	89 34 24             	mov    %esi,(%esp)
  1000fe:	e8 2f 05 00 00       	call   100632 <_ZN11VideoMemory12getCursorPosEv>
  100103:	31 d2                	xor    %edx,%edx
    charEctype.attri = screen[0].attri;     // get current background of console

    // set cursor status
    cursorStatus.c = 'S';
    cursorStatus.attri = 0b10101010;        // light green and flash
}
  100105:	83 c4 10             	add    $0x10,%esp
    charEctype.c = 'S';
  100108:	c6 46 3a 53          	movb   $0x53,0x3a(%esi)
    cPos.y = VideoMemory::getCursorPos() % length;
  10010c:	0f b7 c0             	movzwl %ax,%eax
  10010f:	f7 76 30             	divl   0x30(%esi)
    charEctype.attri = screen[0].attri;     // get current background of console
  100112:	8b 46 2c             	mov    0x2c(%esi),%eax
    cPos.y = VideoMemory::getCursorPos() % length;
  100115:	88 56 39             	mov    %dl,0x39(%esi)
    charEctype.attri = screen[0].attri;     // get current background of console
  100118:	8a 40 01             	mov    0x1(%eax),%al
    cursorStatus.c = 'S';
  10011b:	66 c7 46 3c 53 aa    	movw   $0xaa53,0x3c(%esi)
    charEctype.attri = screen[0].attri;     // get current background of console
  100121:	88 46 3b             	mov    %al,0x3b(%esi)
}
  100124:	8d 65 f8             	lea    -0x8(%ebp),%esp
  100127:	5b                   	pop    %ebx
  100128:	5e                   	pop    %esi
  100129:	5d                   	pop    %ebp
  10012a:	c3                   	ret    
  10012b:	90                   	nop

0010012c <_ZN7Console5clearEv>:

void Console::clear() {
  10012c:	55                   	push   %ebp
  10012d:	89 e5                	mov    %esp,%ebp
  10012f:	53                   	push   %ebx
  100130:	e8 30 ff ff ff       	call   100065 <__x86.get_pc_thunk.bx>
  100135:	81 c3 d7 a2 00 00    	add    $0xa2d7,%ebx
  10013b:	83 ec 10             	sub    $0x10,%esp
    VideoMemory::initVmBuff();
  10013e:	ff 75 08             	pushl  0x8(%ebp)
  100141:	e8 d4 04 00 00       	call   10061a <_ZN11VideoMemory10initVmBuffEv>
}
  100146:	83 c4 10             	add    $0x10,%esp
  100149:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  10014c:	c9                   	leave  
  10014d:	c3                   	ret    

0010014e <_ZN7Console8setColorE6String>:

void Console::setColor(String str) {
  10014e:	55                   	push   %ebp
  10014f:	89 e5                	mov    %esp,%ebp
  100151:	57                   	push   %edi
    uint32_t index;
    for (index = 0; index < COLOR_NUM; index++) {
  100152:	31 ff                	xor    %edi,%edi
void Console::setColor(String str) {
  100154:	56                   	push   %esi
  100155:	53                   	push   %ebx
  100156:	83 ec 1c             	sub    $0x1c,%esp
  100159:	e8 07 ff ff ff       	call   100065 <__x86.get_pc_thunk.bx>
  10015e:	81 c3 ae a2 00 00    	add    $0xa2ae,%ebx
  100164:	8b 75 08             	mov    0x8(%ebp),%esi
  100167:	8d 4e 08             	lea    0x8(%esi),%ecx
  10016a:	8d 47 01             	lea    0x1(%edi),%eax
  10016d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if (str == color[index]) {
  100170:	50                   	push   %eax
  100171:	50                   	push   %eax
  100172:	51                   	push   %ecx
  100173:	ff 75 0c             	pushl  0xc(%ebp)
  100176:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  100179:	e8 9c 08 00 00       	call   100a1a <_ZN6StringeqERKS_>
  10017e:	83 c4 10             	add    $0x10,%esp
  100181:	84 c0                	test   %al,%al
  100183:	75 10                	jne    100195 <_ZN7Console8setColorE6String+0x47>
  100185:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  100188:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  10018b:	83 c1 08             	add    $0x8,%ecx
    for (index = 0; index < COLOR_NUM; index++) {
  10018e:	83 ff 04             	cmp    $0x4,%edi
  100191:	75 d7                	jne    10016a <_ZN7Console8setColorE6String+0x1c>
  100193:	eb 0c                	jmp    1001a1 <_ZN7Console8setColorE6String+0x53>
            break;
        }
    }
    if (index < COLOR_NUM) {
        charEctype.attri = (charEctype.attri & 0xF0) | colorTable[index];
  100195:	8a 46 3b             	mov    0x3b(%esi),%al
  100198:	24 f0                	and    $0xf0,%al
  10019a:	0a 44 3e 28          	or     0x28(%esi,%edi,1),%al
  10019e:	88 46 3b             	mov    %al,0x3b(%esi)
    }
}
  1001a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  1001a4:	5b                   	pop    %ebx
  1001a5:	5e                   	pop    %esi
  1001a6:	5f                   	pop    %edi
  1001a7:	5d                   	pop    %ebp
  1001a8:	c3                   	ret    
  1001a9:	90                   	nop

001001aa <_ZN7Console13setBackgroundE6String>:

void Console::setBackground(String str) {
  1001aa:	55                   	push   %ebp
  1001ab:	89 e5                	mov    %esp,%ebp
  1001ad:	57                   	push   %edi
    uint32_t index = 1;                             // default black
    for (uint32_t i = 0; i < COLOR_NUM; i++) {
  1001ae:	31 ff                	xor    %edi,%edi
void Console::setBackground(String str) {
  1001b0:	56                   	push   %esi
  1001b1:	53                   	push   %ebx
  1001b2:	83 ec 1c             	sub    $0x1c,%esp
  1001b5:	e8 ab fe ff ff       	call   100065 <__x86.get_pc_thunk.bx>
  1001ba:	81 c3 52 a2 00 00    	add    $0xa252,%ebx
  1001c0:	8b 75 08             	mov    0x8(%ebp),%esi
  1001c3:	8d 4e 08             	lea    0x8(%esi),%ecx
  1001c6:	8d 47 01             	lea    0x1(%edi),%eax
  1001c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if (str == color[i]) {
  1001cc:	50                   	push   %eax
  1001cd:	50                   	push   %eax
  1001ce:	51                   	push   %ecx
  1001cf:	ff 75 0c             	pushl  0xc(%ebp)
  1001d2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  1001d5:	e8 40 08 00 00       	call   100a1a <_ZN6StringeqERKS_>
  1001da:	83 c4 10             	add    $0x10,%esp
  1001dd:	84 c0                	test   %al,%al
  1001df:	75 13                	jne    1001f4 <_ZN7Console13setBackgroundE6String+0x4a>
  1001e1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  1001e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  1001e7:	83 c1 08             	add    $0x8,%ecx
    for (uint32_t i = 0; i < COLOR_NUM; i++) {
  1001ea:	83 ff 04             	cmp    $0x4,%edi
  1001ed:	75 d7                	jne    1001c6 <_ZN7Console13setBackgroundE6String+0x1c>
    uint32_t index = 1;                             // default black
  1001ef:	bf 01 00 00 00       	mov    $0x1,%edi
            index = i;
            break;
        }
    }
    charEctype.attri = (charEctype.attri & 0x0F) | ((colorTable[index]) << 4);
  1001f4:	8a 46 3b             	mov    0x3b(%esi),%al
    for (uint32_t row = 0; row < wide; row++) {
  1001f7:	31 c9                	xor    %ecx,%ecx
    charEctype.attri = (charEctype.attri & 0x0F) | ((colorTable[index]) << 4);
  1001f9:	0f b6 54 3e 28       	movzbl 0x28(%esi,%edi,1),%edx
  1001fe:	24 0f                	and    $0xf,%al
  100200:	c1 e2 04             	shl    $0x4,%edx
  100203:	08 d0                	or     %dl,%al
  100205:	88 46 3b             	mov    %al,0x3b(%esi)
    for (uint32_t row = 0; row < wide; row++) {
  100208:	39 4e 34             	cmp    %ecx,0x34(%esi)
  10020b:	76 1e                	jbe    10022b <_ZN7Console13setBackgroundE6String+0x81>
        for (uint32_t col = 0; col < length; col++) {
  10020d:	31 ff                	xor    %edi,%edi
  10020f:	8b 46 30             	mov    0x30(%esi),%eax
  100212:	39 f8                	cmp    %edi,%eax
  100214:	76 12                	jbe    100228 <_ZN7Console13setBackgroundE6String+0x7e>
            screen[row * length + col].attri = charEctype.attri;
  100216:	0f af c1             	imul   %ecx,%eax
  100219:	8a 56 3b             	mov    0x3b(%esi),%dl
  10021c:	8b 5e 2c             	mov    0x2c(%esi),%ebx
  10021f:	01 f8                	add    %edi,%eax
        for (uint32_t col = 0; col < length; col++) {
  100221:	47                   	inc    %edi
            screen[row * length + col].attri = charEctype.attri;
  100222:	88 54 43 01          	mov    %dl,0x1(%ebx,%eax,2)
        for (uint32_t col = 0; col < length; col++) {
  100226:	eb e7                	jmp    10020f <_ZN7Console13setBackgroundE6String+0x65>
    for (uint32_t row = 0; row < wide; row++) {
  100228:	41                   	inc    %ecx
  100229:	eb dd                	jmp    100208 <_ZN7Console13setBackgroundE6String+0x5e>
        }
    }
}
  10022b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  10022e:	5b                   	pop    %ebx
  10022f:	5e                   	pop    %esi
  100230:	5f                   	pop    %edi
  100231:	5d                   	pop    %ebp
  100232:	c3                   	ret    
  100233:	90                   	nop

00100234 <_ZN7Console12setCursorPosEhh>:

void Console::setCursorPos(uint8_t x = 0, uint8_t y = 0) {
  100234:	55                   	push   %ebp
  100235:	89 e5                	mov    %esp,%ebp
  100237:	56                   	push   %esi
  100238:	53                   	push   %ebx
  100239:	83 ec 18             	sub    $0x18,%esp
  10023c:	8b 75 08             	mov    0x8(%ebp),%esi
  10023f:	0f b6 45 0c          	movzbl 0xc(%ebp),%eax
  100243:	8b 4d 10             	mov    0x10(%ebp),%ecx
  100246:	e8 1a fe ff ff       	call   100065 <__x86.get_pc_thunk.bx>
  10024b:	81 c3 c1 a1 00 00    	add    $0xa1c1,%ebx
    cPos.x = x;
  100251:	88 46 38             	mov    %al,0x38(%esi)
void Console::setCursorPos(uint8_t x = 0, uint8_t y = 0) {
  100254:	88 45 f7             	mov    %al,-0x9(%ebp)
  100257:	0f b6 d1             	movzbl %cl,%edx
    cPos.y = y;
    // set cursor status
    screen[cPos.x * length + cPos.y] = cursorStatus;
  10025a:	0f af 46 30          	imul   0x30(%esi),%eax
    cPos.y = y;
  10025e:	88 4e 39             	mov    %cl,0x39(%esi)
    screen[cPos.x * length + cPos.y] = cursorStatus;
  100261:	8b 4e 3c             	mov    0x3c(%esi),%ecx
  100264:	01 c2                	add    %eax,%edx
  100266:	8b 46 2c             	mov    0x2c(%esi),%eax
  100269:	66 89 0c 50          	mov    %cx,(%eax,%edx,2)
    VideoMemory::setCursorPos(cPos.x * length + cPos.y);
  10026d:	0f b6 46 38          	movzbl 0x38(%esi),%eax
  100271:	0f b6 56 39          	movzbl 0x39(%esi),%edx
  100275:	0f af 46 30          	imul   0x30(%esi),%eax
  100279:	01 d0                	add    %edx,%eax
  10027b:	0f b7 c0             	movzwl %ax,%eax
  10027e:	50                   	push   %eax
  10027f:	56                   	push   %esi
  100280:	e8 db 03 00 00       	call   100660 <_ZN11VideoMemory12setCursorPosEt>
}
  100285:	83 c4 10             	add    $0x10,%esp
  100288:	8d 65 f8             	lea    -0x8(%ebp),%esp
  10028b:	5b                   	pop    %ebx
  10028c:	5e                   	pop    %esi
  10028d:	5d                   	pop    %ebp
  10028e:	c3                   	ret    
  10028f:	90                   	nop

00100290 <_ZN7Console12getCursorPosEv>:

const Console::CursorPos & Console::getCursorPos() {
  100290:	55                   	push   %ebp
  100291:	89 e5                	mov    %esp,%ebp
  100293:	56                   	push   %esi
  100294:	8b 75 08             	mov    0x8(%ebp),%esi
  100297:	53                   	push   %ebx
  100298:	e8 c8 fd ff ff       	call   100065 <__x86.get_pc_thunk.bx>
  10029d:	81 c3 6f a1 00 00    	add    $0xa16f,%ebx
    cPos.x = VideoMemory::getCursorPos() / length;
  1002a3:	83 ec 0c             	sub    $0xc,%esp
  1002a6:	56                   	push   %esi
  1002a7:	e8 86 03 00 00       	call   100632 <_ZN11VideoMemory12getCursorPosEv>
  1002ac:	31 d2                	xor    %edx,%edx
  1002ae:	0f b7 c0             	movzwl %ax,%eax
  1002b1:	f7 76 30             	divl   0x30(%esi)
  1002b4:	88 46 38             	mov    %al,0x38(%esi)
    cPos.y = VideoMemory::getCursorPos() % length;
  1002b7:	89 34 24             	mov    %esi,(%esp)
  1002ba:	e8 73 03 00 00       	call   100632 <_ZN11VideoMemory12getCursorPosEv>
  1002bf:	31 d2                	xor    %edx,%edx
  1002c1:	0f b7 c0             	movzwl %ax,%eax
  1002c4:	f7 76 30             	divl   0x30(%esi)
    return cPos;
  1002c7:	8d 46 38             	lea    0x38(%esi),%eax
    cPos.y = VideoMemory::getCursorPos() % length;
  1002ca:	88 56 39             	mov    %dl,0x39(%esi)
}
  1002cd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  1002d0:	5b                   	pop    %ebx
  1002d1:	5e                   	pop    %esi
  1002d2:	5d                   	pop    %ebp
  1002d3:	c3                   	ret    

001002d4 <_ZN7Console4readEv>:
    for (uint32_t i = 0; i < len; i++) {
        wirte(cArry[i]);
    }
}

char Console::read() {
  1002d4:	55                   	push   %ebp
  1002d5:	89 e5                	mov    %esp,%ebp
    return screen[0].c;
  1002d7:	8b 45 08             	mov    0x8(%ebp),%eax
}
  1002da:	5d                   	pop    %ebp
    return screen[0].c;
  1002db:	8b 40 2c             	mov    0x2c(%eax),%eax
  1002de:	8a 00                	mov    (%eax),%al
}
  1002e0:	c3                   	ret    
  1002e1:	90                   	nop

001002e2 <_ZN7Console4readEPcRKt>:

void Console::read(char *cArry, const uint16_t &len) {
  1002e2:	55                   	push   %ebp
  1002e3:	89 e5                	mov    %esp,%ebp
   
}
  1002e5:	5d                   	pop    %ebp
  1002e6:	c3                   	ret    
  1002e7:	90                   	nop

001002e8 <_ZN7Console12scrollScreenEv>:
    } else {
        setCursorPos(cPos.x + 1, 0);
    }
}

void Console::scrollScreen() {
  1002e8:	55                   	push   %ebp
    charEctype.c = ' ';
    for (uint32_t i = 0; i < length * wide; i++) {
  1002e9:	31 c0                	xor    %eax,%eax
void Console::scrollScreen() {
  1002eb:	89 e5                	mov    %esp,%ebp
  1002ed:	57                   	push   %edi
  1002ee:	56                   	push   %esi
  1002ef:	53                   	push   %ebx
  1002f0:	83 ec 0c             	sub    $0xc,%esp
  1002f3:	8b 55 08             	mov    0x8(%ebp),%edx
    charEctype.c = ' ';
  1002f6:	c6 42 3a 20          	movb   $0x20,0x3a(%edx)
    for (uint32_t i = 0; i < length * wide; i++) {
  1002fa:	8b 5a 30             	mov    0x30(%edx),%ebx
  1002fd:	8b 4a 34             	mov    0x34(%edx),%ecx
  100300:	89 de                	mov    %ebx,%esi
  100302:	0f af f1             	imul   %ecx,%esi
  100305:	39 c6                	cmp    %eax,%esi
  100307:	76 20                	jbe    100329 <_ZN7Console12scrollScreenEv+0x41>
  100309:	8b 7a 2c             	mov    0x2c(%edx),%edi
  10030c:	8d 0c 00             	lea    (%eax,%eax,1),%ecx
        if (i < length * (wide - 1)) {
  10030f:	29 de                	sub    %ebx,%esi
  100311:	01 f9                	add    %edi,%ecx
  100313:	39 c6                	cmp    %eax,%esi
  100315:	76 08                	jbe    10031f <_ZN7Console12scrollScreenEv+0x37>
            screen[i] = screen[length + i];
  100317:	01 c3                	add    %eax,%ebx
  100319:	66 8b 1c 5f          	mov    (%edi,%ebx,2),%bx
  10031d:	eb 04                	jmp    100323 <_ZN7Console12scrollScreenEv+0x3b>
        } else {
            screen[i] = charEctype;
  10031f:	66 8b 5a 3a          	mov    0x3a(%edx),%bx
  100323:	66 89 19             	mov    %bx,(%ecx)
    for (uint32_t i = 0; i < length * wide; i++) {
  100326:	40                   	inc    %eax
  100327:	eb d1                	jmp    1002fa <_ZN7Console12scrollScreenEv+0x12>
        }
    }
    setCursorPos(wide - 1, 0);
  100329:	fe c9                	dec    %cl
  10032b:	50                   	push   %eax
  10032c:	0f b6 c9             	movzbl %cl,%ecx
  10032f:	6a 00                	push   $0x0
  100331:	51                   	push   %ecx
  100332:	52                   	push   %edx
  100333:	e8 fc fe ff ff       	call   100234 <_ZN7Console12setCursorPosEhh>
}
  100338:	83 c4 10             	add    $0x10,%esp
  10033b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  10033e:	5b                   	pop    %ebx
  10033f:	5e                   	pop    %esi
  100340:	5f                   	pop    %edi
  100341:	5d                   	pop    %ebp
  100342:	c3                   	ret    
  100343:	90                   	nop

00100344 <_ZN7Console4nextEv>:
void Console::next() {
  100344:	55                   	push   %ebp
  100345:	89 e5                	mov    %esp,%ebp
  100347:	53                   	push   %ebx
  100348:	52                   	push   %edx
    cPos.y = (cPos.y + 1) % length;
  100349:	31 d2                	xor    %edx,%edx
void Console::next() {
  10034b:	8b 5d 08             	mov    0x8(%ebp),%ebx
    cPos.y = (cPos.y + 1) % length;
  10034e:	0f b6 43 39          	movzbl 0x39(%ebx),%eax
  100352:	40                   	inc    %eax
  100353:	f7 73 30             	divl   0x30(%ebx)
    if (cPos.y == 0) {
  100356:	84 d2                	test   %dl,%dl
    cPos.y = (cPos.y + 1) % length;
  100358:	89 d1                	mov    %edx,%ecx
  10035a:	88 53 39             	mov    %dl,0x39(%ebx)
    if (cPos.y == 0) {
  10035d:	75 0d                	jne    10036c <_ZN7Console4nextEv+0x28>
        cPos.x = (cPos.x + 1) % wide;
  10035f:	0f b6 43 38          	movzbl 0x38(%ebx),%eax
  100363:	31 d2                	xor    %edx,%edx
  100365:	40                   	inc    %eax
  100366:	f7 73 34             	divl   0x34(%ebx)
  100369:	88 53 38             	mov    %dl,0x38(%ebx)
    if (cPos.y == 0 && cPos.x == 0) {   // jugde scroll screen
  10036c:	66 83 7b 38 00       	cmpw   $0x0,0x38(%ebx)
  100371:	75 0c                	jne    10037f <_ZN7Console4nextEv+0x3b>
        scrollScreen();
  100373:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
  100376:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  100379:	c9                   	leave  
        scrollScreen();
  10037a:	e9 69 ff ff ff       	jmp    1002e8 <_ZN7Console12scrollScreenEv>
        setCursorPos(cPos.x, cPos.y);
  10037f:	0f b6 c9             	movzbl %cl,%ecx
  100382:	50                   	push   %eax
  100383:	51                   	push   %ecx
  100384:	0f b6 43 38          	movzbl 0x38(%ebx),%eax
  100388:	50                   	push   %eax
  100389:	53                   	push   %ebx
  10038a:	e8 a5 fe ff ff       	call   100234 <_ZN7Console12setCursorPosEhh>
  10038f:	83 c4 10             	add    $0x10,%esp
}
  100392:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  100395:	c9                   	leave  
  100396:	c3                   	ret    
  100397:	90                   	nop

00100398 <_ZN7Console8lineFeedEv>:
void Console::lineFeed() {
  100398:	55                   	push   %ebp
  100399:	89 e5                	mov    %esp,%ebp
  10039b:	83 ec 08             	sub    $0x8,%esp
  10039e:	8b 55 08             	mov    0x8(%ebp),%edx
    if ((uint32_t)(cPos.x + 1) >= wide) {
  1003a1:	0f b6 42 38          	movzbl 0x38(%edx),%eax
  1003a5:	40                   	inc    %eax
  1003a6:	3b 42 34             	cmp    0x34(%edx),%eax
  1003a9:	72 06                	jb     1003b1 <_ZN7Console8lineFeedEv+0x19>
}
  1003ab:	c9                   	leave  
        scrollScreen();
  1003ac:	e9 37 ff ff ff       	jmp    1002e8 <_ZN7Console12scrollScreenEv>
        setCursorPos(cPos.x + 1, 0);
  1003b1:	51                   	push   %ecx
  1003b2:	0f b6 c0             	movzbl %al,%eax
  1003b5:	6a 00                	push   $0x0
  1003b7:	50                   	push   %eax
  1003b8:	52                   	push   %edx
  1003b9:	e8 76 fe ff ff       	call   100234 <_ZN7Console12setCursorPosEhh>
  1003be:	83 c4 10             	add    $0x10,%esp
}
  1003c1:	c9                   	leave  
  1003c2:	c3                   	ret    
  1003c3:	90                   	nop

001003c4 <_ZN7Console5wirteERKc>:
void Console::wirte(const char &c) {
  1003c4:	55                   	push   %ebp
  1003c5:	89 e5                	mov    %esp,%ebp
  1003c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
    if (c == '\n') {
  1003ca:	8b 45 0c             	mov    0xc(%ebp),%eax
void Console::wirte(const char &c) {
  1003cd:	53                   	push   %ebx
  1003ce:	0f b6 59 39          	movzbl 0x39(%ecx),%ebx
    if (c == '\n') {
  1003d2:	8a 10                	mov    (%eax),%dl
  1003d4:	0f b6 41 38          	movzbl 0x38(%ecx),%eax
  1003d8:	0f af 41 30          	imul   0x30(%ecx),%eax
  1003dc:	01 d8                	add    %ebx,%eax
  1003de:	01 c0                	add    %eax,%eax
  1003e0:	03 41 2c             	add    0x2c(%ecx),%eax
  1003e3:	80 fa 0a             	cmp    $0xa,%dl
  1003e6:	75 0f                	jne    1003f7 <_ZN7Console5wirteERKc+0x33>
        charEctype.c = ' ';
  1003e8:	c6 41 3a 20          	movb   $0x20,0x3a(%ecx)
        screen[cPos.x * length + cPos.y] = charEctype;
  1003ec:	66 8b 51 3a          	mov    0x3a(%ecx),%dx
  1003f0:	66 89 10             	mov    %dx,(%eax)
}
  1003f3:	5b                   	pop    %ebx
  1003f4:	5d                   	pop    %ebp
        lineFeed();
  1003f5:	eb a1                	jmp    100398 <_ZN7Console8lineFeedEv>
        charEctype.c = c;
  1003f7:	88 51 3a             	mov    %dl,0x3a(%ecx)
        screen[cPos.x * length + cPos.y] = charEctype;
  1003fa:	66 8b 51 3a          	mov    0x3a(%ecx),%dx
  1003fe:	66 89 10             	mov    %dx,(%eax)
}
  100401:	5b                   	pop    %ebx
  100402:	5d                   	pop    %ebp
        next();
  100403:	e9 3c ff ff ff       	jmp    100344 <_ZN7Console4nextEv>

00100408 <_ZN7Console5wirteEPcRKt>:
void Console::wirte(char *cArry, const uint16_t &len) {
  100408:	55                   	push   %ebp
  100409:	89 e5                	mov    %esp,%ebp
  10040b:	53                   	push   %ebx
    for (uint32_t i = 0; i < len; i++) {
  10040c:	31 db                	xor    %ebx,%ebx
void Console::wirte(char *cArry, const uint16_t &len) {
  10040e:	52                   	push   %edx
    for (uint32_t i = 0; i < len; i++) {
  10040f:	8b 45 10             	mov    0x10(%ebp),%eax
  100412:	0f b7 00             	movzwl (%eax),%eax
  100415:	39 d8                	cmp    %ebx,%eax
  100417:	76 16                	jbe    10042f <_ZN7Console5wirteEPcRKt+0x27>
        wirte(cArry[i]);
  100419:	50                   	push   %eax
  10041a:	50                   	push   %eax
  10041b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10041e:	01 d8                	add    %ebx,%eax
    for (uint32_t i = 0; i < len; i++) {
  100420:	43                   	inc    %ebx
        wirte(cArry[i]);
  100421:	50                   	push   %eax
  100422:	ff 75 08             	pushl  0x8(%ebp)
  100425:	e8 9a ff ff ff       	call   1003c4 <_ZN7Console5wirteERKc>
    for (uint32_t i = 0; i < len; i++) {
  10042a:	83 c4 10             	add    $0x10,%esp
  10042d:	eb e0                	jmp    10040f <_ZN7Console5wirteEPcRKt+0x7>
}
  10042f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  100432:	c9                   	leave  
  100433:	c3                   	ret    

00100434 <_ZN9InterruptC1Ev>:
#include <interrupt.h>

Interrupt::Interrupt() {
  100434:	55                   	push   %ebp
  100435:	89 e5                	mov    %esp,%ebp
    
}
  100437:	5d                   	pop    %ebp
  100438:	c3                   	ret    
  100439:	90                   	nop

0010043a <_ZN9Interrupt7initIDTEv>:
    enableIRQ(2);                                   // set master IR2, because of slave connection to IR2
    
    enableIRQ(8);                                   // set slave IR1, clock interrupt of RTC
}

void Interrupt::initIDT() {
  10043a:	55                   	push   %ebp
  10043b:	89 e5                	mov    %esp,%ebp
  10043d:	57                   	push   %edi
  10043e:	56                   	push   %esi
    extern uptr32_t __vectors[];
    for (uint32_t i = 0; i < sizeof(idt) / sizeof(MMU::GateDesc); i++) {
  10043f:	31 f6                	xor    %esi,%esi
void Interrupt::initIDT() {
  100441:	53                   	push   %ebx
  100442:	e8 1e fc ff ff       	call   100065 <__x86.get_pc_thunk.bx>
  100447:	81 c3 c5 9f 00 00    	add    $0x9fc5,%ebx
  10044d:	83 ec 1c             	sub    $0x1c,%esp
        MMU::setGateDesc(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
  100450:	c7 c0 02 a0 10 00    	mov    $0x10a002,%eax
  100456:	c7 c7 20 a4 10 00    	mov    $0x10a420,%edi
  10045c:	83 ec 0c             	sub    $0xc,%esp
  10045f:	6a 00                	push   $0x0
  100461:	ff 34 b0             	pushl  (%eax,%esi,4)
  100464:	8d 14 f7             	lea    (%edi,%esi,8),%edx
    for (uint32_t i = 0; i < sizeof(idt) / sizeof(MMU::GateDesc); i++) {
  100467:	46                   	inc    %esi
        MMU::setGateDesc(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
  100468:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  10046b:	6a 08                	push   $0x8
  10046d:	6a 00                	push   $0x0
  10046f:	52                   	push   %edx
  100470:	e8 ab 04 00 00       	call   100920 <_ZN3MMU11setGateDescERNS_8GateDescEjjjj>
    for (uint32_t i = 0; i < sizeof(idt) / sizeof(MMU::GateDesc); i++) {
  100475:	83 c4 20             	add    $0x20,%esp
  100478:	81 fe 00 01 00 00    	cmp    $0x100,%esi
  10047e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100481:	75 d9                	jne    10045c <_ZN9Interrupt7initIDTEv+0x22>
    }
	// set for switch from user to kernel
    MMU::setGateDesc(idt[T_SWITCH_TOK], 0, GD_KTEXT, __vectors[T_SWITCH_TOK], DPL_USER);
  100483:	83 ec 0c             	sub    $0xc,%esp
  100486:	6a 03                	push   $0x3
  100488:	ff b0 e4 01 00 00    	pushl  0x1e4(%eax)
  10048e:	8d 87 c8 03 00 00    	lea    0x3c8(%edi),%eax
  100494:	6a 08                	push   $0x8
  100496:	6a 00                	push   $0x0
  100498:	50                   	push   %eax
  100499:	e8 82 04 00 00       	call   100920 <_ZN3MMU11setGateDescERNS_8GateDescEjjjj>
    uint32_t pd_base;       // Base address
}__attribute__ ((packed));  // decide size

static inline void
lidt(struct pseudodesc *pd) {
    asm volatile ("lidt (%0)" :: "r" (pd));
  10049e:	c7 c0 04 a4 10 00    	mov    $0x10a404,%eax
  1004a4:	0f 01 18             	lidtl  (%eax)
	// load the IDT
    lidt(&pdIdt);
}
  1004a7:	83 c4 20             	add    $0x20,%esp
  1004aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  1004ad:	5b                   	pop    %ebx
  1004ae:	5e                   	pop    %esi
  1004af:	5f                   	pop    %edi
  1004b0:	5d                   	pop    %ebp
  1004b1:	c3                   	ret    

001004b2 <_ZN9Interrupt4initEv>:
void Interrupt::init() {
  1004b2:	55                   	push   %ebp
  1004b3:	89 e5                	mov    %esp,%ebp
  1004b5:	56                   	push   %esi
  1004b6:	8b 75 08             	mov    0x8(%ebp),%esi
  1004b9:	53                   	push   %ebx
  1004ba:	e8 a6 fb ff ff       	call   100065 <__x86.get_pc_thunk.bx>
  1004bf:	81 c3 4d 9f 00 00    	add    $0x9f4d,%ebx
    initIDT();
  1004c5:	83 ec 0c             	sub    $0xc,%esp
  1004c8:	56                   	push   %esi
  1004c9:	e8 6c ff ff ff       	call   10043a <_ZN9Interrupt7initIDTEv>
    initPIC();
  1004ce:	89 34 24             	mov    %esi,(%esp)
  1004d1:	e8 32 00 00 00       	call   100508 <_ZN3PIC7initPICEv>
    initClock();
  1004d6:	89 34 24             	mov    %esi,(%esp)
  1004d9:	e8 fe 00 00 00       	call   1005dc <_ZN3RTC9initClockEv>
    enableIRQ(2);                                   // set master IR2, because of slave connection to IR2
  1004de:	58                   	pop    %eax
  1004df:	5a                   	pop    %edx
  1004e0:	6a 02                	push   $0x2
  1004e2:	56                   	push   %esi
  1004e3:	e8 7a 00 00 00       	call   100562 <_ZN3PIC9enableIRQEj>
    enableIRQ(8);                                   // set slave IR1, clock interrupt of RTC
  1004e8:	59                   	pop    %ecx
  1004e9:	58                   	pop    %eax
  1004ea:	6a 08                	push   $0x8
  1004ec:	56                   	push   %esi
  1004ed:	e8 70 00 00 00       	call   100562 <_ZN3PIC9enableIRQEj>
}
  1004f2:	83 c4 10             	add    $0x10,%esp
  1004f5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  1004f8:	5b                   	pop    %ebx
  1004f9:	5e                   	pop    %esi
  1004fa:	5d                   	pop    %ebp
  1004fb:	c3                   	ret    

001004fc <_ZN9Interrupt6enableEv>:

void Interrupt::enable() {
  1004fc:	55                   	push   %ebp
  1004fd:	89 e5                	mov    %esp,%ebp
    asm volatile ("sti");
  1004ff:	fb                   	sti    
    sti();
}
  100500:	5d                   	pop    %ebp
  100501:	c3                   	ret    

00100502 <_ZN9Interrupt7disableEv>:

void Interrupt::disable() {
  100502:	55                   	push   %ebp
  100503:	89 e5                	mov    %esp,%ebp
    asm volatile ("cli");
  100505:	fa                   	cli    
    cli();
}
  100506:	5d                   	pop    %ebp
  100507:	c3                   	ret    

00100508 <_ZN3PIC7initPICEv>:
#include <pic.h>

void PIC::initPIC() {
  100508:	55                   	push   %ebp
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100509:	b0 ff                	mov    $0xff,%al
  10050b:	89 e5                	mov    %esp,%ebp
  10050d:	57                   	push   %edi
  10050e:	56                   	push   %esi
  10050f:	be 21 00 00 00       	mov    $0x21,%esi
  100514:	53                   	push   %ebx
  100515:	89 f2                	mov    %esi,%edx
  100517:	e8 a7 00 00 00       	call   1005c3 <__x86.get_pc_thunk.di>
  10051c:	81 c7 f0 9e 00 00    	add    $0x9ef0,%edi
  100522:	ee                   	out    %al,(%dx)
  100523:	bb a1 00 00 00       	mov    $0xa1,%ebx
  100528:	89 da                	mov    %ebx,%edx
  10052a:	ee                   	out    %al,(%dx)
  10052b:	b1 11                	mov    $0x11,%cl
  10052d:	ba 20 00 00 00       	mov    $0x20,%edx
  100532:	88 c8                	mov    %cl,%al
  100534:	ee                   	out    %al,(%dx)
  100535:	b0 20                	mov    $0x20,%al
  100537:	89 f2                	mov    %esi,%edx
  100539:	ee                   	out    %al,(%dx)
  10053a:	b0 04                	mov    $0x4,%al
  10053c:	ee                   	out    %al,(%dx)
  10053d:	b0 01                	mov    $0x1,%al
  10053f:	ee                   	out    %al,(%dx)
  100540:	ba a0 00 00 00       	mov    $0xa0,%edx
  100545:	88 c8                	mov    %cl,%al
  100547:	ee                   	out    %al,(%dx)
  100548:	b0 70                	mov    $0x70,%al
  10054a:	89 da                	mov    %ebx,%edx
  10054c:	ee                   	out    %al,(%dx)
  10054d:	b0 04                	mov    $0x4,%al
  10054f:	ee                   	out    %al,(%dx)
  100550:	b0 01                	mov    $0x1,%al
  100552:	ee                   	out    %al,(%dx)
    outb(ICW1_ICW4, IO1_8259PIC2);                  // ICW1: edge-tri / cascade
    outb(0x70, IO2_8259PIC2);                       // ICW2: set first vectors of interrupt
    outb(0x04, IO2_8259PIC2);                       // ICW3: second chip is link to IR2 of first chip
    outb(0x01, IO2_8259PIC2);                       // ICW4; normal EOI

    didInit = true;                                 // 
  100553:	c7 c0 20 ac 10 00    	mov    $0x10ac20,%eax
  100559:	c6 00 01             	movb   $0x1,(%eax)
}
  10055c:	5b                   	pop    %ebx
  10055d:	5e                   	pop    %esi
  10055e:	5f                   	pop    %edi
  10055f:	5d                   	pop    %ebp
  100560:	c3                   	ret    
  100561:	90                   	nop

00100562 <_ZN3PIC9enableIRQEj>:

void PIC::enableIRQ(uint32_t irq) {                 // enable irq
  100562:	e8 58 00 00 00       	call   1005bf <__x86.get_pc_thunk.dx>
  100567:	81 c2 a5 9e 00 00    	add    $0x9ea5,%edx
    irqMask &= ~(1 << irq);
  10056d:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
void PIC::enableIRQ(uint32_t irq) {                 // enable irq
  100572:	55                   	push   %ebp
  100573:	89 e5                	mov    %esp,%ebp
    irqMask &= ~(1 << irq);
  100575:	8b 4d 0c             	mov    0xc(%ebp),%ecx
void PIC::enableIRQ(uint32_t irq) {                 // enable irq
  100578:	53                   	push   %ebx
    irqMask &= ~(1 << irq);
  100579:	c7 c3 00 a0 10 00    	mov    $0x10a000,%ebx
  10057f:	d3 c0                	rol    %cl,%eax
    if (didInit) {
  100581:	c7 c2 20 ac 10 00    	mov    $0x10ac20,%edx
    irqMask &= ~(1 << irq);
  100587:	66 8b 0b             	mov    (%ebx),%cx
  10058a:	21 c8                	and    %ecx,%eax
    if (didInit) {
  10058c:	80 3a 00             	cmpb   $0x0,(%edx)
    irqMask &= ~(1 << irq);
  10058f:	98                   	cwtl   
  100590:	0f b7 c8             	movzwl %ax,%ecx
  100593:	66 89 0b             	mov    %cx,(%ebx)
    if (didInit) {
  100596:	74 11                	je     1005a9 <_ZN3PIC9enableIRQEj+0x47>
  100598:	ba 21 00 00 00       	mov    $0x21,%edx
  10059d:	ee                   	out    %al,(%dx)
        outb(irqMask & 0xFF, IO2_8259PIC1);         // master chip
        outb((irqMask >> 8) & 0xFF, IO2_8259PIC2);  // slave chip
  10059e:	89 c8                	mov    %ecx,%eax
  1005a0:	ba a1 00 00 00       	mov    $0xa1,%edx
  1005a5:	c1 e8 08             	shr    $0x8,%eax
  1005a8:	ee                   	out    %al,(%dx)
    }
}
  1005a9:	5b                   	pop    %ebx
  1005aa:	5d                   	pop    %ebp
  1005ab:	c3                   	ret    

001005ac <_ZN3PIC7sendEOIEv>:

void PIC::sendEOI() {
  1005ac:	55                   	push   %ebp
  1005ad:	b0 20                	mov    $0x20,%al
  1005af:	89 e5                	mov    %esp,%ebp
  1005b1:	ba a0 00 00 00       	mov    $0xa0,%edx
  1005b6:	ee                   	out    %al,(%dx)
  1005b7:	ba 20 00 00 00       	mov    $0x20,%edx
  1005bc:	ee                   	out    %al,(%dx)
    outb(EOI_CMD, IO1_8259PIC2);                    // send EOI cmd for slave
    outb(EOI_CMD, IO1_8259PIC1);                    // send EOI cmd for master
  1005bd:	5d                   	pop    %ebp
  1005be:	c3                   	ret    

001005bf <__x86.get_pc_thunk.dx>:
  1005bf:	8b 14 24             	mov    (%esp),%edx
  1005c2:	c3                   	ret    

001005c3 <__x86.get_pc_thunk.di>:
  1005c3:	8b 3c 24             	mov    (%esp),%edi
  1005c6:	c3                   	ret    
  1005c7:	90                   	nop

001005c8 <_ZN3RTC12clInteStatusEv>:
    outb(regA, RTC_DATA_PORT1);                     // write A

    clInteStatus();                                 // clear Interrupt status
}

void RTC::clInteStatus() {
  1005c8:	55                   	push   %ebp
  1005c9:	b0 0c                	mov    $0xc,%al
  1005cb:	89 e5                	mov    %esp,%ebp
  1005cd:	ba 70 00 00 00       	mov    $0x70,%edx
  1005d2:	ee                   	out    %al,(%dx)
     asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  1005d3:	ba 71 00 00 00       	mov    $0x71,%edx
  1005d8:	ec                   	in     (%dx),%al
    outb(RTC_REG_C, RTC_INDEX_PORT1);               // choice reg C
    inb(RTC_DATA_PORT1);                            // read regC to clear interrupt status
  1005d9:	5d                   	pop    %ebp
  1005da:	c3                   	ret    
  1005db:	90                   	nop

001005dc <_ZN3RTC9initClockEv>:
void RTC::initClock() {
  1005dc:	55                   	push   %ebp
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  1005dd:	b0 8b                	mov    $0x8b,%al
  1005df:	89 e5                	mov    %esp,%ebp
  1005e1:	53                   	push   %ebx
  1005e2:	bb 70 00 00 00       	mov    $0x70,%ebx
  1005e7:	89 da                	mov    %ebx,%edx
  1005e9:	ee                   	out    %al,(%dx)
  1005ea:	b9 71 00 00 00       	mov    $0x71,%ecx
  1005ef:	b0 42                	mov    $0x42,%al
  1005f1:	89 ca                	mov    %ecx,%edx
  1005f3:	ee                   	out    %al,(%dx)
  1005f4:	b0 0a                	mov    $0xa,%al
  1005f6:	89 da                	mov    %ebx,%edx
  1005f8:	ee                   	out    %al,(%dx)
     asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  1005f9:	89 ca                	mov    %ecx,%edx
  1005fb:	ec                   	in     (%dx),%al
    regA = (regA & 0xF0) | 0x2;                     // 7.8125ms
  1005fc:	24 f0                	and    $0xf0,%al
  1005fe:	0c 02                	or     $0x2,%al
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100600:	ee                   	out    %al,(%dx)
}
  100601:	5b                   	pop    %ebx
  100602:	5d                   	pop    %ebp
    clInteStatus();                                 // clear Interrupt status
  100603:	eb c3                	jmp    1005c8 <_ZN3RTC12clInteStatusEv>
  100605:	90                   	nop

00100606 <_ZN11VideoMemoryC1Ev>:
#include <vdieomemory.h>

VideoMemory::VideoMemory() {
  100606:	55                   	push   %ebp
  100607:	89 e5                	mov    %esp,%ebp
  100609:	8b 45 08             	mov    0x8(%ebp),%eax
  10060c:	c7 00 00 80 0b 00    	movl   $0xb8000,(%eax)
  100612:	66 c7 40 04 a0 0f    	movw   $0xfa0,0x4(%eax)

}
  100618:	5d                   	pop    %ebp
  100619:	c3                   	ret    

0010061a <_ZN11VideoMemory10initVmBuffEv>:

void VideoMemory::initVmBuff() {
  10061a:	55                   	push   %ebp
    for (uint32_t i = 0; i < VGA_BUFF_SIZE; i++) {
  10061b:	31 c0                	xor    %eax,%eax
void VideoMemory::initVmBuff() {
  10061d:	89 e5                	mov    %esp,%ebp
  10061f:	8b 4d 08             	mov    0x8(%ebp),%ecx
        vmBuffer[i] = 0;
  100622:	8b 11                	mov    (%ecx),%edx
  100624:	c6 04 02 00          	movb   $0x0,(%edx,%eax,1)
    for (uint32_t i = 0; i < VGA_BUFF_SIZE; i++) {
  100628:	40                   	inc    %eax
  100629:	3d a0 0f 00 00       	cmp    $0xfa0,%eax
  10062e:	75 f2                	jne    100622 <_ZN11VideoMemory10initVmBuffEv+0x8>
    }
}
  100630:	5d                   	pop    %ebp
  100631:	c3                   	ret    

00100632 <_ZN11VideoMemory12getCursorPosEv>:

uint16_t VideoMemory::getCursorPos() {
  100632:	55                   	push   %ebp
  100633:	b0 0f                	mov    $0xf,%al
  100635:	89 e5                	mov    %esp,%ebp
  100637:	56                   	push   %esi
  100638:	be d4 03 00 00       	mov    $0x3d4,%esi
  10063d:	53                   	push   %ebx
  10063e:	89 f2                	mov    %esi,%edx
  100640:	ee                   	out    %al,(%dx)
     asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100641:	bb d5 03 00 00       	mov    $0x3d5,%ebx
  100646:	89 da                	mov    %ebx,%edx
  100648:	ec                   	in     (%dx),%al
  100649:	0f b6 c8             	movzbl %al,%ecx
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  10064c:	89 f2                	mov    %esi,%edx
  10064e:	b0 0e                	mov    $0xe,%al
  100650:	ee                   	out    %al,(%dx)
     asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100651:	89 da                	mov    %ebx,%edx
  100653:	ec                   	in     (%dx),%al
    outb(VGA_CURSOR_PORT_D, VGA_INDEX_PORT);
    uint8_t low = inb(VGA_DATA_PORT);
    outb(VGA_CURSOR_PORT_H, VGA_INDEX_PORT);
    uint16_t pos = inb(VGA_DATA_PORT);
    return (pos << 8) + low;
}
  100654:	5b                   	pop    %ebx
    uint16_t pos = inb(VGA_DATA_PORT);
  100655:	0f b6 c0             	movzbl %al,%eax
    return (pos << 8) + low;
  100658:	c1 e0 08             	shl    $0x8,%eax
}
  10065b:	5e                   	pop    %esi
    return (pos << 8) + low;
  10065c:	01 c8                	add    %ecx,%eax
}
  10065e:	5d                   	pop    %ebp
  10065f:	c3                   	ret    

00100660 <_ZN11VideoMemory12setCursorPosEt>:

void VideoMemory::setCursorPos(uint16_t pos) {
  100660:	55                   	push   %ebp
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100661:	b0 0f                	mov    $0xf,%al
  100663:	89 e5                	mov    %esp,%ebp
  100665:	56                   	push   %esi
  100666:	be d4 03 00 00       	mov    $0x3d4,%esi
  10066b:	0f b7 4d 0c          	movzwl 0xc(%ebp),%ecx
  10066f:	53                   	push   %ebx
  100670:	89 f2                	mov    %esi,%edx
  100672:	ee                   	out    %al,(%dx)
  100673:	bb d5 03 00 00       	mov    $0x3d5,%ebx
  100678:	88 c8                	mov    %cl,%al
  10067a:	89 da                	mov    %ebx,%edx
  10067c:	ee                   	out    %al,(%dx)
  10067d:	b0 0e                	mov    $0xe,%al
  10067f:	89 f2                	mov    %esi,%edx
  100681:	ee                   	out    %al,(%dx)
    outb(VGA_CURSOR_PORT_D, VGA_INDEX_PORT);
    outb((pos & 0xFF), VGA_DATA_PORT);
    outb(VGA_CURSOR_PORT_H, VGA_INDEX_PORT);
    outb(((pos >> 8) & 0xFF), VGA_DATA_PORT);
  100682:	89 c8                	mov    %ecx,%eax
  100684:	89 da                	mov    %ebx,%edx
  100686:	c1 e8 08             	shr    $0x8,%eax
  100689:	ee                   	out    %al,(%dx)
  10068a:	5b                   	pop    %ebx
  10068b:	5e                   	pop    %esi
  10068c:	5d                   	pop    %ebp
  10068d:	c3                   	ret    

0010068e <_ZN7OStreamC1E6StringS0_>:
 * @Last Modified time: 2020-03-25 22:00:55
 */

#include <ostream.h>

OStream::OStream(String str, String col = "white") {
  10068e:	55                   	push   %ebp
  10068f:	89 e5                	mov    %esp,%ebp
  100691:	57                   	push   %edi
  100692:	56                   	push   %esi
  100693:	53                   	push   %ebx
  100694:	83 ec 28             	sub    $0x28,%esp
  100697:	e8 c9 f9 ff ff       	call   100065 <__x86.get_pc_thunk.bx>
  10069c:	81 c3 70 9d 00 00    	add    $0x9d70,%ebx
  1006a2:	8b 75 08             	mov    0x8(%ebp),%esi
  1006a5:	8b 7d 10             	mov    0x10(%ebp),%edi
  1006a8:	56                   	push   %esi
  1006a9:	e8 bc f9 ff ff       	call   10006a <_ZN7ConsoleC1Ev>
    cons.setColor(col);
  1006ae:	8b 07                	mov    (%edi),%eax
OStream::OStream(String str, String col = "white") {
  1006b0:	c7 86 44 02 00 00 00 	movl   $0x200,0x244(%esi)
  1006b7:	02 00 00 
    cons.setColor(col);
  1006ba:	5a                   	pop    %edx
  1006bb:	59                   	pop    %ecx
  1006bc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  1006bf:	8b 47 04             	mov    0x4(%edi),%eax
  1006c2:	8d 7d e0             	lea    -0x20(%ebp),%edi
  1006c5:	57                   	push   %edi
  1006c6:	56                   	push   %esi
  1006c7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1006ca:	e8 7f fa ff ff       	call   10014e <_ZN7Console8setColorE6String>
  1006cf:	89 3c 24             	mov    %edi,(%esp)
  1006d2:	e8 f1 02 00 00       	call   1009c8 <_ZN6StringD1Ev>
    buffPointer = 0;
  1006d7:	c7 86 40 02 00 00 00 	movl   $0x0,0x240(%esi)
  1006de:	00 00 00 
  1006e1:	83 c4 10             	add    $0x10,%esp
    for (; buffPointer < str.getLength(); buffPointer++) {
  1006e4:	8b be 40 02 00 00    	mov    0x240(%esi),%edi
  1006ea:	83 ec 0c             	sub    $0xc,%esp
  1006ed:	ff 75 0c             	pushl  0xc(%ebp)
  1006f0:	e8 19 03 00 00       	call   100a0e <_ZNK6String9getLengthEv>
  1006f5:	83 c4 10             	add    $0x10,%esp
  1006f8:	0f b6 c0             	movzbl %al,%eax
  1006fb:	39 c7                	cmp    %eax,%edi
  1006fd:	73 25                	jae    100724 <_ZN7OStreamC1E6StringS0_+0x96>
        buffer[buffPointer] = str[buffPointer];
  1006ff:	50                   	push   %eax
  100700:	50                   	push   %eax
  100701:	ff b6 40 02 00 00    	pushl  0x240(%esi)
  100707:	ff 75 0c             	pushl  0xc(%ebp)
  10070a:	e8 45 03 00 00       	call   100a54 <_ZN6StringixEj>
  10070f:	8b 8e 40 02 00 00    	mov    0x240(%esi),%ecx
  100715:	8a 00                	mov    (%eax),%al
  100717:	88 44 0e 40          	mov    %al,0x40(%esi,%ecx,1)
    for (; buffPointer < str.getLength(); buffPointer++) {
  10071b:	41                   	inc    %ecx
  10071c:	89 8e 40 02 00 00    	mov    %ecx,0x240(%esi)
  100722:	eb bd                	jmp    1006e1 <_ZN7OStreamC1E6StringS0_+0x53>
    }
}
  100724:	8d 65 f4             	lea    -0xc(%ebp),%esp
  100727:	5b                   	pop    %ebx
  100728:	5e                   	pop    %esi
  100729:	5f                   	pop    %edi
  10072a:	5d                   	pop    %ebp
  10072b:	c3                   	ret    

0010072c <_ZN7OStream5flushEv>:

OStream::~OStream() {
    flush();
}

void OStream::flush() {
  10072c:	55                   	push   %ebp
  10072d:	89 e5                	mov    %esp,%ebp
  10072f:	56                   	push   %esi
  100730:	53                   	push   %ebx
  100731:	83 ec 14             	sub    $0x14,%esp
  100734:	8b 75 08             	mov    0x8(%ebp),%esi
  100737:	e8 29 f9 ff ff       	call   100065 <__x86.get_pc_thunk.bx>
  10073c:	81 c3 d0 9c 00 00    	add    $0x9cd0,%ebx
    cons.wirte(buffer, buffPointer);
  100742:	8b 86 40 02 00 00    	mov    0x240(%esi),%eax
  100748:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
  10074c:	8d 45 f6             	lea    -0xa(%ebp),%eax
  10074f:	50                   	push   %eax
  100750:	8d 46 40             	lea    0x40(%esi),%eax
  100753:	50                   	push   %eax
  100754:	56                   	push   %esi
  100755:	e8 ae fc ff ff       	call   100408 <_ZN7Console5wirteEPcRKt>
    buffPointer = 0;
}
  10075a:	83 c4 10             	add    $0x10,%esp
    buffPointer = 0;
  10075d:	c7 86 40 02 00 00 00 	movl   $0x0,0x240(%esi)
  100764:	00 00 00 
}
  100767:	8d 65 f8             	lea    -0x8(%ebp),%esp
  10076a:	5b                   	pop    %ebx
  10076b:	5e                   	pop    %esi
  10076c:	5d                   	pop    %ebp
  10076d:	c3                   	ret    

0010076e <_ZN7OStreamD1Ev>:
OStream::~OStream() {
  10076e:	55                   	push   %ebp
  10076f:	89 e5                	mov    %esp,%ebp
  100771:	57                   	push   %edi
  100772:	56                   	push   %esi
  100773:	53                   	push   %ebx
  100774:	83 ec 18             	sub    $0x18,%esp
  100777:	8b 75 08             	mov    0x8(%ebp),%esi
  10077a:	e8 e6 f8 ff ff       	call   100065 <__x86.get_pc_thunk.bx>
  10077f:	81 c3 8d 9c 00 00    	add    $0x9c8d,%ebx
    flush();
  100785:	56                   	push   %esi
  100786:	e8 a1 ff ff ff       	call   10072c <_ZN7OStream5flushEv>
#include <vdieomemory.h>
#include <string.h>

#define COLOR_NUM       4

class Console : public VideoMemory {
  10078b:	8d 7e 08             	lea    0x8(%esi),%edi
  10078e:	83 c6 28             	add    $0x28,%esi
  100791:	83 c4 10             	add    $0x10,%esp
  100794:	39 f7                	cmp    %esi,%edi
  100796:	74 0e                	je     1007a6 <_ZN7OStreamD1Ev+0x38>
  100798:	83 ee 08             	sub    $0x8,%esi
  10079b:	83 ec 0c             	sub    $0xc,%esp
  10079e:	56                   	push   %esi
  10079f:	e8 24 02 00 00       	call   1009c8 <_ZN6StringD1Ev>
  1007a4:	eb eb                	jmp    100791 <_ZN7OStreamD1Ev+0x23>
}
  1007a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  1007a9:	5b                   	pop    %ebx
  1007aa:	5e                   	pop    %esi
  1007ab:	5f                   	pop    %edi
  1007ac:	5d                   	pop    %ebp
  1007ad:	c3                   	ret    

001007ae <_ZN7OStream5writeERKc>:

void OStream::write(const char &c) {
  1007ae:	55                   	push   %ebp
  1007af:	89 e5                	mov    %esp,%ebp
  1007b1:	53                   	push   %ebx
  1007b2:	50                   	push   %eax
  1007b3:	8b 5d 08             	mov    0x8(%ebp),%ebx
    if (buffPointer + 1 > BUFFER_MAX) {
  1007b6:	8b 83 40 02 00 00    	mov    0x240(%ebx),%eax
  1007bc:	40                   	inc    %eax
  1007bd:	3b 83 44 02 00 00    	cmp    0x244(%ebx),%eax
  1007c3:	76 0c                	jbe    1007d1 <_ZN7OStream5writeERKc+0x23>
        flush();
  1007c5:	83 ec 0c             	sub    $0xc,%esp
  1007c8:	53                   	push   %ebx
  1007c9:	e8 5e ff ff ff       	call   10072c <_ZN7OStream5flushEv>
  1007ce:	83 c4 10             	add    $0x10,%esp
    }
    buffer[buffPointer++] = c;
  1007d1:	8b 83 40 02 00 00    	mov    0x240(%ebx),%eax
  1007d7:	8d 50 01             	lea    0x1(%eax),%edx
  1007da:	89 93 40 02 00 00    	mov    %edx,0x240(%ebx)
  1007e0:	8b 55 0c             	mov    0xc(%ebp),%edx
  1007e3:	8a 12                	mov    (%edx),%dl
  1007e5:	88 54 03 40          	mov    %dl,0x40(%ebx,%eax,1)
}
  1007e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  1007ec:	c9                   	leave  
  1007ed:	c3                   	ret    

001007ee <_ZN7OStream5writeEPKcRKj>:

void OStream::write(const char *arr, const uint32_t &len) {
  1007ee:	55                   	push   %ebp
  1007ef:	89 e5                	mov    %esp,%ebp
  1007f1:	53                   	push   %ebx
    for (uint32_t i = 0; i < len; i++) {
  1007f2:	31 db                	xor    %ebx,%ebx
void OStream::write(const char *arr, const uint32_t &len) {
  1007f4:	52                   	push   %edx
    for (uint32_t i = 0; i < len; i++) {
  1007f5:	8b 45 10             	mov    0x10(%ebp),%eax
  1007f8:	39 18                	cmp    %ebx,(%eax)
  1007fa:	76 16                	jbe    100812 <_ZN7OStream5writeEPKcRKj+0x24>
        write(arr[i]);
  1007fc:	50                   	push   %eax
  1007fd:	50                   	push   %eax
  1007fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  100801:	01 d8                	add    %ebx,%eax
    for (uint32_t i = 0; i < len; i++) {
  100803:	43                   	inc    %ebx
        write(arr[i]);
  100804:	50                   	push   %eax
  100805:	ff 75 08             	pushl  0x8(%ebp)
  100808:	e8 a1 ff ff ff       	call   1007ae <_ZN7OStream5writeERKc>
    for (uint32_t i = 0; i < len; i++) {
  10080d:	83 c4 10             	add    $0x10,%esp
  100810:	eb e3                	jmp    1007f5 <_ZN7OStream5writeEPKcRKj+0x7>
    }
}
  100812:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  100815:	c9                   	leave  
  100816:	c3                   	ret    
  100817:	90                   	nop

00100818 <_ZN7OStream5writeERK6String>:

void OStream::write(const String &str) {
  100818:	55                   	push   %ebp
  100819:	89 e5                	mov    %esp,%ebp
  10081b:	56                   	push   %esi
  10081c:	53                   	push   %ebx
  10081d:	83 ec 1c             	sub    $0x1c,%esp
  100820:	e8 40 f8 ff ff       	call   100065 <__x86.get_pc_thunk.bx>
  100825:	81 c3 e7 9b 00 00    	add    $0x9be7,%ebx
  10082b:	8b 75 0c             	mov    0xc(%ebp),%esi
    write(str.cStr(), str.getLength());
  10082e:	56                   	push   %esi
  10082f:	e8 da 01 00 00       	call   100a0e <_ZNK6String9getLengthEv>
  100834:	89 34 24             	mov    %esi,(%esp)
  100837:	0f b6 c0             	movzbl %al,%eax
  10083a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10083d:	e8 c2 01 00 00       	call   100a04 <_ZNK6String4cStrEv>
  100842:	83 c4 0c             	add    $0xc,%esp
  100845:	8d 55 f4             	lea    -0xc(%ebp),%edx
  100848:	52                   	push   %edx
  100849:	50                   	push   %eax
  10084a:	ff 75 08             	pushl  0x8(%ebp)
  10084d:	e8 9c ff ff ff       	call   1007ee <_ZN7OStream5writeEPKcRKj>
}
  100852:	83 c4 10             	add    $0x10,%esp
  100855:	8d 65 f8             	lea    -0x8(%ebp),%esp
  100858:	5b                   	pop    %ebx
  100859:	5e                   	pop    %esi
  10085a:	5d                   	pop    %ebp
  10085b:	c3                   	ret    

0010085c <_ZN7OStream10writeValueERKj>:

void OStream::writeValue(const uint32_t &val) {
  10085c:	55                   	push   %ebp
  10085d:	89 e5                	mov    %esp,%ebp
  10085f:	57                   	push   %edi
  100860:	56                   	push   %esi
  100861:	53                   	push   %ebx
  100862:	83 ec 3c             	sub    $0x3c,%esp
    if (val < 10) {
  100865:	8b 45 0c             	mov    0xc(%ebp),%eax
void OStream::writeValue(const uint32_t &val) {
  100868:	8b 75 08             	mov    0x8(%ebp),%esi
    if (val < 10) {
  10086b:	8b 00                	mov    (%eax),%eax
  10086d:	83 f8 09             	cmp    $0x9,%eax
  100870:	77 16                	ja     100888 <_ZN7OStream10writeValueERKj+0x2c>
        write(val + '0');
  100872:	04 30                	add    $0x30,%al
  100874:	52                   	push   %edx
  100875:	52                   	push   %edx
  100876:	88 45 c5             	mov    %al,-0x3b(%ebp)
  100879:	8d 45 c5             	lea    -0x3b(%ebp),%eax
  10087c:	50                   	push   %eax
  10087d:	56                   	push   %esi
  10087e:	e8 2b ff ff ff       	call   1007ae <_ZN7OStream5writeERKc>
  100883:	83 c4 10             	add    $0x10,%esp
  100886:	eb 30                	jmp    1008b8 <_ZN7OStream10writeValueERKj+0x5c>
  100888:	31 db                	xor    %ebx,%ebx
  10088a:	8d 7d c4             	lea    -0x3c(%ebp),%edi
    } else {
        uint8_t s[35];
        uint32_t temp = val, pos = 0;
        while (temp) {
            s[pos++] = temp % 10;
  10088d:	31 d2                	xor    %edx,%edx
  10088f:	b9 0a 00 00 00       	mov    $0xa,%ecx
  100894:	f7 f1                	div    %ecx
  100896:	43                   	inc    %ebx
        while (temp) {
  100897:	85 c0                	test   %eax,%eax
            s[pos++] = temp % 10;
  100899:	88 14 1f             	mov    %dl,(%edi,%ebx,1)
        while (temp) {
  10089c:	75 ef                	jne    10088d <_ZN7OStream10writeValueERKj+0x31>
            temp /= 10;
        }
        while (pos) {
            write(s[--pos] + '0');
  10089e:	4b                   	dec    %ebx
  10089f:	8a 44 1d c5          	mov    -0x3b(%ebp,%ebx,1),%al
  1008a3:	04 30                	add    $0x30,%al
  1008a5:	88 45 c4             	mov    %al,-0x3c(%ebp)
  1008a8:	50                   	push   %eax
  1008a9:	50                   	push   %eax
  1008aa:	57                   	push   %edi
  1008ab:	56                   	push   %esi
  1008ac:	e8 fd fe ff ff       	call   1007ae <_ZN7OStream5writeERKc>
        while (pos) {
  1008b1:	83 c4 10             	add    $0x10,%esp
  1008b4:	85 db                	test   %ebx,%ebx
  1008b6:	75 e6                	jne    10089e <_ZN7OStream10writeValueERKj+0x42>
        }
    }
  1008b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  1008bb:	5b                   	pop    %ebx
  1008bc:	5e                   	pop    %esi
  1008bd:	5f                   	pop    %edi
  1008be:	5d                   	pop    %ebp
  1008bf:	c3                   	ret    

001008c0 <_ZN3MMUC1Ev>:
#include <mmu.h>

MMU::MMU() {
  1008c0:	55                   	push   %ebp
  1008c1:	89 e5                	mov    %esp,%ebp

}
  1008c3:	5d                   	pop    %ebp
  1008c4:	c3                   	ret    
  1008c5:	90                   	nop

001008c6 <_ZN3MMU10setSegDescEjjjj>:

void MMU::setSegDesc(uint32_t type,uint32_t base, uint32_t lim, uint32_t dpl) {
  1008c6:	55                   	push   %ebp
  1008c7:	89 e5                	mov    %esp,%ebp
  1008c9:	56                   	push   %esi
  1008ca:	8b 45 08             	mov    0x8(%ebp),%eax
  1008cd:	53                   	push   %ebx
  1008ce:	8b 5d 10             	mov    0x10(%ebp),%ebx
    segdesc.sd_lim_15_0 = lim & 0xffff;
    segdesc.sd_base_15_0 = (base) & 0xffff;
    segdesc.sd_base_23_16 =((base) >> 16) & 0xff;
    segdesc.sd_type = type;
  1008d1:	8a 4d 0c             	mov    0xc(%ebp),%cl
void MMU::setSegDesc(uint32_t type,uint32_t base, uint32_t lim, uint32_t dpl) {
  1008d4:	8b 75 14             	mov    0x14(%ebp),%esi
    segdesc.sd_base_23_16 =((base) >> 16) & 0xff;
  1008d7:	89 da                	mov    %ebx,%edx
  1008d9:	c1 ea 10             	shr    $0x10,%edx
    segdesc.sd_type = type;
  1008dc:	80 e1 0f             	and    $0xf,%cl
    segdesc.sd_base_23_16 =((base) >> 16) & 0xff;
  1008df:	88 50 04             	mov    %dl,0x4(%eax)
    segdesc.sd_type = type;
  1008e2:	8a 50 05             	mov    0x5(%eax),%dl
    segdesc.sd_lim_15_0 = lim & 0xffff;
  1008e5:	66 89 30             	mov    %si,(%eax)
    segdesc.sd_s = 1;
    segdesc.sd_dpl = dpl;
    segdesc.sd_p = 1;
    segdesc.sd_lim_19_16 = (uint16_t)(lim >> 16);
  1008e8:	c1 ee 10             	shr    $0x10,%esi
    segdesc.sd_base_15_0 = (base) & 0xffff;
  1008eb:	66 89 58 02          	mov    %bx,0x2(%eax)
    segdesc.sd_avl = 0;
    segdesc.sd_l = 0;
    segdesc.sd_db = 1;
    segdesc.sd_g = 1;
    segdesc.sd_base_31_24 = (uint16_t)(base >> 24);
  1008ef:	c1 eb 18             	shr    $0x18,%ebx
  1008f2:	88 58 07             	mov    %bl,0x7(%eax)
    segdesc.sd_type = type;
  1008f5:	80 e2 f0             	and    $0xf0,%dl
  1008f8:	08 ca                	or     %cl,%dl
    segdesc.sd_dpl = dpl;
  1008fa:	8a 4d 18             	mov    0x18(%ebp),%cl
    segdesc.sd_s = 1;
  1008fd:	80 ca 10             	or     $0x10,%dl
    segdesc.sd_dpl = dpl;
  100900:	80 e2 9f             	and    $0x9f,%dl
  100903:	80 e1 03             	and    $0x3,%cl
  100906:	c0 e1 05             	shl    $0x5,%cl
  100909:	08 ca                	or     %cl,%dl
    segdesc.sd_p = 1;
  10090b:	80 ca 80             	or     $0x80,%dl
  10090e:	88 50 05             	mov    %dl,0x5(%eax)
    segdesc.sd_lim_19_16 = (uint16_t)(lim >> 16);
  100911:	89 f2                	mov    %esi,%edx
  100913:	80 e2 0f             	and    $0xf,%dl
    segdesc.sd_g = 1;
  100916:	80 ca c0             	or     $0xc0,%dl
  100919:	88 50 06             	mov    %dl,0x6(%eax)
}
  10091c:	5b                   	pop    %ebx
  10091d:	5e                   	pop    %esi
  10091e:	5d                   	pop    %ebp
  10091f:	c3                   	ret    

00100920 <_ZN3MMU11setGateDescERNS_8GateDescEjjjj>:

void MMU::setGateDesc(GateDesc &gate, uint32_t istrap, uint32_t sel, uint32_t off, uint32_t dpl) {
  100920:	55                   	push   %ebp
  100921:	89 e5                	mov    %esp,%ebp
  100923:	8b 45 08             	mov    0x8(%ebp),%eax
    gate.gd_off_15_0 = (uint32_t)(off) & 0xffff;        
    gate.gd_ss = (sel);
  100926:	8b 55 10             	mov    0x10(%ebp),%edx
    gate.gd_args = 0;                                    
    gate.gd_rsv1 = 0;                                    
    gate.gd_type = (istrap) ? STS_TG32 : STS_IG32;    
  100929:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
    gate.gd_s = 0;                                    
    gate.gd_dpl = (dpl);                               
  10092d:	8a 4d 18             	mov    0x18(%ebp),%cl
void MMU::setGateDesc(GateDesc &gate, uint32_t istrap, uint32_t sel, uint32_t off, uint32_t dpl) {
  100930:	53                   	push   %ebx
  100931:	8b 5d 14             	mov    0x14(%ebp),%ebx
    gate.gd_ss = (sel);
  100934:	66 89 50 02          	mov    %dx,0x2(%eax)
    gate.gd_type = (istrap) ? STS_TG32 : STS_IG32;    
  100938:	0f 95 c2             	setne  %dl
  10093b:	80 c2 0e             	add    $0xe,%dl
    gate.gd_dpl = (dpl);                               
  10093e:	80 e1 03             	and    $0x3,%cl
    gate.gd_type = (istrap) ? STS_TG32 : STS_IG32;    
  100941:	80 e2 0f             	and    $0xf,%dl
    gate.gd_dpl = (dpl);                               
  100944:	c0 e1 05             	shl    $0x5,%cl
  100947:	08 ca                	or     %cl,%dl
    gate.gd_off_15_0 = (uint32_t)(off) & 0xffff;        
  100949:	66 89 18             	mov    %bx,(%eax)
    gate.gd_p = 1;                                    
  10094c:	80 ca 80             	or     $0x80,%dl
    gate.gd_off_31_16 = (uint32_t)(off) >> 16;        
  10094f:	c1 eb 10             	shr    $0x10,%ebx
    gate.gd_args = 0;                                    
  100952:	c6 40 04 00          	movb   $0x0,0x4(%eax)
    gate.gd_p = 1;                                    
  100956:	88 50 05             	mov    %dl,0x5(%eax)
    gate.gd_off_31_16 = (uint32_t)(off) >> 16;        
  100959:	66 89 58 06          	mov    %bx,0x6(%eax)
}
  10095d:	5b                   	pop    %ebx
  10095e:	5d                   	pop    %ebp
  10095f:	c3                   	ret    

00100960 <_ZN3MMU11setCallGateERNS_8GateDescEjjj>:

void MMU::setCallGate(GateDesc &gate, uint32_t ss, uint32_t off, uint32_t dpl) {
  100960:	55                   	push   %ebp
  100961:	89 e5                	mov    %esp,%ebp
  100963:	8b 55 08             	mov    0x8(%ebp),%edx
    gate.gd_off_15_0 = (uint32_t)(off) & 0xffff;        
    gate.gd_ss = (ss);                                
  100966:	8b 45 0c             	mov    0xc(%ebp),%eax
void MMU::setCallGate(GateDesc &gate, uint32_t ss, uint32_t off, uint32_t dpl) {
  100969:	8b 4d 10             	mov    0x10(%ebp),%ecx
    gate.gd_args = 0;                                  
    gate.gd_rsv1 = 0;                                  
  10096c:	c6 42 04 00          	movb   $0x0,0x4(%edx)
    gate.gd_ss = (ss);                                
  100970:	66 89 42 02          	mov    %ax,0x2(%edx)
    gate.gd_type = STS_CG32;                          
    gate.gd_s = 0;                                   
    gate.gd_dpl = (dpl);                              
  100974:	8a 45 14             	mov    0x14(%ebp),%al
    gate.gd_off_15_0 = (uint32_t)(off) & 0xffff;        
  100977:	66 89 0a             	mov    %cx,(%edx)
    gate.gd_p = 1;                                  
    gate.gd_off_31_16 = (uint32_t)(off) >> 16;     
  10097a:	c1 e9 10             	shr    $0x10,%ecx
  10097d:	66 89 4a 06          	mov    %cx,0x6(%edx)
    gate.gd_dpl = (dpl);                              
  100981:	24 03                	and    $0x3,%al
  100983:	c0 e0 05             	shl    $0x5,%al
    gate.gd_p = 1;                                  
  100986:	0c 8c                	or     $0x8c,%al
  100988:	88 42 05             	mov    %al,0x5(%edx)
}
  10098b:	5d                   	pop    %ebp
  10098c:	c3                   	ret    
  10098d:	90                   	nop

0010098e <_ZN3MMU6setTCBEv>:

void MMU::setTCB() {
  10098e:	55                   	push   %ebp
  10098f:	89 e5                	mov    %esp,%ebp

  100991:	5d                   	pop    %ebp
  100992:	c3                   	ret    
  100993:	90                   	nop

00100994 <_ZN4Trap4trapEv>:
#include <trap.h>

void Trap::trap() {
  100994:	55                   	push   %ebp
  100995:	89 e5                	mov    %esp,%ebp

  100997:	5d                   	pop    %ebp
  100998:	c3                   	ret    
  100999:	90                   	nop

0010099a <_ZN6String7cStrLenEPKc>:
 * @Last Modified time: 2020-03-25 19:21:46 
 */

#include <string.h>

uint32_t String::cStrLen(ccstring cstr) {
  10099a:	55                   	push   %ebp
    uint32_t len = 0;
  10099b:	31 c0                	xor    %eax,%eax
uint32_t String::cStrLen(ccstring cstr) {
  10099d:	89 e5                	mov    %esp,%ebp
  10099f:	8b 55 0c             	mov    0xc(%ebp),%edx
    auto it = cstr;
    while(*it++ != '\0') {
  1009a2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  1009a6:	74 03                	je     1009ab <_ZN6String7cStrLenEPKc+0x11>
        len++;
  1009a8:	40                   	inc    %eax
    while(*it++ != '\0') {
  1009a9:	eb f7                	jmp    1009a2 <_ZN6String7cStrLenEPKc+0x8>
    }
    return len;
}
  1009ab:	5d                   	pop    %ebp
  1009ac:	c3                   	ret    
  1009ad:	90                   	nop

001009ae <_ZN6StringC1EPKc>:


String::String(ccstring cstr) {
  1009ae:	55                   	push   %ebp
  1009af:	89 e5                	mov    %esp,%ebp
  1009b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  1009b4:	8b 45 0c             	mov    0xc(%ebp),%eax
    str = (cstring)cstr;
  1009b7:	89 01                	mov    %eax,(%ecx)
    length = cStrLen(cstr);
  1009b9:	50                   	push   %eax
  1009ba:	51                   	push   %ecx
  1009bb:	e8 da ff ff ff       	call   10099a <_ZN6String7cStrLenEPKc>
  1009c0:	5a                   	pop    %edx
  1009c1:	5a                   	pop    %edx
  1009c2:	88 41 04             	mov    %al,0x4(%ecx)
}
  1009c5:	c9                   	leave  
  1009c6:	c3                   	ret    
  1009c7:	90                   	nop

001009c8 <_ZN6StringD1Ev>:


String::~String() {                                     //destructor
  1009c8:	55                   	push   %ebp
  1009c9:	89 e5                	mov    %esp,%ebp

}
  1009cb:	5d                   	pop    %ebp
  1009cc:	c3                   	ret    
  1009cd:	90                   	nop

001009ce <_ZN6StringaSEPKc>:


String & String::operator=(ccstring cstr) {             // copy assigment
  1009ce:	55                   	push   %ebp
  1009cf:	89 e5                	mov    %esp,%ebp
  1009d1:	56                   	push   %esi
  1009d2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  1009d5:	53                   	push   %ebx
  1009d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    length = cStrLen(cstr);
  1009d9:	53                   	push   %ebx
  1009da:	51                   	push   %ecx
  1009db:	e8 ba ff ff ff       	call   10099a <_ZN6String7cStrLenEPKc>
  1009e0:	5a                   	pop    %edx
  1009e1:	5e                   	pop    %esi
  1009e2:	88 41 04             	mov    %al,0x4(%ecx)
    //delete [] str;
    //str = new char[length];
    for (uint32_t i = 0; i < length; i++) {
  1009e5:	31 c0                	xor    %eax,%eax
  1009e7:	0f b6 51 04          	movzbl 0x4(%ecx),%edx
  1009eb:	39 c2                	cmp    %eax,%edx
  1009ed:	76 0b                	jbe    1009fa <_ZN6StringaSEPKc+0x2c>
        str[i] = cstr[i];
  1009ef:	8a 14 03             	mov    (%ebx,%eax,1),%dl
  1009f2:	8b 31                	mov    (%ecx),%esi
  1009f4:	88 14 06             	mov    %dl,(%esi,%eax,1)
    for (uint32_t i = 0; i < length; i++) {
  1009f7:	40                   	inc    %eax
  1009f8:	eb ed                	jmp    1009e7 <_ZN6StringaSEPKc+0x19>
    }
    return *this;
}
  1009fa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  1009fd:	89 c8                	mov    %ecx,%eax
  1009ff:	5b                   	pop    %ebx
  100a00:	5e                   	pop    %esi
  100a01:	5d                   	pop    %ebp
  100a02:	c3                   	ret    
  100a03:	90                   	nop

00100a04 <_ZNK6String4cStrEv>:

ccstring String::cStr() const {
  100a04:	55                   	push   %ebp
  100a05:	89 e5                	mov    %esp,%ebp
    return str;
  100a07:	8b 45 08             	mov    0x8(%ebp),%eax
}
  100a0a:	5d                   	pop    %ebp
    return str;
  100a0b:	8b 00                	mov    (%eax),%eax
}
  100a0d:	c3                   	ret    

00100a0e <_ZNK6String9getLengthEv>:

uint8_t String::getLength() const {
  100a0e:	55                   	push   %ebp
  100a0f:	89 e5                	mov    %esp,%ebp
    return length;
  100a11:	8b 45 08             	mov    0x8(%ebp),%eax
}
  100a14:	5d                   	pop    %ebp
    return length;
  100a15:	8a 40 04             	mov    0x4(%eax),%al
}
  100a18:	c3                   	ret    
  100a19:	90                   	nop

00100a1a <_ZN6StringeqERKS_>:

bool String::operator==(const String &_str) {
  100a1a:	55                   	push   %ebp
    bool isEquals = false;
  100a1b:	31 c0                	xor    %eax,%eax
bool String::operator==(const String &_str) {
  100a1d:	89 e5                	mov    %esp,%ebp
  100a1f:	57                   	push   %edi
  100a20:	8b 4d 08             	mov    0x8(%ebp),%ecx
  100a23:	56                   	push   %esi
  100a24:	53                   	push   %ebx
  100a25:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    if (_str.length == length) {
  100a28:	8a 53 04             	mov    0x4(%ebx),%dl
  100a2b:	3a 51 04             	cmp    0x4(%ecx),%dl
  100a2e:	75 1e                	jne    100a4e <_ZN6StringeqERKS_+0x34>
        for (uint32_t i = 0; i < length; i++) {
  100a30:	31 c0                	xor    %eax,%eax
  100a32:	0f b6 fa             	movzbl %dl,%edi
  100a35:	39 c7                	cmp    %eax,%edi
  100a37:	76 0f                	jbe    100a48 <_ZN6StringeqERKS_+0x2e>
            if (str[i] != (_str.str)[i]) {
  100a39:	8b 13                	mov    (%ebx),%edx
  100a3b:	8b 31                	mov    (%ecx),%esi
  100a3d:	8a 14 02             	mov    (%edx,%eax,1),%dl
  100a40:	38 14 06             	cmp    %dl,(%esi,%eax,1)
  100a43:	75 07                	jne    100a4c <_ZN6StringeqERKS_+0x32>
        for (uint32_t i = 0; i < length; i++) {
  100a45:	40                   	inc    %eax
  100a46:	eb ed                	jmp    100a35 <_ZN6StringeqERKS_+0x1b>
                return false;
            }
        }
        isEquals = true;
  100a48:	b0 01                	mov    $0x1,%al
  100a4a:	eb 02                	jmp    100a4e <_ZN6StringeqERKS_+0x34>
    bool isEquals = false;
  100a4c:	31 c0                	xor    %eax,%eax
    }
    return isEquals;
}
  100a4e:	5b                   	pop    %ebx
  100a4f:	5e                   	pop    %esi
  100a50:	5f                   	pop    %edi
  100a51:	5d                   	pop    %ebp
  100a52:	c3                   	ret    
  100a53:	90                   	nop

00100a54 <_ZN6StringixEj>:

// index accessor
char & String::operator[](const uint32_t index) {
  100a54:	55                   	push   %ebp
  100a55:	89 e5                	mov    %esp,%ebp
    return str[index];
  100a57:	8b 45 08             	mov    0x8(%ebp),%eax
  100a5a:	8b 00                	mov    (%eax),%eax
  100a5c:	03 45 0c             	add    0xc(%ebp),%eax
}
  100a5f:	5d                   	pop    %ebp
  100a60:	c3                   	ret    

00100a61 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
  100a61:	1e                   	push   %ds
    pushl %es
  100a62:	06                   	push   %es
    pushl %fs
  100a63:	0f a0                	push   %fs
    pushl %gs
  100a65:	0f a8                	push   %gs
    pushal
  100a67:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
  100a68:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
  100a6d:	8e d8                	mov    %eax,%ds
    movw %ax, %es
  100a6f:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
  100a71:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call _ZN4Trap4trapEv
  100a72:	e8 1d ff ff ff       	call   100994 <_ZN4Trap4trapEv>

    # pop the pushed stack pointer
    popl %esp
  100a77:	5c                   	pop    %esp

00100a78 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
  100a78:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
  100a79:	0f a9                	pop    %gs
    popl %fs
  100a7b:	0f a1                	pop    %fs
    popl %es
  100a7d:	07                   	pop    %es
    popl %ds
  100a7e:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
  100a7f:	83 c4 08             	add    $0x8,%esp
    iret
  100a82:	cf                   	iret   

00100a83 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
  100a83:	6a 00                	push   $0x0
  pushl $0
  100a85:	6a 00                	push   $0x0
  jmp __alltraps
  100a87:	e9 d5 ff ff ff       	jmp    100a61 <__alltraps>

00100a8c <vector1>:
.globl vector1
vector1:
  pushl $0
  100a8c:	6a 00                	push   $0x0
  pushl $1
  100a8e:	6a 01                	push   $0x1
  jmp __alltraps
  100a90:	e9 cc ff ff ff       	jmp    100a61 <__alltraps>

00100a95 <vector2>:
.globl vector2
vector2:
  pushl $0
  100a95:	6a 00                	push   $0x0
  pushl $2
  100a97:	6a 02                	push   $0x2
  jmp __alltraps
  100a99:	e9 c3 ff ff ff       	jmp    100a61 <__alltraps>

00100a9e <vector3>:
.globl vector3
vector3:
  pushl $0
  100a9e:	6a 00                	push   $0x0
  pushl $3
  100aa0:	6a 03                	push   $0x3
  jmp __alltraps
  100aa2:	e9 ba ff ff ff       	jmp    100a61 <__alltraps>

00100aa7 <vector4>:
.globl vector4
vector4:
  pushl $0
  100aa7:	6a 00                	push   $0x0
  pushl $4
  100aa9:	6a 04                	push   $0x4
  jmp __alltraps
  100aab:	e9 b1 ff ff ff       	jmp    100a61 <__alltraps>

00100ab0 <vector5>:
.globl vector5
vector5:
  pushl $0
  100ab0:	6a 00                	push   $0x0
  pushl $5
  100ab2:	6a 05                	push   $0x5
  jmp __alltraps
  100ab4:	e9 a8 ff ff ff       	jmp    100a61 <__alltraps>

00100ab9 <vector6>:
.globl vector6
vector6:
  pushl $0
  100ab9:	6a 00                	push   $0x0
  pushl $6
  100abb:	6a 06                	push   $0x6
  jmp __alltraps
  100abd:	e9 9f ff ff ff       	jmp    100a61 <__alltraps>

00100ac2 <vector7>:
.globl vector7
vector7:
  pushl $0
  100ac2:	6a 00                	push   $0x0
  pushl $7
  100ac4:	6a 07                	push   $0x7
  jmp __alltraps
  100ac6:	e9 96 ff ff ff       	jmp    100a61 <__alltraps>

00100acb <vector8>:
.globl vector8
vector8:
  pushl $8
  100acb:	6a 08                	push   $0x8
  jmp __alltraps
  100acd:	e9 8f ff ff ff       	jmp    100a61 <__alltraps>

00100ad2 <vector9>:
.globl vector9
vector9:
  pushl $9
  100ad2:	6a 09                	push   $0x9
  jmp __alltraps
  100ad4:	e9 88 ff ff ff       	jmp    100a61 <__alltraps>

00100ad9 <vector10>:
.globl vector10
vector10:
  pushl $10
  100ad9:	6a 0a                	push   $0xa
  jmp __alltraps
  100adb:	e9 81 ff ff ff       	jmp    100a61 <__alltraps>

00100ae0 <vector11>:
.globl vector11
vector11:
  pushl $11
  100ae0:	6a 0b                	push   $0xb
  jmp __alltraps
  100ae2:	e9 7a ff ff ff       	jmp    100a61 <__alltraps>

00100ae7 <vector12>:
.globl vector12
vector12:
  pushl $12
  100ae7:	6a 0c                	push   $0xc
  jmp __alltraps
  100ae9:	e9 73 ff ff ff       	jmp    100a61 <__alltraps>

00100aee <vector13>:
.globl vector13
vector13:
  pushl $13
  100aee:	6a 0d                	push   $0xd
  jmp __alltraps
  100af0:	e9 6c ff ff ff       	jmp    100a61 <__alltraps>

00100af5 <vector14>:
.globl vector14
vector14:
  pushl $14
  100af5:	6a 0e                	push   $0xe
  jmp __alltraps
  100af7:	e9 65 ff ff ff       	jmp    100a61 <__alltraps>

00100afc <vector15>:
.globl vector15
vector15:
  pushl $0
  100afc:	6a 00                	push   $0x0
  pushl $15
  100afe:	6a 0f                	push   $0xf
  jmp __alltraps
  100b00:	e9 5c ff ff ff       	jmp    100a61 <__alltraps>

00100b05 <vector16>:
.globl vector16
vector16:
  pushl $0
  100b05:	6a 00                	push   $0x0
  pushl $16
  100b07:	6a 10                	push   $0x10
  jmp __alltraps
  100b09:	e9 53 ff ff ff       	jmp    100a61 <__alltraps>

00100b0e <vector17>:
.globl vector17
vector17:
  pushl $17
  100b0e:	6a 11                	push   $0x11
  jmp __alltraps
  100b10:	e9 4c ff ff ff       	jmp    100a61 <__alltraps>

00100b15 <vector18>:
.globl vector18
vector18:
  pushl $0
  100b15:	6a 00                	push   $0x0
  pushl $18
  100b17:	6a 12                	push   $0x12
  jmp __alltraps
  100b19:	e9 43 ff ff ff       	jmp    100a61 <__alltraps>

00100b1e <vector19>:
.globl vector19
vector19:
  pushl $0
  100b1e:	6a 00                	push   $0x0
  pushl $19
  100b20:	6a 13                	push   $0x13
  jmp __alltraps
  100b22:	e9 3a ff ff ff       	jmp    100a61 <__alltraps>

00100b27 <vector20>:
.globl vector20
vector20:
  pushl $0
  100b27:	6a 00                	push   $0x0
  pushl $20
  100b29:	6a 14                	push   $0x14
  jmp __alltraps
  100b2b:	e9 31 ff ff ff       	jmp    100a61 <__alltraps>

00100b30 <vector21>:
.globl vector21
vector21:
  pushl $0
  100b30:	6a 00                	push   $0x0
  pushl $21
  100b32:	6a 15                	push   $0x15
  jmp __alltraps
  100b34:	e9 28 ff ff ff       	jmp    100a61 <__alltraps>

00100b39 <vector22>:
.globl vector22
vector22:
  pushl $0
  100b39:	6a 00                	push   $0x0
  pushl $22
  100b3b:	6a 16                	push   $0x16
  jmp __alltraps
  100b3d:	e9 1f ff ff ff       	jmp    100a61 <__alltraps>

00100b42 <vector23>:
.globl vector23
vector23:
  pushl $0
  100b42:	6a 00                	push   $0x0
  pushl $23
  100b44:	6a 17                	push   $0x17
  jmp __alltraps
  100b46:	e9 16 ff ff ff       	jmp    100a61 <__alltraps>

00100b4b <vector24>:
.globl vector24
vector24:
  pushl $0
  100b4b:	6a 00                	push   $0x0
  pushl $24
  100b4d:	6a 18                	push   $0x18
  jmp __alltraps
  100b4f:	e9 0d ff ff ff       	jmp    100a61 <__alltraps>

00100b54 <vector25>:
.globl vector25
vector25:
  pushl $0
  100b54:	6a 00                	push   $0x0
  pushl $25
  100b56:	6a 19                	push   $0x19
  jmp __alltraps
  100b58:	e9 04 ff ff ff       	jmp    100a61 <__alltraps>

00100b5d <vector26>:
.globl vector26
vector26:
  pushl $0
  100b5d:	6a 00                	push   $0x0
  pushl $26
  100b5f:	6a 1a                	push   $0x1a
  jmp __alltraps
  100b61:	e9 fb fe ff ff       	jmp    100a61 <__alltraps>

00100b66 <vector27>:
.globl vector27
vector27:
  pushl $0
  100b66:	6a 00                	push   $0x0
  pushl $27
  100b68:	6a 1b                	push   $0x1b
  jmp __alltraps
  100b6a:	e9 f2 fe ff ff       	jmp    100a61 <__alltraps>

00100b6f <vector28>:
.globl vector28
vector28:
  pushl $0
  100b6f:	6a 00                	push   $0x0
  pushl $28
  100b71:	6a 1c                	push   $0x1c
  jmp __alltraps
  100b73:	e9 e9 fe ff ff       	jmp    100a61 <__alltraps>

00100b78 <vector29>:
.globl vector29
vector29:
  pushl $0
  100b78:	6a 00                	push   $0x0
  pushl $29
  100b7a:	6a 1d                	push   $0x1d
  jmp __alltraps
  100b7c:	e9 e0 fe ff ff       	jmp    100a61 <__alltraps>

00100b81 <vector30>:
.globl vector30
vector30:
  pushl $0
  100b81:	6a 00                	push   $0x0
  pushl $30
  100b83:	6a 1e                	push   $0x1e
  jmp __alltraps
  100b85:	e9 d7 fe ff ff       	jmp    100a61 <__alltraps>

00100b8a <vector31>:
.globl vector31
vector31:
  pushl $0
  100b8a:	6a 00                	push   $0x0
  pushl $31
  100b8c:	6a 1f                	push   $0x1f
  jmp __alltraps
  100b8e:	e9 ce fe ff ff       	jmp    100a61 <__alltraps>

00100b93 <vector32>:
.globl vector32
vector32:
  pushl $0
  100b93:	6a 00                	push   $0x0
  pushl $32
  100b95:	6a 20                	push   $0x20
  jmp __alltraps
  100b97:	e9 c5 fe ff ff       	jmp    100a61 <__alltraps>

00100b9c <vector33>:
.globl vector33
vector33:
  pushl $0
  100b9c:	6a 00                	push   $0x0
  pushl $33
  100b9e:	6a 21                	push   $0x21
  jmp __alltraps
  100ba0:	e9 bc fe ff ff       	jmp    100a61 <__alltraps>

00100ba5 <vector34>:
.globl vector34
vector34:
  pushl $0
  100ba5:	6a 00                	push   $0x0
  pushl $34
  100ba7:	6a 22                	push   $0x22
  jmp __alltraps
  100ba9:	e9 b3 fe ff ff       	jmp    100a61 <__alltraps>

00100bae <vector35>:
.globl vector35
vector35:
  pushl $0
  100bae:	6a 00                	push   $0x0
  pushl $35
  100bb0:	6a 23                	push   $0x23
  jmp __alltraps
  100bb2:	e9 aa fe ff ff       	jmp    100a61 <__alltraps>

00100bb7 <vector36>:
.globl vector36
vector36:
  pushl $0
  100bb7:	6a 00                	push   $0x0
  pushl $36
  100bb9:	6a 24                	push   $0x24
  jmp __alltraps
  100bbb:	e9 a1 fe ff ff       	jmp    100a61 <__alltraps>

00100bc0 <vector37>:
.globl vector37
vector37:
  pushl $0
  100bc0:	6a 00                	push   $0x0
  pushl $37
  100bc2:	6a 25                	push   $0x25
  jmp __alltraps
  100bc4:	e9 98 fe ff ff       	jmp    100a61 <__alltraps>

00100bc9 <vector38>:
.globl vector38
vector38:
  pushl $0
  100bc9:	6a 00                	push   $0x0
  pushl $38
  100bcb:	6a 26                	push   $0x26
  jmp __alltraps
  100bcd:	e9 8f fe ff ff       	jmp    100a61 <__alltraps>

00100bd2 <vector39>:
.globl vector39
vector39:
  pushl $0
  100bd2:	6a 00                	push   $0x0
  pushl $39
  100bd4:	6a 27                	push   $0x27
  jmp __alltraps
  100bd6:	e9 86 fe ff ff       	jmp    100a61 <__alltraps>

00100bdb <vector40>:
.globl vector40
vector40:
  pushl $0
  100bdb:	6a 00                	push   $0x0
  pushl $40
  100bdd:	6a 28                	push   $0x28
  jmp __alltraps
  100bdf:	e9 7d fe ff ff       	jmp    100a61 <__alltraps>

00100be4 <vector41>:
.globl vector41
vector41:
  pushl $0
  100be4:	6a 00                	push   $0x0
  pushl $41
  100be6:	6a 29                	push   $0x29
  jmp __alltraps
  100be8:	e9 74 fe ff ff       	jmp    100a61 <__alltraps>

00100bed <vector42>:
.globl vector42
vector42:
  pushl $0
  100bed:	6a 00                	push   $0x0
  pushl $42
  100bef:	6a 2a                	push   $0x2a
  jmp __alltraps
  100bf1:	e9 6b fe ff ff       	jmp    100a61 <__alltraps>

00100bf6 <vector43>:
.globl vector43
vector43:
  pushl $0
  100bf6:	6a 00                	push   $0x0
  pushl $43
  100bf8:	6a 2b                	push   $0x2b
  jmp __alltraps
  100bfa:	e9 62 fe ff ff       	jmp    100a61 <__alltraps>

00100bff <vector44>:
.globl vector44
vector44:
  pushl $0
  100bff:	6a 00                	push   $0x0
  pushl $44
  100c01:	6a 2c                	push   $0x2c
  jmp __alltraps
  100c03:	e9 59 fe ff ff       	jmp    100a61 <__alltraps>

00100c08 <vector45>:
.globl vector45
vector45:
  pushl $0
  100c08:	6a 00                	push   $0x0
  pushl $45
  100c0a:	6a 2d                	push   $0x2d
  jmp __alltraps
  100c0c:	e9 50 fe ff ff       	jmp    100a61 <__alltraps>

00100c11 <vector46>:
.globl vector46
vector46:
  pushl $0
  100c11:	6a 00                	push   $0x0
  pushl $46
  100c13:	6a 2e                	push   $0x2e
  jmp __alltraps
  100c15:	e9 47 fe ff ff       	jmp    100a61 <__alltraps>

00100c1a <vector47>:
.globl vector47
vector47:
  pushl $0
  100c1a:	6a 00                	push   $0x0
  pushl $47
  100c1c:	6a 2f                	push   $0x2f
  jmp __alltraps
  100c1e:	e9 3e fe ff ff       	jmp    100a61 <__alltraps>

00100c23 <vector48>:
.globl vector48
vector48:
  pushl $0
  100c23:	6a 00                	push   $0x0
  pushl $48
  100c25:	6a 30                	push   $0x30
  jmp __alltraps
  100c27:	e9 35 fe ff ff       	jmp    100a61 <__alltraps>

00100c2c <vector49>:
.globl vector49
vector49:
  pushl $0
  100c2c:	6a 00                	push   $0x0
  pushl $49
  100c2e:	6a 31                	push   $0x31
  jmp __alltraps
  100c30:	e9 2c fe ff ff       	jmp    100a61 <__alltraps>

00100c35 <vector50>:
.globl vector50
vector50:
  pushl $0
  100c35:	6a 00                	push   $0x0
  pushl $50
  100c37:	6a 32                	push   $0x32
  jmp __alltraps
  100c39:	e9 23 fe ff ff       	jmp    100a61 <__alltraps>

00100c3e <vector51>:
.globl vector51
vector51:
  pushl $0
  100c3e:	6a 00                	push   $0x0
  pushl $51
  100c40:	6a 33                	push   $0x33
  jmp __alltraps
  100c42:	e9 1a fe ff ff       	jmp    100a61 <__alltraps>

00100c47 <vector52>:
.globl vector52
vector52:
  pushl $0
  100c47:	6a 00                	push   $0x0
  pushl $52
  100c49:	6a 34                	push   $0x34
  jmp __alltraps
  100c4b:	e9 11 fe ff ff       	jmp    100a61 <__alltraps>

00100c50 <vector53>:
.globl vector53
vector53:
  pushl $0
  100c50:	6a 00                	push   $0x0
  pushl $53
  100c52:	6a 35                	push   $0x35
  jmp __alltraps
  100c54:	e9 08 fe ff ff       	jmp    100a61 <__alltraps>

00100c59 <vector54>:
.globl vector54
vector54:
  pushl $0
  100c59:	6a 00                	push   $0x0
  pushl $54
  100c5b:	6a 36                	push   $0x36
  jmp __alltraps
  100c5d:	e9 ff fd ff ff       	jmp    100a61 <__alltraps>

00100c62 <vector55>:
.globl vector55
vector55:
  pushl $0
  100c62:	6a 00                	push   $0x0
  pushl $55
  100c64:	6a 37                	push   $0x37
  jmp __alltraps
  100c66:	e9 f6 fd ff ff       	jmp    100a61 <__alltraps>

00100c6b <vector56>:
.globl vector56
vector56:
  pushl $0
  100c6b:	6a 00                	push   $0x0
  pushl $56
  100c6d:	6a 38                	push   $0x38
  jmp __alltraps
  100c6f:	e9 ed fd ff ff       	jmp    100a61 <__alltraps>

00100c74 <vector57>:
.globl vector57
vector57:
  pushl $0
  100c74:	6a 00                	push   $0x0
  pushl $57
  100c76:	6a 39                	push   $0x39
  jmp __alltraps
  100c78:	e9 e4 fd ff ff       	jmp    100a61 <__alltraps>

00100c7d <vector58>:
.globl vector58
vector58:
  pushl $0
  100c7d:	6a 00                	push   $0x0
  pushl $58
  100c7f:	6a 3a                	push   $0x3a
  jmp __alltraps
  100c81:	e9 db fd ff ff       	jmp    100a61 <__alltraps>

00100c86 <vector59>:
.globl vector59
vector59:
  pushl $0
  100c86:	6a 00                	push   $0x0
  pushl $59
  100c88:	6a 3b                	push   $0x3b
  jmp __alltraps
  100c8a:	e9 d2 fd ff ff       	jmp    100a61 <__alltraps>

00100c8f <vector60>:
.globl vector60
vector60:
  pushl $0
  100c8f:	6a 00                	push   $0x0
  pushl $60
  100c91:	6a 3c                	push   $0x3c
  jmp __alltraps
  100c93:	e9 c9 fd ff ff       	jmp    100a61 <__alltraps>

00100c98 <vector61>:
.globl vector61
vector61:
  pushl $0
  100c98:	6a 00                	push   $0x0
  pushl $61
  100c9a:	6a 3d                	push   $0x3d
  jmp __alltraps
  100c9c:	e9 c0 fd ff ff       	jmp    100a61 <__alltraps>

00100ca1 <vector62>:
.globl vector62
vector62:
  pushl $0
  100ca1:	6a 00                	push   $0x0
  pushl $62
  100ca3:	6a 3e                	push   $0x3e
  jmp __alltraps
  100ca5:	e9 b7 fd ff ff       	jmp    100a61 <__alltraps>

00100caa <vector63>:
.globl vector63
vector63:
  pushl $0
  100caa:	6a 00                	push   $0x0
  pushl $63
  100cac:	6a 3f                	push   $0x3f
  jmp __alltraps
  100cae:	e9 ae fd ff ff       	jmp    100a61 <__alltraps>

00100cb3 <vector64>:
.globl vector64
vector64:
  pushl $0
  100cb3:	6a 00                	push   $0x0
  pushl $64
  100cb5:	6a 40                	push   $0x40
  jmp __alltraps
  100cb7:	e9 a5 fd ff ff       	jmp    100a61 <__alltraps>

00100cbc <vector65>:
.globl vector65
vector65:
  pushl $0
  100cbc:	6a 00                	push   $0x0
  pushl $65
  100cbe:	6a 41                	push   $0x41
  jmp __alltraps
  100cc0:	e9 9c fd ff ff       	jmp    100a61 <__alltraps>

00100cc5 <vector66>:
.globl vector66
vector66:
  pushl $0
  100cc5:	6a 00                	push   $0x0
  pushl $66
  100cc7:	6a 42                	push   $0x42
  jmp __alltraps
  100cc9:	e9 93 fd ff ff       	jmp    100a61 <__alltraps>

00100cce <vector67>:
.globl vector67
vector67:
  pushl $0
  100cce:	6a 00                	push   $0x0
  pushl $67
  100cd0:	6a 43                	push   $0x43
  jmp __alltraps
  100cd2:	e9 8a fd ff ff       	jmp    100a61 <__alltraps>

00100cd7 <vector68>:
.globl vector68
vector68:
  pushl $0
  100cd7:	6a 00                	push   $0x0
  pushl $68
  100cd9:	6a 44                	push   $0x44
  jmp __alltraps
  100cdb:	e9 81 fd ff ff       	jmp    100a61 <__alltraps>

00100ce0 <vector69>:
.globl vector69
vector69:
  pushl $0
  100ce0:	6a 00                	push   $0x0
  pushl $69
  100ce2:	6a 45                	push   $0x45
  jmp __alltraps
  100ce4:	e9 78 fd ff ff       	jmp    100a61 <__alltraps>

00100ce9 <vector70>:
.globl vector70
vector70:
  pushl $0
  100ce9:	6a 00                	push   $0x0
  pushl $70
  100ceb:	6a 46                	push   $0x46
  jmp __alltraps
  100ced:	e9 6f fd ff ff       	jmp    100a61 <__alltraps>

00100cf2 <vector71>:
.globl vector71
vector71:
  pushl $0
  100cf2:	6a 00                	push   $0x0
  pushl $71
  100cf4:	6a 47                	push   $0x47
  jmp __alltraps
  100cf6:	e9 66 fd ff ff       	jmp    100a61 <__alltraps>

00100cfb <vector72>:
.globl vector72
vector72:
  pushl $0
  100cfb:	6a 00                	push   $0x0
  pushl $72
  100cfd:	6a 48                	push   $0x48
  jmp __alltraps
  100cff:	e9 5d fd ff ff       	jmp    100a61 <__alltraps>

00100d04 <vector73>:
.globl vector73
vector73:
  pushl $0
  100d04:	6a 00                	push   $0x0
  pushl $73
  100d06:	6a 49                	push   $0x49
  jmp __alltraps
  100d08:	e9 54 fd ff ff       	jmp    100a61 <__alltraps>

00100d0d <vector74>:
.globl vector74
vector74:
  pushl $0
  100d0d:	6a 00                	push   $0x0
  pushl $74
  100d0f:	6a 4a                	push   $0x4a
  jmp __alltraps
  100d11:	e9 4b fd ff ff       	jmp    100a61 <__alltraps>

00100d16 <vector75>:
.globl vector75
vector75:
  pushl $0
  100d16:	6a 00                	push   $0x0
  pushl $75
  100d18:	6a 4b                	push   $0x4b
  jmp __alltraps
  100d1a:	e9 42 fd ff ff       	jmp    100a61 <__alltraps>

00100d1f <vector76>:
.globl vector76
vector76:
  pushl $0
  100d1f:	6a 00                	push   $0x0
  pushl $76
  100d21:	6a 4c                	push   $0x4c
  jmp __alltraps
  100d23:	e9 39 fd ff ff       	jmp    100a61 <__alltraps>

00100d28 <vector77>:
.globl vector77
vector77:
  pushl $0
  100d28:	6a 00                	push   $0x0
  pushl $77
  100d2a:	6a 4d                	push   $0x4d
  jmp __alltraps
  100d2c:	e9 30 fd ff ff       	jmp    100a61 <__alltraps>

00100d31 <vector78>:
.globl vector78
vector78:
  pushl $0
  100d31:	6a 00                	push   $0x0
  pushl $78
  100d33:	6a 4e                	push   $0x4e
  jmp __alltraps
  100d35:	e9 27 fd ff ff       	jmp    100a61 <__alltraps>

00100d3a <vector79>:
.globl vector79
vector79:
  pushl $0
  100d3a:	6a 00                	push   $0x0
  pushl $79
  100d3c:	6a 4f                	push   $0x4f
  jmp __alltraps
  100d3e:	e9 1e fd ff ff       	jmp    100a61 <__alltraps>

00100d43 <vector80>:
.globl vector80
vector80:
  pushl $0
  100d43:	6a 00                	push   $0x0
  pushl $80
  100d45:	6a 50                	push   $0x50
  jmp __alltraps
  100d47:	e9 15 fd ff ff       	jmp    100a61 <__alltraps>

00100d4c <vector81>:
.globl vector81
vector81:
  pushl $0
  100d4c:	6a 00                	push   $0x0
  pushl $81
  100d4e:	6a 51                	push   $0x51
  jmp __alltraps
  100d50:	e9 0c fd ff ff       	jmp    100a61 <__alltraps>

00100d55 <vector82>:
.globl vector82
vector82:
  pushl $0
  100d55:	6a 00                	push   $0x0
  pushl $82
  100d57:	6a 52                	push   $0x52
  jmp __alltraps
  100d59:	e9 03 fd ff ff       	jmp    100a61 <__alltraps>

00100d5e <vector83>:
.globl vector83
vector83:
  pushl $0
  100d5e:	6a 00                	push   $0x0
  pushl $83
  100d60:	6a 53                	push   $0x53
  jmp __alltraps
  100d62:	e9 fa fc ff ff       	jmp    100a61 <__alltraps>

00100d67 <vector84>:
.globl vector84
vector84:
  pushl $0
  100d67:	6a 00                	push   $0x0
  pushl $84
  100d69:	6a 54                	push   $0x54
  jmp __alltraps
  100d6b:	e9 f1 fc ff ff       	jmp    100a61 <__alltraps>

00100d70 <vector85>:
.globl vector85
vector85:
  pushl $0
  100d70:	6a 00                	push   $0x0
  pushl $85
  100d72:	6a 55                	push   $0x55
  jmp __alltraps
  100d74:	e9 e8 fc ff ff       	jmp    100a61 <__alltraps>

00100d79 <vector86>:
.globl vector86
vector86:
  pushl $0
  100d79:	6a 00                	push   $0x0
  pushl $86
  100d7b:	6a 56                	push   $0x56
  jmp __alltraps
  100d7d:	e9 df fc ff ff       	jmp    100a61 <__alltraps>

00100d82 <vector87>:
.globl vector87
vector87:
  pushl $0
  100d82:	6a 00                	push   $0x0
  pushl $87
  100d84:	6a 57                	push   $0x57
  jmp __alltraps
  100d86:	e9 d6 fc ff ff       	jmp    100a61 <__alltraps>

00100d8b <vector88>:
.globl vector88
vector88:
  pushl $0
  100d8b:	6a 00                	push   $0x0
  pushl $88
  100d8d:	6a 58                	push   $0x58
  jmp __alltraps
  100d8f:	e9 cd fc ff ff       	jmp    100a61 <__alltraps>

00100d94 <vector89>:
.globl vector89
vector89:
  pushl $0
  100d94:	6a 00                	push   $0x0
  pushl $89
  100d96:	6a 59                	push   $0x59
  jmp __alltraps
  100d98:	e9 c4 fc ff ff       	jmp    100a61 <__alltraps>

00100d9d <vector90>:
.globl vector90
vector90:
  pushl $0
  100d9d:	6a 00                	push   $0x0
  pushl $90
  100d9f:	6a 5a                	push   $0x5a
  jmp __alltraps
  100da1:	e9 bb fc ff ff       	jmp    100a61 <__alltraps>

00100da6 <vector91>:
.globl vector91
vector91:
  pushl $0
  100da6:	6a 00                	push   $0x0
  pushl $91
  100da8:	6a 5b                	push   $0x5b
  jmp __alltraps
  100daa:	e9 b2 fc ff ff       	jmp    100a61 <__alltraps>

00100daf <vector92>:
.globl vector92
vector92:
  pushl $0
  100daf:	6a 00                	push   $0x0
  pushl $92
  100db1:	6a 5c                	push   $0x5c
  jmp __alltraps
  100db3:	e9 a9 fc ff ff       	jmp    100a61 <__alltraps>

00100db8 <vector93>:
.globl vector93
vector93:
  pushl $0
  100db8:	6a 00                	push   $0x0
  pushl $93
  100dba:	6a 5d                	push   $0x5d
  jmp __alltraps
  100dbc:	e9 a0 fc ff ff       	jmp    100a61 <__alltraps>

00100dc1 <vector94>:
.globl vector94
vector94:
  pushl $0
  100dc1:	6a 00                	push   $0x0
  pushl $94
  100dc3:	6a 5e                	push   $0x5e
  jmp __alltraps
  100dc5:	e9 97 fc ff ff       	jmp    100a61 <__alltraps>

00100dca <vector95>:
.globl vector95
vector95:
  pushl $0
  100dca:	6a 00                	push   $0x0
  pushl $95
  100dcc:	6a 5f                	push   $0x5f
  jmp __alltraps
  100dce:	e9 8e fc ff ff       	jmp    100a61 <__alltraps>

00100dd3 <vector96>:
.globl vector96
vector96:
  pushl $0
  100dd3:	6a 00                	push   $0x0
  pushl $96
  100dd5:	6a 60                	push   $0x60
  jmp __alltraps
  100dd7:	e9 85 fc ff ff       	jmp    100a61 <__alltraps>

00100ddc <vector97>:
.globl vector97
vector97:
  pushl $0
  100ddc:	6a 00                	push   $0x0
  pushl $97
  100dde:	6a 61                	push   $0x61
  jmp __alltraps
  100de0:	e9 7c fc ff ff       	jmp    100a61 <__alltraps>

00100de5 <vector98>:
.globl vector98
vector98:
  pushl $0
  100de5:	6a 00                	push   $0x0
  pushl $98
  100de7:	6a 62                	push   $0x62
  jmp __alltraps
  100de9:	e9 73 fc ff ff       	jmp    100a61 <__alltraps>

00100dee <vector99>:
.globl vector99
vector99:
  pushl $0
  100dee:	6a 00                	push   $0x0
  pushl $99
  100df0:	6a 63                	push   $0x63
  jmp __alltraps
  100df2:	e9 6a fc ff ff       	jmp    100a61 <__alltraps>

00100df7 <vector100>:
.globl vector100
vector100:
  pushl $0
  100df7:	6a 00                	push   $0x0
  pushl $100
  100df9:	6a 64                	push   $0x64
  jmp __alltraps
  100dfb:	e9 61 fc ff ff       	jmp    100a61 <__alltraps>

00100e00 <vector101>:
.globl vector101
vector101:
  pushl $0
  100e00:	6a 00                	push   $0x0
  pushl $101
  100e02:	6a 65                	push   $0x65
  jmp __alltraps
  100e04:	e9 58 fc ff ff       	jmp    100a61 <__alltraps>

00100e09 <vector102>:
.globl vector102
vector102:
  pushl $0
  100e09:	6a 00                	push   $0x0
  pushl $102
  100e0b:	6a 66                	push   $0x66
  jmp __alltraps
  100e0d:	e9 4f fc ff ff       	jmp    100a61 <__alltraps>

00100e12 <vector103>:
.globl vector103
vector103:
  pushl $0
  100e12:	6a 00                	push   $0x0
  pushl $103
  100e14:	6a 67                	push   $0x67
  jmp __alltraps
  100e16:	e9 46 fc ff ff       	jmp    100a61 <__alltraps>

00100e1b <vector104>:
.globl vector104
vector104:
  pushl $0
  100e1b:	6a 00                	push   $0x0
  pushl $104
  100e1d:	6a 68                	push   $0x68
  jmp __alltraps
  100e1f:	e9 3d fc ff ff       	jmp    100a61 <__alltraps>

00100e24 <vector105>:
.globl vector105
vector105:
  pushl $0
  100e24:	6a 00                	push   $0x0
  pushl $105
  100e26:	6a 69                	push   $0x69
  jmp __alltraps
  100e28:	e9 34 fc ff ff       	jmp    100a61 <__alltraps>

00100e2d <vector106>:
.globl vector106
vector106:
  pushl $0
  100e2d:	6a 00                	push   $0x0
  pushl $106
  100e2f:	6a 6a                	push   $0x6a
  jmp __alltraps
  100e31:	e9 2b fc ff ff       	jmp    100a61 <__alltraps>

00100e36 <vector107>:
.globl vector107
vector107:
  pushl $0
  100e36:	6a 00                	push   $0x0
  pushl $107
  100e38:	6a 6b                	push   $0x6b
  jmp __alltraps
  100e3a:	e9 22 fc ff ff       	jmp    100a61 <__alltraps>

00100e3f <vector108>:
.globl vector108
vector108:
  pushl $0
  100e3f:	6a 00                	push   $0x0
  pushl $108
  100e41:	6a 6c                	push   $0x6c
  jmp __alltraps
  100e43:	e9 19 fc ff ff       	jmp    100a61 <__alltraps>

00100e48 <vector109>:
.globl vector109
vector109:
  pushl $0
  100e48:	6a 00                	push   $0x0
  pushl $109
  100e4a:	6a 6d                	push   $0x6d
  jmp __alltraps
  100e4c:	e9 10 fc ff ff       	jmp    100a61 <__alltraps>

00100e51 <vector110>:
.globl vector110
vector110:
  pushl $0
  100e51:	6a 00                	push   $0x0
  pushl $110
  100e53:	6a 6e                	push   $0x6e
  jmp __alltraps
  100e55:	e9 07 fc ff ff       	jmp    100a61 <__alltraps>

00100e5a <vector111>:
.globl vector111
vector111:
  pushl $0
  100e5a:	6a 00                	push   $0x0
  pushl $111
  100e5c:	6a 6f                	push   $0x6f
  jmp __alltraps
  100e5e:	e9 fe fb ff ff       	jmp    100a61 <__alltraps>

00100e63 <vector112>:
.globl vector112
vector112:
  pushl $0
  100e63:	6a 00                	push   $0x0
  pushl $112
  100e65:	6a 70                	push   $0x70
  jmp __alltraps
  100e67:	e9 f5 fb ff ff       	jmp    100a61 <__alltraps>

00100e6c <vector113>:
.globl vector113
vector113:
  pushl $0
  100e6c:	6a 00                	push   $0x0
  pushl $113
  100e6e:	6a 71                	push   $0x71
  jmp __alltraps
  100e70:	e9 ec fb ff ff       	jmp    100a61 <__alltraps>

00100e75 <vector114>:
.globl vector114
vector114:
  pushl $0
  100e75:	6a 00                	push   $0x0
  pushl $114
  100e77:	6a 72                	push   $0x72
  jmp __alltraps
  100e79:	e9 e3 fb ff ff       	jmp    100a61 <__alltraps>

00100e7e <vector115>:
.globl vector115
vector115:
  pushl $0
  100e7e:	6a 00                	push   $0x0
  pushl $115
  100e80:	6a 73                	push   $0x73
  jmp __alltraps
  100e82:	e9 da fb ff ff       	jmp    100a61 <__alltraps>

00100e87 <vector116>:
.globl vector116
vector116:
  pushl $0
  100e87:	6a 00                	push   $0x0
  pushl $116
  100e89:	6a 74                	push   $0x74
  jmp __alltraps
  100e8b:	e9 d1 fb ff ff       	jmp    100a61 <__alltraps>

00100e90 <vector117>:
.globl vector117
vector117:
  pushl $0
  100e90:	6a 00                	push   $0x0
  pushl $117
  100e92:	6a 75                	push   $0x75
  jmp __alltraps
  100e94:	e9 c8 fb ff ff       	jmp    100a61 <__alltraps>

00100e99 <vector118>:
.globl vector118
vector118:
  pushl $0
  100e99:	6a 00                	push   $0x0
  pushl $118
  100e9b:	6a 76                	push   $0x76
  jmp __alltraps
  100e9d:	e9 bf fb ff ff       	jmp    100a61 <__alltraps>

00100ea2 <vector119>:
.globl vector119
vector119:
  pushl $0
  100ea2:	6a 00                	push   $0x0
  pushl $119
  100ea4:	6a 77                	push   $0x77
  jmp __alltraps
  100ea6:	e9 b6 fb ff ff       	jmp    100a61 <__alltraps>

00100eab <vector120>:
.globl vector120
vector120:
  pushl $0
  100eab:	6a 00                	push   $0x0
  pushl $120
  100ead:	6a 78                	push   $0x78
  jmp __alltraps
  100eaf:	e9 ad fb ff ff       	jmp    100a61 <__alltraps>

00100eb4 <vector121>:
.globl vector121
vector121:
  pushl $0
  100eb4:	6a 00                	push   $0x0
  pushl $121
  100eb6:	6a 79                	push   $0x79
  jmp __alltraps
  100eb8:	e9 a4 fb ff ff       	jmp    100a61 <__alltraps>

00100ebd <vector122>:
.globl vector122
vector122:
  pushl $0
  100ebd:	6a 00                	push   $0x0
  pushl $122
  100ebf:	6a 7a                	push   $0x7a
  jmp __alltraps
  100ec1:	e9 9b fb ff ff       	jmp    100a61 <__alltraps>

00100ec6 <vector123>:
.globl vector123
vector123:
  pushl $0
  100ec6:	6a 00                	push   $0x0
  pushl $123
  100ec8:	6a 7b                	push   $0x7b
  jmp __alltraps
  100eca:	e9 92 fb ff ff       	jmp    100a61 <__alltraps>

00100ecf <vector124>:
.globl vector124
vector124:
  pushl $0
  100ecf:	6a 00                	push   $0x0
  pushl $124
  100ed1:	6a 7c                	push   $0x7c
  jmp __alltraps
  100ed3:	e9 89 fb ff ff       	jmp    100a61 <__alltraps>

00100ed8 <vector125>:
.globl vector125
vector125:
  pushl $0
  100ed8:	6a 00                	push   $0x0
  pushl $125
  100eda:	6a 7d                	push   $0x7d
  jmp __alltraps
  100edc:	e9 80 fb ff ff       	jmp    100a61 <__alltraps>

00100ee1 <vector126>:
.globl vector126
vector126:
  pushl $0
  100ee1:	6a 00                	push   $0x0
  pushl $126
  100ee3:	6a 7e                	push   $0x7e
  jmp __alltraps
  100ee5:	e9 77 fb ff ff       	jmp    100a61 <__alltraps>

00100eea <vector127>:
.globl vector127
vector127:
  pushl $0
  100eea:	6a 00                	push   $0x0
  pushl $127
  100eec:	6a 7f                	push   $0x7f
  jmp __alltraps
  100eee:	e9 6e fb ff ff       	jmp    100a61 <__alltraps>

00100ef3 <vector128>:
.globl vector128
vector128:
  pushl $0
  100ef3:	6a 00                	push   $0x0
  pushl $128
  100ef5:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
  100efa:	e9 62 fb ff ff       	jmp    100a61 <__alltraps>

00100eff <vector129>:
.globl vector129
vector129:
  pushl $0
  100eff:	6a 00                	push   $0x0
  pushl $129
  100f01:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
  100f06:	e9 56 fb ff ff       	jmp    100a61 <__alltraps>

00100f0b <vector130>:
.globl vector130
vector130:
  pushl $0
  100f0b:	6a 00                	push   $0x0
  pushl $130
  100f0d:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
  100f12:	e9 4a fb ff ff       	jmp    100a61 <__alltraps>

00100f17 <vector131>:
.globl vector131
vector131:
  pushl $0
  100f17:	6a 00                	push   $0x0
  pushl $131
  100f19:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
  100f1e:	e9 3e fb ff ff       	jmp    100a61 <__alltraps>

00100f23 <vector132>:
.globl vector132
vector132:
  pushl $0
  100f23:	6a 00                	push   $0x0
  pushl $132
  100f25:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
  100f2a:	e9 32 fb ff ff       	jmp    100a61 <__alltraps>

00100f2f <vector133>:
.globl vector133
vector133:
  pushl $0
  100f2f:	6a 00                	push   $0x0
  pushl $133
  100f31:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
  100f36:	e9 26 fb ff ff       	jmp    100a61 <__alltraps>

00100f3b <vector134>:
.globl vector134
vector134:
  pushl $0
  100f3b:	6a 00                	push   $0x0
  pushl $134
  100f3d:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
  100f42:	e9 1a fb ff ff       	jmp    100a61 <__alltraps>

00100f47 <vector135>:
.globl vector135
vector135:
  pushl $0
  100f47:	6a 00                	push   $0x0
  pushl $135
  100f49:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
  100f4e:	e9 0e fb ff ff       	jmp    100a61 <__alltraps>

00100f53 <vector136>:
.globl vector136
vector136:
  pushl $0
  100f53:	6a 00                	push   $0x0
  pushl $136
  100f55:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
  100f5a:	e9 02 fb ff ff       	jmp    100a61 <__alltraps>

00100f5f <vector137>:
.globl vector137
vector137:
  pushl $0
  100f5f:	6a 00                	push   $0x0
  pushl $137
  100f61:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
  100f66:	e9 f6 fa ff ff       	jmp    100a61 <__alltraps>

00100f6b <vector138>:
.globl vector138
vector138:
  pushl $0
  100f6b:	6a 00                	push   $0x0
  pushl $138
  100f6d:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
  100f72:	e9 ea fa ff ff       	jmp    100a61 <__alltraps>

00100f77 <vector139>:
.globl vector139
vector139:
  pushl $0
  100f77:	6a 00                	push   $0x0
  pushl $139
  100f79:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
  100f7e:	e9 de fa ff ff       	jmp    100a61 <__alltraps>

00100f83 <vector140>:
.globl vector140
vector140:
  pushl $0
  100f83:	6a 00                	push   $0x0
  pushl $140
  100f85:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
  100f8a:	e9 d2 fa ff ff       	jmp    100a61 <__alltraps>

00100f8f <vector141>:
.globl vector141
vector141:
  pushl $0
  100f8f:	6a 00                	push   $0x0
  pushl $141
  100f91:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
  100f96:	e9 c6 fa ff ff       	jmp    100a61 <__alltraps>

00100f9b <vector142>:
.globl vector142
vector142:
  pushl $0
  100f9b:	6a 00                	push   $0x0
  pushl $142
  100f9d:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
  100fa2:	e9 ba fa ff ff       	jmp    100a61 <__alltraps>

00100fa7 <vector143>:
.globl vector143
vector143:
  pushl $0
  100fa7:	6a 00                	push   $0x0
  pushl $143
  100fa9:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
  100fae:	e9 ae fa ff ff       	jmp    100a61 <__alltraps>

00100fb3 <vector144>:
.globl vector144
vector144:
  pushl $0
  100fb3:	6a 00                	push   $0x0
  pushl $144
  100fb5:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
  100fba:	e9 a2 fa ff ff       	jmp    100a61 <__alltraps>

00100fbf <vector145>:
.globl vector145
vector145:
  pushl $0
  100fbf:	6a 00                	push   $0x0
  pushl $145
  100fc1:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
  100fc6:	e9 96 fa ff ff       	jmp    100a61 <__alltraps>

00100fcb <vector146>:
.globl vector146
vector146:
  pushl $0
  100fcb:	6a 00                	push   $0x0
  pushl $146
  100fcd:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
  100fd2:	e9 8a fa ff ff       	jmp    100a61 <__alltraps>

00100fd7 <vector147>:
.globl vector147
vector147:
  pushl $0
  100fd7:	6a 00                	push   $0x0
  pushl $147
  100fd9:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
  100fde:	e9 7e fa ff ff       	jmp    100a61 <__alltraps>

00100fe3 <vector148>:
.globl vector148
vector148:
  pushl $0
  100fe3:	6a 00                	push   $0x0
  pushl $148
  100fe5:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
  100fea:	e9 72 fa ff ff       	jmp    100a61 <__alltraps>

00100fef <vector149>:
.globl vector149
vector149:
  pushl $0
  100fef:	6a 00                	push   $0x0
  pushl $149
  100ff1:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
  100ff6:	e9 66 fa ff ff       	jmp    100a61 <__alltraps>

00100ffb <vector150>:
.globl vector150
vector150:
  pushl $0
  100ffb:	6a 00                	push   $0x0
  pushl $150
  100ffd:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
  101002:	e9 5a fa ff ff       	jmp    100a61 <__alltraps>

00101007 <vector151>:
.globl vector151
vector151:
  pushl $0
  101007:	6a 00                	push   $0x0
  pushl $151
  101009:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
  10100e:	e9 4e fa ff ff       	jmp    100a61 <__alltraps>

00101013 <vector152>:
.globl vector152
vector152:
  pushl $0
  101013:	6a 00                	push   $0x0
  pushl $152
  101015:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
  10101a:	e9 42 fa ff ff       	jmp    100a61 <__alltraps>

0010101f <vector153>:
.globl vector153
vector153:
  pushl $0
  10101f:	6a 00                	push   $0x0
  pushl $153
  101021:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
  101026:	e9 36 fa ff ff       	jmp    100a61 <__alltraps>

0010102b <vector154>:
.globl vector154
vector154:
  pushl $0
  10102b:	6a 00                	push   $0x0
  pushl $154
  10102d:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
  101032:	e9 2a fa ff ff       	jmp    100a61 <__alltraps>

00101037 <vector155>:
.globl vector155
vector155:
  pushl $0
  101037:	6a 00                	push   $0x0
  pushl $155
  101039:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
  10103e:	e9 1e fa ff ff       	jmp    100a61 <__alltraps>

00101043 <vector156>:
.globl vector156
vector156:
  pushl $0
  101043:	6a 00                	push   $0x0
  pushl $156
  101045:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
  10104a:	e9 12 fa ff ff       	jmp    100a61 <__alltraps>

0010104f <vector157>:
.globl vector157
vector157:
  pushl $0
  10104f:	6a 00                	push   $0x0
  pushl $157
  101051:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
  101056:	e9 06 fa ff ff       	jmp    100a61 <__alltraps>

0010105b <vector158>:
.globl vector158
vector158:
  pushl $0
  10105b:	6a 00                	push   $0x0
  pushl $158
  10105d:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
  101062:	e9 fa f9 ff ff       	jmp    100a61 <__alltraps>

00101067 <vector159>:
.globl vector159
vector159:
  pushl $0
  101067:	6a 00                	push   $0x0
  pushl $159
  101069:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
  10106e:	e9 ee f9 ff ff       	jmp    100a61 <__alltraps>

00101073 <vector160>:
.globl vector160
vector160:
  pushl $0
  101073:	6a 00                	push   $0x0
  pushl $160
  101075:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
  10107a:	e9 e2 f9 ff ff       	jmp    100a61 <__alltraps>

0010107f <vector161>:
.globl vector161
vector161:
  pushl $0
  10107f:	6a 00                	push   $0x0
  pushl $161
  101081:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
  101086:	e9 d6 f9 ff ff       	jmp    100a61 <__alltraps>

0010108b <vector162>:
.globl vector162
vector162:
  pushl $0
  10108b:	6a 00                	push   $0x0
  pushl $162
  10108d:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
  101092:	e9 ca f9 ff ff       	jmp    100a61 <__alltraps>

00101097 <vector163>:
.globl vector163
vector163:
  pushl $0
  101097:	6a 00                	push   $0x0
  pushl $163
  101099:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
  10109e:	e9 be f9 ff ff       	jmp    100a61 <__alltraps>

001010a3 <vector164>:
.globl vector164
vector164:
  pushl $0
  1010a3:	6a 00                	push   $0x0
  pushl $164
  1010a5:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
  1010aa:	e9 b2 f9 ff ff       	jmp    100a61 <__alltraps>

001010af <vector165>:
.globl vector165
vector165:
  pushl $0
  1010af:	6a 00                	push   $0x0
  pushl $165
  1010b1:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
  1010b6:	e9 a6 f9 ff ff       	jmp    100a61 <__alltraps>

001010bb <vector166>:
.globl vector166
vector166:
  pushl $0
  1010bb:	6a 00                	push   $0x0
  pushl $166
  1010bd:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
  1010c2:	e9 9a f9 ff ff       	jmp    100a61 <__alltraps>

001010c7 <vector167>:
.globl vector167
vector167:
  pushl $0
  1010c7:	6a 00                	push   $0x0
  pushl $167
  1010c9:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
  1010ce:	e9 8e f9 ff ff       	jmp    100a61 <__alltraps>

001010d3 <vector168>:
.globl vector168
vector168:
  pushl $0
  1010d3:	6a 00                	push   $0x0
  pushl $168
  1010d5:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
  1010da:	e9 82 f9 ff ff       	jmp    100a61 <__alltraps>

001010df <vector169>:
.globl vector169
vector169:
  pushl $0
  1010df:	6a 00                	push   $0x0
  pushl $169
  1010e1:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
  1010e6:	e9 76 f9 ff ff       	jmp    100a61 <__alltraps>

001010eb <vector170>:
.globl vector170
vector170:
  pushl $0
  1010eb:	6a 00                	push   $0x0
  pushl $170
  1010ed:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
  1010f2:	e9 6a f9 ff ff       	jmp    100a61 <__alltraps>

001010f7 <vector171>:
.globl vector171
vector171:
  pushl $0
  1010f7:	6a 00                	push   $0x0
  pushl $171
  1010f9:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
  1010fe:	e9 5e f9 ff ff       	jmp    100a61 <__alltraps>

00101103 <vector172>:
.globl vector172
vector172:
  pushl $0
  101103:	6a 00                	push   $0x0
  pushl $172
  101105:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
  10110a:	e9 52 f9 ff ff       	jmp    100a61 <__alltraps>

0010110f <vector173>:
.globl vector173
vector173:
  pushl $0
  10110f:	6a 00                	push   $0x0
  pushl $173
  101111:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
  101116:	e9 46 f9 ff ff       	jmp    100a61 <__alltraps>

0010111b <vector174>:
.globl vector174
vector174:
  pushl $0
  10111b:	6a 00                	push   $0x0
  pushl $174
  10111d:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
  101122:	e9 3a f9 ff ff       	jmp    100a61 <__alltraps>

00101127 <vector175>:
.globl vector175
vector175:
  pushl $0
  101127:	6a 00                	push   $0x0
  pushl $175
  101129:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
  10112e:	e9 2e f9 ff ff       	jmp    100a61 <__alltraps>

00101133 <vector176>:
.globl vector176
vector176:
  pushl $0
  101133:	6a 00                	push   $0x0
  pushl $176
  101135:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
  10113a:	e9 22 f9 ff ff       	jmp    100a61 <__alltraps>

0010113f <vector177>:
.globl vector177
vector177:
  pushl $0
  10113f:	6a 00                	push   $0x0
  pushl $177
  101141:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
  101146:	e9 16 f9 ff ff       	jmp    100a61 <__alltraps>

0010114b <vector178>:
.globl vector178
vector178:
  pushl $0
  10114b:	6a 00                	push   $0x0
  pushl $178
  10114d:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
  101152:	e9 0a f9 ff ff       	jmp    100a61 <__alltraps>

00101157 <vector179>:
.globl vector179
vector179:
  pushl $0
  101157:	6a 00                	push   $0x0
  pushl $179
  101159:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
  10115e:	e9 fe f8 ff ff       	jmp    100a61 <__alltraps>

00101163 <vector180>:
.globl vector180
vector180:
  pushl $0
  101163:	6a 00                	push   $0x0
  pushl $180
  101165:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
  10116a:	e9 f2 f8 ff ff       	jmp    100a61 <__alltraps>

0010116f <vector181>:
.globl vector181
vector181:
  pushl $0
  10116f:	6a 00                	push   $0x0
  pushl $181
  101171:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
  101176:	e9 e6 f8 ff ff       	jmp    100a61 <__alltraps>

0010117b <vector182>:
.globl vector182
vector182:
  pushl $0
  10117b:	6a 00                	push   $0x0
  pushl $182
  10117d:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
  101182:	e9 da f8 ff ff       	jmp    100a61 <__alltraps>

00101187 <vector183>:
.globl vector183
vector183:
  pushl $0
  101187:	6a 00                	push   $0x0
  pushl $183
  101189:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
  10118e:	e9 ce f8 ff ff       	jmp    100a61 <__alltraps>

00101193 <vector184>:
.globl vector184
vector184:
  pushl $0
  101193:	6a 00                	push   $0x0
  pushl $184
  101195:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
  10119a:	e9 c2 f8 ff ff       	jmp    100a61 <__alltraps>

0010119f <vector185>:
.globl vector185
vector185:
  pushl $0
  10119f:	6a 00                	push   $0x0
  pushl $185
  1011a1:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
  1011a6:	e9 b6 f8 ff ff       	jmp    100a61 <__alltraps>

001011ab <vector186>:
.globl vector186
vector186:
  pushl $0
  1011ab:	6a 00                	push   $0x0
  pushl $186
  1011ad:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
  1011b2:	e9 aa f8 ff ff       	jmp    100a61 <__alltraps>

001011b7 <vector187>:
.globl vector187
vector187:
  pushl $0
  1011b7:	6a 00                	push   $0x0
  pushl $187
  1011b9:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
  1011be:	e9 9e f8 ff ff       	jmp    100a61 <__alltraps>

001011c3 <vector188>:
.globl vector188
vector188:
  pushl $0
  1011c3:	6a 00                	push   $0x0
  pushl $188
  1011c5:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
  1011ca:	e9 92 f8 ff ff       	jmp    100a61 <__alltraps>

001011cf <vector189>:
.globl vector189
vector189:
  pushl $0
  1011cf:	6a 00                	push   $0x0
  pushl $189
  1011d1:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
  1011d6:	e9 86 f8 ff ff       	jmp    100a61 <__alltraps>

001011db <vector190>:
.globl vector190
vector190:
  pushl $0
  1011db:	6a 00                	push   $0x0
  pushl $190
  1011dd:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
  1011e2:	e9 7a f8 ff ff       	jmp    100a61 <__alltraps>

001011e7 <vector191>:
.globl vector191
vector191:
  pushl $0
  1011e7:	6a 00                	push   $0x0
  pushl $191
  1011e9:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
  1011ee:	e9 6e f8 ff ff       	jmp    100a61 <__alltraps>

001011f3 <vector192>:
.globl vector192
vector192:
  pushl $0
  1011f3:	6a 00                	push   $0x0
  pushl $192
  1011f5:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
  1011fa:	e9 62 f8 ff ff       	jmp    100a61 <__alltraps>

001011ff <vector193>:
.globl vector193
vector193:
  pushl $0
  1011ff:	6a 00                	push   $0x0
  pushl $193
  101201:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
  101206:	e9 56 f8 ff ff       	jmp    100a61 <__alltraps>

0010120b <vector194>:
.globl vector194
vector194:
  pushl $0
  10120b:	6a 00                	push   $0x0
  pushl $194
  10120d:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
  101212:	e9 4a f8 ff ff       	jmp    100a61 <__alltraps>

00101217 <vector195>:
.globl vector195
vector195:
  pushl $0
  101217:	6a 00                	push   $0x0
  pushl $195
  101219:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
  10121e:	e9 3e f8 ff ff       	jmp    100a61 <__alltraps>

00101223 <vector196>:
.globl vector196
vector196:
  pushl $0
  101223:	6a 00                	push   $0x0
  pushl $196
  101225:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
  10122a:	e9 32 f8 ff ff       	jmp    100a61 <__alltraps>

0010122f <vector197>:
.globl vector197
vector197:
  pushl $0
  10122f:	6a 00                	push   $0x0
  pushl $197
  101231:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
  101236:	e9 26 f8 ff ff       	jmp    100a61 <__alltraps>

0010123b <vector198>:
.globl vector198
vector198:
  pushl $0
  10123b:	6a 00                	push   $0x0
  pushl $198
  10123d:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
  101242:	e9 1a f8 ff ff       	jmp    100a61 <__alltraps>

00101247 <vector199>:
.globl vector199
vector199:
  pushl $0
  101247:	6a 00                	push   $0x0
  pushl $199
  101249:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
  10124e:	e9 0e f8 ff ff       	jmp    100a61 <__alltraps>

00101253 <vector200>:
.globl vector200
vector200:
  pushl $0
  101253:	6a 00                	push   $0x0
  pushl $200
  101255:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
  10125a:	e9 02 f8 ff ff       	jmp    100a61 <__alltraps>

0010125f <vector201>:
.globl vector201
vector201:
  pushl $0
  10125f:	6a 00                	push   $0x0
  pushl $201
  101261:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
  101266:	e9 f6 f7 ff ff       	jmp    100a61 <__alltraps>

0010126b <vector202>:
.globl vector202
vector202:
  pushl $0
  10126b:	6a 00                	push   $0x0
  pushl $202
  10126d:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
  101272:	e9 ea f7 ff ff       	jmp    100a61 <__alltraps>

00101277 <vector203>:
.globl vector203
vector203:
  pushl $0
  101277:	6a 00                	push   $0x0
  pushl $203
  101279:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
  10127e:	e9 de f7 ff ff       	jmp    100a61 <__alltraps>

00101283 <vector204>:
.globl vector204
vector204:
  pushl $0
  101283:	6a 00                	push   $0x0
  pushl $204
  101285:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
  10128a:	e9 d2 f7 ff ff       	jmp    100a61 <__alltraps>

0010128f <vector205>:
.globl vector205
vector205:
  pushl $0
  10128f:	6a 00                	push   $0x0
  pushl $205
  101291:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
  101296:	e9 c6 f7 ff ff       	jmp    100a61 <__alltraps>

0010129b <vector206>:
.globl vector206
vector206:
  pushl $0
  10129b:	6a 00                	push   $0x0
  pushl $206
  10129d:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
  1012a2:	e9 ba f7 ff ff       	jmp    100a61 <__alltraps>

001012a7 <vector207>:
.globl vector207
vector207:
  pushl $0
  1012a7:	6a 00                	push   $0x0
  pushl $207
  1012a9:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
  1012ae:	e9 ae f7 ff ff       	jmp    100a61 <__alltraps>

001012b3 <vector208>:
.globl vector208
vector208:
  pushl $0
  1012b3:	6a 00                	push   $0x0
  pushl $208
  1012b5:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
  1012ba:	e9 a2 f7 ff ff       	jmp    100a61 <__alltraps>

001012bf <vector209>:
.globl vector209
vector209:
  pushl $0
  1012bf:	6a 00                	push   $0x0
  pushl $209
  1012c1:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
  1012c6:	e9 96 f7 ff ff       	jmp    100a61 <__alltraps>

001012cb <vector210>:
.globl vector210
vector210:
  pushl $0
  1012cb:	6a 00                	push   $0x0
  pushl $210
  1012cd:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
  1012d2:	e9 8a f7 ff ff       	jmp    100a61 <__alltraps>

001012d7 <vector211>:
.globl vector211
vector211:
  pushl $0
  1012d7:	6a 00                	push   $0x0
  pushl $211
  1012d9:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
  1012de:	e9 7e f7 ff ff       	jmp    100a61 <__alltraps>

001012e3 <vector212>:
.globl vector212
vector212:
  pushl $0
  1012e3:	6a 00                	push   $0x0
  pushl $212
  1012e5:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
  1012ea:	e9 72 f7 ff ff       	jmp    100a61 <__alltraps>

001012ef <vector213>:
.globl vector213
vector213:
  pushl $0
  1012ef:	6a 00                	push   $0x0
  pushl $213
  1012f1:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
  1012f6:	e9 66 f7 ff ff       	jmp    100a61 <__alltraps>

001012fb <vector214>:
.globl vector214
vector214:
  pushl $0
  1012fb:	6a 00                	push   $0x0
  pushl $214
  1012fd:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
  101302:	e9 5a f7 ff ff       	jmp    100a61 <__alltraps>

00101307 <vector215>:
.globl vector215
vector215:
  pushl $0
  101307:	6a 00                	push   $0x0
  pushl $215
  101309:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
  10130e:	e9 4e f7 ff ff       	jmp    100a61 <__alltraps>

00101313 <vector216>:
.globl vector216
vector216:
  pushl $0
  101313:	6a 00                	push   $0x0
  pushl $216
  101315:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
  10131a:	e9 42 f7 ff ff       	jmp    100a61 <__alltraps>

0010131f <vector217>:
.globl vector217
vector217:
  pushl $0
  10131f:	6a 00                	push   $0x0
  pushl $217
  101321:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
  101326:	e9 36 f7 ff ff       	jmp    100a61 <__alltraps>

0010132b <vector218>:
.globl vector218
vector218:
  pushl $0
  10132b:	6a 00                	push   $0x0
  pushl $218
  10132d:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
  101332:	e9 2a f7 ff ff       	jmp    100a61 <__alltraps>

00101337 <vector219>:
.globl vector219
vector219:
  pushl $0
  101337:	6a 00                	push   $0x0
  pushl $219
  101339:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
  10133e:	e9 1e f7 ff ff       	jmp    100a61 <__alltraps>

00101343 <vector220>:
.globl vector220
vector220:
  pushl $0
  101343:	6a 00                	push   $0x0
  pushl $220
  101345:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
  10134a:	e9 12 f7 ff ff       	jmp    100a61 <__alltraps>

0010134f <vector221>:
.globl vector221
vector221:
  pushl $0
  10134f:	6a 00                	push   $0x0
  pushl $221
  101351:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
  101356:	e9 06 f7 ff ff       	jmp    100a61 <__alltraps>

0010135b <vector222>:
.globl vector222
vector222:
  pushl $0
  10135b:	6a 00                	push   $0x0
  pushl $222
  10135d:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
  101362:	e9 fa f6 ff ff       	jmp    100a61 <__alltraps>

00101367 <vector223>:
.globl vector223
vector223:
  pushl $0
  101367:	6a 00                	push   $0x0
  pushl $223
  101369:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
  10136e:	e9 ee f6 ff ff       	jmp    100a61 <__alltraps>

00101373 <vector224>:
.globl vector224
vector224:
  pushl $0
  101373:	6a 00                	push   $0x0
  pushl $224
  101375:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
  10137a:	e9 e2 f6 ff ff       	jmp    100a61 <__alltraps>

0010137f <vector225>:
.globl vector225
vector225:
  pushl $0
  10137f:	6a 00                	push   $0x0
  pushl $225
  101381:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
  101386:	e9 d6 f6 ff ff       	jmp    100a61 <__alltraps>

0010138b <vector226>:
.globl vector226
vector226:
  pushl $0
  10138b:	6a 00                	push   $0x0
  pushl $226
  10138d:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
  101392:	e9 ca f6 ff ff       	jmp    100a61 <__alltraps>

00101397 <vector227>:
.globl vector227
vector227:
  pushl $0
  101397:	6a 00                	push   $0x0
  pushl $227
  101399:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
  10139e:	e9 be f6 ff ff       	jmp    100a61 <__alltraps>

001013a3 <vector228>:
.globl vector228
vector228:
  pushl $0
  1013a3:	6a 00                	push   $0x0
  pushl $228
  1013a5:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
  1013aa:	e9 b2 f6 ff ff       	jmp    100a61 <__alltraps>

001013af <vector229>:
.globl vector229
vector229:
  pushl $0
  1013af:	6a 00                	push   $0x0
  pushl $229
  1013b1:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
  1013b6:	e9 a6 f6 ff ff       	jmp    100a61 <__alltraps>

001013bb <vector230>:
.globl vector230
vector230:
  pushl $0
  1013bb:	6a 00                	push   $0x0
  pushl $230
  1013bd:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
  1013c2:	e9 9a f6 ff ff       	jmp    100a61 <__alltraps>

001013c7 <vector231>:
.globl vector231
vector231:
  pushl $0
  1013c7:	6a 00                	push   $0x0
  pushl $231
  1013c9:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
  1013ce:	e9 8e f6 ff ff       	jmp    100a61 <__alltraps>

001013d3 <vector232>:
.globl vector232
vector232:
  pushl $0
  1013d3:	6a 00                	push   $0x0
  pushl $232
  1013d5:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
  1013da:	e9 82 f6 ff ff       	jmp    100a61 <__alltraps>

001013df <vector233>:
.globl vector233
vector233:
  pushl $0
  1013df:	6a 00                	push   $0x0
  pushl $233
  1013e1:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
  1013e6:	e9 76 f6 ff ff       	jmp    100a61 <__alltraps>

001013eb <vector234>:
.globl vector234
vector234:
  pushl $0
  1013eb:	6a 00                	push   $0x0
  pushl $234
  1013ed:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
  1013f2:	e9 6a f6 ff ff       	jmp    100a61 <__alltraps>

001013f7 <vector235>:
.globl vector235
vector235:
  pushl $0
  1013f7:	6a 00                	push   $0x0
  pushl $235
  1013f9:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
  1013fe:	e9 5e f6 ff ff       	jmp    100a61 <__alltraps>

00101403 <vector236>:
.globl vector236
vector236:
  pushl $0
  101403:	6a 00                	push   $0x0
  pushl $236
  101405:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
  10140a:	e9 52 f6 ff ff       	jmp    100a61 <__alltraps>

0010140f <vector237>:
.globl vector237
vector237:
  pushl $0
  10140f:	6a 00                	push   $0x0
  pushl $237
  101411:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
  101416:	e9 46 f6 ff ff       	jmp    100a61 <__alltraps>

0010141b <vector238>:
.globl vector238
vector238:
  pushl $0
  10141b:	6a 00                	push   $0x0
  pushl $238
  10141d:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
  101422:	e9 3a f6 ff ff       	jmp    100a61 <__alltraps>

00101427 <vector239>:
.globl vector239
vector239:
  pushl $0
  101427:	6a 00                	push   $0x0
  pushl $239
  101429:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
  10142e:	e9 2e f6 ff ff       	jmp    100a61 <__alltraps>

00101433 <vector240>:
.globl vector240
vector240:
  pushl $0
  101433:	6a 00                	push   $0x0
  pushl $240
  101435:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
  10143a:	e9 22 f6 ff ff       	jmp    100a61 <__alltraps>

0010143f <vector241>:
.globl vector241
vector241:
  pushl $0
  10143f:	6a 00                	push   $0x0
  pushl $241
  101441:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
  101446:	e9 16 f6 ff ff       	jmp    100a61 <__alltraps>

0010144b <vector242>:
.globl vector242
vector242:
  pushl $0
  10144b:	6a 00                	push   $0x0
  pushl $242
  10144d:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
  101452:	e9 0a f6 ff ff       	jmp    100a61 <__alltraps>

00101457 <vector243>:
.globl vector243
vector243:
  pushl $0
  101457:	6a 00                	push   $0x0
  pushl $243
  101459:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
  10145e:	e9 fe f5 ff ff       	jmp    100a61 <__alltraps>

00101463 <vector244>:
.globl vector244
vector244:
  pushl $0
  101463:	6a 00                	push   $0x0
  pushl $244
  101465:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
  10146a:	e9 f2 f5 ff ff       	jmp    100a61 <__alltraps>

0010146f <vector245>:
.globl vector245
vector245:
  pushl $0
  10146f:	6a 00                	push   $0x0
  pushl $245
  101471:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
  101476:	e9 e6 f5 ff ff       	jmp    100a61 <__alltraps>

0010147b <vector246>:
.globl vector246
vector246:
  pushl $0
  10147b:	6a 00                	push   $0x0
  pushl $246
  10147d:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
  101482:	e9 da f5 ff ff       	jmp    100a61 <__alltraps>

00101487 <vector247>:
.globl vector247
vector247:
  pushl $0
  101487:	6a 00                	push   $0x0
  pushl $247
  101489:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
  10148e:	e9 ce f5 ff ff       	jmp    100a61 <__alltraps>

00101493 <vector248>:
.globl vector248
vector248:
  pushl $0
  101493:	6a 00                	push   $0x0
  pushl $248
  101495:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
  10149a:	e9 c2 f5 ff ff       	jmp    100a61 <__alltraps>

0010149f <vector249>:
.globl vector249
vector249:
  pushl $0
  10149f:	6a 00                	push   $0x0
  pushl $249
  1014a1:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
  1014a6:	e9 b6 f5 ff ff       	jmp    100a61 <__alltraps>

001014ab <vector250>:
.globl vector250
vector250:
  pushl $0
  1014ab:	6a 00                	push   $0x0
  pushl $250
  1014ad:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
  1014b2:	e9 aa f5 ff ff       	jmp    100a61 <__alltraps>

001014b7 <vector251>:
.globl vector251
vector251:
  pushl $0
  1014b7:	6a 00                	push   $0x0
  pushl $251
  1014b9:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
  1014be:	e9 9e f5 ff ff       	jmp    100a61 <__alltraps>

001014c3 <vector252>:
.globl vector252
vector252:
  pushl $0
  1014c3:	6a 00                	push   $0x0
  pushl $252
  1014c5:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
  1014ca:	e9 92 f5 ff ff       	jmp    100a61 <__alltraps>

001014cf <vector253>:
.globl vector253
vector253:
  pushl $0
  1014cf:	6a 00                	push   $0x0
  pushl $253
  1014d1:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
  1014d6:	e9 86 f5 ff ff       	jmp    100a61 <__alltraps>

001014db <vector254>:
.globl vector254
vector254:
  pushl $0
  1014db:	6a 00                	push   $0x0
  pushl $254
  1014dd:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
  1014e2:	e9 7a f5 ff ff       	jmp    100a61 <__alltraps>

001014e7 <vector255>:
.globl vector255
vector255:
  pushl $0
  1014e7:	6a 00                	push   $0x0
  pushl $255
  1014e9:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
  1014ee:	e9 6e f5 ff ff       	jmp    100a61 <__alltraps>
