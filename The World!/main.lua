local TearFlags = (function() TearFlags = {
	FLAG_NO_EFFECT = 0,
	FLAG_SPECTRAL = 1,
	FLAG_PIERCING = 1<<1,
	FLAG_HOMING = 1<<2,
	FLAG_SLOWING = 1<<3,
	FLAG_POISONING = 1<<4,
	FLAG_FREEZING = 1<<5,
	FLAG_COAL = 1<<6,
	FLAG_PARASITE = 1<<7,
	FLAG_MAGIC_MIRROR = 1<<8,
	FLAG_POLYPHEMUS = 1<<9,
	FLAG_WIGGLE_WORM = 1<<10,
	FLAG_UNK1 = 1<<11, --No noticeable effect
	FLAG_IPECAC = 1<<12,
	FLAG_CHARMING = 1<<13,
	FLAG_CONFUSING = 1<<14,
	FLAG_ENEMIES_DROP_HEARTS = 1<<15,
	FLAG_TINY_PLANET = 1<<16,
	FLAG_ANTI_GRAVITY = 1<<17,
	FLAG_CRICKETS_BODY = 1<<18,
	FLAG_RUBBER_CEMENT = 1<<19,
	FLAG_FEAR = 1<<20,
	FLAG_PROPTOSIS = 1<<21,
	FLAG_FIRE = 1<<22,
	FLAG_STRANGE_ATTRACTOR = 1<<23,
	FLAG_UNK2 = 1<<24, --Possible worm?
	FLAG_PULSE_WORM = 1<<25,
	FLAG_RING_WORM = 1<<26,
	FLAG_FLAT_WORM = 1<<27,
	FLAG_UNK3 = 1<<28, --Possible worm?
	FLAG_UNK4 = 1<<29, --Possible worm?
	FLAG_UNK5 = 1<<30, --Possible worm?
	FLAG_HOOK_WORM = 1<<31,
	FLAG_GODHEAD = 1<<32,
	FLAG_UNK6 = 1<<33, --No noticeable effect
	FLAG_UNK7 = 1<<34, --No noticeable effect
	FLAG_EXPLOSIVO = 1<<35,
	FLAG_CONTINUUM = 1<<36,
	FLAG_HOLY_LIGHT = 1<<37,
	FLAG_KEEPER_HEAD = 1<<38,
	FLAG_ENEMIES_DROP_BLACK_HEARTS = 1<<39,
	FLAG_ENEMIES_DROP_BLACK_HEARTS2 = 1<<40,
	FLAG_GODS_FLESH = 1<<41,
	FLAG_UNK8 = 1<<42, --No noticeable effect
	FLAG_TOXIC_LIQUID = 1<<43,
	FLAG_OUROBOROS_WORM = 1<<44,
	FLAG_GLAUCOMA = 1<<45,
	FLAG_BOOGERS = 1<<46,
	FLAG_PARASITOID = 1<<47,
	FLAG_UNK9 = 1<<48, --No noticeable effect
	FLAG_SPLIT = 1<<49,
	FLAG_DEADSHOT = 1<<50,
	FLAG_MIDAS = 1<<51,
	FLAG_EUTHANASIA = 1<<52,
	FLAG_JACOBS_LADDER = 1<<53,
	FLAG_LITTLE_HORN = 1<<54,
	FLAG_GHOST_PEPPER = 1<<55
}

return TearFlags end)()

local mod = RegisterMod("The World!", 1)
local TheWorld = Isaac.GetItemIdByName("The World!")

local time_stopped = false

local time_stopped_room = -1
local shouldUpdateTearFlags = false
local firstTearInTimeStop = -1
local timestopCountdown = -1
local rechargeCountdown = -1

