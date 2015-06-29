-- Used to keep track of projectiles after creation
ProjectileHolder = {}
BeamStacks = {0,0,0,0,0,0,0,0,0,0}
MultishotStacks = {0,0,0,0,0,0,0,0,0,0}
TimerCount = 0
 
-- Constants
MODIFIER_DUR = {15.0, 3.0, 5.0}
CUSTOM_ARROWS = {"fire", "frost", "lightning"}
CUSTOM_ARROWS_ITEM = {"item_fire_arrows", "item_frost_arrows", "item_lightning_arrows"}
MODIFIER_NAMES = {"modifier_burn", "modifier_slow", "modifier_armor"}
 
function normalArrow( args )
        local caster = args.caster

        local projectileData = {
                modifiersList = {},
                modifiersNumber = {},
                fDamageMultiplier = 0.70,
        }
        local projectile = {
                --EffectName = "particles/test_particle/ranged_tower_good.vpcf",
                EffectName = "particles/arrow/archer_normal_arrow.vpcf",
                --vSpawnOrigin = hero:GetAbsOrigin(),
                vSpawnOrigin = caster:GetAbsOrigin() + Vector(0,0,80),    --{unit=hero, attach="attach_attack1", offset=Vector(0,0,0)},
                fDistance = args.FixedDistance,
                fStartRadius = args.StartRadius,
                fEndRadius = args.EndRadius,
                Source = args.caster,
                fExpireTime = 10.0,
                vVelocity = caster:GetForwardVector() * args.MoveSpeed, -- RandomVector(1000),
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
                draw = false,--          draw = {alpha=1, color=Vector(200,0,0)},
                --iPositionCP = 0,
                --iVelocityCP = 1,
                --ControlPoints = {[5]=Vector(100,0,0), [10]=Vector(0,0,1)},
                --fRehitDelay = .3,
                --fChangeDelay = 1,
                --fRadiusStep = 10,
                --bUseFindUnitsInRadius = false,

                UnitTest = function(self, unit) return unit:GetUnitName() ~= "npc_dummy_unit" and unit:GetTeamNumber() ~= caster:GetTeamNumber() end,
                OnUnitHit = function(self, unit) arrowHit( args, unit, projectileData ) end,
                --OnTreeHit = function(self, tree) ... end,
                --OnWallHit = function(self, gnvPos) ... end,
                --OnGroundHit = function(self, groundPos) ... end,
                --OnFinish = function(self, pos) ... end,
        }
        local PROC_CHANCE = {18, 15, 15}
        local particleString = ""
        local randomProc = 0
 
        -- Elemental Arrow
        for i, v in pairs(CUSTOM_ARROWS_ITEM) do
                randomProc = RandomInt(0, 100)
                if caster:HasItemInInventory(CUSTOM_ARROWS_ITEM[i]) and randomProc <= PROC_CHANCE[i] then
                        particleString = particleString .. CUSTOM_ARROWS[i] .. "_"
                        table.insert(projectileData.modifiersList, MODIFIER_NAMES[i])
                        table.insert(projectileData.modifiersNumber, i)
                        -- Lightning Arrow
                        if CUSTOM_ARROWS_ITEM[i] == "item_lightning_arrows" then
                                projectile.vVelocity = projectile.vVelocity * 1.25
                        end
                end
        end
        -- Arrow Particles
        if particleString ~= "" then
                projectile.EffectName = "particles/arrow/archer_" .. particleString .."arrow.vpcf"
        end
 
        -- Dual Arrow
        local projectile2Data = {
                modifiersList = {},
                modifiersNumber = {},
                fDamageMultiplier = 0.70,
        }
        local projectile2 = {
                --EffectName = "particles/test_particle/ranged_tower_good.vpcf",
                EffectName = "particles/arrow/archer_normal_arrow.vpcf",
                --vSpawnOrigin = hero:GetAbsOrigin(),
                vSpawnOrigin = caster:GetAbsOrigin() + Vector(0,0,80),    --{unit=hero, attach="attach_attack1", offset=Vector(0,0,0)},
                fDistance = args.FixedDistance,
                fStartRadius = args.StartRadius,
                fEndRadius = args.EndRadius,
                Source = args.caster,
                fExpireTime = 10.0,
                vVelocity = caster:GetForwardVector() * args.MoveSpeed, -- RandomVector(1000),
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
                draw = false,--          draw = {alpha=1, color=Vector(200,0,0)},
                --iPositionCP = 0,
                --iVelocityCP = 1,
                --ControlPoints = {[5]=Vector(100,0,0), [10]=Vector(0,0,1)},
                --fRehitDelay = .3,
                --fChangeDelay = 1,
                --fRadiusStep = 10,
                --bUseFindUnitsInRadius = false,

                UnitTest = function(self, unit) return unit:GetUnitName() ~= "npc_dummy_unit" and unit:GetTeamNumber() ~= caster:GetTeamNumber() end,
                OnUnitHit = function(self, unit) arrowHit( args, unit, projectile2Data) end,
                --OnTreeHit = function(self, tree) ... end,
                --OnWallHit = function(self, gnvPos) ... end,
                --OnGroundHit = function(self, groundPos) ... end,
                --OnFinish = function(self, pos) ... end,
        }
        if caster:HasItemInInventory("item_dual_arrows") then
                MultishotStacks[caster:GetMainControllingPlayer() +1] = MultishotStacks[caster:GetMainControllingPlayer() +1] +1
                if MultishotStacks[caster:GetMainControllingPlayer() +1] >= 4 then
                        MultishotStacks[caster:GetMainControllingPlayer() +1] = MultishotStacks[caster:GetMainControllingPlayer() +1] -4
                        Timers:CreateTimer('Multishot Delay', {
                                                useGameTime = false,
                                                endTime = 0.3,
                                                callback = function()
                                                EmitSoundOn("Ability.Powershot", caster)
                                                -- Create Dual Arrow
                                                local createdProjectile2 = Projectiles:CreateProjectile(projectile2)
                                                -- Sniper Speed Increase
                                                if caster:GetName() == "npc_dota_hero_mirana" then
                                                        projectileSpeedIncrease(createdProjectile2, 0.5, 8, 1.5)
                                                end
                                                end    
                                        })
                end
        end

        EmitSoundOn("Ability.Powershot", caster)
        -- Create Arrow
        local createdProjectile = Projectiles:CreateProjectile(projectile)
        -- Sniper Speed Increase
        if caster:GetName() == "npc_dota_hero_mirana" then
                projectileSpeedIncrease(createdProjectile, 0.5, 8, 1.5)
        end
        
        updateArrowStacks(caster)
