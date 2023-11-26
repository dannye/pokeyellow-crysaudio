CinnabarPokecenter_Script:
	call Serial_TryEstablishingExternallyClockedConnection
	jp EnableAutoTextBoxDrawing

CinnabarPokecenter_TextPointers:
	def_text_pointers
	dw_const CinnabarPokecenterNurseText,            TEXT_CINNABARPOKECENTER_NURSE
	dw_const CinnabarPokecenterCooltrainerFText,     TEXT_CINNABARPOKECENTER_COOLTRAINER_F
	dw_const CinnabarPokecenterGentlemanText,        TEXT_CINNABARPOKECENTER_GENTLEMAN
	dw_const CinnabarPokecenterLinkReceptionistText, TEXT_CINNABARPOKECENTER_LINK_RECEPTIONIST
	dw_const CinnabarPokecenterChanseyText,          TEXT_CINNABARPOKECENTER_CHANSEY

CinnabarPokecenterNurseText:
	script_pokecenter_nurse

CinnabarPokecenterCooltrainerFText:
	text_far _CinnabarPokecenterCooltrainerFText
	text_end

CinnabarPokecenterGentlemanText:
	text_far _CinnabarPokecenterGentlemanText
	text_end

CinnabarPokecenterLinkReceptionistText:
	script_cable_club_receptionist

CinnabarPokecenterChanseyText:
	text_asm
	callfar PokecenterChanseyText
	jp TextScriptEnd
