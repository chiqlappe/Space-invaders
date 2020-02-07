;=============================
;PC-8001 "INVADER"�p
;�T�E���h�p�b�`
;2020/02/07
;
;USAGE: MON+GCF00
;=============================

FALSE	EQU	0

BOMBB	EQU	00000001B	;������
BEAMB	EQU	00000010B	;�r�[�����ˉ�
UFOHITB	EQU	00000100B	;UFO�q�b�g��
THITB	EQU	00001000B	;�^�[�Q�b�g�q�b�g��
STEPB	EQU	00010000B	;�s�i��
UFOB	EQU	00100000B	;UFO��s��
PORT	EQU	10H		;�T�E���h�{�[�h�̃|�[�g�ԍ�

EOD	EQU	0FFH		;�f�[�^�G���h�}�[�J�[

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
;�p�b�`�𓖂Ă�
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
;�T�E���h�{�[�h������������
;-----------------------------
SNDINIT:
	LD	A,0FFH
	OUT	(PORT),A
	LD	(SND),A
	RET

;-----------------------------
;���𔭐�
;IN	C=�r�b�g�p�^�[��
;-----------------------------
PLAYSND:
	IN	A,(08H)		;�J�i�L�[����������Ă��邩�H
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
;�����~
;IN	C=�r�b�g�p�^�[��
;-----------------------------
STOPSND:
	LD	A,(SND)
	OR	C
	OUT	(PORT),A
	LD	(SND),A
	RET

;-----------------------------
;�r�[�����ˉ�
;-----------------------------
BEAM:
	LD	C,BEAMB
	CALL	PLAYSND
	JP	Z0060

;-----------------------------
;UFO��s��
;-----------------------------
UFO:
	LD	(UFOODD),A
	LD	C,UFOB
	JP	PLAYSND

;-----------------------------
;UFO��s�����q�b�g����~
;-----------------------------
UFO_STOP:
	LD	C,UFOB+UFOHITB
	JP	STOPSND

;-----------------------------
;UFO�q�b�g��
;-----------------------------
UFOHIT:
	CALL	UFO_STOP
	LD	C,UFOHITB
	JP	PLAYSND

;-----------------------------
;�^�[�Q�b�g�q�b�g��
;-----------------------------
HIT:
	LD	C,THITB
	JP	PLAYSND

;-----------------------------
;�r�[���J�[������
;-----------------------------
BOMB:
	LD	C,BOMBB
	CALL	PLAYSND

	LD	HL,0F353H
	RET

;-----------------------------
;�r�[���J�[��������~
;-----------------------------
BOMB_STOP:
	LD	C,BOMBB
	JP	STOPSND


;-----------------------------
;�s�i���p�J�E���^
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
;�s�i��
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
;��ʏ���
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
;�Q�[���I�[�o�[��
;-----------------------------
GAMEOVER:
	CALL	SNDINIT
	LD	HL,0F4F7H
	RET


;-----------------------------
;�Q�[���^�C�g���ύX
;-----------------------------
TITLE:	DB	0ACH,9AH,40H,4CH,58H,0FAH,70H,8EH,0BEH,40H,52H,58H,0A6H,0ACH	;"SPACE INVADERS"
	DB	EOD




;=============================



PATCH_DATA:

;������
	DW	0E101H
	DB	0FH
	CALL	SNDINIT
	CALL	INIT01
	CALL	INIT02
	CALL	INIT03
	JP	Z0345

;�r�[�����ˉ�
	DW	0D2FBH
	DB	03H
	CALL	Z,BEAM

;UFO��s��
	DW	0D95BH
	DB	03H
	CALL	UFO

	DW	0D95EH
	DB	03H
	DB	00H,00H,00H

	DW	0D9B7H
	DB	03H
	DB	00H,00H,00H

;UFO��s����~
	DW	0D9D6H
	DB	03H
	CALL	UFO_STOP

;UFO�q�b�g��
	DW	0DA8AH
	DB	03H
	JP	UFOHIT

	DW	0DA7EH
	DB	01H
	DB	80H

;�^�[�Q�b�g�q�b�g��
	DW	0D466H
	DB	03H
	CALL	HIT

;BEEP������������
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

;�r�[���J�[������
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

;�r�[���J�[��������~
	DW	0D88DH
	DB	03H
	CALL	BOMB_STOP

;�X�e�[�W�N���A��
	DW	0DF79H
	DB	06H
	CALL	SNDINIT
	JP	0DF50H

;��ʏ���
	DW	0DB09H
	DB	03H
	JP	CLS

;�Q�[���I�[�o�[��
	DW	0DE80H
	DB	03H
	CALL	GAMEOVER

;�X�e�b�v��
	DW	0D5BCH
	DB	03H
	CALL	STEP

;�X�e�b�v���p�J�E���^
	DW	0D900H
	DB	03H
	CALL	STEP_CNT

;�X�e�[�W�N���A��̃E�F�C�g�J�b�g
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


SND:	DB	00H		;�|�[�g10H�ɏo�͂����l
STEPC:	DB	00H		;�X�e�b�v�������p�J�E���^
STEPD:	DB	00H		;�X�e�b�v����~�p�J�E���^
