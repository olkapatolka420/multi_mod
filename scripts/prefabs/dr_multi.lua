local MakePlayerCharacter = require "prefabs/player_common"

local assets = {
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
}

-- Your character's stats
TUNING.DR_MULTI_HEALTH = 130
TUNING.DR_MULTI_HUNGER = 150
TUNING.DR_MULTI_SANITY = 110

-- Custom starting inventory
TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.DR_MULTI = {
	"greengem",
	"bird_egg"
}

local start_inv = {}
for k, v in pairs(TUNING.GAMEMODE_STARTING_ITEMS) do
    start_inv[string.lower(k)] = v.DR_MULTI
end
local prefabs = FlattenTree(start_inv, true)
table.insert(prefabs, "nacho")

local function configure_nacho(nacho, leader)
	if nacho.components.inspectable ~= nil then
		nacho.components.inspectable.nameoverride = "NACHO"
	end
	nacho:AddTag("dr_multi_nacho")
	nacho.components.follower:SetLeader(leader)
	nacho.components.container:WidgetSetup("chester")
end

local function ensure_nacho(inst)
	local x, y, z = inst.Transform:GetWorldPosition()
	local candidates = {}
	local seen = {}

	local function add_candidate(entity)
		if entity:IsValid() and not seen[entity]
			and (entity.prefab == "nacho" or entity.prefab == "critter_puppy")
			and (entity:HasTag("dr_multi_nacho")
				or (entity.components.follower ~= nil and entity.components.follower.leader == inst)
				or (entity.components.inspectable ~= nil and entity.components.inspectable.nameoverride == "NACHO")) then
			seen[entity] = true
			table.insert(candidates, entity)
		end
	end

	if inst.components.leader ~= nil then
		for follower in pairs(inst.components.leader.followers) do
			add_candidate(follower)
		end
	end

	for _, entity in ipairs(TheSim:FindEntities(x, y, z, 40, { "critter" }, { "INLIMBO" })) do
		add_candidate(entity)
	end

	local nacho = inst.nacho ~= nil and inst.nacho:IsValid()
		and inst.nacho.prefab == "nacho" and inst.nacho or nil
	if nacho == nil then
		for _, candidate in ipairs(candidates) do
			if candidate.prefab == "nacho" then
				nacho = candidate
				break
			end
		end
	end
	if nacho == nil then
		for _, candidate in ipairs(candidates) do
			if candidate.components.container ~= nil then
				nacho = candidate
				break
			end
		end
	end

	if nacho == nil then
		nacho = SpawnPrefab("nacho")
		if nacho ~= nil then
			nacho.Transform:SetPosition(x + 1, y, z)
		end
	end

	if nacho ~= nil then
		configure_nacho(nacho, inst)
		inst.nacho = nacho
		for _, duplicate in ipairs(candidates) do
			if duplicate ~= nacho and duplicate:IsValid()
				and (duplicate.prefab == "nacho" or duplicate.prefab == "critter_puppy") then
				if duplicate.components.container ~= nil then
					for slot = 1, duplicate.components.container:GetNumSlots() do
						local item = duplicate.components.container:RemoveItemBySlot(slot)
						if item ~= nil then
							local leftover = nacho.components.container:GiveItem(item)
							if leftover ~= nil then
								leftover.Transform:SetPosition(duplicate.Transform:GetWorldPosition())
							end
						end
					end
				end
				duplicate:Remove()
			end
		end
	end
end

local function update_sanity_glow(inst)
	if inst.Light ~= nil then
		local should_glow = not inst:HasTag("playerghost")
			and not inst.components.health:IsDead()
			and inst.components.sanity.current < 40
		inst.Light:Enable(should_glow)
	end
end

local function onbecamehuman(inst)
	inst.components.locomotor:SetExternalSpeedMultiplier(inst, "dr_multi_speed_mod", 1)
	update_sanity_glow(inst)
	local function reconcile_nacho()
		if inst:IsValid() and not inst:HasTag("playerghost") then
			ensure_nacho(inst)
		end
	end
	inst:DoTaskInTime(1, reconcile_nacho)
	inst:DoTaskInTime(4, reconcile_nacho)
end

local function onbecameghost(inst)
	inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "dr_multi_speed_mod")
	if inst.Light ~= nil then
		inst.Light:Enable(false)
	end
end

local function add_zombie_revival(inst)
	local health = inst.components.health
	local sanity = inst.components.sanity
	local original_dodelta = health.DoDelta

	health.DoDelta = function(component, amount, overtime, cause, ignore_invincible, afflicter, ignore_absorb)
		if amount < 0 and not component:IsDead()
			and (ignore_invincible or not component.invincible)
			and (component.minhealth == nil or component.minhealth <= 0)
			and component.currenthealth + amount <= 0
			and sanity.current > 0 then
			local restored_health = sanity.current
			sanity:DoDelta(-restored_health, false, "dr_multi_zombie")
			return original_dodelta(component, restored_health - component.currenthealth, false, "dr_multi_zombie")
		end

		return original_dodelta(component, amount, overtime, cause, ignore_invincible, afflicter, ignore_absorb)
	end
end

