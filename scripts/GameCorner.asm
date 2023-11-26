GameCorner_Script:
	call GameCornerSelectLuckySlotMachine
	call GameCornerSetRocketHideoutDoorTile
	call EnableAutoTextBoxDrawing
	ld hl, GameCorner_ScriptPointers
	ld a, [wGameCornerCurScript]
	jp CallFunctionInTable

GameCornerSelectLuckySlotMachine:
	ld hl, wCurrentMapScriptFlags
	bit 6, [hl]
	res 6, [hl]
	ret z
	call Random
	ldh a, [hRandomAdd]
	cp $7
	jr nc, .not_max
	ld a, $8
.not_max
	srl a
	srl a
	srl a
	ld [wLuckySlotHiddenObjectIndex], a
	ret

GameCornerSetRocketHideoutDoorTile:
	ld hl, wCurrentMapScriptFlags
	bit 5, [hl]
	res 5, [hl]
	ret z
	CheckEvent EVENT_FOUND_ROCKET_HIDEOUT
	ret nz
	ld a, $2a
	ld [wNewTileBlockID], a
	lb bc, 2, 8
	predef_jump ReplaceTileBlock

GameCornerReenterMapAfterPlayerLoss:
	xor a ; SCRIPT_GAMECORNER_DEFAULT
	ld [wJoyIgnore], a
	ld [wGameCornerCurScript], a
	ld [wCurMapScript], a
	ret

GameCorner_ScriptPointers:
	def_script_pointers
	dw_const GameCornerDefaultScript,      SCRIPT_GAMECORNER_DEFAULT
	dw_const GameCornerRocketBattleScript, SCRIPT_GAMECORNER_ROCKET_BATTLE
	dw_const GameCornerRocketExitScript,   SCRIPT_GAMECORNER_ROCKET_EXIT

GameCornerDefaultScript:
	ret

GameCornerRocketBattleScript:
	ld a, [wIsInBattle]
	cp $ff
	jp z, GameCornerReenterMapAfterPlayerLoss
	ld a, D_RIGHT | D_LEFT | D_UP | D_DOWN
	ld [wJoyIgnore], a
	ld a, TEXT_GAMECORNER_ROCKET_AFTER_BATTLE
	ldh [hSpriteIndexOrTextID], a
	call DisplayTextID
	ld a, GAMECORNER_ROCKET
	ldh [hSpriteIndex], a
	call SetSpriteMovementBytesToFF
	ld de, GameCornerMovement_Rocket_WalkAroundPlayer
	ld a, [wYCoord]
	cp 6
	jr nz, .not_direct_movement
	ld de, GameCornerMovement_Rocket_WalkDirect
	jr .got_rocket_movement
.not_direct_movement
	ld a, [wXCoord]
	cp 8
	jr nz, .pikachu
	ld de, GameCornerMovement_Rocket_WalkDirect
	jr .got_rocket_movement
.pikachu
	callfar GameCornerPikachuMovementScript
	ld de, GameCornerMovement_Rocket_WalkAroundPlayer
.got_rocket_movement
	ld a, GAMECORNER_ROCKET
	ldh [hSpriteIndex], a
	call MoveSprite
	ld a, SCRIPT_GAMECORNER_ROCKET_EXIT
	ld [wGameCornerCurScript], a
	ret

GameCornerMovement_Rocket_WalkAroundPlayer:
	db NPC_MOVEMENT_DOWN
	db NPC_MOVEMENT_RIGHT
	db NPC_MOVEMENT_RIGHT
	db NPC_MOVEMENT_RIGHT
	db NPC_MOVEMENT_UP
	db NPC_MOVEMENT_RIGHT
	db NPC_MOVEMENT_RIGHT
	db NPC_MOVEMENT_RIGHT
	db -1 ; end

GameCornerMovement_Rocket_WalkDirect:
	db NPC_MOVEMENT_RIGHT
	db NPC_MOVEMENT_RIGHT
	db NPC_MOVEMENT_RIGHT
	db NPC_MOVEMENT_RIGHT
	db NPC_MOVEMENT_RIGHT
	db -1 ; end

GameCornerRocketExitScript:
	ld a, [wd730]
	bit 0, a
	ret nz
	xor a
	ld [wJoyIgnore], a
	ld a, HS_GAME_CORNER_ROCKET
	ld [wMissableObjectIndex], a
	predef HideObject
	ld hl, wCurrentMapScriptFlags
	set 5, [hl]
	set 6, [hl]
	ld a, SCRIPT_GAMECORNER_DEFAULT
	ld [wGameCornerCurScript], a
	ret

