	object_const_def
	const_export OAKSLAB_RIVAL
	const_export OAKSLAB_EEVEE_POKE_BALL
	const_export OAKSLAB_OAK1
	const_export OAKSLAB_POKEDEX1
	const_export OAKSLAB_POKEDEX2
	const_export OAKSLAB_OAK2
	const_export OAKSLAB_GIRL
	const_export OAKSLAB_SCIENTIST1
	const_export OAKSLAB_SCIENTIST2

OaksLab_Object:
	db $3 ; border block

	def_warp_events
	warp_event  4, 11, LAST_MAP, 3
	warp_event  5, 11, LAST_MAP, 3

	def_bg_events

	def_object_events
	object_event  4,  3, SPRITE_BLUE, STAY, NONE, TEXT_OAKSLAB_RIVAL, OPP_RIVAL1, 1
	object_event  7,  3, SPRITE_POKE_BALL, STAY, NONE, TEXT_OAKSLAB_EEVEE_POKE_BALL
	object_event  5,  2, SPRITE_OAK, STAY, DOWN, TEXT_OAKSLAB_OAK1
	object_event  2,  1, SPRITE_POKEDEX, STAY, NONE, TEXT_OAKSLAB_POKEDEX1
	object_event  3,  1, SPRITE_POKEDEX, STAY, NONE, TEXT_OAKSLAB_POKEDEX2
	object_event  5, 10, SPRITE_OAK, STAY, UP, TEXT_OAKSLAB_OAK2
	object_event  1,  9, SPRITE_GIRL, WALK, UP_DOWN, TEXT_OAKSLAB_GIRL
	object_event  2, 10, SPRITE_SCIENTIST, STAY, NONE, TEXT_OAKSLAB_SCIENTIST1
	object_event  8, 10, SPRITE_SCIENTIST, STAY, NONE, TEXT_OAKSLAB_SCIENTIST2

	def_warps_to OAKS_LAB
