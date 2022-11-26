local loaded = false
local models = {
	[0] = `mp_m_freemode_01`, 
	[1] = `mp_f_freemode_01`
}
local defaultspawn = Config.Spawn
local xSound = nil
xsound = function()
	o = function()
		sound = exports.xSound
	end
	local XSOUND = pcall(sound, res or false)
	if not XSOUND then
		play = exports.renzu_mp3.PlayUrl
		xSound = exports.renzu_mp3
	elseif XSOUND then
		xSound = exports.xSound
	end
end
Citizen.CreateThread(function ()
	DoScreenFadeOut(300)
	Wait(1001)
	SendNUIMessage({fade = true})
	if Config.bgmusic and not pcall(xsound, res or false) then xSound = nil end
     while true do
          Wait(0)
          if NetworkIsSessionActive() or NetworkIsPlayerActive(PlayerId()) then
			if xSound then
				Citizen.CreateThreadNow(function ()
					if xSound:soundExists('chosen') then
						xSound:Destroy('chosen')
					end
					xSound:PlayUrl('intro', 'https://www.youtube.com/watch?v=41cqwo504hA', 0.5, false, options)
				end)
			end
			CharacterSelect()
			exports['spawnmanager']:setAutoSpawn(false)
			break
          end
     end
end)

local callbacks = {}
local num = 0
local characters = {}
callback = function(name,...)
	callbacks[name] = promise:new()
	TriggerServerEvent('servercallback',name,...)
	return Citizen.Await(callbacks[name])
end

RegisterNetEvent('servercallback', function(name,data)
    callbacks[name]:resolve(data)
end)

local chosen = false
local cam = nil

WeatherTransition = function()
	TriggerEvent('qb-weathersync:client:DisableSync')
	CreateThread(function ()
		time = 1
		count = 0
		ts = 0
		while not loaded and not chosen do
			SetRainFxIntensity(0.1)
			NetworkOverrideClockTime(time, 1, 0)
			SetWeatherTypeTransition(`THUNDER`,`CLEAR`,0.7)
			ts = ts + 1
			count = count + 1
			if count > 10 then
				count = 0
				time = time + 1
				if time >= 24 and ts < 500 then
						time = 0
				end
				if time >= 23 and ts > 500 then
						time = 23
				end
			end
			DisplayRadar(false)
			Wait(0)
		end
		SetWeatherTypeNowPersist('CLEAR') -- initial set weather
	end)
end

local pedshots = {}

CreatePedHeadShots = function(characters)
	for i = 1, 5 do
		local chardata = characters[i]
		local slot = i-1
		if chardata and not pedshots[slot] then
			local skin = chardata.skin
			skin.sex = chardata.sex == "m" and 0 or 1
			local model = models[skin.sex] or models[0]
			RequestModel(model)
			while not HasModelLoaded(model) do Wait(0) end
			local ped = CreatePed(16,model, chardata.position.x,chardata.position.y,chardata.position.z-0.5,chardata.position.heading or 0.0,0,1)
			while not DoesEntityExist(ped) do Wait(1) end
			SetFocusEntity(ped)
			SetEntityCoords(PlayerPedId(), chardata.position.x,chardata.position.y-10,chardata.position.z-0.5)
			SetSkin(ped, skin)
			Wait(111)
			local pedshot , handle = GetPedShot(ped)
			pedshots[slot] = pedshot
			SendNUIMessage({pedshots = pedshot, slot = slot})
			Wait(10)
			ClearPedHeadshots(handle)
			DeleteEntity(ped)
		else
			SendNUIMessage({pedshots = 'default', slot = slot, default = true})
		end
	end
end

