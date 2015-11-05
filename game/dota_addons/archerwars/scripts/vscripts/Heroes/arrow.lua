-- Used to keep track of projectiles after creation
ProjectileHolder = {}
TimerCount = 0
 
function normalArrow( keys )
        if keys.caster.arrow_charges > 0 then
                local caster = keys.caster
                local target = keys.target
                local ability = keys.ability
                local ability_level = ability:GetLevel() - 1

                -- variables
                local modifierName = "modifier_arrow_stack_counter_datadriven"
                local arrow_speed = ability:GetLevelSpecialValueFor( "arrow_speed", ( ability:GetLevel() - 1 ) )
                local range = ability:GetLevelSpecialValueFor( "range", ( ability:GetLevel() - 1 ) )
                local maximum_charges = ability:GetLevelSpecialValueFor( "maximum_charges", ( ability:GetLevel() - 1 ) )
                local charge_replenish_time = ability:GetLevelSpecialValueFor( "charge_replenish_time", ( ability:GetLevel() - 1 ) )
                local particle_name = keys.particle_name
                local startAttackSound = "Ability.Powershot"

                local arrow_speed_bonus = 0
                local arrow_speed_modifiers = caster:FindAllModifiersByName("modifier_arrow_speed")
                if arrow_speed_modifiers ~= nil then
                        for _, arrow_speed_modifier in pairs( arrow_speed_modifiers ) do
                                arrow_speed_bonus = arrow_speed_bonus + 50
                        end
                end
                if caster:FindModifierByName("modifier_gem_sacrifice") ~= nil then arrow_speed_bonus = arrow_speed_bonus + 100 end
                
                -- Deplete charge
                local next_charge = caster.arrow_charges - 1
                if caster.arrow_charges == maximum_charges then
                        caster:RemoveModifierByName( modifierName )
                        ability:ApplyDataDrivenModifier( caster, caster, modifierName, { Duration = charge_replenish_time } )
                        arrow_start_cooldown( caster, charge_replenish_time )
                end
                caster:SetModifierStackCount( modifierName, caster, next_charge )
                caster.arrow_charges = next_charge
        
                -- Check if stack is 0, display ability cooldown
                if caster.arrow_charges == 0 then
                        -- Start Cooldown from caster.arrow_cooldown
                        ability:StartCooldown( caster.arrow_cooldown )
                else
                        ability:EndCooldown()
                end

                local projectile = {
                        EffectName = particle_name,
                        vSpawnOrigin = caster:GetAbsOrigin() + Vector(0,0,80),    --{unit=hero, attach="attach_attack1", offset=Vector(0,0,0)},
                        fDistance = range,
                        fStartRadius = arrow_width,
                        fEndRadius = arrow_width,
                        Source = keys.caster,
                        fExpireTime = 10.0,
                        vVelocity = caster:GetForwardVector() * (arrow_speed + arrow_speed_bonus), -- RandomVector(1000),
                        UnitBehavior = PROJECTILES_NOTHING,
                        bMultipleHits = false,
                        bIgnoreSource = true,
                        TreeBehavior = PROJECTILES_NOTHING,
                        bCutTrees = false,
                        WallBehavior = PROJECTILES_NOTHING,
                        GroundBehavior = PROJECTILES_NOTHING,
                        fGroundOffset = 80,
                        nChangeMax = 10,
                        bRecreateOnChange = true,
                        bZCheck = false,
                        bGroundLock = true,
                        draw = false,
                        UnitTest = function(self, unit) return unit:GetUnitName() ~= "npc_dummy_unit" and unit:GetTeamNumber() ~= caster:GetTeamNumber() end,
                        OnUnitHit = function(self, unit) arrowHit(keys, unit) end,
                }

                EmitSoundOn(startAttackSound, caster)
                -- Create Arrow
                local createdProjectile = Projectiles:CreateProjectile(projectile)

                -- Demolitionist Arrow Tracker
                if caster:GetName() == "npc_dota_hero_clinkz" then
                        table.insert(caster.ExplosiveArrows, createdProjectile)
                end
                -- Sniper Speed Increase
                if caster:GetName() == "npc_dota_hero_mirana" then
                        projectileSpeedIncrease(createdProjectile, 0.5, 8, 1.5)
                end
        end
end
 
