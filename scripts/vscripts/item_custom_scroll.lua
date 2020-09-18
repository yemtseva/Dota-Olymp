item_custom_scroll = class({})
LinkLuaModifier( "modifier_item_custom_scroll", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function item_custom_scroll:OnAbilityPhaseStart()
	self.vTargetPosition = self:GetCursorPosition()
	--if(self.vTargetPosition.z > (self:GetCaster():GetOrigin().z+20))  do not execute if player tries to jump on second floor
	local nTeam = self:GetCaster():GetTeamNumber()
	local nEnemyTeam = nil
	if nTeam == DOTA_TEAM_GOODGUYS then
		nEnemyTeam = DOTA_TEAM_BADGUYS
	else
		nEnemyTeam = DOTA_TEAM_GOODGUYS
	end

	self.nFXIndexStart = ParticleManager:CreateParticle( "particles/econ/items/tinker/boots_of_travel/teleport_start_bots_counter.vpcf", PATTACH_CUSTOMORIGIN, nil )
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

	self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_item_custom_scroll", kv )


	return true;
end

----------------------------------------------------------------------------------------------------
function item_custom_scroll:OnAbilityPhaseInterrupted()
	ParticleManager:SetParticleControl( self.nFXIndexStart, 2, Vector( 0, 0, 0 ) )
	ParticleManager:SetParticleControl( self.nFXIndexEnd, 2, Vector( 0, 0, 0 ) )
	ParticleManager:SetParticleControl( self.nFXIndexEndTeam, 2, Vector( 0, 0, 0 ) )

	ParticleManager:DestroyParticle( self.nFXIndexStart, false )
	ParticleManager:DestroyParticle( self.nFXIndexEnd, false )
	ParticleManager:DestroyParticle( self.nFXIndexEndTeam, false )

	self:GetCaster():RemoveModifierByName( "modifier_item_custom_scroll" )

	MinimapEvent( self:GetCaster():GetTeamNumber(), self:GetCaster(), 0, 0, DOTA_MINIMAP_EVENT_CANCEL_TELEPORTING, 0 )
end
--------------------------------------------------------------------------------

function item_custom_scroll:OnSpellStart()

	ProjectileManager:ProjectileDodge( self:GetCaster() )
	FindClearSpaceForUnit( self:GetCaster(), self.vTargetPosition, true )
	self:GetCaster():StartGesture( ACT_DOTA_TELEPORT_END )

	print(self.vTargetPosition)


	ParticleManager:DestroyParticle( self.nFXIndexStart, false )
	ParticleManager:DestroyParticle( self.nFXIndexEnd, false )
	ParticleManager:DestroyParticle( self.nFXIndexEndTeam, false )

	------------------------------------------------------------------------------
	-- Destroys item after a use --
	local item = self:GetCaster():GetItemInSlot(0)
	self:GetCaster():RemoveItem(item)

end