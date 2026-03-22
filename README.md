# takep8088
8088 Single Board Computer  

<img src=https://github.com/takeokas/takep8088/blob/main/front.jpg width=200 >
<img src=https://github.com/takeokas/takep8088/blob/main/back.jpg width=200 >

## Spec  
- S-RAM 1MBytes  
--  全メモリ空間  
-- AS6C4008-55PCN (512KW×8bit)2チップ  
-- リセット直後は、メモリ空間の後半 512K は、ROM  
-- 出力ポートのアクセスで、後半512KをROM/RAM切り替え  

- ROM 64Bytes  
-- SST 27SF512(EEPROM)  
-- 27C512互換であれば使用可能、2764あたりからそのまま差し込めるはず  

- SIO 8251(USART)  
-- ジャンパ J1 で、ボーレート用クロックの周波数を選択可能  
-- 秋月で販売されている FTDI USBシリアル変換ケーブル(5V) が直接 差せる  
--  https://akizukidenshi.com/catalog/g/g105841/    

- フリーランニング・タイマ  
  18.75Hz / 9.375Hz を JP1 で、選択可能  

- Crystal 14.7456MHz  
-- 8251(USART) の baud rate generation に、いい感じの周波数  
-- CPU は、約 4.9MHz で動作  
-- 周辺IOのクロックは、約2.45MHz  

## ボード  
<img src=https://github.com/takeokas/takep8088/blob/main/takep8088-jumper.png width=200>

- ジャンパ J1  
-- 8251(USART)のボーレート・ジェネレータの周波数選択  
  19200/9600/4800 bps  (f/1の場合)  
  
- ジャンパ JP1  
-- フリーランニング・タイマの周期選択  
  18.75Hz / 9.375Hz

- ワイヤリング  
<img src=https://github.com/takeokas/takep8088/blob/main/takep-wiring.png  width=400>

-- 8251 TX Empty割込みを使用する場合は、7405 の空き入力端子に、8251-TXE を接続する  
-- 7405 の空き入力ピンは、(手配線などで) 必ず GND へ、接続する。さもないと、Interrupt Enableした途端に、割込みが発生する。  
-- U20 74139が、74HC139 のときは、空き入力ピンを、DT-R、SS0 に接続すること。74LS139など TTL のときは、open のママでも支障ない。  

※ワイヤがあるのは、設計どおり  
-- PCBレイアウト中に、引き回しを諦めただけ…orz  


## 回路
### 7405: 割込み 要求  
-- 7405の入力は、反転されて、すべてワイアードORして反転して、8088のINT(割込み要求)に接続  
-- 7405のopenな端子は、自分で(手ハンダで?)、PullDownの必要あり  
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

## その他  
- HOLD を、Vcc に、手動で接続してみると、CPU の実行が停止し、HLDA LEDが点灯する  
- HOLD を使用する機器は、HOLD 端子に接続するとよい(PCB では、Pull Downしているのみ)  

