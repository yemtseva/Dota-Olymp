custom_tp = class({})
LinkLuaModifier( "modifier_custom_tp", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function custom_tp:OnAbilityPhaseStart()
	self.vTargetPosition = self:GetCursorPosition()
	--if(self.vTargetPosition.z > (self:GetCaster():GetOrigin().z+20))  do not execute if player tries to jump on second floor
	local nTeam = self:GetCaster():GetTeamNumber()
	local nEnemyTeam = nil
	if nTeam == DOTA_TEAM_GOODGUYS then
		nEnemyTeam = DOTA_TEAM_BADGUYS
	else
		nEnemyTeam = DOTA_TEAM_GOODGUYS
	end

	self.nFXIndexStart = ParticleManager:CreateParticle( "particles/econ/events/fall_major_2015/teleport_start_fallmjr_2015_i.vpcf", PATTACH_CUSTOMORIGIN, nil )
	ParticleManager:SetParticleControl( self.nFXIndexStart, 0, self:GetCaster():GetOrigin() )
	ParticleManager:SetParticleControl( self.nFXIndexStart, 2, Vector( 1, 0, 0 ) )

	self.nFXIndexEnd = ParticleManager:CreateParticleForTeam( "particles/econ/events/fall_major_2015/teleport_end_fallmjr_2015_dust.vpcf", PATTACH_CUSTOMORIGIN, nil, nEnemyTeam )
	ParticleManager:SetParticleControl( self.nFXIndexEnd, 1, self.vTargetPosition )
	ParticleManager:SetParticleControl( self.nFXIndexEnd, 2, Vector ( 1, 0, 0 ) )
	
	self.nFXIndexEndTeam = ParticleManager:CreateParticleForTeam( "particles/econ/events/fall_major_2015/teleport_end_fallmjr_2015_playercolor.vpcf", PATTACH_CUSTOMORIGIN, nil, nTeam )
	ParticleManager:SetParticleControl( self.nFXIndexEndTeam, 1, self.vTargetPosition )
	ParticleManager:SetParticleControl( self.nFXIndexEndTeam, 2, Vector ( 1, 0, 0 ) )

	MinimapEvent( nTeam, self:GetCaster(), self.vTargetPosition.x, self.vTargetPosition.y, DOTA_MINIMAP_EVENT_TEAMMATE_TELEPORTING, self:GetCastPoint() )

	local kv = {
		duration = self:GetCastPoint(),
		target_x = self.vTargetPosition.x,
		target_y = self.vTargetPosition.y,
		target_z = self.vTargetPosition.z
	}

	self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_custom_tp", kv )


	return true;
end

--------------------------------------------------------------------------------

function custom_tp:OnAbilityPhaseInterrupted()
	ParticleManager:SetParticleControl( self.nFXIndexStart, 2, Vector( 0, 0, 0 ) )
	ParticleManager:SetParticleControl( self.nFXIndexEnd, 2, Vector( 0, 0, 0 ) )
	ParticleManager:SetParticleControl( self.nFXIndexEndTeam, 2, Vector( 0, 0, 0 ) )

	ParticleManager:DestroyParticle( self.nFXIndexStart, false )
	ParticleManager:DestroyParticle( self.nFXIndexEnd, false )
	ParticleManager:DestroyParticle( self.nFXIndexEndTeam, false )

	self:GetCaster():RemoveModifierByName( "modifier_custom_tp" )

	MinimapEvent( self:GetCaster():GetTeamNumber(), self:GetCaster(), 0, 0, DOTA_MINIMAP_EVENT_CANCEL_TELEPORTING, 0 )
end

--------------------------------------------------------------------------------

function custom_tp:OnSpellStart()

	ProjectileManager:ProjectileDodge( self:GetCaster() )
	--FindClearSpaceForUnit( self:GetCaster(), self.vTargetPosition, false )
	self:GetCaster():StartGesture( ACT_DOTA_TELEPORT_END )


	local building = CreateUnitByName("npc_dota_building_homebase", self.vTargetPosition, true, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber())
    building:SetOwner(self:GetCaster())
    building:SetAbsOrigin(self.vTargetPosition)
	--Timers:CreateTimer(function() building:SetAbsOrigin(self.vTargetPosition) end)

	ParticleManager:DestroyParticle( self.nFXIndexStart, false )
	ParticleManager:DestroyParticle( self.nFXIndexEnd, false )
	ParticleManager:DestroyParticle( self.nFXIndexEndTeam, false )
end