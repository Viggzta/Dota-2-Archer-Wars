--ArcherWars
ARCHERS = {}							-- Here we store all the heroes for each player
KILLS = {}								-- Score tracker
KILLS[0] = 0
KILLS[1] = 0
KILLS[2] = 0
KILLS[3] = 0
KILLS[4] = 0
KILLS[5] = 0
KILLS[6] = 0
KILLS[7] = 0
KILLS[8] = 0
KILLS[9] = 0

if ArcherWarsGameMode == nil then
	ArcherWarsGameMode = class({})
end

function ArcherWarsGameMode:InitGameMode()
	ArcherWarsGameMode = self
	GameMode = GameRules:GetGameModeEntity()

	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 1 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 1 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_1, 1 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_2, 1 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_3, 1 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_4, 1 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_5, 1 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_6, 1 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_7, 1 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_8, 1 )

	for team = 0, (DOTA_TEAM_COUNT-1) do
		color = PLAYER_COLORS3[ team ]
		if color then
			SetTeamCustomHealthbarColor( team, color[1], color[2], color[3] )
		end
	end

	-------------------------------------------------------------

	-- Normal income gives unreliable gold(now what we want)
	GameRules:SetGoldPerTick( GOLD_PER_TICK )
	GameRules:SetGoldTickTime(6)

	-- Setup Gamerules
	GameRules:SetHeroRespawnEnabled( ENABLE_HERO_RESPAWN )
  	GameRules:SetUseUniversalShopMode( UNIVERSAL_SHOP_MODE )
  	-- Hero Selection
	GameRules:SetSameHeroSelectionEnabled( ALLOW_SAME_HERO_SELECTION )
	GameRules:SetHeroSelectionTime( HERO_SELECTION_TIME )
	-- Game Phases
	GameRules:SetPreGameTime( PRE_GAME_TIME )
	GameRules:SetPostGameTime( POST_GAME_TIME )
	-- Gameplay
	GameRules:SetTreeRegrowTime( TREE_REGROW_TIME )
	GameRules:SetRuneSpawnTime( RUNE_SPAWN_TIME )
	GameRules:SetUseBaseGoldBountyOnHeroes( USE_FIXED_HERO_GOLD_BOUNTY )
	-- Minimap
	GameRules:SetHeroMinimapIconScale( MINIMAP_ICON_SIZE )
	GameRules:SetCreepMinimapIconScale( MINIMAP_CREEP_ICON_SIZE )
	GameRules:SetRuneMinimapIconScale( MINIMAP_RUNE_ICON_SIZE )

	-- Camera Distance
	GameMode:SetCameraDistanceOverride( CAMERA_DISTANCE_OVERRIDE )
	-- Recomended Items
	GameMode:SetRecommendedItemsDisabled( RECOMMENDED_BUILDS_DISABLED )
	-- Hero Levels and XP
	GameMode:SetCustomHeroMaxLevel( MAX_LEVEL )
	GameMode:SetCustomXPRequiredToReachNextLevel( XP_PER_LEVEL_TABLE )
	GameMode:SetUseCustomHeroLevels( USE_CUSTOM_HERO_LEVELS )
	GameMode:SetBuybackEnabled( BUYBACK_ENABLED )
	GameMode:SetFixedRespawnTime( FIXED_RESPAWN_TIME )

	GameRules:SetUseCustomHeroXPValues ( USE_CUSTOM_XP_VALUES )
	
	GameRules:SetHideKillMessageHeaders(true)
	GameRules:SetFirstBloodActive(false)	-- Disables x2 first blood bonus
	GameRules:SetTimeOfDay(0)

	-- Setup GameMode, and Initial Top Bar Values
	GameMode:SetTopBarTeamValuesOverride(true)
	GameMode:SetTopBarTeamValue(2, 0)
	GameMode:SetTopBarTeamValue(3, 0)
	GameMode:SetHUDVisible(9, false)
	GameMode:SetHUDVisible(12, false) 

	-- Setup thinkState for later switching of thinkstates
	self.thinkState = Dynamic_Wrap(ArcherWarsGameMode, '_thinkState_PreGame')

	-- Setup game Hooks
	ListenToGameEvent('npc_spawned', Dynamic_Wrap(ArcherWarsGameMode, 'LearnLocate'), self)
	ListenToGameEvent('npc_spawned', Dynamic_Wrap(ArcherWarsGameMode, 'TeleportSpawn'), self)
	ListenToGameEvent( "game_rules_state_change", Dynamic_Wrap( ArcherWarsGameMode, 'OnGameRulesStateChange' ), self)
	ListenToGameEvent('entity_killed', Dynamic_Wrap(ArcherWarsGameMode, 'UpdateScore'), self)

	self:RegisterCommands()

	GameMode:SetThink("Think", self, 0.25)

	print('ArcherWars Init Gamemode finished')
