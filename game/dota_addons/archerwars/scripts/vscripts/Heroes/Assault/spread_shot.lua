function Activate( keys )
        local caster = keys.caster
        local target = keys.target
        local ability = keys.ability
        local ability_level = ability:GetLevel() - 1

        -- Ability variables
        local arrow_speed = ability:GetLevelSpecialValueFor("arrow_speed", ability_level)
        local arrow_width = ability:GetLevelSpecialValueFor("arrow_width", ability_level)
        local distance = ability:GetLevelSpecialValueFor("range", ability_level)
        local particle_name = keys.particle_name
        local sound_name = "Ability.Powershot"

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
 
        for i=-18,18,18 do
                info.vVelocity = RotatePosition(Vector(0,0,0), QAngle(0,i,0), caster:GetForwardVector()) * arrow_speed
                projectile = ProjectileManager:CreateLinearProjectile(info)
        end
        EmitSoundOn(sound_name, caster)
end
 
function Hit( keys )
        local caster = keys.caster
        local target = keys.target
        local ability = keys.ability
        local ability_level = ability:GetLevel() - 1

        -- Ability variables
        local damage = ability:GetLevelSpecialValueFor("damage", ability_level) 
        local sound_name = "Hero_Windrunner.PowershotDamage"

        -- Not hitting invisible units
        if target:IsInvisible() then
                if not caster:CanEntityBeSeenByMyTeam(target) then
                        return
                end
        end

        local damageTable = {
                        victim = target,
                        attacker = caster,
                        damage = damage,
                        damage_type = DAMAGE_TYPE_PHYSICAL,
                }
        ApplyDamage(damageTable)
        EmitSoundOn(sound_name, target)
end