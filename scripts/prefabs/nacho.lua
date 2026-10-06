local brain = require("brains/crittersbrain")

local assets =
{
	Asset("ANIM", "anim/pupington_build.zip"),
	Asset("ANIM", "anim/pupington_basic.zip"),
	Asset("ANIM", "anim/pupington_emotes.zip"),
	Asset("ANIM", "anim/pupington_traits.zip"),
	Asset("ANIM", "anim/pupington_jump.zip"),
}

local function should_wake(inst)
	return (DefaultWakeTest(inst) and not (inst.components.follower.leader and inst.components.follower.leader:HasTag("sleeping")))
		or not inst.components.follower:IsNearLeader(6)
end

local function should_sleep(inst)
	return (DefaultSleepTest(inst)
		or (inst.components.follower.leader and inst.components.follower.leader:HasTag("sleeping")))
		and inst.components.follower:IsNearLeader(5)
end

local function nacho_fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddDynamicShadow()
	inst.entity:AddNetwork()

	inst.DynamicShadow:SetSize(1, 0.33)
	inst.Transform:SetFourFaced()
	inst.AnimState:SetBank("pupington")
	inst.AnimState:SetBuild("pupington_build")
	inst.AnimState:PlayAnimation("idle_loop")
	MakeCharacterPhysics(inst, 1, 0.5)
	inst.Physics:SetDontRemoveOnSleep(true)

	inst:AddTag("critter")
	inst:AddTag("companion")
	inst:AddTag("notraptrigger")
	inst:AddTag("noauradamage")
	inst:AddTag("small_livestock")
	inst:AddTag("NOBLOCK")
	inst:AddTag("dr_multi_nacho")

	inst:AddComponent("talker")
	inst.components.talker:MakeChatter()

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst.GetPeepChance = function()
		return 0
	end
	inst.IsAffectionate = function()
		return true
	end
	inst.IsPlayful = inst.IsAffectionate
	inst.IsSuperCute = inst.IsAffectionate
	inst.playmatetags = { "critter" }

	inst:AddComponent("inspectable")
	inst.components.inspectable.nameoverride = "NACHO"

	inst:AddComponent("follower")
	inst.components.follower:KeepLeaderOnAttacked()
	inst.components.follower.keepdeadleader = true
	inst.components.follower.keepleaderduringminigame = true

	inst:AddComponent("knownlocations")

	inst:AddComponent("sleeper")
	inst.components.sleeper:SetResistance(3)
	inst.components.sleeper.testperiod = GetRandomWithVariance(6, 2)
	inst.components.sleeper:SetSleepTest(should_sleep)
	inst.components.sleeper:SetWakeTest(should_wake)

	inst:AddComponent("eater")
	inst.components.eater:SetDiet({ FOODTYPE.MONSTER }, { FOODTYPE.MONSTER })

	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.CRITTER_HUNGERTIME)
	inst.components.perishable:StopPerishing()

	inst:AddComponent("locomotor")
	inst.components.locomotor:EnableGroundSpeedMultiplier(true)
	inst.components.locomotor:SetTriggersCreep(false)
	inst.components.locomotor.softstop = true
	inst.components.locomotor.walkspeed = TUNING.CRITTER_WALK_SPEED
	inst.components.locomotor:SetAllowPlatformHopping(true)

	inst:AddComponent("embarker")
	inst.components.embarker.embark_speed = inst.components.locomotor.walkspeed
	inst:AddComponent("drownable")

	inst:AddComponent("crittertraits")
	inst:AddComponent("timer")
	inst:AddComponent("container")
	inst.components.container:WidgetSetup("chester")

	inst:SetBrain(brain)
	inst:SetStateGraph("SGcritter_puppy")

	local function schedule_speech()
		inst:DoTaskInTime(math.random(10,20), function()
			if not inst:IsValid() then
				return
			end

			if not inst:HasTag("sleeping") and not inst:IsAsleep() then
				inst.components.talker:Chatter("NACHO_TALK", math.random(#STRINGS.NACHO_TALK), 2, true)
			end
			schedule_speech()
		end)
	end
	schedule_speech()

	return inst
end

return Prefab("nacho", nacho_fn, assets)
