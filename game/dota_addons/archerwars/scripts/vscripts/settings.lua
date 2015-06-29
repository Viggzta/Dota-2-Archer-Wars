STARTING_GOLD = 0						-- How much gold each player starts with
KILLS_TO_WIN = 20						-- How many kills required to win

ENABLE_HERO_RESPAWN = true				-- Should the heroes automatically respawn on a timer or stay dead until manually respawned
UNIVERSAL_SHOP_MODE = true				-- Should the main shop contain Secret Shop items as well as regular items
ALLOW_SAME_HERO_SELECTION = true		-- Should we let people select the same hero as each other

HERO_SELECTION_TIME = 30.0				-- How long should we let people select their hero?
FIXED_RESPAWN_TIME = 4.0				-- How long should the respawn timer be for heroes?
PRE_GAME_TIME = 20.0					-- How long after people select their heroes should the horn blow and the game start?
POST_GAME_TIME = 20.0					-- How long should we let people look at the scoreboard before closing the server automatically?
TREE_REGROW_TIME = 5.0					-- How long should it take individual trees to respawn after being cut down/destroyed?

GOLD_PER_TICK = 10						-- How much gold should players get per tick?
GOLD_AND_XP_TICK_TIME = 6				-- How long should we wait in seconds between gold ticks?

RECOMMENDED_BUILDS_DISABLED = true		-- Should we disable the recommened builds for heroes (Note: this is not working currently I believe)
CAMERA_DISTANCE_OVERRIDE = 1800.0		-- How far out should we allow the camera to go?  1134 is the default in Dota

MINIMAP_ICON_SIZE = 1					-- What icon size should we use for our heroes?
MINIMAP_CREEP_ICON_SIZE = 1				-- What icon size should we use for creeps?
MINIMAP_RUNE_ICON_SIZE = 1				-- What icon size should we use for runes?

RUNE_SPAWN_TIME = 120					-- How long in seconds should we wait between rune spawns?
CUSTOM_BUYBACK_COST_ENABLED = false		-- Should we use a custom buyback cost setting?
CUSTOM_BUYBACK_COOLDOWN_ENABLED = false	-- Should we use a custom buyback time?
BUYBACK_ENABLED = false					-- Should we allow people to buyback when they die?

DISABLE_FOG_OF_WAR_ENTIRELY = false		-- Should we disable fog of war entirely for both teams?
USE_STANDARD_DOTA_BOT_THINKING = false	-- Should we have bots act like they would in Dota? (This requires 3 lanes, normal items, etc)
USE_FIXED_HERO_GOLD_BOUNTY = true		-- Should we give gold for hero kills by the units bounty values?

USE_CUSTOM_TOP_BAR_VALUES = false		-- Should we do customized top bar values or use the default kill count per team?
TOP_BAR_VISIBLE = false					-- Should we display the top bar score/count at all?
SHOW_KILLS_ON_TOPBAR = false			-- Should we display kills only on the top bar? (No denies, suicides, kills by neutrals)  Requires USE_CUSTOM_TOP_BAR_VALUES

REMOVE_ILLUSIONS_ON_DEATH = true		-- Should we remove all illusions if the main hero dies?
DISABLE_GOLD_SOUNDS = false				-- Should we disable the gold sound when players get gold?

USE_CUSTOM_HERO_LEVELS = true			-- Should we allow heroes to have custom levels?
MAX_LEVEL = 12							-- What level should we let heroes get to?
USE_CUSTOM_XP_VALUES = true				-- Should we use custom XP values to level up heroes, or the default Dota numbers?

-- Required XP per level
XP_PER_LEVEL_TABLE = {
	0, -- 1
	100, -- 2
	400, -- 3
	700, -- 4
	1000, -- 5
	1300, -- 6
	1600, -- 7
	1900, -- 8
	2200, -- 9
	2500, -- 10
	2800, -- 11
	3100  -- 12
}

PLAYER_COLORS = {}						-- Hex values for all players where 0 is radiant and 1 is dire, rest are custom team 1-8
PLAYER_COLORS[0] = "2e6ae6"				-- Blue
PLAYER_COLORS[1] = "e67ab0"				-- Pink
PLAYER_COLORS[2] = "5de6ad"				-- Teal
PLAYER_COLORS[3] = "ad00ad"				-- Purple
PLAYER_COLORS[4] = "dcd90a"				-- Yellow
PLAYER_COLORS[5] = "e66200"				-- Orange
PLAYER_COLORS[6] = "92a440"				-- Green
PLAYER_COLORS[7] = "5cc5e0"				-- Light Blue
PLAYER_COLORS[8] = "00771f"				-- Dark Green
PLAYER_COLORS[9] = "956000"				-- Brown
PLAYER_COLORS2 = {}						-- RGB values for all players where 0 is radiant and 1 is dire, rest are custom team 1-8
PLAYER_COLORS2[0] = {R = 42, G = 106, B = 230}				-- Blue
PLAYER_COLORS2[1] = {R = 230, G = 122, B = 176}				-- Pink
PLAYER_COLORS2[2] = {R = 93, G = 230, B = 173}				-- Teal
PLAYER_COLORS2[3] = {R = 173, G = 0, B = 173}				-- Purple
PLAYER_COLORS2[4] = {R = 220, G = 217, B = 10}				-- Yellow
PLAYER_COLORS2[5] = {R = 230, G = 98, B = 0}				-- Orange
PLAYER_COLORS2[6] = {R = 146, G = 164, B = 64}				-- Green
PLAYER_COLORS2[7] = {R = 92, G = 197, B = 224}				-- Light Blue
PLAYER_COLORS2[8] = {R = 0, G = 119, B = 31}				-- Dark Green
PLAYER_COLORS2[9] = {R = 149, G = 96, B = 0}				-- Brown
PLAYER_COLORS3 = {}
PLAYER_COLORS3[DOTA_TEAM_GOODGUYS] = {42, 106, 230}			-- Blue
PLAYER_COLORS3[DOTA_TEAM_BADGUYS] = {230, 122, 176}			-- Pink
PLAYER_COLORS3[DOTA_TEAM_CUSTOM_1] = {93, 230, 173}			-- Teal
PLAYER_COLORS3[DOTA_TEAM_CUSTOM_2] = {173, 0, 173}			-- Purple
PLAYER_COLORS3[DOTA_TEAM_CUSTOM_3] = {220, 217, 10}			-- Yellow
PLAYER_COLORS3[DOTA_TEAM_CUSTOM_4] = {230, 98, 0}			-- Orange
PLAYER_COLORS3[DOTA_TEAM_CUSTOM_5] = {146, 164, 64}			-- Green
PLAYER_COLORS3[DOTA_TEAM_CUSTOM_6] = {92, 197, 224}			-- Light Blue
PLAYER_COLORS3[DOTA_TEAM_CUSTOM_7] = {0, 119, 31}			-- Dark Green
PLAYER_COLORS3[DOTA_TEAM_CUSTOM_8] = {149, 96, 0}			-- Brown