;
; RTC4543SA WRITE (YM2203 Board for PC-8001)
;
    org 0A000h
;
; N-BASICのUSR関数で呼ぶ
;

; 入力パラメーター
;   DE   : ストリングディスクリプタアドレス
;   ストリングディスクリプタ
;   +00 - 文字列長
;   +01 - 文字格納アドレス下位バイト
;   +02 - 文字格納アドレス上位バイト
;


NULL    EQU 00h
;
OPN_CTL EQU 080h
OPN_DATA EQU 081h
OPN_B_OUT EQU 080h
OPN_A_OUT EQU 040h
OPN_B_IN EQU 07Fh
OPN_A_IN EQU 0BFh
OPN_REG_CTL  EQU 07h
OPN_REG_IOA  EQU 0Eh
OPN_REG_IOB  EQU 0Fh
;
CE_ON   EQU 040h
CE_OFF  EQU 0BFh
WR_ON   EQU 020h
WR_OFF  EQU 0DFh
CLK_ON  EQU 010h
CLK_OFF EQU 0EFh
;
START:
    LD (STR_PTR),DE
    LD A,(DE)
    LD (STR_LEN),A
    INC DE
    LD A,(DE)
    LD L,A
    INC DE
    LD A,(DE)
    LD H,A
    LD (DATE_STR_PTR),HL
    CALL MAIN
    RET
;
;------------------------------------
; 処理メイン
;------------------------------------
MAIN:
    CALL INIT_OPN
    CALL WR_ON_SET
    CALL CE_ON_SET
;
    LD HL,(DATE_STR_PTR)
    LD B,13
    LD DE,12
    ADD HL,DE      ; 指定文字列の最後をポイント
;
_MAIN_LOOP:
    LD A,(HL)
    SUB A,30h       ; 数字の文字コードをBCDへ
;
    LD C,4          ; 4bit分処理
_OUT_LOOP:
    RRC A
    JP C,_ON_OUT
    PUSH AF
    LD A,00h
    JR _RTC_OUT
_ON_OUT:
    PUSH AF
    LD A,01h
_RTC_OUT:
    PUSH AF
    LD A,OPN_REG_IOA
    OUT (OPN_CTL),A
    POP AF
;
    OUT (OPN_DATA),A
    CALL CLK1       ; 1Clock
    POP AF
    DEC C
    JR NZ,_OUT_LOOP
;
    DEC HL
    DEC B
    JR NZ,_MAIN_LOOP
;
    CALL CE_OFF_SET
    CALL WR_OFF_SET
;
    RET
;
;------------------------------------
; 1クロック ON→OFF
;------------------------------------
CLK1:
    LD A,OPN_REG_IOB
    OUT (OPN_CTL),A
;
    LD A,(OPN_IOB_DATA)
    OR CLK_ON
    OUT (OPN_DATA),A
    PUSH AF
    LD A,A          ; DUMMY
    LD A,A          ; DUMMY
    LD A,A          ; DUMMY
    LD A,A          ; DUMMY
    LD A,OPN_REG_IOB
    OUT (OPN_CTL),A
    POP AF
    AND CLK_OFF
    OUT (OPN_DATA),A
    LD (OPN_IOB_DATA),A
    RET

;------------------------------------
; WRピン ON
;------------------------------------
WR_ON_SET:
    LD A,OPN_REG_IOB
    OUT (OPN_CTL),A
;    
    LD A,(OPN_IOB_DATA)
    OR WR_ON
    OUT (OPN_DATA),A
    LD (OPN_IOB_DATA),A
    RET
;------------------------------------
; WRピン OFF
;------------------------------------
WR_OFF_SET:
    LD A,OPN_REG_IOB
    OUT (OPN_CTL),A
;
    LD A,(OPN_IOB_DATA)
    AND WR_OFF
    OUT (OPN_DATA),A
    LD (OPN_IOB_DATA),A
    RET

;------------------------------------
; CEピン ON
;------------------------------------
CE_ON_SET:
    LD A,OPN_REG_IOB
    OUT (OPN_CTL),A
;    
    LD A,(OPN_IOB_DATA)
    OR CE_ON
    OUT (OPN_DATA),A
    LD (OPN_IOB_DATA),A
    RET
;------------------------------------
; CEピン OFF
;------------------------------------
CE_OFF_SET:
    LD A,OPN_REG_IOB
    OUT (OPN_CTL),A
;
    LD A,(OPN_IOB_DATA)
    AND CE_OFF
    OUT (OPN_DATA),A
    LD (OPN_IOB_DATA),A
    RET

;------------------------------------
; OPN初期化 ポートA IN、ポートB OUT
;------------------------------------
INIT_OPN:
    LD A,OPN_REG_CTL
    OUT (OPN_CTL),A
    IN  A,(OPN_DATA)
    OR  A,OPN_A_OUT
    OR  A,OPN_B_OUT
    LD  (OPN_CTL_DATA),A
    OUT (OPN_DATA),A
;
    LD A,OPN_REG_IOB
    OUT (OPN_CTL),A
    LD  A,0
    AND A,WR_OFF
    AND A,CE_OFF
    OUT (OPN_DATA),A
    NOP
    NOP
    LD  (OPN_IOB_DATA),A
;
    RET
;
; RAM
DATE_STR_PTR DS 2
STR_PTR      DS 2
STR_LEN      DS 1
OPN_CTL_DATA DS 1
OPN_IOB_DATA DS 1
