-- Generated from template

if CAddonTemplateGameMode == nil then
	CAddonTemplateGameMode = class({})
end

function Precache( context )
	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]
	PrecacheUnitByNameSync("npc_dota_building_homebase", context)
	PrecacheResource( "particle", "particles/econ/events/nexon_hero_compendium_2014/teleport_end_spiral_nexon_hero_cp_2014.vpcf", context )
end

require("game_setup")

-- Create the game mode when we activate
function Activate()
	GameRules.AddonTemplate = CAddonTemplateGameMode()
	GameRules.AddonTemplate:InitGameMode()
end

function CAddonTemplateGameMode:InitGameMode()

	print( "Template addon is loaded." )
	GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 2 )
	GameSetup:init()

	ListenToGameEvent("npc_spawned", Dynamic_Wrap(self, "OnUnitSpawned"), self)
      
end

function CAddonTemplateGameMode:OnUnitSpawned( args )
	local entH = EntIndexToHScript(args.entindex)
	if entH ~= nil then
		local count = entH:GetAbilityCount()
		if entH:IsHero() then

			--add starting items
			local hero = entH
			if hero:HasItemInInventory("item_custom_scroll") == false then
				hero:AddItemByName("item_custom_scroll")
				hero:AddItemByName("item_second_worker")
			end

			--level up all abilities to max
			local i = 0
			while i < 24 or i < count do
				local abil = hero:GetAbilityByIndex(i)
				if abil ~= nil then
					local maxLevel = abil:GetMaxLevel()
					abil:SetLevel(maxLevel);
				end
				i = i + 1
			end
		end
	end
end

-- Evaluate the state of the game
function CAddonTemplateGameMode:OnThink()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		--print( "Template addon script is running." )
	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil
	end
	return 1
end