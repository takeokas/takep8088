

all: test1 test2 usart mem mem2 loader tst tst2 xmodem

xmodem: xmodem.asm
	nasm -f bin -l xmodem.lst  $<  # bin
	cp -p xmodem* ~/tmp/

tst2: tst2.asm
	nasm -f bin -l tst2.lst  $<  # bin
	cp -p tst2* ~/tmp/

tst: tst.asm
	nasm -f bin -l tst.lst  $<  # bin
	cp -p tst* ~/tmp/

loader: loader.asm
	nasm -f bin -l loader.lst  $<  # bin
	#nasm  -l loader.lst  $<  # bin
	cp -p loader* ~/tmp/

mem2: mem2.asm
	nasm -f bin -l mem2.lst  $<  # bin
	cp -p mem2* ~/tmp/

mem: mem.asm
	nasm -f srec  $<   # motorola S-Rec
	nasm -f bin -l mem.lst  $<  # bin
	cp -p mem* ~/tmp/

usart: usart.asm
	nasm -f srec  $<   # motorola S-Rec
	nasm -f bin -l usart.lst  $<  # bin
	cp -p usart* ~/tmp/

test2: test2.asm
	nasm -f srec  $<   # motorola S-Rec
	nasm -f bin -l test2.lst  $<  # bin
	cp -p test2* ~/tmp/

test1: test1.asm
	nasm -f srec  $<   # motorola S-Rec
	nasm -f bin -l test1.lst  $<  # bin
	#nasm -f bin -o test1 $<  # bin
	#nasm test1.asm
	cp -p test1* ~/tmp/


test0v2: test0v2.asm
	nasm -f srec  $<   # motorola S-Rec
	nasm -f ith -o test0v2.ith $<  # Intel Hex
	nasm -f bin -o test0v2 $<  # bin
	#nasm test0v2.asm
	cp -p test0v2* ~/tmp/


distest0v2: test0v2
	ndisasm test0v2
