function Activate( keys )
	local caster = keys.caster
    local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	-- Ability variables
	local instances = ability:GetLevelSpecialValueFor("instances", ability_level)
	local arrow_speed = ability:GetLevelSpecialValueFor("arrow_speed", ability_level)
	local arrow_width = ability:GetLevelSpecialValueFor("arrow_width", ability_level)
	local distance = ability:GetLevelSpecialValueFor("range", ability_level)
	local channelTime = ability:GetChannelTime()
	local particle_name = keys.particle_name
	local startAttackSound = "Ability.Powershot"

	local info =
    {
    	Ability = keys.ability,
		EffectName = particle_name,
		iMoveSpeed = arrow_speed,
		vSpawnOrigin = caster:GetAbsOrigin(),
		fDistance = distance,
		fStartRadius = arrow_width,
		fEndRadius = arrow_width,
		Source = caster,
		bHasFrontalCone = false,
		bReplaceExisting = false,
		iUnitTargetTeam = ability:GetAbilityTargetTeam(),
		iUnitTargetFlags = ability:GetAbilityTargetFlags(),
		iUnitTargetType = ability:GetAbilityTargetType(),
		fExpireTime = GameRules:GetGameTime() + 10.0,
		bDeleteOnHit = false,
		vVelocity = caster:GetForwardVector() * arrow_speed,
	}

	for i=instances,1,-1 do
		Timers:CreateTimer(caster:GetPlayerOwnerID() .. 'RapidFireInterval' .. i, {
            useGameTime = false,
            endTime = (channelTime/instances) * i,
            callback = function()
            	if ability:IsChanneling() then
            		StartAnimation(caster, {duration=0.5, activity=ACT_DOTA_ATTACK, rate=2.0})
            		StartSoundEvent(startAttackSound, caster)
            		projectile = ProjectileManager:CreateLinearProjectile(info)
            	end
        	end
        })
	end
end

function Hit( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	-- Ability variables
	local damage = ability:GetLevelSpecialValueFor("damage", ability_level) 
	local hitAttackSound = "Hero_Windrunner.PowershotDamage"

	-- Not hitting invisible units
    if target:IsInvisible() then
        if not caster:CanEntityBeSeenByMyTeam(target) then
            return
    	end
    end

	-- Initialize the damage table and deal the damage
	local damage_table = {}
	damage_table.attacker = caster
	damage_table.victim = target
	damage_table.ability = ability
	damage_table.damage_type = ability:GetAbilityDamageType()
	damage_table.damage = damage

	ApplyDamage(damage_table)
	StartSoundEvent(hitAttackSound, caster)
end