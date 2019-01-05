;
; UPPER BORDER TEXT LINE UPDATER
;

; Check to see if anything needs calling
update_ub	ldx scroll_cnt_ub
		bne *+$05
		jmp uub_fetch

		cpx #$02
		bne *+$05
		jmp uub_render_00

		cpx #$12
		bne *+$05
		jmp uub_render_01

		cpx #$22
		bne *+$05
		jmp uub_render_02

		cpx #$03
		bne *+$05
		jmp uub_render_03

		cpx #$13
		bne *+$05
		jmp uub_render_04

		cpx #$23
		bne *+$05
		jmp uub_render_05

		cpx #$04
		bne *+$05
		jmp uub_render_06

		cpx #$14
		bne *+$05
		jmp uub_render_07

		cpx #$24
		bne *+$05
		jmp uub_render_08

		cpx #$05
		bne *+$05
		jmp uub_render_09

		cpx #$15
		bne *+$05
		jmp uub_render_0a

		cpx #$25
		bne *+$05
		jmp uub_render_0b

		cpx #$06
		bne *+$05
		jmp uub_render_0c

		cpx #$16
		bne *+$05
		jmp uub_render_0d

		cpx #$26
		bne *+$05
		jmp uub_render_0e

		cpx #$07
		bne *+$05
		jmp uub_render_0f

		cpx #$17
		bne *+$05
		jmp uub_render_10

		cpx #$27
		bne *+$05
		jmp uub_render_11

		cpx #$08
		bne *+$05
		jmp uub_render_12

		rts

; Fetch a new line of text
uub_fetch	ldx #$00

mread_ub	lda scroll_text_ub
		bne okay_ub
		jsr reset_ub
		jmp mread_ub

okay_ub		sta buffer_ub,x
		inc mread_ub+$01
		bne *+$05
		inc mread_ub+$02

		inx
		cpx #$13
		bne mread_ub

		rts

; Self mod reset code for the above
reset_ub	lda #<scroll_text_ub
		sta mread_ub+$01
		lda #>scroll_text_ub
		sta mread_ub+$02
		rts


; Render the left hand ghostbyte character
uub_render_00	lda buffer_ub+$00
		jsr char_read_init

		jsr char_read
		sta ghost_ub_00a+$01
		jsr char_read
		sta ghost_ub_01a+$01
		jsr char_read
		sta ghost_ub_02a+$01
		jsr char_read
		sta ghost_ub_03a+$01
		jsr char_read
		sta ghost_ub_04a+$01
		jsr char_read
		sta ghost_ub_05a+$01
		jsr char_read
		sta ghost_ub_06a+$01
		jsr char_read
		sta ghost_ub_07a+$01

		rts


; Render the first sprite
uub_render_01	lda buffer_ub+$01
		jsr char_read_init

		ldx #$00
render_ub_s1a	jsr char_read
		sta scroll_sprs_ub+$003,x
		inx
		inx
		inx
		cpx #$18
		bne render_ub_s1a
		rts


uub_render_02	lda buffer_ub+$02
		jsr char_read_init

		ldx #$00
render_ub_s1b	jsr char_read
		sta scroll_sprs_ub+$004,x
		inx
		inx
		inx
		cpx #$18
		bne render_ub_s1b

		rts


uub_render_03	lda buffer_ub+$03
		jsr char_read_init

		ldx #$00
render_ub_s1c	jsr char_read
		sta scroll_sprs_ub+$005,x
		inx
		inx
		inx
		cpx #$18
		bne render_ub_s1c

		rts


; Render the second sprite
uub_render_04	lda buffer_ub+$04
		jsr char_read_init

		ldx #$00
render_ub_s2a	jsr char_read
		sta scroll_sprs_ub+$043,x
		inx
		inx
		inx
		cpx #$18
		bne render_ub_s2a

		rts


uub_render_05	lda buffer_ub+$05
		jsr char_read_init

		ldx #$00
render_ub_s2b	jsr char_read
		sta scroll_sprs_ub+$044,x
		inx
		inx
		inx
		cpx #$18
		bne render_ub_s2b

		rts