IntroCam = function()
	chosen = false
	loaded = false
	SendNUIMessage({fade = true})
	SendNUIMessage({showui = true})
	characters = callback('getcharacters')
	DoScreenFadeIn(1000)
	CreatePedHeadShots(characters)
	WeatherTransition()
	SetEntityCoords(PlayerPedId(), 0.0,0.0,777.0)
	cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", 1609.6380615234,-2272.8967285156,483.33, 0.00, 0.00, -10.00, 100.00, false, 0)
	Wait(3000)
	DoScreenFadeIn(1000)
	SetCamActive(cam, true)
	RenderScriptCams(true, true, 6000, true, true)
	SendNUIMessage({fade = false})
	SendNUIMessage({showui = true})
	local camloc = Config.CameraIntro
	SendNUIMessage({showlogo = true})
	while #(GetFinalRenderedCamCoord() - vec3(1609.6380615234,-2272.8967285156,483.33)) > 10 do Wait(111) end
	SendNUIMessage({characters = characters})
	while not chosen do
		for k,v in ipairs(camloc) do
			if not chosen then
				SetCamParams(cam, v.coord, v.rot, 50.0, 8000, 0, 0, 2)
				SendNUIMessage({showlogo = false})
				SendNUIMessage({show = true})
				SetNuiFocus(true,true)
			else
				break
			end
			while #(GetFinalRenderedCamCoord() - v.coord) > 10 and not chosen do  
				local camcoord = GetFinalRenderedCamCoord()
				SetFocusPosAndVel(camcoord.x,camcoord.y,camcoord.z)
				Wait(111) 
			end
			Wait(2000)
		end
		Wait(10)
	end
end

local peds = {}
local lastped = nil
local chosenslot = 1

CharacterSelect = function()
	local ped = PlayerPedId()
	DisplayRadar(0)
	SetEntityCoords(ped, 0.0,0.0,1000.0)
	TriggerEvent('esx:loadingScreenOff')
	ShutdownLoadingScreen()
	ShutdownLoadingScreenNui()
	ShutdownLoadingScreenNui(true)
	RequestCollisionAtCoord(0.0,0.0,777.0)
	SetEntityVisible(ped, false)
	FreezeEntityPosition(ped, true)
	DoScreenFadeOut(300)
	IntroCam()
	DoScreenFadeIn(300)
	Wait(2000)
	ClearFocus()
	SetFocusEntity(PlayerPedId())
end

Cleanups = function()
	if DoesCamExist(cam) then
		SetCamActive(cam, false)
		RenderScriptCams(false, false, 0, true, true)
	end
	SetNuiFocus(false, false)
	SetEntityVisible(PlayerPedId(),true)
	ClearFocus()
	SetFocusEntity(PlayerPedId())
	for k,v in pairs(peds) do
		if DoesEntityExist(v) then
			DeleteEntity(v)
		end
	end
end

