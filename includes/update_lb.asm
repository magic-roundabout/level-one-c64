;
; LOWER BORDER SCROLL UPDATER
;

update_lb	ldx #$00
mover_lb	asl char_buffer+$00,x
		rol char_buffer+$01,x

		rol scroll_sprs_lb+$1c8,x
		rol scroll_sprs_lb+$1c7,x
		rol scroll_sprs_lb+$1c6,x

		rol scroll_sprs_lb+$188,x
		rol scroll_sprs_lb+$187,x
		rol scroll_sprs_lb+$186,x

		rol scroll_sprs_lb+$148,x
		rol scroll_sprs_lb+$147,x
		rol scroll_sprs_lb+$146,x

		rol scroll_sprs_lb+$108,x
		rol scroll_sprs_lb+$107,x
		rol scroll_sprs_lb+$106,x

		rol scroll_sprs_lb+$0c8,x
		rol scroll_sprs_lb+$0c7,x
		rol scroll_sprs_lb+$0c6,x

		rol scroll_sprs_lb+$088,x
		rol scroll_sprs_lb+$087,x
		rol char_buffer+$02,x

;		rol scroll_sprs_lb+$086,x

		inx
		inx
		inx
		cpx #$18
		bne mover_lb

; Mask the left-hand character
		ldx #$00
		ldy #$00
mask_lb		lda char_buffer+$02,y
		ora lb_char_mask,x
		sta scroll_sprs_lb+$086,y
		iny
		iny
		iny
		inx
		cpx #$08
		bne mask_lb

; Copy the second character buffer to the ghostbyte splits
		lda char_buffer+$01
		sta ghost_lb_00b+$01
		lda char_buffer+$04
		sta ghost_lb_01b+$01
		lda char_buffer+$07
		sta ghost_lb_02b+$01
		lda char_buffer+$0a
		sta ghost_lb_03b+$01
		lda char_buffer+$0d
		sta ghost_lb_04b+$01
		lda char_buffer+$10
		sta ghost_lb_05b+$01
		lda char_buffer+$13
		sta ghost_lb_06b+$01
		lda char_buffer+$16
		sta ghost_lb_07b+$01

; Fetch a new character
		ldx scroll_cnt_lb
		inx
		cpx #$08
		bne sclb_xb

mread_lb	lda scroll_text_lb
		bne okay_lb
		jsr reset_lb
		jmp mread_lb

okay_lb		sta def_copy_lb+$01
		lda #$00
		asl def_copy_lb+$01
		rol
		asl def_copy_lb+$01
		rol
		asl def_copy_lb+$01
		rol
		clc
		adc #$d8
		sta def_copy_lb+$02

		lda #$33
		sta $01

		ldx #$00
		ldy #$00
def_copy_lb	lda $6464,x
		eor #$ff
		sta char_buffer,y
		iny
		iny
		iny
		inx
		cpx #$08
		bne def_copy_lb

		lda #$35
		sta $01

		inc mread_lb+$01
		bne *+$05
		inc mread_lb+$02


		ldx #$00
sclb_xb		stx scroll_cnt_lb

		rts

; Reset the scroll self mod
reset_lb	lda #<scroll_text_lb
		sta mread_lb+$01
		lda #>scroll_text_lb
		sta mread_lb+$02
		rts