# 👯 renzu_multicharacter
Hi, i want to share this new resource :heart: 
Fivem - ESX &amp; QBCORE Multicharacters

![image](https://user-images.githubusercontent.com/82306584/204663183-47535b6d-1f4c-4a4a-9bff-7f9132dcd50b.png)

# :boom: Feature
- Support ESX and QBCORE
- ESX Legacy Standard Multicharacter Logic using (char) as prefix
- Intro Cameras and BG music
- Character Deletion
- Support Showing Your custom Logo
- Builtin Character Registration
- Supports Spawn Selector (by default this uses my renzu_spawn as a Selector)
- Supports Latest skinchanger & fivemappearance or qb-clothing
- Supports /relog command (logout)
- Supports Updating Slots number via config or commands. there is no maximum number but 10-20 is good.
- Support Starter items
- Player States on UI

# 🕹️ Commands
- /relog (logout)
- /updatecharslots (update the total of slots) ex. /updatecharslots ID 10

# 👦🏻 Skin Resource
- Support skinchanger, fivemappearance, illenium-appearance, qb-clothing

# Skin Menus / Character Creator Support
- we include multiple resource for each skin resource and you can add more if yours is missing.
```
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
```

# #️⃣ Player States in UI
![image](https://user-images.githubusercontent.com/82306584/204690922-e62e1043-62c1-4393-a918-43131e0a75f2.png)

[details="States Information"]
- this shows the current state of player if its set manually. (ex. shows if player is dead)
- callbacks are triggered once player has been login.
- sample use case: register state if player is in vehicle'
```
exports.renzu_multicharacter:RegisterStates('invehicle', function()
 	if not lib then return end -- ox_lib
 	print('registered')
 	lib.onCache('vehicle', function(value)
 		print(value)
 		LocalPlayer.state:set('invehicle',value and {net = NetworkGetNetworkIdFromEntity(value) or false},true)
 	end)
end,false) -- set spawn selector true or false
```
- and once the player accidentaly logout, once the player login again, they will automatically spawn on the vehicle even if its moving.
- there could be more use case. like if player is in jail or hospital, community service you could potentially disable spawn selector for ex.
- more use case is if player is in apartment or housing. you could preload the house while the player is respawning.
- set manualy

```
 		LocalPlayer.state:set('isdead',value,true)
```
[/details]


# 🛠️ install


[details="Installation"]
-  make sure this config from esx is setup this way
```
Config.Multichar                = true -- Enable support for esx_multicharacter
Config.Identity                 = true -- Select a characters identity data before they have loaded in (this happens by default with multichar)
```

- verify your using ESX legacy or latest QBCORE
- stop esx_multicharacter
- stop esx_identity or keep it
- stop qb-multicharacters
- stop qb-spawn if your are going to use my spawn resource. renzu_spawn

# esx sql column dependencies
- make sure you have this skin column from users @ esx_skin sql
``` 
ALTER TABLE `users` ADD COLUMN `skin` LONGTEXT NULL DEFAULT NULL;
```
- make sure you have this column from users @ esx_identity sql
```
ALTER TABLE `users`
	ADD COLUMN `firstname` VARCHAR(16) NULL DEFAULT NULL,
	ADD COLUMN `lastname` VARCHAR(16) NULL DEFAULT NULL,
	ADD COLUMN `dateofbirth` VARCHAR(10) NULL DEFAULT NULL,
	ADD COLUMN `sex` VARCHAR(1) NULL DEFAULT NULL,
	ADD COLUMN `height` INT NULL DEFAULT NULL
;
```

# qbcore sql 
- if you are recently using qb-multicharacters there should be no sql missing
[/details]



# ⛓️ Dependency
- [ESX](https://github.com/esx-framework/esx-legacy) or [QBCORE](https://github.com/Qbox-project/qb-core)
- [skinchanger](https://github.com/esx-framework/esx-legacy/tree/755bb0f8aa9e1814d3db929c436ab1aa3c61f95b/%5Besx%5D/skinchanger) or [fivemappearance](https://github.com/wasabirobby/fivem-appearance) or [qb-clothing](https://github.com/Qbox-project/qb-clothing)
- [xsound](https://github.com/Xogy/xsound) or [renzu_mp3](https://github.com/renzuzu/renzu_mp3) (for bg intro) (OPTIONAL)
- [renzu_spawn](https://forum.cfx.re/t/renzu-spawn-character-spawn-selector/4959467) - for spawn selector (OPTIONAL)

# 🤝 compatibilites
- this supports qb-spawn ( you need to disable spawnselector in config ) - by default qbcore is setup this way. so you can have your spawn in aparment, housing etc.. (temporary until i release my housing with apartments)
- esx_kashacters identifier logic - this dont support the old multicharacter logic. its only support if your esx legacy is using char as prefix for multicharacters
- skinchanger repos - this supports the skinchanger so this probably supports CUI characters too. since its a revamped skinchanger with creator ui.

# :heart:  contribution
if you found issues or enhancement idea you can post it here or [here](https://github.com/renzuzu/renzu_multicharacter/issues)