ShowCharacter = function(slot)
	chosenslot = slot
	if DoesEntityExist(lastped) then DeleteEntity(lastped) end
	chosen = true
	local chardata = characters[tonumber(slot)]
	if xSound then
		if xSound:soundExists('intro') then
			xSound:Destroy('intro')
		end
		if not xSound:soundExists('chosen') then
			xSound:PlayUrl('chosen', 'https://www.youtube.com/watch?v=TjF_V_feppI', 0.09, false, options)
		end
	end
	if chardata and not chardata.new then
		SendNUIMessage({showoptions = 'existing', slot = slot})
	else
		SendNUIMessage({showoptions = 'new', slot = slot})
		if not DoesEntityExist(peds[slot]) then
			RequestModel(models[0])
			while not HasModelLoaded(models[0]) do Wait(100) end
			peds[slot] = CreatePed(4,models[0], defaultspawn.x,defaultspawn.y,defaultspawn.z-0.9, 0.0,0,1)
			while not DoesEntityExist(peds[slot]) do Wait(1) end
			lastped = peds[slot]
		end
		SetSkin(peds[slot],Config.Default['m'])
		characters[tonumber(slot)] = {position = {x = defaultspawn.x, y = defaultspawn.y+10, z = defaultspawn.z}, new = true}
		SetBlockingOfNonTemporaryEvents(peds[slot], true)
		TaskTurnPedToFaceCoord(peds[slot],defaultspawn.x,defaultspawn.y+10,defaultspawn.z)
		SetCamParams(cam, defaultspawn.x,defaultspawn.y+10,defaultspawn.z, 0.0,0.0,0.0, 20.0, 1, 0, 0, 2)
		PointCamAtCoord(cam,defaultspawn.x,defaultspawn.y,defaultspawn.z)
		SetEntityCoords(PlayerPedId(),defaultspawn.x,defaultspawn.y+20,defaultspawn.z)
		SetFocusPosAndVel(defaultspawn.x,defaultspawn.y+10,defaultspawn.z)
		return
	end
	local skin = chardata.skin
	if string.find(tostring(chardata.sex):lower(), 'mal') then chardata.sex ='m' elseif string.find(tostring(chardata.sex):lower(),'fem') then chardata.sex = 'f' end -- supports other identity logic
	skin.sex = chardata.sex == "m" and 0 or 1
	local model = models[skin.sex] or models[0]
	if not DoesEntityExist(peds[slot]) then
		RequestModel(model)
		while not HasModelLoaded(model) do Wait(100) end
		peds[slot] = CreatePed(16,model, chardata.position.x,chardata.position.y,chardata.position.z-0.9,chardata.position.heading or 0.0,0,1)
		while not DoesEntityExist(peds[slot]) do Wait(1) end
		lastped = peds[slot]
	end
	
	SetBlockingOfNonTemporaryEvents(peds[slot], true)
	SetSkin(peds[slot], skin)
	SetEntityCoords(PlayerPedId(),chardata.position.x,chardata.position.y+20,chardata.position.z+0.5)
	SetFocusPosAndVel(chardata.position.x,chardata.position.y+10,chardata.position.z+0.5)
	SetCamParams(cam, chardata.position.x,chardata.position.y+10,chardata.position.z+0.5, 0.0,0.0,0.0, 20.0, 1, 0, 0, 2)
	PointCamAtCoord(cam,chardata.position.x,chardata.position.y,chardata.position.z)
	TaskTurnPedToFaceCoord(peds[slot],chardata.position.x,chardata.position.y+10,chardata.position.z+0.5)
end

SetupPlayer = function()
	local coord = vec3(characters[chosenslot].position.x,characters[chosenslot].position.y,characters[chosenslot].position.z)
	SetFocusPosAndVel(coord.x,coord.y,coord.z)
	RequestCollisionAtCoord(coord.x,coord.y,coord.z)
	SetEntityCoords(PlayerPedId(),coord.x,coord.y,coord.z)
	FreezeEntityPosition(PlayerPedId(), true)
	while not HasCollisionLoadedAroundEntity(PlayerPedId()) do Wait(1) end
	FreezeEntityPosition(PlayerPedId(), false)
	if xSound and xSound:soundExists('chosen') then
		xSound:Destroy('chosen')
	end
end

ChooseCharacter = function(slot)
	chosenslot = slot
	if Config.framework == 'QBCORE' then
		slot = characters[slot].citizenid
	end
	local login = callback('renzu_multicharacter:choosecharacter', slot)
end

SpawnSelect = function(coord)
	if Config.framework == 'QBCORE' then
		QBCore = exports['qb-core']:GetCoreObject()
		local PlayerData = QBCore.Functions.GetPlayerData()
		TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
		TriggerEvent('QBCore:Client:OnPlayerLoaded')
		local insideMeta = PlayerData.metadata["inside"]
		if insideMeta.house ~= nil then
            local houseId = insideMeta.house
            TriggerEvent('qb-houses:client:LastLocationHouse', houseId)
        elseif insideMeta.apartment.apartmentType ~= nil or insideMeta.apartment.apartmentId ~= nil then
            local apartmentType = insideMeta.apartment.apartmentType
            local apartmentId = insideMeta.apartment.apartmentId
            TriggerEvent('qb-apartments:client:LastLocationHouse', apartmentType, apartmentId)
        end
	end
	if Config.SpawnSelector then
		local coord = coord
		spawn = Config.SpawnSelectorExport(coord)
	end
end

local skin = {}