-- 2. DOPIERO POTEM ONLOAD, KTÓRY JĄ WYWOŁUJE
local function onload(inst)
    inst:ListenForEvent("ms_respawnedfromghost", onbecamehuman)
    inst:ListenForEvent("ms_becameghost", onbecameghost)

    if inst:HasTag("playerghost") then
        onbecameghost(inst)
    else
        onbecamehuman(inst)
    end

end


-- This initializes for both the server and client. Tags can be added here.
local common_postinit = function(inst)
	inst.AnimState:SetScale(1.1, 1.1)
	-- Minimap icon
	inst.MiniMapEntity:SetIcon( "dr_multi.tex" )

	inst.entity:AddLight()
	inst.Light:SetRadius(1)
	inst.Light:SetFalloff(0.7)
	inst.Light:SetIntensity(0.7)
	inst.Light:SetColour(0, 1, 0)
	inst.Light:Enable(false)
end

-- This initializes for the server only. Components are added here.
local master_postinit = function(inst)
	
	-- Set starting inventory
    inst.starting_inventory = start_inv[TheNet:GetServerGameMode()] or start_inv.default
	
	-- choose which sounds this character will play
	inst.soundsname = "willow"
	
	-- Uncomment if "wathgrithr"(Wigfrid) or "webber" voice is used
    --inst.talker_path_override = "dontstarve_DLC001/characters/"
	
	-- Stats	
	inst.components.health:SetMaxHealth(TUNING.DR_MULTI_HEALTH)
	inst.components.hunger:SetMax(TUNING.DR_MULTI_HUNGER)
	inst.components.sanity:SetMax(TUNING.DR_MULTI_SANITY)
	add_zombie_revival(inst)
	inst:ListenForEvent("sanitydelta", update_sanity_glow)
	update_sanity_glow(inst)
	
	-- Damage multiplier (optional)
    inst.components.combat.damagemultiplier = 1
	
	-- Hunger rate (optional)
	inst.components.hunger.hungerrate = 0.8 * TUNING.WILSON_HUNGER_RATE
	
	inst.OnLoad = onload
    inst.OnNewSpawn = onload
	
	-- Sanity night drain rate
	inst.components.sanity.night_drain_mult = 1.1

    local faint_wakeup_pending = false
    local original_cometotestfn = inst.components.grogginess.cometotestfn
    inst.components.grogginess.cometotestfn = function(target)
        local should_come_to = original_cometotestfn(target)
        if should_come_to and faint_wakeup_pending then
            faint_wakeup_pending = false
            TheWorld:DoTaskInTime(0.2, function()
                if target:IsValid() and target.components.talker then
                    target.components.talker:Say("oh...", 2, true, true)
                end
            end)
        end
        return should_come_to
    end

    -- Losowe omdlenia w ciągu dnia (poza walką i gdy nikt go nie goni)
    inst:DoPeriodicTask(30, function()
        -- 1. Czy postać żyje
        local is_alive = not inst:HasTag("playerghost") and not (inst.components.health and inst.components.health:IsDead())
        if not (TheWorld.state.isday and is_alive) then
            return
        end

        -- 2. Sprawdzenie, czy sam walczył w ciągu ostatnich 10 sekund lub ma cel
        if inst.components.combat then
            local time_since_attack = GetTime() - (inst.components.combat.lastdoattacktime or 0)
            local time_since_hit = GetTime() - (inst.components.combat.lastwasattackedtime or 0)

            if inst.components.combat:HasTarget() or time_since_attack < 10 or time_since_hit < 10 then
                return -- W walce, przerywamy
            end
        end

        -- 3. Sprawdzenie, czy jakikolwiek potwór/mob w promieniu 25 jednostek targetuje gracza
        local x, y, z = inst.Transform:GetWorldPosition()
        local threat = FindEntity(inst, 25, function(target)
            return target.components.combat 
                and target.components.combat.target == inst
        end, nil, { "INLIMBO", "playerghost" })

        if threat ~= nil then
            return -- Coś nas targetuje/goni, nie mdlejemy
        end

        -- 4. Losowanie omdlenia
        -- 4. Losowanie omdlenia
        if math.random() < 0.1 then
            if inst.components.talker then
                inst.components.talker:Say("oh... im feeling dizzy...")
            end
            
            local sleep_time = 1 -- DOKŁADNY CZAS OMDLENIA W SEKUNDACH

            if inst.components.grogginess then
                -- 1. Resetujemy ewentualne stare wartości i dodajemy stan uśpienia
                faint_wakeup_pending = true
                inst.components.grogginess:AddGrogginess(10)

                
                -- 2. Wymuszamy czas trwania nokautu w komponencie
                inst.components.grogginess.knockouttime = sleep_time
                inst.components.grogginess.knockoutduration = sleep_time
                


                -- 3. Jeśli gra sama go nie wybudzi po tym czasie, wybudzamy go ręcznie
                inst:DoTaskInTime(sleep_time, function()
                    if inst.components.grogginess and inst.sg and inst.sg:HasStateTag("knockout") then
                        inst.components.grogginess:ResetGrogginess()
                    else
                        faint_wakeup_pending = false
                    end
                end
            )
                
            end
        end
    end)
	
end

return MakePlayerCharacter("dr_multi", prefabs, assets, common_postinit, master_postinit, prefabs)
