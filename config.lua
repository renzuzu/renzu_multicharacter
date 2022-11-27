Config = {}
Config.Locale = 'en'
Config.framework = 'ESX' -- ESX or QBCORE

-- if using qbcore use qb-clothing or fivemappearance. 
Config.skin = 'skinchanger' -- skinchanger , fivemappearance, qb-clothing
-- skin resource

-- SPAWN resource
Config.SpawnSelector = true -- enable this if you want to use spawn selector
Config.SpawnSelectorExport = function(coord) -- by default it uses my spawn resource
	return exports.renzu_spawn:Selector({x = coord.x, y = coord.y, z = coord.z, heading = coord.w})
end
-- intro
Config.bgmusic = true -- play bg music on intro character select
Config.IntroURL = 'https://www.youtube.com/watch?v=41cqwo504hA' -- bg music on intro
Config.CameraIntro = { -- camera locations when doing intro
	[1] = {coord = vec3(-378.5999755859,504.25170898438,434.6608581543), rot = vec3(0.00, 0.00, 151.00)},
	[2] = {coord = vec3(169.95536804199,-964.54614257813,64.203475952148), rot = vec3(360.00, 0.00, -30.00)},
	[3] = {coord = vec3(-407.0290222168,1312.7703857422,390.61987304), rot = vec3(360.00, 0.00, 180.00)},
	[4] = {coord = vec3(-1040.8935546875,-937.53588867188,114.1599731445), rot = vec3(360.00, 0.00, 169.00)},
	[5] = {coord = vec3(907.22625732422,108.29551696777,137.6200256347), rot = vec3(320.00, 5.00, 180.00)},
}
-- Allows players to delete their characters
Config.CanDelete = true
-- This is the default number of slots for EVERY player
Config.Slots = 5 -- todo with possible command for admins.
--------------------

-- Text to prepend to each character (char#:identifier) - keep it short
Config.Prefix = 'char'
-- DEFAULT SPAWN
Config.Spawn = vector3(-1037.59,-2736.90,20.16)
--------------------

-- Do not use unless you are prepared to adjust your resources to correctly reset data
Config.Relog = true
-------------------