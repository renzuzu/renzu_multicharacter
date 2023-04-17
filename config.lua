Config = {}
Config.Locale = 'en'
Config.UseDefaultRegister = true -- if false you will use other registration resource ex. esx_identite,
Config.RegisterHook = {
	event = true,
	call = 'esx_identity:showRegisterIdentity' -- sample esx_identity compatibility. for more compatibilty see bottom.
}

-- SPAWN resource
Config.SpawnSelector = true -- enable this if you want to use spawn selector
Config.SpawnSelectInNewOnly = false -- set this to true if you want to use SpawnSelector on new players only
Config.SpawnSelectorExport = function(coord) -- by default it uses my spawn resource
	return exports.renzu_spawn:Selector({x = coord.x, y = coord.y, z = coord.z, heading = coord.w})
end
-- intro
Config.bgmusic = false -- play bg music on intro character select
Config.IntroURL = 'https://www.youtube.com/watch?v=41cqwo504hA' -- bg music on intro
Config.cam = true -- intro camera

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
Config.Slots = 1
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
	[1] = {item = 'pizzaslice1', amount = 20},
	[2] = {item = 'water', amount = 20},
	[3] = {item = 'phone', amount = 1},
	[4] = {item = 'startercar', amount = 1},
	[5] = {item = 'money', amount = 50000},
	[6] = {item = 'lockpick', amount = 1},
	[7] = {item = 'houselockpick', amount = 1},
	[8] = {item = 'icecream1', amount = 10},

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
	['illeniumappearance'] = {}, -- is there any creator uses fivemappearance? i will leave this todo for now
	['fivemappearance'] = {}, -- is there any creator uses fivemappearance? i will leave this todo for now
	['qb-clothing'] = {
		['qb-clothing'] = { event = 'qb-clothing:client:openMenu', use = true},
	},
}
-- compatibility with IlleniumStudios version of fivemappearance for qbcore
Config.fivemappearanceConfig = {
	ped = true, headBlend = true, faceFeatures = true, headOverlays = true, components = true, componentConfig = { masks = true, upperBody = true, lowerBody = true, bags = true, shoes = true, scarfAndChains = true, bodyArmor = true, shirts = true, decals = true, jackets = true }, props = true, propConfig = { hats = true, glasses = true, ear = true, watches = true, bracelets = true }, tattoos = true, enableExit = true,
}

-- Choose Skin Resource
Config.skinsupport = {
	['fivem-appearance'] = true,
	['skinchanger'] = true,
	['qb-clothing'] = true,
	['illenium-appearance'] = true
}

Config.skin = 'none' -- do not replace this. this resource automatically detect your skin resourc if its supported.
local skincount = {}
local lowpriority = 'skinchanger' -- for people who started 2 skin resource :facepalm
for skin,_ in pairs(Config.skinsupport) do
	if GetResourceState(skin) == 'started' or GetResourceState(skin) == 'starting' then -- autodetect skin resource
		Config.skin = skin
		table.insert(skincount,skin)
	end
end
if Config.skin == 'none' then
	warn('YOU DONT HAVE ANY SUPPORTED SKIN RESOURCE')
end
if #skincount > 1 then
	warn('you have multiple skin resource started. start only 1 supported skin resource. ex. fivem-appearance, skinchanger cannot be started at the same time!')
	for k,skin in pairs(skincount) do
		if lowpriority ~= skin then
			Config.skin = skin
		end
	end
	warn('USING '..Config.skin..' Anyway')
end

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

-- skin resource

-- FRAMEWORK AUTO DETECT 2 supported framework
Config.framework = GetResourceState('es_extended') ==  'started' and 'ESX' or GetResourceState('qb-core') ==  'started' and 'QBCORE'
if not Config.framework then warn("NO FRAMEWORK DETECTED") end
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

-- Custom identity / register resource
-- exports.renzu_multicharacter:RegisterComplete(source, {
--     firstname = 'Firstname', lastname = 'Lastname', sex = 'm', height = 100,
-- })
-- you need to trigger this export from server after you complete your registration form from your registration resource.
-- if your using esx_identity its automatically supported you dont need to trigger the export and any other resource adapted to the ESX legacy identity logic.