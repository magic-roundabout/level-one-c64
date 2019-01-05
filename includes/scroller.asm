;
; BACKGROUND SCROLL UPDATER
;

; Point the RLE routine at the map data and set some counters
scroll_init	lda #<map_data
		sta rle_read+$01
		lda #>map_data
		sta rle_read+$02

		lda #$00
		sta rle_timer
		sta rle_byte

		lda #scroll_length
		sta map_width

		rts

; Manage the scrolling
scroll_manage	lda bg_scroll_x

sm_chk_00	bne sm_chk_01
		jmp scroll_1a

sm_chk_01	cmp #$01
		bne sm_chk_02
		jmp scroll_1b

sm_chk_02	cmp #$02
		bne sm_chk_03
		jmp scroll_1c

sm_chk_03	cmp #$03
		bne sm_chk_08
		jmp unpack_1


sm_chk_08	cmp #$08
		bne sm_chk_09
		jmp scroll_2a

sm_chk_09	cmp #$09
		bne sm_chk_0a
		jmp scroll_2b

sm_chk_0a	cmp #$0a
		bne sm_chk_0b
		jmp scroll_2c

sm_chk_0b	cmp #$0b
		bne sm_chk_out
		jmp unpack_2

sm_chk_out	rts

; Copy to buffer 1 - pass 1
scroll_1a	ldx #$00
s1a_loop

!set line_cnt=$00
!do {
		lda buffer_2+(line_cnt*$28)+$01,x
		sta buffer_1+(line_cnt*$28)+$00,x

		!set line_cnt=line_cnt+$01
} until line_cnt=$08

		inx
		cpx #$26
		bne s1a_loop

		rts

; Copy to buffer 1 - pass 2
scroll_1b	ldx #$00
s1b_loop

!set line_cnt=$08
!do {
		lda buffer_2+(line_cnt*$28)+$01,x
		sta buffer_1+(line_cnt*$28)+$00,x

		!set line_cnt=line_cnt+$01
} until line_cnt=$10

		inx
		cpx #$26
		bne s1b_loop

		rts

; Copy to buffer 1 - pass 3
scroll_1c	ldx #$00
s1c_loop

!set line_cnt=$10
!do {
		lda buffer_2+(line_cnt*$28)+$01,x
		sta buffer_1+(line_cnt*$28)+$00,x

		!set line_cnt=line_cnt+$01
} until line_cnt=$19

		inx
		cpx #$26
		bne s1c_loop

		rts

; Buffer 1 - unpack a column of data
unpack_1

!set line_cnt=$00
!do {
		jsr rle_unpack
		sta buffer_1+$026+(line_cnt*$28)

		!set line_cnt=line_cnt+$1
} until line_cnt=$19

		rts


; Copy to buffer 2 - pass 1
scroll_2a	ldx #$00
s2a_loop

!set line_cnt=$00
!do {
		lda buffer_1+(line_cnt*$28)+$01,x
		sta buffer_2+(line_cnt*$28)+$00,x

		!set line_cnt=line_cnt+$01
} until line_cnt=$08

		inx
		cpx #$26
		bne s2a_loop

		rts

; Copy to buffer 2 - pass 2
scroll_2b	ldx #$00
s2b_loop

!set line_cnt=$08
!do {
		lda buffer_1+(line_cnt*$28)+$01,x
		sta buffer_2+(line_cnt*$28)+$00,x

		!set line_cnt=line_cnt+$01
} until line_cnt=$10

		inx
		cpx #$26
		bne s2b_loop

		rts

; Copy to buffer 2 - pass 3
scroll_2c	ldx #$00
s2c_loop

!set line_cnt=$10
!do {
		lda buffer_1+(line_cnt*$28)+$01,x
		sta buffer_2+(line_cnt*$28)+$00,x

		!set line_cnt=line_cnt+$01
} until line_cnt=$19

		inx
		cpx #$26
		bne s2c_loop

		rts

; Buffer 1 - unpack a column of data
unpack_2

!set line_cnt=$00
!do {
		jsr rle_unpack
		sta buffer_2+$026+(line_cnt*$28)

		!set line_cnt=line_cnt+$1
} until line_cnt=$19

		rts
