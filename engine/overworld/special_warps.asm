PrepareForSpecialWarp::
	call LoadSpecialWarpData
	predef LoadTilesetHeader
	ld hl, wd732
	bit 2, [hl] ; dungeon warp or fly warp?
	res 2, [hl]
	jr z, .debugNewGameWarp
	ld a, [wDestinationMap]
	jr .next
.debugNewGameWarp
	bit BIT_DEBUG_MODE, [hl]
	jr z, .setNewGameMatWarp ; apply to StartNewGameDebug only
	call PrepareNewGameDebug
.setNewGameMatWarp
	; This is called by OakSpeech during StartNewGame and
	; loads the first warp event for the specified map index.
	ld a, PALLET_TOWN 
.next
	ld b, a
	ld a, [wd72d]
	and a
	jr nz, .next2
	ld a, b
.next2
	ld hl, wd732
	bit 4, [hl] ; dungeon warp
	ret nz
	ld [wLastMap], a
	ret

LoadSpecialWarpData:
	ld a, [wd72d]
	cp TRADE_CENTER
	jr nz, .notTradeCenter
	ld hl, TradeCenterPlayerWarp
	ldh a, [hSerialConnectionStatus]
	cp USING_INTERNAL_CLOCK
	jr z, .copyWarpData
	ld hl, TradeCenterFriendWarp
	jr .copyWarpData
.notTradeCenter
	cp COLOSSEUM
	jr nz, .notColosseum
	ld hl, ColosseumPlayerWarp
	ldh a, [hSerialConnectionStatus]
	cp USING_INTERNAL_CLOCK
	jr z, .copyWarpData
	ld hl, ColosseumFriendWarp
	jr .copyWarpData
.notColosseum
	ld a, [wd732]
	bit BIT_DEBUG_MODE, a
	; warp to wLastMap (PALLET_TOWN) for StartNewGameDebug
	jr nz, .notNewGameWarp
	bit 2, a
	jr nz, .notNewGameWarp
	ld hl, NewGameWarp
.copyWarpData
	ld de, wCurMap
	ld c, $7
.copyWarpDataLoop
	ld a, [hli]
	ld [de], a
	inc de
	dec c
	jr nz, .copyWarpDataLoop
	ld a, [hli]
	ld [wCurMapTileset], a
	xor a
	jr .done
.notNewGameWarp
	ld a, [wLastMap] ; this value is overwritten before it's ever read
	ld hl, wd732
	bit 4, [hl] ; dungeon warp
	jr nz, .usedDungeonWarp
	bit 6, [hl] ; blacked out
	res 6, [hl]
	jr z, .otherDestination
	ld a, [wLastBlackoutMap]
	jr .usedFlyWarp
.usedDungeonWarp
	ld hl, wd72d
	res 4, [hl]
	ld a, [wDungeonWarpDestinationMap]
	ld b, a
	ld [wCurMap], a
	ld a, [wWhichDungeonWarp]
	ld c, a
	ld hl, DungeonWarpList
	ld de, 0
	ld a, 6
	ld [wDungeonWarpDataEntrySize], a
.dungeonWarpListLoop
	ld a, [hli]
	cp b
	jr z, .matchedDungeonWarpDestinationMap
	inc hl
	jr .nextDungeonWarp
.matchedDungeonWarpDestinationMap
	ld a, [hli]
	cp c
	jr z, .matchedDungeonWarpID
.nextDungeonWarp
	ld a, [wDungeonWarpDataEntrySize]
	add e
	ld e, a
	jr .dungeonWarpListLoop
.matchedDungeonWarpID
	ld hl, DungeonWarpData
	add hl, de
	jr .copyWarpData2
.otherDestination
	ld a, [wDestinationMap]
.usedFlyWarp
	ld b, a
	ld [wCurMap], a
	ld hl, FlyWarpDataPtr
.flyWarpDataPtrLoop
	ld a, [hli]
	inc hl
	cp b
	jr z, .foundFlyWarpMatch
	inc hl
	inc hl
	jr .flyWarpDataPtrLoop
.foundFlyWarpMatch
	ld a, [hli]
	ld h, [hl]
	ld l, a
.copyWarpData2
	ld de, wCurrentTileBlockMapViewPointer
	ld c, $6
.copyWarpDataLoop2
	ld a, [hli]
	ld [de], a
	inc de
	dec c
	jr nz, .copyWarpDataLoop2
	xor a ; OVERWORLD
	ld [wCurMapTileset], a
.done
	ld [wYOffsetSinceLastSpecialWarp], a
	ld [wXOffsetSinceLastSpecialWarp], a
	ld a, -1 ; exclude normal warps
	ld [wDestinationWarpID], a
	ret

INCLUDE "data/maps/special_warps.asm"
