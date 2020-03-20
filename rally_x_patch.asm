;=============================
;PC-8001 "RALLY-X"�p�p�b�`
;2020/03/20
;
;�Q�[���{�̂����[�h��ɂ��̃v���O������A800H������s���ĉ�����
;BGM�ǉ��p�b�`�͂��̃p�b�`�𓖂ĂĂ�����s���ĉ�����
;
;=============================

FALSE		EQU	00H
TRUE		EQU	!FALSE

PLAYER_ADRS	EQU	08040H
PLAY_SONG	EQU	PLAYER_ADRS + 010H
INIT_BGM	EQU	PLAYER_ADRS + 013H
PLAY_BGM	EQU	PLAYER_ADRS + 016H
STOP_PCG	EQU	PLAYER_ADRS + 019H
PLAY_SONG_NUM	EQU	0A03AH
SONG_NUMBER	EQU	0A0F0H
BGMMARK		EQU	0E1H
BGM		EQU	8B00H

ROUND		EQU	0BBE7H

;-----------------------------

	ORG	0A800H

	LD	HL,PATCH_DATA
.L1:	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL

	LD	A,D
	OR	E
	JP	Z,5C66H

	LD	C,(HL)
	INC	HL
	LD	B,00H
	LDIR
	JR	.L1

;=============================
;�p�b�`�f�[�^
;=============================

PATCH_DATA:

;�Q�[���X�s�[�h
P1:	DW	0D001H
	DB	P2-$-1
	DB	02H		;1~3 1=�ō���

;���b�L�[�`�F�b�N�|�C���g����
P2:	DW	0E7F8H
	DB	P3-$-1
	DB	00H,00H

;�}�C�J�[��������
P3:	DW	0E5DFH
	DB	P4-$-1
	DB	40H		;������Z������

;���S�ύX
P4:	DW	0E4FAH
	DB	P5-$-1
	DB	80H,88H,08H,00H,88H,08H,80H,88H,08H,00H,88H,88H,00H,88H,08H	;"namco"
	DB	0F0H,00H,0F0H,0E0H,0AAH,0FAH,0F0H,0F0H,0F0H,70H,88H,88H,70H,88H,78H

;�Q�[�����ύX
P5:	DW	0E473H
	DB	P6-$-1
	CALL	NAME

;�����}�[�N�\������
P6:	DW	0E5C8H
	DB	P7-$-1
	JP	BOMB

;�Q�[���I�[�o�[����
P7:	DW	0E61FH
	DB	P8-$-1
	JP	GAMEOVER

;��������
P8:
	DW	0DFC4H		;BGM�p�b�`���
	DB	P9-$-1
	JP	DEAD_SCRN

;�^�C�g�����
P9:	DW	0C510H
	DB	P10-$-1
	CALL	TITLE

;�n�C�X�R�A�X�V
P10:	DW	0C9E4H
	DB	P11-$-1
	CALL	SCORE
	NOP
	NOP
	NOP

;�`�������W���O�X�e�[�W�^�C�g��
P11:	DW	0E51AH
	DB	P12-$-1
	CALL	CHALLENGE

;
P12:	DW	0D8DDH
	DB	P13-$-1
	CALL	INIT_SCRN
	NOP

;
P13:
	DW	0DE75H
	DB	P14-$-1
	JP	CHECK1

;
P14:
	DW	0000H


;=============================
;�ǉ����[�`��
;=============================

INIT_SCRN:
	CALL	SET_MAPCOL	;
	LD	L,030H
	LD	E,02H
	RET

;����=�ΐF 98H,����=���F B8H,�㋉=���F D8H ,�G�L�X�p�[�g=�s���N 78H
SET_MAPCOL:
	LD	A,(ROUND)	;
	SRL	A		;
	SRL	A		;A<-(ROUND)/4
	AND	03H		;
	LD	C,A		;
	LD	B,00H		;
	LD	HL,.TBL		;
	ADD	HL,BC		;
	LD	A,(HL)		;
	CALL	PALETTE		;
	RET			;
.TBL:	DB	98H,0B8H,0D8H,78H


CHALLENGE:
	CALL	0E626H
	LD	A,0D8H		;���������F�ɂ���
	CALL	PALETTE		;
	LD	A,58H		;
	LD	(0F533H),A	;
	LD	(0F533H+120),A	;
	RET
;
TITLE:
	XOR	A		;�n�C�X�R�A�X�V�t���O���~�낷
	LD	(NEWHSC),A	;
	CALL	0E423H
	LD	A,03EH
	CALL	0E626H
	RET

NAME:
	LD	A,0D8H		;���������F�ɂ���
	CALL	PALETTE		;
	LD	A,58H		;�w��s��ԐF�ɂ���
	LD	(0F3CBH),A	;
	LD	(0F443H),A	;
	LD	(0FD2BH),A	;
	LD	(0FDA3H),A	;
	LD	A,0F8H		;�w��s�𔒐F�ɂ���
	LD	(0F4BBH),A	;
	LD	(0F533H),A	;
	LD	HL,01101H	;"NEW"��\������
	CALL	0E66FH		;
	DB	"NEW",00H	;
	LD	HL,01C01H
	RET

;�����}�[�N�\������
BOMB:
	CALL	0D92AH
	LD	DE,.DATA	
	LD	BC,0603H	
	CALL	0D5D5H
	JP	0E5DDH
.DATA:	DB	0C6H,0F8H,0CEH,0C8H,0C8H,16H
	DB	62H,0BFH,10H,0B0H,0CFH,00H
	DB	74H,13H,7FH,72H,1FH,43H

;�s�P�ʂő����l���Z�b�g����
;IN	A=�����l,B=�s��,HL=�擪�A�h���X
SETATRB:
	LD	DE,78H
.L1:	LD	(HL),A
	ADD	HL,DE
	DJNZ	.L1
	RET

;�n�C�X�R�A���
HISCRN:
	LD	A,03EH
	CALL	0E626H

	LD	A,58H
	LD	B,4
	LD	HL,0F4BBH
	CALL	SETATRB

	LD	A,0D8H
	LD	B,5
	LD	HL,0FBC3H
	CALL	SETATRB

	LD	HL,1003H
	CALL	0E66FH
	DB	"YOU",40H,"DID",40H,"IT",40H,5EH,5EH,00H

	LD	HL,1009H
	CALL	0E66FH
	DB	"THE",40H,"HI",5CH,"SCORE",00H

	LD	HL,120CH
	CALL	0E66FH
	DB	"OF",40H,"THE",40H,"DAY",00H

	LD	HL,0B12H
	CALL	0E66FH
	DB	"GO",40H,"FOR",40H,"THE",40H,"WORLD",00H

	LD	HL,0F15H
	CALL	0E66FH
	DB	"RECORD",40H,"NOW",5EH,5EH,00H

	LD	A,(BGM)
	CP	BGMMARK
	JR	NZ,.NOPCG

	LD	A,6
	CALL	PLAY_SONG_NUM
	CALL	STOP_PCG
	LD	HL,0400H
	JR	.L1

.NOPCG:	LD	HL,0800H
.L1:	CALL	0DA0AH
	RET

;�Q�[���I�[�o�[����
GAMEOVER:
	LD	HL,0800H
	CALL	0DA0AH
	LD	A,38H
	CALL	PALETTE
	LD	A,(NEWHSC)
	AND	A
	CALL	NZ,HISCRN
	CALL	SET_MAPCOL
	RET

;�p���b�g�`�F���W
;IN	A=�����R�[�h
PALETTE:
	LD	HL,0F350H+3
	LD	DE,120
	LD	B,25
.L1:	LD	(HL),A
	ADD	HL,DE
	DJNZ	.L1
	RET

;
DEAD_SCRN:
	JP	NZ,0DFB2H
	LD	A,58H		;��ʂ�Ԃ�����
	CALL	PALETTE		;
	JP	0DFC7H		;

;
CHECK1:
	JR	NC,.L1
	LD	A,(0BB72H)	;���b�h�J�[�̓X�^�[�g�O���H
	AND	A		;
	JP	Z,0DF88H
.L1:	JP	0DE78H

;
SCORE:
.L1:	LD	A,(DE)
	LD	(HL),A
	INC	DE
	INC	HL
	DJNZ	.L1

	LD	A,0FFH		;
	LD	(NEWHSC),A	;�n�C�X�R�A�X�V�t���O�𗧂Ă�
	RET


;�n�C�X�R�A�X�V�t���O
NEWHSC:	DB	00H

