SoftReset::
	call StopAllSounds
	call GBPalWhiteOut
	ld c, 32
	call DelayFrames
	; fallthrough

Init::
;  Program init.

; * LCD enabled
; * Window tile map at $9C00
; * Window display enabled
; * BG and window tile data at $8800
; * BG tile map at $9800
; * 8x8 OBJ size
; * OBJ display enabled
; * BG display enabled
DEF LCDC_DEFAULT EQU LCDC_ON | LCDC_WIN_9C00 | LCDC_WIN_ON | LCDC_BLOCK21 | LCDC_BG_9800 | LCDC_OBJ_8 | LCDC_OBJ_ON | LCDC_BG_ON

	di

	xor a
	ldh [rIF], a
	ldh [rIE], a
	ldh [rSCX], a
	ldh [rSCY], a
	ldh [rSB], a
	ldh [rSC], a
	ldh [rWX], a
	ldh [rWY], a
	ldh [rTMA], a
	ldh [rTAC], a
	ldh [rBGP], a
	ldh [rOBP0], a
	ldh [rOBP1], a

	ld a, LCDC_ON
	ldh [rLCDC], a
	call DisableLCD

	ld sp, wStack

	ld hl, STARTOF(WRAM0)
	ld bc, SIZEOF(WRAM0)
.loop
	ld [hl], 0
	inc hl
	dec bc
	ld a, b
	or c
	jr nz, .loop

	call ClearVram

	ld hl, STARTOF(HRAM)
	ld bc, SIZEOF(HRAM) - 1
	call FillMemory

	call ClearSprites

	ld a, BANK(WriteDMACodeToHRAM)
	ldh [hLoadedROMBank], a
	ld [rROMB], a
	call WriteDMACodeToHRAM

	xor a
	ldh [hTileAnimations], a
	ldh [rSTAT], a
	ldh [hSCX], a
	ldh [hSCY], a
	ldh [rIF], a
	ld [wc0f3], a
	ld [wc0f3 + 1], a
	ld a, IE_VBLANK | IE_TIMER | IE_SERIAL
	ldh [rIE], a

	ld a, 144 ; move the window off-screen
	ldh [hWY], a
	ldh [rWY], a
	ld a, 7
	ldh [rWX], a

	ld a, CONNECTION_NOT_ESTABLISHED
	ldh [hSerialConnectionStatus], a

	ld h, HIGH(vBGMap0)
	call ClearBgMap
	ld h, HIGH(vBGMap1)
	call ClearBgMap

	ld a, LCDC_DEFAULT
	ldh [rLCDC], a
	ld a, 16
	ldh [hSoftReset], a
	call StopAllSounds

	ei

	predef LoadSGB

;	ld a, 0 ; BANK(SFX_Shooting_Star)
;	ld [wAudioROMBank], a
;	ld [wAudioSavedROMBank], a
	ld a, $9c
	ldh [hAutoBGTransferDest + 1], a
	xor a
	ldh [hAutoBGTransferDest], a
	dec a
	ld [wUpdateSpritesEnabled], a

	predef PlayIntro

	call DisableLCD
	call ClearVram
	call GBPalNormal
	call ClearSprites
	ld a, LCDC_DEFAULT
	ldh [rLCDC], a

	jp PrepareTitleScreen

ClearVram::
	ld hl, STARTOF(VRAM)
	ld bc, SIZEOF(VRAM)
	xor a
	jp FillMemory


StopAllSounds::
;	ld a, 0 ; BANK("Audio Engine 1")
;	ld [wAudioROMBank], a
;	ld [wAudioSavedROMBank], a
	xor a
	ld [wMusicFade], a
	ld [wMusicFadeID], a
	ld [wLastMusicSoundID], a
	jp StopAllMusic