GameCorner_TextPointers:
	def_text_pointers
	dw_const GameCornerBeauty1Text,           TEXT_GAMECORNER_BEAUTY1
	dw_const GameCornerClerkText,             TEXT_GAMECORNER_CLERK
	dw_const GameCornerMiddleAgedMan1Text,    TEXT_GAMECORNER_MIDDLE_AGED_MAN1
	dw_const GameCornerBeauty2Text,           TEXT_GAMECORNER_BEAUTY2
	dw_const GameCornerFishingGuru1Text,      TEXT_GAMECORNER_FISHING_GURU1
	dw_const GameCornerMiddleAgedWomanText,   TEXT_GAMECORNER_MIDDLE_AGED_WOMAN
	dw_const GameCornerGymGuideText,          TEXT_GAMECORNER_GYM_GUIDE
	dw_const GameCornerGamblerText,           TEXT_GAMECORNER_GAMBLER
	dw_const GameCornerMiddleAgedMan2Text,    TEXT_GAMECORNER_MIDDLE_AGED_MAN2
	dw_const GameCornerFishingGuru2Text,      TEXT_GAMECORNER_FISHING_GURU2
	dw_const GameCornerRocketText,            TEXT_GAMECORNER_ROCKET
	dw_const GameCornerPosterText,            TEXT_GAMECORNER_POSTER
	dw_const GameCornerRocketAfterBattleText, TEXT_GAMECORNER_ROCKET_AFTER_BATTLE

GameCornerBeauty1Text:
	text_far _GameCornerBeauty1Text
	text_end

GameCornerClerkText:
	text_asm
	; Show player's coins
	call GameCornerDrawCoinBox
	ld hl, .DoYouNeedSomeGameCoins
	call PrintText
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	and a
	jr nz, .declined
	; Can only get more coins if you
	; - have the Coin Case
	ld b, COIN_CASE
	call IsItemInBag
	jr z, .no_coin_case
	; - have room in the Coin Case for at least 9 coins
	call Has9990Coins
	jr nc, .coin_case_full
	; - have at least 1000 yen
	xor a
	ldh [hMoney], a
	ldh [hMoney + 2], a
	ld a, $10
	ldh [hMoney + 1], a
	call HasEnoughMoney
	jr nc, .buy_coins
	ld hl, .CantAffordTheCoins
	jr .print_ret
.buy_coins
	; Spend 1000 yen
	xor a
	ldh [hMoney], a
	ldh [hMoney + 2], a
	ld a, $10
	ldh [hMoney + 1], a
	ld hl, hMoney + 2
	ld de, wPlayerMoney + 2
	ld c, $3
	predef SubBCDPredef
	; Receive 50 coins
	xor a
	ldh [hUnusedCoinsByte], a
	ldh [hCoins], a
	ld a, $50
	ldh [hCoins + 1], a
	ld de, wPlayerCoins + 1
	ld hl, hCoins + 1
	ld c, $2
	predef AddBCDPredef
	; Update display
	call GameCornerDrawCoinBox
	ld hl, .ThanksHereAre50Coins
	jr .print_ret
.declined
	ld hl, .PleaseComePlaySometime
	jr .print_ret
.coin_case_full
	ld hl, .CoinCaseIsFull
	jr .print_ret
.no_coin_case
	ld hl, .DontHaveCoinCase
.print_ret
	call PrintText
	jp TextScriptEnd

.DoYouNeedSomeGameCoins:
	text_far _GameCornerClerkDoYouNeedSomeGameCoinsText
	text_end

.ThanksHereAre50Coins:
	text_far _GameCornerClerkThanksHereAre50CoinsText
	text_end

.PleaseComePlaySometime:
	text_far _GameCornerClerkPleaseComePlaySometimeText
	text_end

.CantAffordTheCoins:
	text_far _GameCornerClerkCantAffordTheCoinsText
	text_end

.CoinCaseIsFull:
	text_far _GameCornerClerkCoinCaseIsFullText
	text_end

.DontHaveCoinCase:
	text_far _GameCornerClerkDontHaveCoinCaseText
	text_end

GameCornerMiddleAgedMan1Text:
	text_far _GameCornerMiddleAgedMan1Text
	text_end

GameCornerBeauty2Text:
	text_far _GameCornerBeauty2Text
	text_end