-- SKIN FUNCTIONS
SetSkin = function(ped,skn)
	if Config.skinchanger then
		exports['skinchanger']:loadmulticharpeds(ped, skn)
	elseif Config.fivemappearance then
		exports['fivem-appearance']:setPedAppearance(ped, skn)
	elseif Config.framework == 'QBCORE' then
		TriggerEvent('qb-clothing:client:loadPlayerClothing', skn, ped)
	end
end

GetModel = function(str)
	if Config.skinchanger then
		skin = Config.Default[str]
		skin.sex = str == "m" and 0 or 1
		local model = skin.sex == 0 and `mp_m_freemode_01` or `mp_f_freemode_01`
		return model
	elseif Config.fivemappearance then
		skin.sex = str == "m" and 0 or 1
		local model = skin.sex == 0 and `mp_m_freemode_01` or `mp_f_freemode_01`
		return model
	elseif Config.framework == 'QBCORE' then
		local model = skin.sex == 0 and `mp_m_freemode_01` or `mp_f_freemode_01`
		return model
	end
end

finished = false
SkinMenu = function()
	if Config.skinchanger then
		TriggerEvent('skinchanger:loadSkin', skin, function()
			local playerPed = PlayerPedId()
			SetPedAoBlobRendering(playerPed, true)
			ResetEntityAlpha(playerPed)
			SetEntityVisible(playerPed,true)
			TriggerEvent('esx_skin:openSaveableMenu', function()
				finished = true end, function() finished = true
			end)
		end)
	elseif Config.fivemappearance then
		local config = {
			ped = true,
			headBlend = true,
			faceFeatures = true,
			headOverlays = true,
			components = true,
			props = true,
			tattoos = true
		}
		local playerPed = PlayerPedId()
		SetPedAoBlobRendering(playerPed, true)
		ResetEntityAlpha(playerPed)
		SetEntityVisible(playerPed,true)
		exports['fivem-appearance']:startPlayerCustomization(function (appearance)
		if (appearance) then
			if not characters[chosenslot] then characters[chosenslot] = {} end
			characters[chosenslot].skin = appearance
			local save = callback('renzu_multicharacter:saveappearance', appearance)
			finished = true
		end
		end, config)
	elseif Config.framework == 'QBCORE' then
		TriggerEvent('qb-clothing:client:openMenu')
	end
end

LoadSkin = function()
	if Config.skinchanger then
		TriggerEvent('skinchanger:loadSkin', characters[chosenslot].skin)
	elseif Config.fivemappearance then
		exports['fivem-appearance']:setPlayerAppearance(characters[chosenslot].skin)
	elseif Config.framework == 'QBCORE' then
		TriggerEvent('qb-clothing:client:loadPlayerClothing', characters[chosenslot].skin, PlayerPedId())
	end
end
-- SKIN FUNCTIONS

-- HANDLE PLAYER LOADED
RegisterNetEvent('esx:playerLoaded', function(playerData, isNew, skin)
	local spawn = playerData.coords
	skin = skin
	if not isNew then
		if string.find(tostring(playerData.sex):lower(), 'mal') then playerData.sex ='m' elseif string.find(tostring(playerData.sex):lower(),'fem') then playerData.sex = 'f' end -- supports other identity logic
		skin.sex = playerData.sex == "m" and 0 or 1
	end
	if isNew or not skin or #skin == 1 then
		Cleanups()
		SpawnSelect(vec4(defaultspawn.x,defaultspawn.y+10,defaultspawn.z,0.0))
		finished = false

		local model = GetModel(playerData.sex)
		RequestModel(model)
		while not HasModelLoaded(model) do
			RequestModel(model)
			Wait(0)
		end
		SetPlayerModel(PlayerId(), model)
		SetModelAsNoLongerNeeded(model)
		SkinMenu()
		repeat Wait(200) until finished
	end

	if not isNew then LoadSkin() end
	Wait(400)
	repeat Wait(200) until not IsScreenFadedOut()
	TriggerServerEvent('esx:onPlayerSpawn')
	TriggerEvent('esx:onPlayerSpawn')
	TriggerEvent('playerSpawned')
	TriggerEvent('esx:restoreLoadout')
	SetupPlayer()
	characters, hidePlayers = {}, false
end)

