# takep8088
8088 Single Board Computer  

<img src=https://github.com/takeokas/takep8088/blob/main/IMG_8818.jpg width=200 >
<img src=https://github.com/takeokas/takep8088/blob/main/IMG_8819.jpg width=200 >

## Spec  
- S-RAM 1MBytes  
--  全メモリ空間  
-- AS6C4008-55PCN (512KW×8bit)2チップ  

- ROM 64Bytes  
-- SST 27SF512(EEPROM)  
-- 27C512互換であれば使用可能、2764あたりからそのまま差し込めるはず  
-- 出力ポートのアクセスで、後半512MをROM/RAM切り替え  

- Crystal 14.7456MHz  
-- 8251(USART) の baud rate generation に、いい感じの周波数  
-- CPU は、約 4.9MHz で動作  
-- 周辺IOのクロックは、約2.45MHz  

※ワイヤがあるのは、設計どおり  
-- 引き回しを諦めた…orz  

## ボード  
<img src=https://github.com/takeokas/takep8088/blob/main/takep8088-jumper.png width=200>

- ジャンパ J1
-- 8251(USART)のボーレート・ジェネレータの周波数選択  
  19200/9600/4800 bps  (f/1の場合)  
  
- ジャンパ JP1  
-- フリーランニング・タイマの周期選択  
  18.75Hz / 9.375Hz


## 回路
### 7405: 割込み 要求  
-- 7405の入力は、反転されて、すべてワイアードORして反転して、8088のINT(割込み要求)に接続  
-- 7405のopenな端子は、PullDownの必要あり  
-- 後から付けた機器からの割込み要求は、7405の空き端子に接続するとよい  

### 8251 TX Empty 割込み 要求  
-- 8251の RX割込みは、PCBで7405に接続済み  
-- 8251の TXE(empty)割込み使うよね!  
-- 自分で、7405 に配線してください ＼(^^;／  
-- PCBのレイアウトを諦めた=それが設計だっ  

### 余りゲート  
-- U1,74LS14: B(3,4),C(5,6),F(13,12)  
-- U12,74LS00: A(1,2,3),B(4,5,6)  
-- U24,74LS00: C(10,9,8),D(13,12,11)  
-- U23,74LS74: B(8-13)  

## IOポート  
###  IO port address  

   00-03 : usart0 (rw) USART レジスタ; 通常 00と01 を使用する  
   04-07 : sw1 (rd);  D0: SWの値を読む, D1: timerIRQ の確認  
   08-0B : timer-irq-clr (wr); timer IRQのクリア  
   0C-0F : sysreg (wr),D0:/rom0-ena=0でROM, 1でRAM1, D1:timer-int-ena=1でtimer割込み可, D2:led2, D3:led3  
  
   10-13 : inport2(rd),  D0: U18[2pin]=NC, D1:U18[4pin]=NC;U18=74LS367  
   14-17 :   
   18-1B :   
   1C-1F :   
   
### IO port 説明  
- sysreg (WR) 0x0C ; U5,74LS174  
-- D0: /rom0-ena (reset:0), 0:ROM0 / 1:RAM1 (メモリ空間後半 A19==1 を ROM/RAM切り替え)  
-- D1: timer-int-ena (reset:0), 0:disable / 1:enable  
-- D2: LED2 (resetで0, 点灯)  
-- D3: LED3 (resetで0, 点灯)  
-- D4: (U5 Q4)Open  
-- D5: (U5 Q5)Open  
  
- SW1 (RD) 0x04  
-- D0: SW  
-- D1 : free running timer IRQ 読み出し  
  
- timer-irq-clr  (WR) 0x08  
-- free running timer INT clear  
-- 1/(2^18) カウンタ割り込みクリア  
  
- inport2(rd) 0x10  
-- U18=74LS367  
-- D0: U18[2pin]=NC, D1:U18[4pin]=NC;  
-- D2: U18[6pin]=NC, D5:U18[10pin]=NC;   
※D3,D4 は飛ばしている(配線の困難性から)

