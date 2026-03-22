;--------------------------------------
; XMODEM Receive loader (Checksum)
;受信開始時に NAK を送信
;SOH を受信 → 128バイト受信
;チェックサム確認
;OK → ACK / NG → NAK
;EOT を受信したら ACK を返して終了
;受信データは 000400h に格納
;--------------------------------------
; takep8088
USARTD	equ	00h	;8251 data register
USARTC	equ	01h	;8251 control register
;
stack_seg	equ 02000h
stack		equ 00000h ; 0FFFFから前へ
;
	;; Xmodem constants
SOH equ 01h
EOT equ 04h
ACK equ 06h
NAK equ 15h
CAN equ 18h
;
;
;;;  loaded bin top= 00400h, 
recv_objseg equ 040h	;recv obj from 00400h
recv_objoff equ 000h
;
block_no equ 0fff0h		;0400h+fff0h
;
;;; 
;;; 0FFF00h
	section .text
	;org 0ff00h
start_off equ 0ff00h
	TIMES start_off-($-$$) DB 0FFh
;;; 
start:	
	;;; stack<= 02000h 
	mov ax,stack_seg
	mov ss,ax
	mov sp,stack
	;
	;mov ax,data_seg
	;mov ds,ax
	;mov es,ax
	;
	;
;	8251 setup
	mov	dx,USARTC
	mov	al,00h	;Default mode or no operation
	out	dx,al	;Try command
	out	dx,al	;Try command
	out	dx,al	;Try command
	mov	al,40h	;reset
	out	dx,al	;Out it
	mov	CX,16	;Delay
	loop	$	;Delay
	mov	al,4eh	;mode
	out	dx,al	;Out it
	mov	al,37h	;command
	out	dx,al	;Out it
	;; end of 8251 setup
	mov al,"*"
	call putc
;
xmodem_start:
    mov ax,recv_objseg
    mov ds,ax
    mov es,ax
    ;
    ;mov al,1
    ;mov [block_no], al
    mov byte [block_no], 1
	;; 
    call send_nak    ; 最初の NAK
    mov di,recv_objoff
	;; 
main_loop:
    call getc
    cmp al, SOH
    je recv_block
    cmp al, EOT
    je recv_eot
    jmp main_loop

;--------------------------
; 128バイトブロック受信
;--------------------------
recv_block:
    call getc         ; block number
    mov bl, al
    ;
    call getc         ; inverted block number
    not al
    cmp al, bl
    jne block_error
    ;
    cmp bl, [block_no]
    jne block_error
    ; データ受信
    mov cx, 128
    xor dh, dh             ; checksum=0
    ;
recv_data:
    call getc
    mov [di], al
    add dh, al ; checksum +=al
    inc di
    loop recv_data
    ;
    call getc	;recv checksum
    cmp al, dh    ; check チェックサム    
    jne block_error
    ; OK
    call send_ack
    inc byte [block_no]
    jmp main_loop
	;;
block_error:
    call send_nak
    jmp main_loop

;--------------------------
; EOT処理 & jump to loaded Obj
;--------------------------
recv_eot:
	call send_ack
	;; display hex dump
	mov di,0400h		; 00400 番地から
	mov cx,100
ld01:	
	MOV  al,[DI]
	call hex
	INC  DI
	LOOP  ld01
	;; jump to loaded obj
	jmp  040h:0h ;db 0eah ;jmp far, offset, segment; start=400h{cs=40h,pc=00h}
	;; 
;;; 
send_ack:
    mov al, ACK
    jmp putc

send_nak:
    mov al, NAK
    jmp putc

;--------------------------
; Serial I/O
;--------------------------
send_char:
putc:	push ax
putc1:	in	al,USARTC	;Get status
	and	al,01h		;check TxBUF empty
	jz	putc1		;wait for empty
	pop	ax		;Restore char
	out	USARTD,al	;Out it
	ret
	;; end of putc

recv_char:
getc:	
getc1:
	;;; himatubusi SW->LED
	in al,04h		;read SW1
	add al,al
	add al,al
	out 0Ch,al		;out LED
	;;; 
	in	al,USARTC	;Get status
	and	al,02h		;check RxBUF full
	jz	getc1		;wait for empty
	in	al,USARTD	;Get Char
	ret
	;; end of getc
;;; 
hex:
	push ax
	;shr al,4
	shr al,1
	shr al,1
	shr al,1
	shr al,1
	call hexlo
	pop ax
hexlo:
	and al,0Fh
	add al, 90h
	daa
	adc al, 40h
	daa
	;jmp putc
	call putc
	ret
;;; 

;;;
;;;
;;;
	; Reset  at FFFF0h
	;section .text
        ;org     0fff0h		;offset
reset_off equ 0fff0h
	TIMES reset_off-($-$$) DB 0FFh
	;
        db      0eah    ;jmp far
        dw      start   ;offset
        dw      0F000h   ;segment
                        ;

;--------------------------
; Data Area
;--------------------------
;block_no:	db 1
;buffer:	db 128 dup (0)

;end
