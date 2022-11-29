# renzu_multicharacter
Fivem - ESX &amp; QBCORE Multicharacters
![image](https://user-images.githubusercontent.com/82306584/204109418-19518fb1-f2d3-4818-86b4-f41b21f423c3.png)
![image](https://user-images.githubusercontent.com/82306584/204109522-ad386b70-eeef-4a4c-8b84-f1d190e6a189.png)
![image](https://user-images.githubusercontent.com/82306584/204109548-2ce22080-4279-4e26-a4ca-d8e120e021ac.png)

# Feature
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

# Commands
- /relog (logout)
- /updatecharslots (update the total of slots) ex. /updatecharslots ID 10

# Skin Resource
- Support skinchanger, fivemappearance, qb-clothing
```
Config.skin = 'skinchanger' -- skinchanger , fivemappearance, qb-clothing
```
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

# Player States in UI
![image](https://user-images.githubusercontent.com/82306584/204421392-1f1df56b-60c2-483c-ba14-a5c7bd802f92.png)
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

# install

-  make sure this config from esx is setup this way
```
Config.Multichar                = true -- Enable support for esx_multicharacter
Config.Identity                 = true -- Select a characters identity data before they have loaded in (this happens by default with multichar)
```
- verify whats your framework config.lua
```
Config.framework = 'ESX' -- ESX or QBCORE
```
- verify your skin resource
```
Config.skin = 'skinchanger' -- skinchanger , fivemappearance, qb-clothing
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


# Dependency
- ESX or QBCORE
- skinchanger or fivemappearance or qb-clothing
- xsound or renzu_mp3 (for bg intro) (OPTIONAL)
- renzu_spawn - for spawn selector (OPTIONAL)

# compatibilites
- this supports qb-spawn ( you need to disable spawnselector in config ) - by default qbcore is setup this way. so you can have your spawn in aparment, housing etc.. (temporary until i release my housing with apartments)
- esx_kashacters identifier logic - this dont support the old multicharacter logic. its only support if your esx legacy is using char as prefix for multicharacters
- skinchanger repos - this supports the skinchanger so this probably supports CUI characters too. since its a revamped skinchanger with creator ui.
