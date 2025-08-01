INCLUDE "macros/asserts.asm"
INCLUDE "macros/const.asm"
INCLUDE "macros/predef.asm"
INCLUDE "macros/farcall.asm"
INCLUDE "macros/data.asm"
INCLUDE "macros/code.asm"
INCLUDE "macros/gfx.asm"
INCLUDE "macros/coords.asm"
INCLUDE "macros/vc.asm"

;INCLUDE "macros/scripts/audio.asm"
INCLUDE "macros/scripts/maps.asm"
INCLUDE "macros/scripts/events.asm"
INCLUDE "macros/scripts/text.asm"
INCLUDE "macros/scripts/gfx_anims.asm"

INCLUDE "constants/charmap.asm"
INCLUDE "constants/hardware.inc"
INCLUDE "constants/oam_constants.asm"
INCLUDE "constants/ram_constants.asm"
INCLUDE "constants/misc_constants.asm"
INCLUDE "constants/gfx_constants.asm"
INCLUDE "constants/serial_constants.asm"
INCLUDE "constants/script_constants.asm"
INCLUDE "constants/type_constants.asm"
INCLUDE "constants/battle_constants.asm"
INCLUDE "constants/battle_anim_constants.asm"
INCLUDE "constants/move_constants.asm"
INCLUDE "constants/move_animation_constants.asm"
INCLUDE "constants/move_effect_constants.asm"
INCLUDE "constants/item_constants.asm"
INCLUDE "constants/pokemon_constants.asm"
INCLUDE "constants/pokedex_constants.asm"
INCLUDE "constants/pokemon_data_constants.asm"
INCLUDE "constants/trainer_constants.asm"
INCLUDE "constants/icon_constants.asm"
INCLUDE "constants/sprite_constants.asm"
INCLUDE "constants/sprite_data_constants.asm"
INCLUDE "constants/palette_constants.asm"
INCLUDE "constants/list_constants.asm"
INCLUDE "constants/map_constants.asm"
INCLUDE "constants/map_data_constants.asm"
INCLUDE "constants/map_object_constants.asm"
INCLUDE "constants/hide_show_constants.asm"
INCLUDE "constants/sprite_set_constants.asm"
INCLUDE "constants/credits_constants.asm"
;INCLUDE "constants/audio_constants.asm"
INCLUDE "constants/music_constants.asm"
INCLUDE "constants/tileset_constants.asm"
INCLUDE "constants/event_constants.asm"
INCLUDE "constants/text_constants.asm"
INCLUDE "constants/menu_constants.asm"
INCLUDE "constants/sprite_anim_constants.asm"
INCLUDE "constants/pikachu_emotion_constants.asm"

IF DEF(_YELLOW_VC)
INCLUDE "vc/pokeyellow.constants.asm"
ENDC
