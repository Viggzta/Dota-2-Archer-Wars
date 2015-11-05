function Activate( keys )
	local caster = keys.caster
	local ability = keys.ability

	-- Ability variables
	local health_cost_percent = keys.health_cost_percent
	local damage = caster:GetHealth() * (health_cost_percent/100)

	local damageTable = {
		victim = caster,
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_PURE,
    }
    ApplyDamage(damageTable)
end