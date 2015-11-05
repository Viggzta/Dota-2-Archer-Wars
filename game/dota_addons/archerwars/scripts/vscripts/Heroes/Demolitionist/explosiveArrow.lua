-- This ability was made possible thanks to kritth.
function shootExplosiveArrow( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	-- Ability variables
	local frame = 0.03
	local forwardVec = (keys.target_points[1] - caster:GetAbsOrigin()):Normalized()
	local speed = ability:GetLevelSpecialValueFor("arrow_speed", ability_level)
	local maximum_distance = ability:GetLevelSpecialValueFor("range", ability_level)
	local target = caster:GetAbsOrigin() + maximum_distance * forwardVec

	local arrow_speed_modifiers = caster:FindAllModifiersByName("modifier_arrow_speed")
	if arrow_speed_modifiers ~= nil then
		for _, arrow_speed_modifier in pairs( arrow_speed_modifiers ) do
			speed = speed + 100
		end
	end
	if caster:FindModifierByName("modifier_gem_sacrifice") ~= nil then speed = speed + 200 end

	if caster.ability_current_point == nil then caster.ability_current_point = {} end
	table.insert(caster.ability_current_point, caster:GetAbsOrigin() + forwardVec * speed * frame * 3) -- Multiplying by 3 to get explosion centered on the arrow
	local id = #caster.ability_current_point

	Timers:CreateTimer( function()
		if ( caster.ability_current_point[id] - target ):Length2D() < 50 then
			caster.ability_current_point[id] = nil
			return nil
		else
			caster.ability_current_point[id] = caster.ability_current_point[id] + forwardVec * speed * frame
			return frame
		end
	end)
end

function explodeArrow( keys )
	local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	-- Effects and Sounds
	local particle_name = keys.particle_name
	local sound_name = keys.sound_name

	-- Variables from KV
	local radius = ability:GetLevelSpecialValueFor( "radius", ( ability:GetLevel() - 1 ) )
	local damage = ability:GetLevelSpecialValueFor( "damage", ( ability:GetLevel() - 1 ) )

	if caster.ability_current_point == nil then return end -- If table is not populated, stop script.

	local damage_table = {}
	damage_table.attacker = caster
	damage_table.ability = ability
	damage_table.damage_type = ability:GetAbilityDamageType()
	damage_table.damage = damage
	
	for i, impact_location in pairs(caster.ability_current_point) do
		if impact_location ~= nil then
			local fxIndex = ParticleManager:CreateParticle( particle_name, PATTACH_POINT, caster )
			ParticleManager:SetParticleControl( fxIndex, 0, impact_location )

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
		StartSoundEventFromPosition(sound_name, impact_location)
		end
	end

	for k in pairs(caster.ExplosiveArrows) do
		caster.ExplosiveArrows[k]:Destroy()
		caster.ExplosiveArrows[k] = nil
	end
end