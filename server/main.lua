local callbacks = {}
registercallback = function(name,cb) -- create dependent callbacks. so we wont have much convertion for other frameworks
	callbacks[name] = cb
end

RegisterNetEvent('servercallback', function(name,...)
    TriggerClientEvent('servercallback',source,name,callbacks[name](source,...))
end)

registercallback('renzu_multicharacter:choosecharacter', function(source,slot)
	Login(source,slot,nil)
	return LoadPlayer(source)
end)

registercallback('renzu_multicharacter:createcharacter', function(source,data)
	Login(source,data.slot,data.info)
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
	return GetCharacters(source,data)
end)

RegisterNetEvent('esx_multicharacter:relog', function()
     local src = source
     TriggerEvent('esx:playerLogout', src)
	 if QBCore then
		QBCore.Player.Logout(src)
	 end
end)