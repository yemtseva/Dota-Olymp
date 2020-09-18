item_second_worker = class({})
LinkLuaModifier( "modifier_item_second_worker", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function item_second_worker:OnAbilityPhaseStart()
	self.vTargetPosition = self:GetCursorPosition()
	--if(self.vTargetPosition.z > (self:GetCaster():GetOrigin().z+20))  do not execute if player tries to jump on second floor
	local nTeam = self:GetCaster():GetTeamNumber()
	local nEnemyTeam = nil
	if nTeam == DOTA_TEAM_GOODGUYS then
		nEnemyTeam = DOTA_TEAM_BADGUYS
	else
		nEnemyTeam = DOTA_TEAM_GOODGUYS
	end

	self.nFXIndexStart = ParticleManager:CreateParticle( "", PATTACH_CUSTOMORIGIN, nil )
	ParticleManager:SetParticleControl( self.nFXIndexStart, 0, self:GetCaster():GetOrigin() )
	ParticleManager:SetParticleControl( self.nFXIndexStart, 2, Vector( 1, 0, 0 ) )

	self.nFXIndexEnd = ParticleManager:CreateParticleForTeam( "", PATTACH_CUSTOMORIGIN, nil, nEnemyTeam )
	ParticleManager:SetParticleControl( self.nFXIndexEnd, 1, self.vTargetPosition )
	ParticleManager:SetParticleControl( self.nFXIndexEnd, 2, Vector ( 1, 0, 0 ) )
	
	self.nFXIndexEndTeam = ParticleManager:CreateParticleForTeam( "particles/econ/items/tinker/boots_of_travel/teleport_end_bots.vpcf", PATTACH_CUSTOMORIGIN, nil, nTeam )
	ParticleManager:SetParticleControl( self.nFXIndexEndTeam, 1, self.vTargetPosition )
	ParticleManager:SetParticleControl( self.nFXIndexEndTeam, 2, Vector ( 1, 0, 0 ) )

	MinimapEvent( nTeam, self:GetCaster(), self.vTargetPosition.x, self.vTargetPosition.y, DOTA_MINIMAP_EVENT_TEAMMATE_TELEPORTING, self:GetCastPoint() )

	local kv = {
		duration = self:GetCastPoint(),
		target_x = self.vTargetPosition.x,
		target_y = self.vTargetPosition.y,
		target_z = self.vTargetPosition.z
	}

	self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_item_second_worker", kv )


	return true;
end

-------------------------------------------------------------------------------

function item_second_worker:OnAbilityPhaseInterrupted()
	ParticleManager:SetParticleControl( self.nFXIndexStart, 2, Vector( 0, 0, 0 ) )
	ParticleManager:SetParticleControl( self.nFXIndexEnd, 2, Vector( 0, 0, 0 ) )
	ParticleManager:SetParticleControl( self.nFXIndexEndTeam, 2, Vector( 0, 0, 0 ) )

	ParticleManager:DestroyParticle( self.nFXIndexStart, false )
	ParticleManager:DestroyParticle( self.nFXIndexEnd, false )
	ParticleManager:DestroyParticle( self.nFXIndexEndTeam, false )

	self:GetCaster():RemoveModifierByName( "modifier_item_second_worker" )

	MinimapEvent( self:GetCaster():GetTeamNumber(), self:GetCaster(), 0, 0, DOTA_MINIMAP_EVENT_CANCEL_TELEPORTING, 0 )
end
--------------------------------------------------------------------------------

function item_second_worker:OnSpellStart()

	ProjectileManager:ProjectileDodge( self:GetCaster() )


	ParticleManager:DestroyParticle( self.nFXIndexStart, false )
	ParticleManager:DestroyParticle( self.nFXIndexEnd, false )
	ParticleManager:DestroyParticle( self.nFXIndexEndTeam, false )
	
	-----------------------------------------------------------------------------
	-- Creates the second rabochie -- 
		local player = self:GetCaster()
		local playerID = player:GetPlayerID()
		local team = PlayerResource:GetTeam(playerID)
		CreateUnitByName("maps/prefabs/npc_hellbear.vmap", self.vTargetPosition, true, nil, nil, team)
		local unit = CreateUnitByName("npc_dota_hero_templar_assassin", self.vTargetPosition, true, player, player, team)
		unit:SetControllableByPlayer(playerID, true)
		unit:StartGesture( ACT_DOTA_TELEPORT_END )
		--Deletes two scrolls--
		local item1 = unit:GetItemInSlot(0) 
		local item2 = unit:GetItemInSlot(1)
		unit:RemoveItem(item1)
		unit:RemoveItem(item2)
		-----------------------
	------------------------------------------------------------------------------
	
	CreateUnitByName("npc_hellbear", self.vTargetPosition, true, nil, nil, team)
	
	
	
	-- Destroys item after a use --
	local item = self:GetCaster():GetItemInSlot(1)
	self:GetCaster():RemoveItem(item)

end