end

function ArcherWarsGameMode:OnGameRulesStateChange()
	local nNewState = GameRules:State_Get()
	print( "OnGameRulesStateChange: " .. nNewState )

	if nNewState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		--self.AssignTeams()
	end
end

function ArcherWarsGameMode:Think()
	-- Track game time, since the dt passed in to think is actually wall-clock time not simulation time.
	local now = GameRules:GetGameTime()
	if ArcherWarsGameMode.t0 == nil then
		ArcherWarsGameMode.t0 = now
	end

	--self:UpdateScoreboard()

	local dt = now - ArcherWarsGameMode.t0
	ArcherWarsGameMode.t0 = now

	ArcherWarsGameMode:thinkState( dt )
	return 0.25
end

function ArcherWarsGameMode:RegisterCommands()
	print('commands')
	--Convars:RegisterCommand('assigntoteams', function(),'Assign all players to teams.', FCVAR_CHEAT)
end

-- PreGame, runs during pre game time, so the doesn't start until it ends.
function ArcherWarsGameMode:_thinkState_PreGame()
	-- Check if game is still in pre game, or earlier state, if so do nothing.
	if GameRules:State_Get() <= DOTA_GAMERULES_STATE_PRE_GAME then
		return
	end
	GameRules:SendCustomMessage('<font color="#72C49E">Archer Wars</font>', 0, 0)
	GameRules:SendCustomMessage('First player to get <font color="#cb215d">' .. KILLS_TO_WIN ..'</font> kills win! GLHF!', 0, 0)
	EmitGlobalSound( "ui.npe_objective_given" )

	GameMode:SetThink("GiveXp", self, 6.0 )
	for npcId, v in pairs(ARCHERS) do
		ARCHERS[npcId]:RemoveModifierByName("modifier_spawnshield")
		ARCHERS[npcId]:RemoveModifierByName("modifier_burst")
	end

	-- Now that the game isn't in pregame, start the warmup phase.
	print('[[ArcherWars]] GameState Entering WarmUp')
	self.thinkState = Dynamic_Wrap( ArcherWarsGameMode, '_thinkState_Game' )
end

-- PreGame, runs during pre game time, so the doesn't start until it ends.
function ArcherWarsGameMode:_thinkState_Game()
end

function ArcherWarsGameMode:UpdateScore( keys )
	local attacker = EntIndexToHScript(keys.entindex_attacker)
	local victim = EntIndexToHScript(keys.entindex_killed)
	local attackerPlayer = attacker:GetPlayerOwner()
	local attackerID = attackerPlayer:GetPlayerID()
	local attackerTeam = attackerPlayer:GetAssignedHero():GetTeam()

	local attackerName = PlayerResource:GetPlayerName(attackerID)

	if attacker:IsHero() and victim:IsHero() then
		KILLS[attackerID] = KILLS[attackerID] + 1
		-- 5 kills
		if KILLS[attackerID] == KILLS_TO_WIN-5 then
			GameRules:SendCustomMessage('<font color="#' .. PLAYER_COLORS[attackerID] .. '">' .. attackerName .. '</font> needs <font color="#cb215d">5</font> more kills to win!', 0, 0)
		end
		-- 1 kill
		if KILLS[attackerID] == KILLS_TO_WIN-1 then
			GameRules:SendCustomMessage('<font color="#' .. PLAYER_COLORS[attackerID] .. '">' .. attackerName .. '</font> needs <font color="#cb215d">1</font> more kill to win!', 0, 0)
			EmitGlobalSound( "ui.npe_objective_complete" )
		end
		-- Winner
		if KILLS[attackerID] >= KILLS_TO_WIN then
			GameRules:SendCustomMessage('<font color="#' .. PLAYER_COLORS[attackerID] .. '">' .. attackerName .. '</font> is the best archer. Congratulations!', 0, 0)
			GameRules:SetGameWinner(attackerTeam)
		end
	end