GameCornerFishingGuru1Text:
	text_asm
	CheckEvent EVENT_GOT_10_COINS
	jr nz, .alreadyGotNpcCoins
	ld hl, .WantToPlayText
	call PrintText
	ld b, COIN_CASE
	call IsItemInBag
	jr z, .dontHaveCoinCase
	call Has9990Coins
	jr nc, .coinCaseFull
	xor a
	ldh [hUnusedCoinsByte], a
	ldh [hCoins], a
	ld a, $10
	ldh [hCoins + 1], a
	ld de, wPlayerCoins + 1
	ld hl, hCoins + 1
	ld c, $2
	predef AddBCDPredef
	SetEvent EVENT_GOT_10_COINS
	ld a, $1
	ld [wDoNotWaitForButtonPressAfterDisplayingText], a
	ld hl, .Received10CoinsText
	jr .print_ret
.alreadyGotNpcCoins
	ld hl, .WinsComeAndGoText
	jr .print_ret
.coinCaseFull
	ld hl, .DontNeedMyCoinsText
	jr .print_ret
.dontHaveCoinCase
	ld hl, GameCornerOopsForgotCoinCaseText
.print_ret
	call PrintText
	jp TextScriptEnd

.WantToPlayText:
	text_far _GameCornerFishingGuru1WantToPlayText
	text_end

.Received10CoinsText:
	text_far _GameCornerFishingGuru1Received10CoinsText
	sound_get_item_1
	text_end

.DontNeedMyCoinsText:
	text_far _GameCornerFishingGuru1DontNeedMyCoinsText
	text_end

.WinsComeAndGoText:
	text_far _GameCornerFishingGuru1WinsComeAndGoText
	text_end

GameCornerMiddleAgedWomanText:
	text_far _GameCornerMiddleAgedWomanText
	text_end

GameCornerGymGuideText:
	text_asm
	CheckEvent EVENT_BEAT_ERIKA
	ld hl, GameCornerGymGuideChampInMakingText
	jr z, .not_defeated
	ld hl, GameCornerGymGuideTheyOfferRarePokemonText
.not_defeated
	call PrintText
	jp TextScriptEnd

GameCornerGymGuideChampInMakingText:
	text_far _GameCornerGymGuideChampInMakingText
	text_end

GameCornerGymGuideTheyOfferRarePokemonText:
	text_far _GameCornerGymGuideTheyOfferRarePokemonText
	text_end

GameCornerGamblerText:
	text_far _GameCornerGamblerText
	text_end

GameCornerMiddleAgedMan2Text:
	text_asm
	CheckEvent EVENT_GOT_20_COINS_2
	jr nz, .alreadyGotNpcCoins
	ld hl, .WantSomeCoinsText
	call PrintText
	ld b, COIN_CASE
	call IsItemInBag
	jr z, .dontHaveCoinCase
	call Has9990Coins
	jr nc, .coinCaseFull
	xor a
	ldh [hUnusedCoinsByte], a
	ldh [hCoins], a
	ld a, $20
	ldh [hCoins + 1], a
	ld de, wPlayerCoins + 1
	ld hl, hCoins + 1
	ld c, $2
	predef AddBCDPredef
	SetEvent EVENT_GOT_20_COINS_2
	ld hl, .Received20CoinsText
	jr .print_ret
.alreadyGotNpcCoins
	ld hl, .INeedMoreCoinsText
	jr .print_ret
.coinCaseFull
	ld hl, .YouHaveLotsOfCoinsText
	jr .print_ret
.dontHaveCoinCase
	ld hl, GameCornerOopsForgotCoinCaseText
.print_ret
	call PrintText
	jp TextScriptEnd

.WantSomeCoinsText:
	text_far _GameCornerMiddleAgedMan2WantSomeCoinsText
	text_end

.Received20CoinsText:
	text_far _GameCornerMiddleAgedMan2Received20CoinsText
	sound_get_item_1
	text_end

.YouHaveLotsOfCoinsText:
	text_far _GameCornerMiddleAgedMan2YouHaveLotsOfCoinsText
	text_end

.INeedMoreCoinsText:
	text_far _GameCornerMiddleAgedMan2INeedMoreCoinsText
	text_end

GameCornerFishingGuru2Text:
	text_asm
	CheckEvent EVENT_GOT_20_COINS
	jr nz, .alreadyGotNpcCoins
	ld hl, .ThrowingMeOffText
	call PrintText
	ld b, COIN_CASE
	call IsItemInBag
	jr z, .dontHaveCoinCase
	call Has9990Coins
	jr z, .coinCaseFull
	xor a
	ldh [hUnusedCoinsByte], a
	ldh [hCoins], a
	ld a, $20
	ldh [hCoins + 1], a
	ld de, wPlayerCoins + 1
	ld hl, hCoins + 1
	ld c, $2
	predef AddBCDPredef
	SetEvent EVENT_GOT_20_COINS
	ld hl, .Received20CoinsText
	jr .print_ret
