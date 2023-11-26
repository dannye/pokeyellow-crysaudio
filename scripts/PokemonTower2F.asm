PokemonTower2F_Script:
	call EnableAutoTextBoxDrawing
	ld hl, PokemonTower2F_ScriptPointers
	ld a, [wPokemonTower2FCurScript]
	jp CallFunctionInTable

PokemonTower2FResetRivalEncounter:
	xor a ; SCRIPT_POKEMONTOWER2F_DEFAULT
	ld [wJoyIgnore], a
	ld [wPokemonTower2FCurScript], a
	ld [wCurMapScript], a
	ret

PokemonTower2F_ScriptPointers:
	def_script_pointers
	dw_const PokemonTower2FDefaultScript,       SCRIPT_POKEMONTOWER2F_DEFAULT
	dw_const PokemonTower2FDefeatedRivalScript, SCRIPT_POKEMONTOWER2F_DEFEATED_RIVAL
	dw_const PokemonTower2FRivalExitsScript,    SCRIPT_POKEMONTOWER2F_RIVAL_EXITS

PokemonTower2FDefaultScript:
IF DEF(_DEBUG)
	call DebugPressedOrHeldB
	ret nz
ENDC
	CheckEvent EVENT_BEAT_POKEMON_TOWER_RIVAL
	ret nz
	ld hl, PokemonTower2FRivalEncounterEventCoords
	call ArePlayerCoordsInArray
	ret nc
	call StopAllMusic
	ld c, 0 ; BANK(Music_MeetRival)
	ld a, MUSIC_MEET_RIVAL
	call PlayMusic
	ResetEvent EVENT_POKEMON_TOWER_RIVAL_ON_LEFT
	ld a, [wCoordIndex]
	cp $1
	ld a, PLAYER_DIR_UP
	ld b, SPRITE_FACING_DOWN
	jr nz, .player_below_rival
; the rival is on the left side and the player is on the right side
	SetEvent EVENT_POKEMON_TOWER_RIVAL_ON_LEFT
	ld a, PLAYER_DIR_LEFT
	ld b, SPRITE_FACING_RIGHT
.player_below_rival
	ld [wPlayerMovingDirection], a
	ld a, POKEMONTOWER2F_RIVAL
	ldh [hSpriteIndex], a
	ld a, b
	ldh [hSpriteFacingDirection], a
	call SetSpriteFacingDirectionAndDelay
	ld a, TEXT_POKEMONTOWER2F_RIVAL
	ldh [hSpriteIndexOrTextID], a
	call DisplayTextID
	xor a
	ldh [hJoyHeld], a
	ldh [hJoyPressed], a
	ret

PokemonTower2FRivalEncounterEventCoords:
	dbmapcoord 15,  5
	dbmapcoord 14,  6
	db $0F ; end? (should be $ff?)

PokemonTower2FDefeatedRivalScript:
	ld a, [wIsInBattle]
	cp $ff
	jp z, PokemonTower2FResetRivalEncounter
	ld a, D_RIGHT | D_LEFT | D_UP | D_DOWN
	ld [wJoyIgnore], a
	SetEvent EVENT_BEAT_POKEMON_TOWER_RIVAL
	ld a, TEXT_POKEMONTOWER2F_RIVAL
	ldh [hSpriteIndexOrTextID], a
	call DisplayTextID
	ld de, PokemonTower2FRivalDownThenRightMovement
	CheckEvent EVENT_POKEMON_TOWER_RIVAL_ON_LEFT
	jr nz, .got_movement
	callfar PokemonTower2FPikachuMovementScript
	ld de, PokemonTower2FRivalRightThenDownMovement
.got_movement
	ld a, POKEMONTOWER2F_RIVAL
	ldh [hSpriteIndex], a
	call MoveSprite
	call StopAllMusic
	farcall Music_RivalAlternateStart
	ld a, SCRIPT_POKEMONTOWER2F_RIVAL_EXITS
	ld [wPokemonTower2FCurScript], a
	ld [wCurMapScript], a
	ret

PokemonTower2FRivalRightThenDownMovement:
	db NPC_MOVEMENT_RIGHT
	db NPC_MOVEMENT_DOWN
	db NPC_MOVEMENT_DOWN
	db NPC_MOVEMENT_RIGHT
	db NPC_MOVEMENT_DOWN
	db NPC_MOVEMENT_DOWN
	db NPC_MOVEMENT_RIGHT
	db NPC_MOVEMENT_RIGHT
	db -1 ; end

PokemonTower2FRivalDownThenRightMovement:
	db NPC_MOVEMENT_DOWN
	db NPC_MOVEMENT_DOWN
	db NPC_MOVEMENT_RIGHT
	db NPC_MOVEMENT_RIGHT
	db NPC_MOVEMENT_RIGHT
	db NPC_MOVEMENT_RIGHT
	db NPC_MOVEMENT_DOWN
	db NPC_MOVEMENT_DOWN
	db -1 ; end

PokemonTower2FRivalExitsScript:
	ld a, [wd730]
	bit 0, a
	ret nz
	ld a, HS_POKEMON_TOWER_2F_RIVAL
	ld [wMissableObjectIndex], a
	predef HideObject
	xor a
	ld [wJoyIgnore], a
	call PlayDefaultMusic
	ld a, SCRIPT_POKEMONTOWER2F_DEFAULT
	ld [wPokemonTower2FCurScript], a
	ld [wCurMapScript], a
	ret

PokemonTower2F_TextPointers:
	def_text_pointers
	dw_const PokemonTower2FRivalText,     TEXT_POKEMONTOWER2F_RIVAL
	dw_const PokemonTower2FChannelerText, TEXT_POKEMONTOWER2F_CHANNELER

PokemonTower2FRivalText:
	text_asm
	CheckEvent EVENT_BEAT_POKEMON_TOWER_RIVAL
	jr z, .do_battle
	ld hl, .HowsYourDexText
	call PrintText
	jr .text_script_end
.do_battle
	ld hl, .WhatBringsYouHereText
	call PrintText
	ld hl, wd72d
	set 6, [hl]
	set 7, [hl]
	ld hl, .DefeatedText
	ld de, .VictoryText
	call SaveEndBattleTextPointers
	ld a, OPP_RIVAL2
	ld [wCurOpponent], a
	ld a, [wRivalStarter]
	add $1
	ld [wTrainerNo], a

	ld a, SCRIPT_POKEMONTOWER2F_DEFEATED_RIVAL
	ld [wPokemonTower2FCurScript], a
	ld [wCurMapScript], a
.text_script_end
	jp TextScriptEnd

.WhatBringsYouHereText:
	text_far _PokemonTower2FRivalWhatBringsYouHereText
	text_end

.DefeatedText:
	text_far _PokemonTower2FRivalDefeatedText
	text_end

.VictoryText:
	text_far _PokemonTower2FRivalVictoryText
	text_end

.HowsYourDexText:
	text_far _PokemonTower2FRivalHowsYourDexText
	text_end

PokemonTower2FChannelerText:
	text_far _PokemonTower2FChannelerText
	text_end
