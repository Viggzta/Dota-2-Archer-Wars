function Activate( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	-- Ability variables
	local delay = ability:GetLevelSpecialValueFor("delay", ability_level)
	local radius = ability:GetLevelSpecialValueFor("radius", ability_level)
	local damage = ability:GetLevelSpecialValueFor("damage", ability_level)
	local particle_name = keys.particle_name
	local impact_location = keys.target_points[1]
	local startAttackSound = "Hero_Gyrocopter.CallDown.Fire"
	local casterAttackSound = "Hero_Gyrocopter.CallDown.Fire.Self"
	local impactAttackSound = "Hero_Gyrocopter.CallDown.Damage"

	particle = ParticleManager:CreateParticle(particle_name, PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle, 1, impact_location)
	ParticleManager:SetParticleControl(particle, 3, impact_location)
	ParticleManager:SetParticleControl(particle, 5, Vector(radius, 0, 0))

	StartSoundEventFromPosition(startAttackSound, impact_location)
	StartSoundEvent(casterAttackSound, caster)

	-- Initialize the damage table and deal the damage
	local damage_table = {}
	damage_table.attacker = caster
	damage_table.ability = ability
	damage_table.damage_type = ability:GetAbilityDamageType()
	damage_table.damage = damage

	Timers:CreateTimer(caster:GetPlayerOwnerID() .. 'RainDelay', {
		useGameTime = false,
		endTime = delay,
		callback = function()
			local targets = FindUnitsInRadius( 
			caster:GetTeamNumber(), 
			impact_location, 
			caster, 
			radius, 
			ability:GetAbilityTargetTeam(), 
			ability:GetAbilityTargetType(), 
			ability:GetAbilityTargetFlags(), 
			0, 
			false
			)
			for _, unit in pairs( targets ) do
				-- Not hitting invisible units
				if unit:IsInvisible() then
					if caster:CanEntityBeSeenByMyTeam(unit) then
						damage_table.victim = unit
						ApplyDamage(damage_table)
					end
				else
					damage_table.victim = unit
					ApplyDamage(damage_table)
				end	
			end
		StartSoundEventFromPosition(impactAttackSound, impact_location)
		end
	})
end