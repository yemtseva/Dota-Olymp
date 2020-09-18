modifier_item_second_worker= class({})

--------------------------------------------------------------------------------

function modifier_item_second_worker:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function modifier_item_second_worker:OnCreated( kv )
	if IsServer() then
		self.vStartPos = self:GetParent():GetOrigin()
		self.vEndPos = Vector( kv["target_x"], kv["target_y"], kv["target_y"] )

		self:GetParent():StartGesture( ACT_DOTA_TELEPORT )
		self:StartIntervalThink( self:GetAbility():GetChannelTime() - 0.25 )

		EmitSoundOnLocationWithCaster( self.vStartPos, "Hero_Furion.Teleport_Grow", self:GetCaster() )
		EmitSoundOnLocationWithCaster( self.vEndPos, "Hero_Furion.Teleport_Grow", self:GetCaster() )
	end
end

--------------------------------------------------------------------------------

function modifier_item_second_worker:OnDestroy()
	if IsServer() then
		StopSoundOn( "Hero_Furion.Teleport_Grow", self:GetCaster() )
		StopSoundOn( "Hero_Furion.Teleport_Grow", self:GetCaster() )

		self:GetParent():RemoveGesture( ACT_DOTA_TELEPORT )
	end
end

--------------------------------------------------------------------------------

function modifier_item_second_worker:OnIntervalThink()
	if IsServer() then
		StopSoundOn( "Hero_Furion.Teleport_Grow", self:GetCaster() )
		StopSoundOn( "Hero_Furion.Teleport_Grow", self:GetCaster() )

		self:StartIntervalThink( 1.5 )

		EmitSoundOnLocationWithCaster( self.vStartPos, "Hero_Furion.Teleport_Disappear", self:GetCaster() )
		EmitSoundOnLocationWithCaster( self.vEndPos, "Hero_Furion.Teleport_Appear", self:GetCaster() )
	end
end