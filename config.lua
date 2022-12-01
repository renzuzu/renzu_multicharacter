Config = {}
Config.Locale = 'en'
Config.framework = 'ESX' -- ESX or QBCORE

-- if using qbcore use qb-clothing or fivemappearance. 
Config.skin = 'fivemappearance' -- skinchanger , fivemappearance, qb-clothing
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
Config.Slots = 5
Config.commandslot = 'updatecharslots' -- /updatecharslots 7
--------------------

-- Text to prepend to each character (char#:identifier) - keep it short
Config.Prefix = 'char'
-- DEFAULT SPAWN
Config.Spawn = vector3(-1037.59,-2736.90,20.16)
--------------------

-- Do not use unless you are prepared to adjust your resources to correctly reset data
Config.Relog = true
-------------------

Config.ESXStarterItem = {
	[1] = {item = 'bread', amount = 10},
	[2] = {item = 'water', amount = 10},
}

Config.Animations = {
	['choose'] = {
		[1] = {dict = 'anim@mp_player_intcelebrationfemale@blow_kiss', anim = 'blow_kiss'},
		[2] = {dict = 'anim@arena@celeb@podium@no_prop@', anim = 'regal_c_1st'},

		[3] = {dict = 'anim@mp_player_intcelebrationfemale@shadow_boxing', anim = 'shadow_boxing'},

		[4] = {dict = 'mini@triathlon', anim = 'want_some_of_this'},

		[5] = {dict = 'random@street_race', anim = 'grid_girl_race_start'},

		[6] = {dict = 'amb@world_human_hang_out_street@male_c@idle_a', anim = 'idle_b'},

		[7] = {dict = 'anim@arena@celeb@flat@solo@no_props@', anim = 'flip_a_player_a'},
		[8] = {dict = 'timetable@reunited@ig_2', anim = 'jimmy_getknocked'},
		[9] = {dict = 'anim@mp_player_intcelebrationmale@karate_chops', anim = 'karate_chops'},

		[10] = {dict = 'anim@mp_player_intupperpeace', anim = 'idle_a_fp'},

	},
	['delete'] = {
		[1] = {dict = 'anim@mp_player_intcelebrationmale@cut_throat', anim = 'cut_throat'},
		[2] = {dict = 'gestures@m@standing@casual', anim = 'gesture_damn'},
		[3] = {dict = 'anim@mp_player_intupperface_palm', anim = 'idle_a'},
		[4] = {dict = 'anim@mp_player_intupperfinger', anim = 'idle_a_fp'},

	}
}

-- skin menus
-- set use to true if you want to use the skin menus
-- do not set multiple trues on the same resource eg. skinchanger
-- you can add more skin menu or creator events
Config.SkinMenus = {
	['skinchanger'] = {
		['esx_skin'] = {event = 'esx_skin:openSaveableMenu', use = true},
		['VexCreator'] = {event = 'VexCreator:loadCreator', use = false},
		['cui_character'] = {event = 'cui_character:open', use = false},
		['example_resource'] = {exports = 'exports.example:Creator', event = nil, use = false}, -- example support exports
	},
	['fivemappearance'] = {}, -- is there any creator uses fivemappearance? i will leave this todo for now
	['qb-clothing'] = {
		['qb-clothing'] = { event = 'qb-clothing:client:openMenu', use = true},
	},
}
-- compatibility with IlleniumStudios version of fivemappearance for qbcore
Config.fivemappearanceConfig = {
	ped = true, headBlend = true, faceFeatures = false, headOverlays = false, components = true, componentConfig = { masks = true, upperBody = true, lowerBody = true, bags = true, shoes = true, scarfAndChains = true, bodyArmor = true, shirts = true, decals = true, jackets = true }, props = true, propConfig = { hats = true, glasses = true, ear = true, watches = true, bracelets = true }, tattoos = true, enableExit = true,
}

--- do not edit
Config.SkinMenu = {}
for resource,v in pairs(Config.SkinMenus) do
	if resource == Config.skin then
		for k,v in pairs(v) do
			if v.use then
				Config.SkinMenu[resource] = {event = v.event or false, exports = v.exports or false}
			end
		end
	end
end

-- extra ui info ex. LocalPlayer.state:set('invehicle',true,true)
-- take note this utilise state bag. so the state value should be sent by client or server manualy.
Config.Status = {
	['invehicle'] = '<i class="fas fa-car-side"></i>',
	['isdead'] = '<i class="fas fa-skull-crossbones"></i>',
	['premium'] = '<i class="fas fa-star"></i>',
	['injail'] = '<i class="fas fa-drum-steelpan"></i>',
	['iscuffed'] = '<i class="fab fa-fedora"></i>',
	['incommunityservice'] = '<i class="fas fa-broom"></i>',
	['isbanned'] = '<i class="fas fa-user-lock"></i>',
	['inbed'] = '<i class="fas fa-bed"></i>',
	['inhouse'] = '<i class="fas fa-house-user"></i>',
	['inapartment'] = '<i class="fas fa-building"></i>',
	['inmlo'] = '<i class="fas fa-home"></i>',
	['admin'] = '<i class="fas fa-crown"></i>',
}