RegisterNetEvent('esx:onPlayerLogout', function()
	DoScreenFadeOut(500)
	Wait(1000)
	CharacterSelect()
	TriggerEvent('esx_skin:resetFirstSpawn')
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    DoScreenFadeOut(500)
	Wait(1000)
	CharacterSelect()
end)

RegisterCommand('relog', function(source, args, rawCommand)
	if Config.Relog and not LocalPlayer.state.isdead then
		TriggerServerEvent('esx_multicharacter:relog')
	end
end)

-- NUI CALLBACKS
RegisterNUICallback('nuicb', function(data)
	if data.msg == 'showchar' then
		ShowCharacter(data.slot)
	end
	if data.msg == 'chooseslot' then
		ChooseCharacter(data.slot)
		Cleanups()
		SpawnSelect(vec4(characters[chosenslot].position.x,characters[chosenslot].position.y,characters[chosenslot].position.z,characters[chosenslot].position.heading or 0.0))
	end
	if data.msg == 'create' then
		data.info.height = 100 -- is this really needed
		chosenslot = data.slot
		callback('renzu_multicharacter:createcharacter', {info = data.info, slot = data.slot})
		Cleanups()
		if Config.framework == 'QBCORE' and GetResourceState('qb-spawn') ~= 'started' then
			local model = GetModel(data.info.sex)
			RequestModel(model)
			while not HasModelLoaded(model) do
				RequestModel(model)
				Wait(0)
			end
			SetPlayerModel(PlayerId(), model)
			SetModelAsNoLongerNeeded(model)
			SpawnSelect(vec4(defaultspawn.x,defaultspawn.y+10,defaultspawn.z,0.0))
			SkinMenu()
		end
	end
	if data.msg == 'deletechar' then
		if Config.framework == 'QBCORE' then data.slot = characters[chosenslot].citizenid end
		callback('renzu_multicharacter:deletecharacter', data.slot)	
		CharacterSelect()
		characters[chosenslot] = nil
		pedshots[chosenslot] = nil
	end
	if data.msg == 'sex' then
		DeleteEntity(peds[data.slot])
		local model = data.sex == 'm' and `mp_m_freemode_01` or `mp_f_freemode_01`
		RequestModel(model)
		while not HasModelLoaded(model) do
				Wait(100)
		end
		peds[data.slot] = CreatePed(4,model, defaultspawn.x,defaultspawn.y,defaultspawn.z-0.5, 0.0,0,1)
		while not DoesEntityExist(peds[data.slot]) do Wait(1) end
		lastped = peds[data.slot]
		SetSkin(peds[data.slot],Config.Default[data.sex])
		characters[tonumber(data.slot)] = {position = {x = defaultspawn.x, y = defaultspawn.y+10, z = defaultspawn.z}, new = true}
		SetBlockingOfNonTemporaryEvents(peds[data.slot], true)
		TaskTurnPedToFaceCoord(peds[data.slot],defaultspawn.x,defaultspawn.y,defaultspawn.z)
	end
end)

GetPedShot = function(ped)
	Wait(0)
	local ped = ped
	local tempHandle = RegisterPedheadshotTransparent(ped)
	local headshotTxd = nil

	local timer = 1200
	while not IsPedheadshotReady(tempHandle) and timer > 0 or not IsPedheadshotValid(tempHandle) and timer > 0 do
		Wait(1)
		timer = timer - 10
	end
	headshotTxd = GetPedheadshotTxdString(tempHandle)
	if headshotTxd == nil or headshotTxd == 0 or tempHandle == 0 then
		tempHandle = RegisterPedheadshot_3(PlayerPedId())
		timer = 1200
		while not IsPedheadshotReady(tempHandle) and timer > 0 or not IsPedheadshotValid(tempHandle) and timer > 0 do
			Wait(1)
			timer = timer - 10
		end
		headshotTxd = GetPedheadshotTxdString(tempHandle)
	end
	return headshotTxd, tempHandle
end

ClearPedHeadshots = function(handle)
	UnregisterPedheadshot(handle)
end