uub_render_06	lda buffer_ub+$06
		jsr char_read_init

		ldx #$00
render_ub_s2c	jsr char_read
		sta scroll_sprs_ub+$045,x
		inx
		inx
		inx
		cpx #$18
		bne render_ub_s2c

		rts


; Render the third sprite
uub_render_07	lda buffer_ub+$07
		jsr char_read_init

		ldx #$00
render_ub_s3a	jsr char_read
		sta scroll_sprs_ub+$083,x
		inx
		inx
		inx
		cpx #$18
		bne render_ub_s3a

		rts


uub_render_08	lda buffer_ub+$08
		jsr char_read_init

		ldx #$00
render_ub_s3b	jsr char_read
		sta scroll_sprs_ub+$084,x
		inx
		inx
		inx
		cpx #$18
		bne render_ub_s3b

		rts


uub_render_09	lda buffer_ub+$09
		jsr char_read_init

		ldx #$00
render_ub_s3c	jsr char_read
		sta scroll_sprs_ub+$085,x
		inx
		inx
		inx
		cpx #$18
		bne render_ub_s3c

		rts


; Render the fourth sprite
uub_render_0a	lda buffer_ub+$0a
		jsr char_read_init

		ldx #$00
render_ub_s4a	jsr char_read
		sta scroll_sprs_ub+$0c3,x
		inx
		inx
		inx
		cpx #$18
		bne render_ub_s4a

		rts


uub_render_0b	lda buffer_ub+$0b
		jsr char_read_init

		ldx #$00
render_ub_s4b	jsr char_read
		sta scroll_sprs_ub+$0c4,x
		inx
		inx
		inx
		cpx #$18
		bne render_ub_s4b

		rts


uub_render_0c	lda buffer_ub+$0c
		jsr char_read_init

		ldx #$00
render_ub_s4c	jsr char_read
		sta scroll_sprs_ub+$0c5,x
		inx
		inx
		inx
		cpx #$18
		bne render_ub_s4c

		rts


; Render the fifth sprite
uub_render_0d	lda buffer_ub+$0d
		jsr char_read_init

		ldx #$00
render_ub_s5a	jsr char_read
		sta scroll_sprs_ub+$103,x
		inx
		inx
		inx
		cpx #$18
		bne render_ub_s5a

		rts


uub_render_0e	lda buffer_ub+$0e
		jsr char_read_init

		ldx #$00
render_ub_s5b	jsr char_read
		sta scroll_sprs_ub+$104,x
		inx
		inx
		inx
		cpx #$18
		bne render_ub_s5b

		rts


uub_render_0f	lda buffer_ub+$0f
		jsr char_read_init

		ldx #$00
render_ub_s5c	jsr char_read
		sta scroll_sprs_ub+$105,x
		inx
		inx
		inx
		cpx #$18
		bne render_ub_s5c

		rts


; Render the sixth sprite
uub_render_10	lda buffer_ub+$10
		jsr char_read_init

		ldx #$00
render_ub_s6a	jsr char_read
		sta scroll_sprs_ub+$143,x
		inx
		inx
		inx
		cpx #$18
		bne render_ub_s6a

		rts


uub_render_11	lda buffer_ub+$11
		jsr char_read_init

		ldx #$00
render_ub_s6b	jsr char_read
		sta scroll_sprs_ub+$144,x
		inx
		inx
		inx
		cpx #$18
		bne render_ub_s6b

		rts


uub_render_12	lda buffer_ub+$12
		jsr char_read_init

		ldx #$00
render_ub_s6c	jsr char_read
		sta scroll_sprs_ub+$145,x
		inx
		inx
		inx
		cpx #$18
		bne render_ub_s6c

		rts

; Self mod code for reading the ROM font
char_read_init	sta char_read+$01
		lda #$00
		asl char_read+$01
		rol
		asl char_read+$01
		rol
		asl char_read+$01
		rol
		clc
		adc #$dc
		sta char_read+$02
		rts

char_read	lda $dc00
		inc char_read+$01
		bne *+$05
		inc char_read+$02
		rts