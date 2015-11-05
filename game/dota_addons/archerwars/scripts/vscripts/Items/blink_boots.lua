function Activate(keys)
	local point = keys.target_points[1]
	local caster = keys.caster
	local casterPos = caster:GetAbsOrigin()
	local pid = caster:GetPlayerID()
	local difference = point - casterPos
	local range = keys.range

	local start_particle = ParticleManager:CreateParticle( "particles/items_fx/blink_dagger_start.vpcf", PATTACH_POINT, caster )
	ParticleManager:SetParticleControl( start_particle, 0, casterPos )

	if difference:Length2D() > range then
		point = casterPos + (point - casterPos):Normalized() * range
	end

	FindClearSpaceForUnit(caster, point, false)

	local end_particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_antimage/antimage_blink_end.vpcf", PATTACH_POINT, caster )
end