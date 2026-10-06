local assets =
{
	Asset( "ANIM", "anim/dr_multi.zip" ),
	Asset( "ANIM", "anim/ghost_dr_multi_build.zip" ),
}

local skins =
{
	normal_skin = "dr_multi",
	ghost_skin = "ghost_dr_multi_build",
}

return CreatePrefabSkin("dr_multi_none",
{
	base_prefab = "dr_multi",
	type = "base",
	assets = assets,
	skins = skins, 
	skin_tags = {"DR_MULTI", "CHARACTER", "BASE"},
	build_name_override = "dr_multi",
	rarity = "Character",
})