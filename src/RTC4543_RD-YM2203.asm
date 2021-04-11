;
; RTC4543SA READ (YM2203 Board for PC-8001)
;
;
; N-BASICのUSR関数で呼ぶ
;

; 入力パラメーター
;   DE   : ストリングディスクリプタアドレス
;   ストリングディスクリプタ
;   +00 - 文字列長
;   +01 - 文字格納アドレス下位バイト
;   +02 - 文字格納アドレス上位バイト
    org 0A100h
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
;------------------------------------
; 処理メイン
;------------------------------------
MAIN:
    INC DE
    LD A,(DE)
    LD L,A
    INC DE
    LD A,(DE)
    LD H,A
;
    CALL INIT_OPN
    CALL WR_OFF_SET
    CALL CE_ON_SET
;
    LD DE,12
    ADD HL,DE
;
; 秒 取得 
    LD C,4
    CALL GET_DATA
    CALL SET_RESULT
    LD C,3
    CALL GET_DATA
    CALL SET_RESULT
; -- FDT受け捨て
    LD C,1
    CALL GET_DATA
;
; 分 取得 
    LD C,4
    CALL GET_DATA
    CALL SET_RESULT
    LD C,3
    CALL GET_DATA
    CALL SET_RESULT
; -- ユーザービット受け捨て
    LD C,1
    CALL GET_DATA
;
; 時 取得 
    LD C,4
    CALL GET_DATA
    CALL SET_RESULT
    LD C,2
    CALL GET_DATA
    CALL SET_RESULT
; -- ユーザービット受け捨て
    LD C,2
    CALL GET_DATA
;
; 曜日 取得 
    LD C,3
    CALL GET_DATA
    CALL SET_RESULT
; -- ユーザービット受け捨て
    LD C,1
    CALL GET_DATA
; 日 取得 
    LD C,4
    CALL GET_DATA
    CALL SET_RESULT
    LD C,2
    CALL GET_DATA
    CALL SET_RESULT
; -- ユーザービット受け捨て
    LD C,2
    CALL GET_DATA
;
; 月 取得 
    LD C,4
    CALL GET_DATA
    CALL SET_RESULT
    LD C,1
    CALL GET_DATA
    CALL SET_RESULT
; -- ユーザービット受け捨て
    LD C,3
    CALL GET_DATA
;
; 年 取得 
    LD C,4
    CALL GET_DATA
    CALL SET_RESULT
    LD C,4
    CALL GET_DATA
    CALL SET_RESULT
;
    CALL CE_OFF_SET
;
    RET
;

;------------------------------------
; 結果文字セット
;------------------------------------
SET_RESULT:
    ADD A,30h   ; 数字文字コードへ
    LD (HL),A
    DEC HL
    RET

;------------------------------------
; 指定ビット(Cレジスタ)分 読み出し Aレジスタへ
;------------------------------------
GET_DATA:
    LD D,C
    INC D
    LD B,0
_GET_DATA_LOOP:
    CALL CLK1
;
    LD A,OPN_REG_IOA
    OUT (OPN_CTL),A
;
    IN A,(OPN_DATA)
    AND 01h
    CALL NZ,_SHIFT_BIT
    ADD A,B
    LD B,A
    DEC C
    RET Z
    JR _GET_DATA_LOOP

_SHIFT_BIT:
    PUSH BC
    PUSH AF
    LD A,D
    SUB A,C
    LD C,A
    POP AF
_SHIFT_BIT_LOOP:
    DEC C
    JR Z,_SHIFT_BIT_END
    SLA A
    JR _SHIFT_BIT_LOOP
_SHIFT_BIT_END:
    POP BC
    RET

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
    AND A,OPN_A_IN
    OR  A,OPN_B_OUT
    LD  (OPN_CTL_DATA),A
    OUT (OPN_DATA),A
;
    LD A,OPN_REG_IOB
    OUT (OPN_CTL),A
    LD  A,0
    OR  A,WR_ON
    AND A,CE_OFF
    OUT (OPN_DATA),A
    NOP
    NOP
    LD  (OPN_IOB_DATA),A
;
    RET
;
;
; RAM
DATE_STR_PTR DS 2
STR_PTR      DS 2
STR_LEN      DS 1
OPN_CTL_DATA DS 1
OPN_IOB_DATA DS 1

    END