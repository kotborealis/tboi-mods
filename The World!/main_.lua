import TearFlags from 'TearFlags.lua'

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