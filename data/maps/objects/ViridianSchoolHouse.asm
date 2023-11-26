	object_const_def
	const_export VIRIDIANSCHOOLHOUSE_BRUNETTE_GIRL
	const_export VIRIDIANSCHOOLHOUSE_COOLTRAINER_F
	const_export VIRIDIANSCHOOLHOUSE_LITTLE_GIRL

ViridianSchoolHouse_Object:
	db $a ; border block

	def_warp_events
	warp_event  2,  7, LAST_MAP, 3
	warp_event  3,  7, LAST_MAP, 3

	def_bg_events

	def_object_events
	object_event  3,  5, SPRITE_BRUNETTE_GIRL, STAY, UP, TEXT_VIRIDIANSCHOOLHOUSE_BRUNETTE_GIRL
	object_event  4,  1, SPRITE_COOLTRAINER_F, STAY, DOWN, TEXT_VIRIDIANSCHOOLHOUSE_COOLTRAINER_F
	object_event  4,  5, SPRITE_LITTLE_GIRL, STAY, UP, TEXT_VIRIDIANSCHOOLHOUSE_LITTLE_GIRL

	def_warps_to VIRIDIAN_SCHOOL_HOUSE
