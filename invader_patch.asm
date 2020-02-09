;=============================
;PC-8001 "INVADER"用
;サウンドパッチ
;2020/02/09
;
;USAGE: MON+GCE00
;=============================

FALSE	EQU	00H

BOMBB	EQU	00000001B	;爆発音
BEAMB	EQU	00000010B	;ビーム発射音
UFOHITB	EQU	00000100B	;UFOヒット音
THITB	EQU	00001000B	;ターゲットヒット音
STEPB	EQU	00010000B	;行進音
UFOB	EQU	00100000B	;UFO飛行音
PORT	EQU	10H		;サウンドボードのポート番号
EOD	EQU	0FFH		;データエンドマーカー

GPUT	EQU	0D180H
Z0060	EQU	0D304H
Z0093	EQU	0D4DBH
Z0212	EQU	0D4E6H
UFOPCLR	EQU	0D5F4H
Z0226	EQU	0DB09H
Z0345	EQU	0DF48H
INIT01	EQU	0DF80H
INIT03	EQU	0E150H
FONT	EQU	0E200H
INIT02	EQU	0E210H
Z0071	EQU	0E3DAH
GDAD	EQU	0E410H
GSIZE	EQU	0E412H
INVLEFT	EQU	0E41FH
Z0102	EQU	0E421H
Z0087	EQU	0E422H
UFOODD	EQU	0E42BH
CLOCK	EQU	0E44BH
INVFORM	EQU	0E450H

;=============================

	ORG	0CE00H

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

;-----------------------------
;レインボーボーナス判定
;-----------------------------
BONUS:
	LD	A,(Z0087)	;最後に加算されたポイントが01Hならボーナス確定
	CP	01H		;
	JR	NZ,.EXIT	;

	LD	C,UFOB
	CALL	PLAYSND

	LD	B,03H
.L1:	PUSH	BC
	CALL	RAINBOW
	CALL	RAINBOW_CLR
	POP	BC
	DJNZ	.L1
	CALL	RAINBOW
	CALL	SNDINIT

	LD	A,08H
.L2:	LD	B,00H
	CALL	WAIT
	DEC	A
	JR	NZ,.L2

	LD	IX,Z0102	;ポイント加算
	LD	A,50H		;
	LD	(IX+1D),A	;
	CALL	Z0212		;

.EXIT:	JP	0DEE3H		;

;-----------------------------
;ボーナスメッセージ
;-----------------------------
BONUS_TXT:
	DB	46H,94H,8EH,0B8H,0ACH,0FAH,028H,094H,094H,0FAH,09AH,094H,070H,08EH,0B2H,0ACH,0FFH	;"BONUS 500 POINTS"


;-----------------------------
;IN	B=長さ MAX 00H
;-----------------------------
WAIT:
	LD	C,00H
.L1:	DEC	C
	JR	NZ,.L1
	DJNZ	.L1
	RET

;-----------------------------
;レインボー表示
;-----------------------------
RAINBOW:
	LD	HL,BONUS_TXT	;
	LD	DE,0FDDAH	;
	CALL	GPRT		;

	LD	H,27H
	LD	L,16H
	LD	B,01H
	LD	C,01H

.L1:	PUSH	BC

	CALL	RBSUB1
	CALL	RBSUB2
	CALL	RBSUB3
	DEC	L
	DEC	L

	LD	B,40H
	CALL	WAIT

	POP	BC
	INC	C
	INC	B
	LD	A,C
	CP	0AH
	JR	NZ,.L1
	RET

;-----------------------------
;レインボー消去
;-----------------------------
RAINBOW_CLR:
	LD	H,00H
	LD	L,19H
	LD	B,18H

.L1:	PUSH	BC
	PUSH	HL

	CALL	03F3H
	LD	B,50H
	XOR	A
.L2:	LD	(HL),A
	INC	HL
	DJNZ	.L2

	POP	HL
	DEC	L

	POP	BC
	DJNZ	.L1
	RET


;-----------------------------
;レインボーサブ１
;IN	H=X,L=Y,C=N
;-----------------------------
RBSUB1:	PUSH	HL
	PUSH	BC
	CALL	03F3H		;(H,L)->VRAM HL
	LD	A,0F0H
	LD	(HL),A
	POP	BC
	POP	HL
	RET

;-----------------------------
;レインボーサブ２
;IN	H=X,L=Y,C=N
;-----------------------------
RBSUB2:
	PUSH	BC
	PUSH	HL

	DEC	C
	JR	Z,.EXIT

.L1:	LD	A,H
	SUB	C
	JR	C,.EXIT

	LD	H,A
	CALL	RBSUB1
	DJNZ	.L1

.EXIT:	POP	HL
	POP	BC
	RET

;-----------------------------
;レインボーサブ３
;IN	H=X,L=Y,C=N
;-----------------------------
RBSUB3:
	PUSH	BC
	PUSH	HL

	DEC	C
	JR	Z,.EXIT

.L1:	LD	A,H
	ADD	A,C
	CP	4EH		;=78
	JR	NC,.EXIT

	LD	H,A
	CALL	RBSUB1
	DJNZ	.L1

.EXIT:	POP	HL
	POP	BC
	RET

;-----------------------------
;文字列をセミグラで出力する
;IN	DE=VRAM,HL=データ格納アドレス
;-----------------------------
GPRT:	LD	(GP1),HL	;
	LD	(GP2),DE	;
.L1:	LD	HL,(GP1)	;
	LD	DE,(GP2)	;
	LD	A,(HL)		;
	CP	0FFH		;
	RET	Z		;
	INC	HL		;
	LD	(GP1),HL	;
	PUSH	DE		;
	INC	DE		;
	INC	DE		;
	INC	DE		;
	LD	(GP2),DE	;
	POP	DE		;
	LD	HL,FONT		;
	LD	B,00H		;
	LD	C,A		;
	ADD	HL,BC		;
	LD	(GDAD),HL	;
	LD	A,06H		;
	LD	(GSIZE),A	;
	CALL	GPUT		;
	JR	.L1		;

;=============================
;パッチデータ
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

;"SPACE INVADER"
	DW	0DB74H
	DB	06H
	LD	DE,0F4F4H
	LD	HL,TITLE

;レインボーボーナス処理＆ステージクリア後のウェイトカット
	DW	0DF26H
	DB	03H
	JP	BONUS

;フォント "5"
	DW	0E228H
	DB	06H
	DB	0AEH,0AAH,02H,84H,88H,07H

;END OF DATA
	DB	00H,00H,00H

;=============================
;ワークエリア
;=============================

SND:	DB	00H		;ポート10Hに出力した値
STEPC:	DB	00H		;ステップ音発生用カウンタ
STEPD:	DB	00H		;ステップ音停止用カウンタ
GP1:	DB	00H,00H		;GPRT用
GP2:	DB	00H,00H		;GPRT用

