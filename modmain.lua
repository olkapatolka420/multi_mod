PrefabFiles = {
	"dr_multi",
	"dr_multi_none",
	"nacho",
}

Assets = {
    Asset( "IMAGE", "images/saveslot_portraits/dr_multi.tex" ),
    Asset( "ATLAS", "images/saveslot_portraits/dr_multi.xml" ),

    Asset( "IMAGE", "images/selectscreen_portraits/dr_multi.tex" ),
    Asset( "ATLAS", "images/selectscreen_portraits/dr_multi.xml" ),
	
    Asset( "IMAGE", "images/selectscreen_portraits/dr_multi_silho.tex" ),
    Asset( "ATLAS", "images/selectscreen_portraits/dr_multi_silho.xml" ),

    Asset( "IMAGE", "bigportraits/dr_multi.tex" ),
    Asset( "ATLAS", "bigportraits/dr_multi.xml" ),
	
	Asset( "IMAGE", "images/map_icons/dr_multi.tex" ),
	Asset( "ATLAS", "images/map_icons/dr_multi.xml" ),
	
	Asset( "IMAGE", "images/avatars/avatar_dr_multi.tex" ),
    Asset( "ATLAS", "images/avatars/avatar_dr_multi.xml" ),
	
	Asset( "IMAGE", "images/avatars/avatar_ghost_dr_multi.tex" ),
    Asset( "ATLAS", "images/avatars/avatar_ghost_dr_multi.xml" ),
	
	Asset( "IMAGE", "images/avatars/self_inspect_dr_multi.tex" ),
    Asset( "ATLAS", "images/avatars/self_inspect_dr_multi.xml" ),
	
	Asset( "IMAGE", "images/names_dr_multi.tex" ),
    Asset( "ATLAS", "images/names_dr_multi.xml" ),
	
	Asset( "IMAGE", "images/names_gold_dr_multi.tex" ),
    Asset( "ATLAS", "images/names_gold_dr_multi.xml" ),
}

AddMinimapAtlas("images/map_icons/dr_multi.xml")

local require = GLOBAL.require
local STRINGS = GLOBAL.STRINGS
local containers = require "containers"

AddReplicableComponent("container")
containers.params.nacho = containers.params.chester

-- The character select screen lines
STRINGS.CHARACTER_TITLES.dr_multi = "The Mad Scientist"
STRINGS.CHARACTER_NAMES.dr_multi = "Dr Multi"
STRINGS.CHARACTER_DESCRIPTIONS.dr_multi = "*Works with uranium\n*Has iron deficiency"
STRINGS.CHARACTER_QUOTES.dr_multi = "\"Who said that there must be only one God?\""
STRINGS.CHARACTER_SURVIVABILITY.dr_multi = "Slim"

-- Custom speech strings
STRINGS.CHARACTERS.DR_MULTI = require "speech_dr_multi"

-- The character's name as appears in-game 
STRINGS.NAMES.DR_MULTI = "Dr Multi"
STRINGS.NAMES.NACHO = "Nacho"
STRINGS.SKIN_NAMES.dr_multi_none = "Dr Multi"
STRINGS.NACHO_TALK = {
    "kurwa",
    "dada",
    "spierdalaj",
    "kocham piwo",
    "where is mama",
}

-- The skins shown in the cycle view window on the character select screen.
-- A good place to see what you can put in here is in skinutils.lua, in the function GetSkinModes
local skin_modes = {
    { 
        type = "ghost_skin",
        anim_bank = "ghost",
        idle_anim = "idle", 
        scale = 0.75, 
        offset = { 0, -25 } 
    },
}

-- Add mod character to mod character list. Also specify a gender. Possible genders are MALE, FEMALE, ROBOT, NEUTRAL, and PLURAL.
AddModCharacter("dr_multi", "MALE", skin_modes)