end
 
function arrowHit( args, target, projectileData )
        local caster = args.caster
        local totalDamage = math.floor((args.Damage + getArrowDamageIncrease(caster)) * projectileData.fDamageMultiplier)	-- Also adds bonus damage from [Arrow Damage]

        if target:IsInvisible() then
                if not caster:CanEntityBeSeenByMyTeam(target) then
                        return
                end
        end
        
        EmitSoundOn("Hero_Windrunner.PowershotDamage", target)
        local damageTable = {
                victim = target,
                attacker = caster,
                damage = totalDamage,
		damage_type = DAMAGE_TYPE_PHYSICAL,
		}
        local randomProc = RandomInt(0, 100)
        -- Critical Arrow (MM Luck)
        if (caster:HasItemInInventory("item_mm_luck_3")) and randomProc <= 20 then
                damageTable.damage = damageTable.damage * 1.25
        elseif (caster:HasItemInInventory("item_mm_luck_2")) and randomProc <= 15 then
                damageTable.damage = damageTable.damage * 1.33
        elseif (caster:HasItemInInventory("item_mm_luck")) and randomProc <= 10 then
                damageTable.damage = damageTable.damage * 1.50
        end
 
        -- Arrow Damage
        ApplyDamage(damageTable)
 
        -- Mana Steal
        randomProc = RandomInt(0, 100)
        if (caster:HasItemInInventory("item_mana_steal")) then
                if randomProc <= 35 then
                        target:ReduceMana(50)
                        caster:GiveMana(50)
                end
        end
        -- Life Steal
        stealLife( damageTable.damage, caster )
 
        -- Astral Compass
        if caster:HasItemInInventory("item_astral_compass") then
                BeamStacks[caster:GetMainControllingPlayer() +1] = BeamStacks[caster:GetMainControllingPlayer() +1] +1
                if BeamStacks[caster:GetMainControllingPlayer() +1] >= 3 then
                        BeamStacks[caster:GetMainControllingPlayer() +1] = BeamStacks[caster:GetMainControllingPlayer() +1] -3
                        local lunarDamageTable = {
                        victim = target,
                        attacker = caster,
                        damage = 125,
                        damage_type = DAMAGE_TYPE_PHYSICAL,
                }
                giveUnitDataDrivenModifier(caster, target, "modifier_beam", 1.0)
                Timers:CreateTimer('Lunar Delay', {
                                                useGameTime = false,
                                                endTime = 0.3,
                                                callback = function()
                                                -- Lunar Damage
                                                ApplyDamage(lunarDamageTable)
                                                end    
                                        })
                end
        end
 
        -- Elemental Arrow Debuffs
        if projectileData.modifiersList ~= nil then
                local modList = projectileData.modifiersList
                local modNumber = projectileData.modifiersNumber
                for j, v in pairs(modList) do
                        giveUnitDataDrivenModifier(caster, target, modList[j], MODIFIER_DUR[modNumber[j]])
                end
        end
        updateArrowStacks(caster)
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
 
