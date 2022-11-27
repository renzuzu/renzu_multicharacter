local callbacks = {}
registercallback = function(name,cb) -- create dependent callbacks. so we wont have much convertion for other frameworks
	callbacks[name] = cb
end

RegisterNetEvent('servercallback', function(name,...)
    TriggerClientEvent('servercallback',source,name,callbacks[name](source,...))
end)

registercallback('renzu_multicharacter:choosecharacter', function(source,slot)
	Login(source,slot,nil)
	SetPlayerRoutingBucket(source,0)
	return LoadPlayer(source)
end)

registercallback('renzu_multicharacter:createcharacter', function(source,data)
	Login(source,data.slot,data.info)
	SetPlayerRoutingBucket(source,0)
	return LoadPlayer(source)
end)

registercallback('renzu_multicharacter:deletecharacter', function(source,slot)
	return DeleteCharacter(source,slot)
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