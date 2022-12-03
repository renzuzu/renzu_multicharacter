local callbacks = {}
local logout = {}
local registered = {}
registercallback = function(name,cb) -- create callbacks. so we wont have much convertion for other frameworks
	callbacks[name] = cb
end

RegisterNetEvent('servercallback', function(name,...)
    TriggerClientEvent('servercallback',source,name,callbacks[name](source,...))
end)

registercallback('renzu_multicharacter:choosecharacter', function(source,slot)
	Login(source,slot,nil)
	SetPlayerRoutingBucket(source,0)
	logout[source] = false
	return LoadPlayer(source)
end)

registercallback('renzu_multicharacter:createcharacter', function(source,data)
	local source = source
	local data = data
	if Config.UseDefaultRegister then
		Login(source,data.slot,data.info)
		SetPlayerRoutingBucket(source,0)
		logout[source] = false
	else
		registered[source] = data
	end
	return true
end)

registercallback('renzu_multicharacter:deletecharacter', function(source,slot)
	return Config.CanDelete and DeleteCharacter(source,slot)
end)

registercallback('renzu_multicharacter:saveappearance', function(source,skin)
	SaveSkin(source,skin)
	return true
end)

registercallback('getcharacters', function(source,data)
	SetPlayerRoutingBucket(source,math.random(99,999))
	local slots = json.decode(GetResourceKvpString("char_slots") or '[]') or {}
	local availableslots = slots[GetIdentifiers(source)] or Config.Slots
	return GetCharacters(source,data,availableslots)
end)

RegisterNetEvent('esx_multicharacter:relog', function()
     local src = source
     TriggerEvent('esx:playerLogout', src)
	 if QBCore then
		QBCore.Player.Logout(src)
	 end
	 logout[src] = true
end)

RegisterNetEvent('esx_identity:completedRegistration', function(src, data)
	if not registered[src] then return end
	Login(src,registered[src].slot,data)
	SetPlayerRoutingBucket(src,0)
	logout[src] = false
end)

exports('RegisterComplete', function(src, data)
	if not registered[src] then return end
	Login(src,registered[src].slot,data)
	SetPlayerRoutingBucket(src,0)
	logout[src] = false
end)

RegisterNetEvent("playerDropped",function()
	local source = source
	logout[source] = true
end)

GetIdentifiers = function(id)
	local license = nil
	local numIdentifiers = GetNumPlayerIdentifiers(id)
	for i = 0, numIdentifiers do
		local identifier = GetPlayerIdentifier(id, i)
        if string.find(GetPlayerIdentifier(id, i),'license') then
			license = identifier
			break
		end
    end
	return license
end

for name,v in pairs(Config.Status) do
	AddStateBagChangeHandler(name, nil, function(bagName, _, value, _, _)
		Wait(1500)
		if value == nil then return end
		local status = GlobalState.PlayerStates
		local net = tonumber(bagName:gsub('player:', ''), 10)
		if logout[net] then return end
		local ply = Player(net).state
		if not status[ply.identifier] then status[ply.identifier] = {} end
		status[ply.identifier][name] = value
		SetResourceKvp('char_status',json.encode(status))
		GlobalState.PlayerStates = status
	end)
end

registercallback('setplayertolastvehicle', function(source,net)
	local vehicle = NetworkGetEntityFromNetworkId(net)
	if DoesEntityExist(vehicle) then
		for i = 0-1, 7 do
			if GetPedInVehicleSeat(vehicle,i) == 0 then
				SetPedIntoVehicle(GetPlayerPed(source),vehicle,i)
				return true
			end
		end
	end
	local ply = Player(source).state
	ply:set('invehicle',false,true) -- remove state if vehicle is not exist anymore
	return false
end)