end

---------------------------------------------------------------------------
-- Simple scoreboard using debug text
---------------------------------------------------------------------------
function ArcherWarsGameMode:UpdateScoreboard()
	local sortedTeams = {}
	for i, archer in pairs( ARCHERS ) do
		table.insert( sortedTeams, { name = PlayerResource:GetPlayerName(i), teamScore = KILLS[i] } )
	end

	-- reverse-sort by score
	table.sort( sortedTeams, function(a,b) return ( a.teamScore > b.teamScore ) end )

	UTIL_ResetMessageTextAll()
	UTIL_MessageTextAll( "#ScoreboardTitle", 235, 211, 3, 255 )
	for n, t in pairs( sortedTeams ) do
	local smallName = string.sub(t.name, 0, 13)
	local nameLength = string.len(smallName)
    UTIL_MessageTextAll( "▌" .. t.teamScore .. "	" .. smallName, PLAYER_COLORS2[n-1].R , PLAYER_COLORS2[n-1].G, PLAYER_COLORS2[n-1].B, 255 )
	end
end

function ArcherWarsGameMode:GiveXp()
	-- Check if the game is over
	if GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil
	end

	local highestXP = 0
	local playerXP = 0

	-- Get the highest XP in the game
	for npcId, v in pairs(ARCHERS) do
		playerXP = PlayerResource:GetPlayer(npcId):GetAssignedHero():GetCurrentXP()
		if highestXP < playerXP then
			highestXP = playerXP
		end
	end

	-- Give all players XP depending on the difference in XP to the highest
	for npcId, v in pairs(ARCHERS) do
		playerXP = PlayerResource:GetPlayer(npcId):GetAssignedHero():GetCurrentXP()
		local xpGive = (highestXP - playerXP)/10
		-- All players below 100 XP gets a base gain of 10 XP
		if playerXP < 100 then
			xpGive = xpGive + 10
		end
		ARCHERS[npcId]:AddExperience(xpGive, false, false)
		-- Give gold per tick
		--PlayerResource:SetGold(npcId, GOLD_PER_TICK, true) --PlayerResource:GetGold(npcId) + 
	end

	return 6.0
end

-- Learns the Track ability without spending a point
function ArcherWarsGameMode:LearnLocate( keys )
	local hero = EntIndexToHScript(keys.entindex)
	if hero:IsHero() then
		local Ability = hero:FindAbilityByName("archer_locate")
		if Ability then
			Ability:SetLevel(1)
		end
	end
end

-- Send the player to a random spawn location and gives them a shield buff
function ArcherWarsGameMode:TeleportSpawn( keys )
	local npc = EntIndexToHScript(keys.entindex)
	local points = Entities:FindAllByName( "*_point_teleport_spot" )
	local point = points[math.random(table.getn(points))]:GetAbsOrigin()

	if npc:IsHero() then
		if ARCHERS[npc:GetPlayerOwnerID()] == nil then
			npc:SetGold( 0, false)
			if GameRules:State_Get() < DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
				giveUnitDataDrivenModifier(npc, npc, "modifier_spawnshield", 60)
				giveUnitDataDrivenModifier(npc, npc, "modifier_burst", 60)
			end
			ARCHERS[npc:GetPlayerOwnerID()] = npc
		end

		FindClearSpaceForUnit(npc, point, false)
		npc:Stop()
		giveUnitDataDrivenModifier(npc, npc, "modifier_spawnshield", 3)
	end
end

function giveUnitDataDrivenModifier(source, target, modifier, dur)
		local item = CreateItem( "item_apply_modifiers", source, source)
		item:ApplyDataDrivenModifier( source, target, modifier, {duration=dur} )
		local buff = target:FindModifierByName( modifier )
		--print("Current dur: " .. buff:GetDuration())
		--print("Target dur: " .. dur)
		if buff:GetDuration() < dur then
			buff:SetDuration( dur, true)
		end
end