.alreadyGotNpcCoins
	ld hl, .CloselyWatchTheReelsText
	jr .print_ret
.coinCaseFull
	ld hl, .YouGotYourOwnCoinsText
	jr .print_ret
.dontHaveCoinCase
	ld hl, GameCornerOopsForgotCoinCaseText
.print_ret
	call PrintText
	jp TextScriptEnd

.ThrowingMeOffText:
	text_far _GameCornerFishingGuru2ThrowingMeOffText
	text_end

.Received20CoinsText:
	text_far _GameCornerFishingGuru2Received20CoinsText
	sound_get_item_1
	text_end

.YouGotYourOwnCoinsText:
	text_far _GameCornerFishingGuru2YouGotYourOwnCoinsText
	text_end

.CloselyWatchTheReelsText:
	text_far _GameCornerFishingGuru2CloselyWatchTheReelsText
	text_end

GameCornerRocketText:
	text_asm
	ld hl, .ImGuardingThisPosterText
	call PrintText
	ld hl, wd72d
	set 6, [hl]
	set 7, [hl]
	ld hl, .BattleEndText
	ld de, .BattleEndText
	call SaveEndBattleTextPointers
	ldh a, [hSpriteIndex]
	ld [wSpriteIndex], a
	call EngageMapTrainer
	call InitBattleEnemyParameters
	xor a
	ldh [hJoyHeld], a
	ldh [hJoyPressed], a
	ldh [hJoyReleased], a
	ld a, SCRIPT_GAMECORNER_ROCKET_BATTLE
	ld [wGameCornerCurScript], a
	jp TextScriptEnd

.ImGuardingThisPosterText:
	text_far _GameCornerRocketImGuardingThisPosterText
	text_end

.BattleEndText:
	text_far _GameCornerRocketBattleEndText
	text_end

GameCornerRocketAfterBattleText:
	text_far _GameCornerRocketAfterBattleText
	text_end

GameCornerPosterText:
	text_asm
	ld a, $1
	ld [wDoNotWaitForButtonPressAfterDisplayingText], a
	ld hl, .SwitchBehindPosterText
	call PrintText
	call WaitForSoundToFinish
	ld a, SFX_GO_INSIDE
	call PlaySound
	call WaitForSoundToFinish
	SetEvent EVENT_FOUND_ROCKET_HIDEOUT
	ld a, $43
	ld [wNewTileBlockID], a
	lb bc, 2, 8
	predef ReplaceTileBlock
	jp TextScriptEnd

.SwitchBehindPosterText:
	text_far _GameCornerPosterSwitchBehindPosterText
	text_asm
	ld a, SFX_SWITCH
	call PlaySound
	call WaitForSoundToFinish
	jp TextScriptEnd

GameCornerOopsForgotCoinCaseText:
	text_far _GameCornerOopsForgotCoinCaseText
	text_end

GameCornerDrawCoinBox:
	ld hl, wd730
	set 6, [hl]
	hlcoord 11, 0
	lb bc, 5, 7
	call TextBoxBorder
	call UpdateSprites
	hlcoord 12, 1
	lb bc, 4, 7
	call ClearScreenArea
	hlcoord 12, 2
	ld de, GameCornerMoneyText
	call PlaceString
	hlcoord 12, 3
	ld de, GameCornerBlankText1
	call PlaceString
	hlcoord 12, 3
	ld de, wPlayerMoney
	ld c, 3 | MONEY_SIGN | LEADING_ZEROES
	call PrintBCDNumber
	hlcoord 12, 4
	ld de, GameCornerCoinText
	call PlaceString
	hlcoord 12, 5
	ld de, GameCornerBlankText2
	call PlaceString
	hlcoord 15, 5
	ld de, wPlayerCoins
	ld c, $82
	call PrintBCDNumber
	ld hl, wd730
	res 6, [hl]
	ret

GameCornerMoneyText:
	db "MONEY@"

GameCornerCoinText:
	db "COIN@"

GameCornerBlankText1:
	db "       @"

GameCornerBlankText2:
	db "       @"

Has9990Coins:
	ld a, $99
	ldh [hCoins], a
	ld a, $90
	ldh [hCoins + 1], a
	jp HasEnoughCoins
