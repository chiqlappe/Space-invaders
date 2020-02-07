;=============================
;PC-8001 "INVADER"用
;サウンドパッチ
;2020/02/07
;
;USAGE: MON+GCF00
;=============================

FALSE	EQU	0

BOMBB	EQU	00000001B	;爆発音
BEAMB	EQU	00000010B	;ビーム発射音
UFOHITB	EQU	00000100B	;UFOヒット音
THITB	EQU	00001000B	;ターゲットヒット音
STEPB	EQU	00010000B	;行進音
UFOB	EQU	00100000B	;UFO飛行音
PORT	EQU	10H		;サウンドボードのポート番号

EOD	EQU	0FFH		;データエンドマーカー

Z0060	EQU	0D304H
UFOPCLR	EQU	0D5F4H
Z0226	EQU	0DB09H
Z0345	EQU	0DF48H
INIT01	EQU	0DF80H
INIT03	EQU	0E150H
INIT02	EQU	0E210H
Z0071	EQU	0E3DAH
INVLEFT	EQU	0E41FH
UFOODD	EQU	0E42BH
CLOCK	EQU	0E44BH
INVFORM	EQU	0E450H


	ORG	0CF00H

;-----------------------------
;パッチを当てる
;-----------------------------
PATCH:
	LD	HL,PATCH_DATA
.L1:	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	C,(HL)
	INC	HL
	LD	B,00H
	LD	A,C
	AND	A
	JP	Z,5C66H
	LDIR
	JR	.L1

;-----------------------------
;サウンドボードを初期化する
;-----------------------------
SNDINIT:
	LD	A,0FFH
	OUT	(PORT),A
	LD	(SND),A
	RET

;-----------------------------
;音を発生
;IN	C=ビットパターン
;-----------------------------
PLAYSND:
	IN	A,(08H)		;カナキーが押下されているか？
	AND	00100000B	;
	RET	Z		;

	LD	A,(SND)
	OR	C
	OUT	(PORT),A
	XOR	C
	OUT	(PORT),A
	LD	(SND),A
	RET

;-----------------------------
;音を停止
;IN	C=ビットパターン
;-----------------------------
STOPSND:
	LD	A,(SND)
	OR	C
	OUT	(PORT),A
	LD	(SND),A
	RET

;-----------------------------
;ビーム発射音
;-----------------------------
BEAM:
	LD	C,BEAMB
	CALL	PLAYSND
	JP	Z0060

;-----------------------------
;UFO飛行音
;-----------------------------
UFO:
	LD	(UFOODD),A
	LD	C,UFOB
	JP	PLAYSND

;-----------------------------
;UFO飛行音＆ヒット音停止
;-----------------------------
UFO_STOP:
	LD	C,UFOB+UFOHITB
	JP	STOPSND

;-----------------------------
;UFOヒット音
;-----------------------------
UFOHIT:
	CALL	UFO_STOP
	LD	C,UFOHITB
	JP	PLAYSND

;-----------------------------
;ターゲットヒット音
;-----------------------------
HIT:
	LD	C,THITB
	JP	PLAYSND

;-----------------------------
;ビームカー爆発音
;-----------------------------
BOMB:
	LD	C,BOMBB
	CALL	PLAYSND

	LD	HL,0F353H
	RET

;-----------------------------
;ビームカー爆発音停止
;-----------------------------
BOMB_STOP:
	LD	C,BOMBB
	JP	STOPSND


;-----------------------------
;行進音用カウンタ
;-----------------------------
STEP_CNT:
	LD	HL,STEPC
	LD	A,(HL)
	AND	A
	JR	Z,.L1
	DEC	(HL)

.L1:	LD	HL,CLOCK	;
	RET

;-----------------------------
;行進音
;-----------------------------
STEP:
	CALL	UFOPCLR		;

	LD	A,(STEPC)
	AND	A
	JR	NZ,.L1

.L2:	LD	A,04H
	LD	(STEPD),A

	LD	A,(INVLEFT)
	ADD	A,04H
	LD	(STEPC),A

	LD	A,(SND)
	OR	A
	SBC	A,01000000B
	LD	(SND),A
	LD	C,STEPB
	CALL	PLAYSND
	RET

.L1:	LD	HL,STEPD
	DEC	(HL)
	RET	NZ

	LD	C,STEPB
	CALL	STOPSND
	RET


;-----------------------------
;画面消去
;-----------------------------
CLS:
	CALL	SNDINIT

	LD	A,018H		;
	LD	DE,0F378H	;
	CALL	046CH		;
	XOR	A		;
	LD	(Z0071),A	;
	RET			;


;-----------------------------
;ゲームオーバー時
;-----------------------------
GAMEOVER:
	CALL	SNDINIT
	LD	HL,0F4F7H
	RET


;-----------------------------
;ゲームタイトル変更
;-----------------------------
TITLE:	DB	0ACH,9AH,40H,4CH,58H,0FAH,70H,8EH,0BEH,40H,52H,58H,0A6H,0ACH	;"SPACE INVADERS"
	DB	EOD




;=============================



PATCH_DATA:

;初期化
	DW	0E101H
	DB	0FH
	CALL	SNDINIT
	CALL	INIT01
	CALL	INIT02
	CALL	INIT03
	JP	Z0345

;ビーム発射音
	DW	0D2FBH
	DB	03H
	CALL	Z,BEAM

;UFO飛行音
	DW	0D95BH
	DB	03H
	CALL	UFO

	DW	0D95EH
	DB	03H
	DB	00H,00H,00H

	DW	0D9B7H
	DB	03H
	DB	00H,00H,00H

;UFO飛行音停止
	DW	0D9D6H
	DB	03H
	CALL	UFO_STOP

;UFOヒット音
	DW	0DA8AH
	DB	03H
	JP	UFOHIT

	DW	0DA7EH
	DB	01H
	DB	80H

;ターゲットヒット音
	DW	0D466H
	DB	03H
	CALL	HIT

;BEEP音処理を消去
	DW	0DCD2H
	DB	09H
	DB	00H,00H,00H
	DB	00H,00H,00H
	DB	00H,00H,00H

	DW	0DF91H
	DB	09H
	DB	00H,00H,00H
	DB	00H,00H,00H
	DB	00H,00H,00H

;ビームカー爆発音
	DW	0D859H
	DB	03H
	CALL	BOMB

	DW	0D888H
	DB	02H
	NOP
	NOP

	DW	0D86DH
	DB	01H
	DB	03H

;ビームカー爆発音停止
	DW	0D88DH
	DB	03H
	CALL	BOMB_STOP

;ステージクリア時
	DW	0DF79H
	DB	06H
	CALL	SNDINIT
	JP	0DF50H

;画面消去
	DW	0DB09H
	DB	03H
	JP	CLS

;ゲームオーバー時
	DW	0DE80H
	DB	03H
	CALL	GAMEOVER

;ステップ音
	DW	0D5BCH
	DB	03H
	CALL	STEP

;ステップ音用カウンタ
	DW	0D900H
	DB	03H
	CALL	STEP_CNT

;ステージクリア後のウェイトカット
	DW	0DF26H
	DB	03H
	JP	0DEE3H

;"SPACE INVADER"
	DW	0DB74H
	DB	06H
	LD	DE,0F4F4H
	LD	HL,TITLE

;END OF DATA
	DB	00H,00H,00H


SND:	DB	00H		;ポート10Hに出力した値
STEPC:	DB	00H		;ステップ音発生用カウンタ
STEPD:	DB	00H		;ステップ音停止用カウンタ