function arrowHit( keys, target )
        local caster = keys.caster
        local ability = keys.ability
        local ability_level = ability:GetLevel() - 1
        
        -- Ability variables
        local damage = ability:GetLevelSpecialValueFor("damage", ability_level) 
        damage = damage + caster:GetAverageTrueAttackDamage()
        local hitAttackSound = "Hero_Windrunner.PowershotDamage"

        -- Not hitting invisible units
        if target:IsInvisible() then
                if not caster:CanEntityBeSeenByMyTeam(target) then
                        return
                end
        end

        if caster:FindModifierByName("modifier_ichor_bow") ~= nil then 
                target:Kill(ability, caster)
                caster:Heal(caster:GetMaxHealth() * 0.2, caster)
                local particle_blood_target = ParticleManager:CreateParticle("particles/units/heroes/hero_life_stealer/life_stealer_infest_emerge_bloody.vpcf", PATTACH_POINT_FOLLOW, target)
                local particle_blood = ParticleManager:CreateParticle("particles/units/heroes/hero_huskar/huskar_lifebreak_bloodyend.vpcf", PATTACH_POINT_FOLLOW, caster)
                ParticleManager:SetParticleControl(particle_blood, 1, target:GetAbsOrigin())
                EmitSoundOn("Hero_LifeStealer.Infest", target)
                return
        end
        
        local damageTable = {
                victim = target,
                attacker = caster,
                damage = damage,
		damage_type = DAMAGE_TYPE_PHYSICAL,
	}
 
        -- Arrow Damage
        ApplyDamage(damageTable)
        EmitSoundOn(hitAttackSound, target)

        if caster:FindModifierByName("modifier_lifesteal") ~= nil then 
                caster:Heal(damage * 0.15, caster)
                local particle_lifesteal = ParticleManager:CreateParticle("particles/items3_fx/octarine_core_lifesteal.vpcf", PATTACH_POINT_FOLLOW, caster)
        end
end

-- Used for snipers arrows
function projectileSpeedIncrease(projectile, timeInterval, intervalCount, speedAmplification)
        for times=1, intervalCount do
        Timers:CreateTimer(TimerCount .. 'Speed Increase' .. times, {
                useGameTime = false,
                endTime = timeInterval*times,
                callback = function()
                        projectile:SetVelocity(projectile:GetVelocity() * speedAmplification)
                end    
                })
        end
        TimerCount = TimerCount + 1
end

function PrintTable( tableToPrint )
	print("Printing table!")
	for key,value in pairs(tableToPrint) do print(key,value) end
end

function arrow_start_charge( keys )
        -- Only start charging at level 1
        if keys.ability:GetLevel() ~= 1 then return end
        -- Variables
        local caster = keys.caster
        local ability = keys.ability
        local modifierName = "modifier_arrow_stack_counter_datadriven"
        local maximum_charges = ability:GetLevelSpecialValueFor( "maximum_charges", ( ability:GetLevel() - 1 ) )
        local charge_replenish_time = ability:GetLevelSpecialValueFor( "charge_replenish_time", ( ability:GetLevel() - 1 ) )
        
        -- Initialize stack
        caster:SetModifierStackCount( modifierName, caster, 0 )
        caster.arrow_charges = maximum_charges
        caster.start_charge = false
        caster.arrow_cooldown = 0.0
        
        ability:ApplyDataDrivenModifier( caster, caster, modifierName, {} )
        caster:SetModifierStackCount( modifierName, caster, maximum_charges )
        
        -- create timer to restore stack
        Timers:CreateTimer( function()
                        -- Restore charge
                        if caster.start_charge and caster.arrow_charges < maximum_charges then
                                -- Calculate stacks
                                local next_charge = caster.arrow_charges + 1
                                caster:RemoveModifierByName( modifierName )
                                if next_charge ~= maximum_charges then
                                        ability:ApplyDataDrivenModifier( caster, caster, modifierName, { Duration = charge_replenish_time } )
                                        arrow_start_cooldown( caster, charge_replenish_time )
                                else
                                        ability:ApplyDataDrivenModifier( caster, caster, modifierName, {} )
                                        caster.start_charge = false
                                end
                                caster:SetModifierStackCount( modifierName, caster, next_charge )
                                
                                -- Update stack
                                caster.arrow_charges = next_charge
                        end
                        
                        -- Check if max is reached then check every 0.5 seconds if the charge is used
                        if caster.arrow_charges ~= maximum_charges then
                                caster.start_charge = true
                                return charge_replenish_time
                        else
                                return 0.5
                        end
                end
        )
end

function arrow_start_cooldown( caster, charge_replenish_time )
        caster.arrow_cooldown = charge_replenish_time
        Timers:CreateTimer( function()
                        local current_cooldown = caster.arrow_cooldown - 0.1
                        if current_cooldown > 0.1 then
                                caster.arrow_cooldown = current_cooldown
                                return 0.1
                        else
                                return nil
                        end
                end
        )
end