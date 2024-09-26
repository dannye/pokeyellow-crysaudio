; not zero if an NPC movement script is running, the player character is
; automatically stepping down from a door, or joypad states are being simulated
IsPlayerCharacterBeingControlledByGame::
	ld a, [wNPCMovementScriptPointerTableNum]
	and a
	ret nz
	ld a, [wMovementFlags]
	bit BIT_EXITING_DOOR, a
	ret nz
	ld a, [wStatusFlags5]
	and 1 << BIT_SCRIPTED_MOVEMENT_STATE
	ret

RunNPCMovementScript::
	ld hl, wMovementFlags
	bit BIT_STANDING_ON_DOOR, [hl]
	res BIT_STANDING_ON_DOOR, [hl]
	jr nz, .playerStepOutFromDoor
	ld a, [wNPCMovementScriptPointerTableNum]
	and a
	ret z
	dec a
	add a
	ld d, 0
	ld e, a
	ld hl, .NPCMovementScriptPointerTables
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ldh a, [hLoadedROMBank]
	push af
	ld a, [wNPCMovementScriptBank]
	call BankswitchCommon
	ld a, [wNPCMovementScriptFunctionNum]
	call CallFunctionInTable
	pop af
	call BankswitchCommon
	ret

.NPCMovementScriptPointerTables
	dw PalletMovementScriptPointerTable
	dw PewterMuseumGuyMovementScriptPointerTable
	dw PewterGymGuyMovementScriptPointerTable
.playerStepOutFromDoor
	farjp PlayerStepOutFromDoor

EndNPCMovementScript::
	farjp _EndNPCMovementScript

DebugPressedOrHeldB:: ; dummy except in _DEBUG
; This is used to skip Trainer battles, the
; Safari Game step counter, and some NPC scripts.
IF DEF(_DEBUG)
	ldh a, [hJoyHeld]
	bit BIT_B_BUTTON, a
	ret nz
	ldh a, [hJoyPressed]
	bit BIT_B_BUTTON, a
	ret
ENDC
	ret