function mod:OnUpdate()
	local player = Isaac.GetPlayer(0)
	if shouldUpdateTearFlags then
		if time_stopped then
			player.TearFlags = player.TearFlags | TearFlags.FLAG_ANTI_GRAVITY
		else
			player.TearFlags = player.TearFlags & ~TearFlags.FLAG_ANTI_GRAVITY
		end
		shouldUpdateTearFlags = false
	end

	if not time_stopped then 
		rechargeCountdown = rechargeCountdown - 1
		if rechargeCountdown == 0 then
			player:SetActiveCharge(1)
		end
		return 
	end

	local entities = Isaac.GetRoomEntities()

	if time_stopped_room ~= Game():GetLevel():GetCurrentRoomIndex() then
		timestop()
		player:SetActiveCharge(1)
		return
	end

	timestopCountdown = timestopCountdown - 1
	if timestopCountdown == 0 then
		timestop()
		return
	end

	for i = 1, #entities do
		local e = entities[i]
		if e.Type == EntityType.ENTITY_TEAR then
			local t = e:ToTear()

			if firstTearInTimeStop == -1 and t.FrameCount == 0 then
				firstTearInTimeStop = t.TearIndex
			end

			if firstTearInTimeStop ~= -1 and t.WaitFrames == 0 and t.TearIndex >= firstTearInTimeStop then
				timestop()
				break
			end
		end
	end
end

function mod:OnItemUse()
	if not time_stopped then
		timestop()
	end

	return true
end

function timestop()
	local player = Isaac.GetPlayer(0)
	local entities = Isaac.GetRoomEntities()

	time_stopped = not time_stopped

	for i = 1, #entities do
		local e = entities[i]
		if e.Type ~= EntityType.ENTITY_PLAYER and e.Type ~= EntityType.ENTITY_TEAR and e.Type ~= EntityType.ENTITY_FAMILIAR and e.Type ~= EntityType.ENTITY_BOMBDROP and e.Type ~= EntityType.ENTITY_PICKUP and e.Type ~= EntityType.ENTITY_SLOT and e.Type ~= EntityType.ENTITY_PROJECTILE and e.Type ~= EntityType.ENTITY_EFFECT and e.Type ~= EntityType.ENTITY_TEXT and e.Type ~= EntityType.ENTITY_KNIFE and e.Type ~= EntityType.ENTITY_LASER then
			if time_stopped then
				e:AddEntityFlags(EntityFlag.FLAG_NO_SPRITE_UPDATE)
				e:AddEntityFlags(EntityFlag.FLAG_FREEZE)
			else
				e:ClearEntityFlags(EntityFlag.FLAG_NO_SPRITE_UPDATE)
				e:ClearEntityFlags(EntityFlag.FLAG_FREEZE)
			end
		end
	end

	if time_stopped then 
		log("Toki wa tomare!")
		timestopCountdown = 100
		rechargeCountdown = -1
		time_stopped_room = Game():GetLevel():GetCurrentRoomIndex()
	else 
		log("Toki wa ugoki desu...")
		timestopCountdown = -1
		rechargeCountdown = 200
		time_stopped_room = -1
	end

	shouldUpdateTearFlags = true
	firstTearInTimeStop = -1
end

mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.OnItemUse, TheWorld)
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.OnUpdate)

local _1ktd_rs_dbg_log = {}
local _1ktd_rs_dbg_size = 10
local _1ktd_rs_dbg_x = 50
local _1ktd_rs_dbg_y = 25
local _1ktd_rs_dbg_offset = 10

function log(str)
	table.insert(_1ktd_rs_dbg_log, str)

	if #_1ktd_rs_dbg_log > _1ktd_rs_dbg_size then
		table.remove(_1ktd_rs_dbg_log, 1)
	end
end

function _1ktd_rs_dbg_render()
	local x = _1ktd_rs_dbg_x
	local y = _1ktd_rs_dbg_y
	for i = 1, #_1ktd_rs_dbg_log do
		Isaac.RenderText(_1ktd_rs_dbg_log[i], x, y, 255, 255, 255, 225)
		y = y + _1ktd_rs_dbg_offset
	end
end