function getArrowDamageIncrease( caster )
        local inventory = { caster:GetItemInSlot(0), caster:GetItemInSlot(1), caster:GetItemInSlot(2), caster:GetItemInSlot(3), caster:GetItemInSlot(4), caster:GetItemInSlot(5), }
        local bonusDamage = 0
 
        for i, v in pairs(inventory) do
                for j, v in pairs(CUSTOM_ARROWS_ITEM) do
                        if inventory[i]:GetName() == CUSTOM_ARROWS_ITEM[j] then
                                bonusDamage = bonusDamage + 25
                                break
                        end
                        if inventory[i]:GetName() == "item_reinforced_arrows" then
                                bonusDamage = bonusDamage + 25
                                break
                        end
                end
        end
 
        return bonusDamage
end
 
function getItemsAmount( caster, name)
        local inventory = { caster:GetItemInSlot(0), caster:GetItemInSlot(1), caster:GetItemInSlot(2), caster:GetItemInSlot(3), caster:GetItemInSlot(4), caster:GetItemInSlot(5), }
        local itemsFound = 0
 
        for i, _ in pairs(inventory) do
                if inventory[i]:GetName() == name then
                        itemsFound = itemsFound + 1
                end
        end
 
        return itemsFound
end
 
function stealLife( damageDone, caster )
        local amount = math.floor(damageDone * 0.10)
 
        if (caster:HasItemInInventory("item_lifesteal_mask")) then
                caster:Heal(amount, caster)
        end
end

function updateArrowStacks( caster )
        local id = caster:GetMainControllingPlayer() +1
        UTIL_ResetMessageText(id)
        if MultishotStacks[id] == 3 then
                UTIL_MessageText(id, "Double Shot: " .. MultishotStacks[id],255, 128, 0, 255)
        else
                UTIL_MessageText(id, "Double Shot: " .. MultishotStacks[id],255, 255, 255, 255)
        end
        if BeamStacks[id] == 2 then
                UTIL_MessageText(id, "Starfall: " .. BeamStacks[id],255, 128, 0, 255)
        else
                UTIL_MessageText(id, "Starfall: " .. BeamStacks[id],255, 255, 255, 255)
        end
end
 
-- /////////////////////////////////////////////////////////////////////////////
-- //////////////////////////// Projectile Handlers ////////////////////////////
-- /////////////////////////////////////////////////////////////////////////////
function addToProjectileHolder(infoTable, projectileID)
        local projectileEntry =
        {
                projectileID = projectileID,
                creationTime = GameRules:GetGameTime(),
                SpawnOrigin = infoTable.vSpawnOrigin,
                VelocityVector = infoTable.vVelocity,
                info = infoTable
        }
        table.insert(ProjectileHolder, projectileEntry)
        Timers:CreateTimer(30, function() return projectileHolderCleaner() end)
end
 
function projectileHolderCleaner()
        table.remove(ProjectileHolder,1)
end
 
function getProjectileHolderID(projectileID)
        for i, v in pairs(ProjectileHolder) do
                if projectileID == ProjectileHolder[i].projectileID then
                        return i
                end
        end
        return nil
end
 
function findClosestInProjectileHolder(locationVector)
	local currentTime = GameRules:GetGameTime()
	local BestProjectile = 1
	local BestDistanceDiff = 999999 -- Basically just a large number to start with
	for listCount = 1, #ProjectileHolder do
		--PrintTable(ProjectileHolder)
		projectile = ProjectileHolder[listCount]
		projectileLocation = projectile.SpawnOrigin + ( projectile.VelocityVector * ( currentTime - projectile.creationTime))
		DistanceDiff = (projectileLocation - locationVector):Length2D()
		if DistanceDiff < BestDistanceDiff then
			BestProjectile = listCount
			BestDistanceDiff = DistanceDiff
		end
	end
	local projectile = ProjectileHolder[BestProjectile]
	local travilDistanceVector = projectile.VelocityVector * ( currentTime - projectile.creationTime)
	--local travilDistanceFloat = math.sqrt((travilDistanceVector.x * travilDistanceVector.x) + (travilDistanceVector.y * travilDistanceVector.y))
	local travilDistanceFloat = travilDistanceVector:Length2D()
	local projectileReturnID = projectile.projectileID
	projectileLocation = projectile.SpawnOrigin + ( projectile.VelocityVector * ( currentTime - projectile.creationTime))
	--print (projectileLocation)
	--PrintTable(ProjectileHolder)
	return projectileReturnID, travilDistanceFloat
end

function PrintTable( tableToPrint )
	print("Printing table!")
	for key,value in pairs(tableToPrint) do print(key,value) end
end