ESX,QBCORE = nil,nil
if Config.framework == 'ESX' then
	ESX = exports['es_extended']:getSharedObject()
elseif Config.framework == 'QBCORE' then
	QBCore = exports['qb-core']:GetCoreObject()
end

function GetPlayerFromId(src)
	self = {}
	self.src = src
	if Config.framework == 'ESX' then
		return ESX.GetPlayerFromId(self.src)
	elseif Config.framework == 'QBCORE' then
		xPlayer = QBCore.Functions.GetPlayer(self.src)
		xPlayer.identifier = xPlayer.citizenid
		if not xPlayer then return end
		return xPlayer
	end
end

GetCharacters = function(source,data,slots)
	local characters = {}
	if Config.framework == 'ESX' then
		local license = ESX.GetIdentifier(source)
		local id = Config.Prefix..'%:'..license
		local data = MySQL.query.await('SELECT * FROM users WHERE identifier LIKE ?', {'%'..id..'%'})
		if data then
			for k,v in pairs(data) do
				local job, grade = v.job or 'unemployed', tostring(v.job_grade)
				if ESX.Jobs[job] and ESX.Jobs[job].grades then
					if job ~= 'unemployed' then grade = ESX.Jobs[job].grades[grade] and ESX.Jobs[job].grades[grade].label or ESX.Jobs[job].grades[tonumber(grade)] and ESX.Jobs[job].grades[tonumber(grade)].label else grade = '' end
					job = ESX.Jobs[job].label
				end
				local accounts = json.decode(v.accounts)
				local id = tonumber(string.sub(v.identifier, #Config.Prefix+1, string.find(v.identifier, ':')-1))
				local firstname = v.firstname or 'No name'
				local lastname = v.lastname or 'No Lastname'
				if not characters[id] then
					characters[id] = {
						slot = id,
						identifier = v.identifier,
						name = firstname..' '..lastname,
						job = job or 'Unemployed',
						grade = grade or 'No grade',
						dateofbirth = v.dateofbirth or '',
						bank = accounts.bank,
						money = accounts.money,
						skin = v.skin and json.decode(v.skin or '[]') or {},
						sex = v.sex,
						position = v.position and v.position ~= '' and json.decode(v.position) or vec3(280.03,-584.29,43.29),
						extras = GetExtras(v.identifier,v.group)
					}
				end
			end
		end
		return {characters = characters , slots = slots}
	else
		local license = QBCore.Functions.GetIdentifier(source, 'license')
		local plyChars = {}
		local result = MySQL.query.await('SELECT * FROM players WHERE license = ?', {license})
		if result and #result > 0 then
			for i = 1, (#result), 1 do
				local skin = MySQL.query.await('SELECT * FROM playerskins WHERE citizenid = ? AND active = ?', { result[i].citizenid, 1 })
				local info = json.decode(result[i].charinfo)
				local money = json.decode(result[i].money)
				local job = json.decode(result[i].job)
				local firstname = info.firstname or 'No name'
				local lastname = info.lastname or 'No Lastname'
				local playerskin = skin and skin[1] and json.decode(skin[1].skin) or {}
				playerskin.model = skin and skin[1] and tonumber(skin[1].model)
				characters[result[i].cid] = {
					slot = result[i].cid,
					name = firstname..' '..lastname,
					job = job.label or 'Unemployed',
					grade = job.grade.name or 'gago',
					dateofbirth = info.birthdate or '',
					bank = money.bank,
					money = money.cash,
					citizenid = result[i].citizenid,
					identifier = result[i].citizenid,
					skin = playerskin,
					sex = info.gender == 0 and 'm' or 'f',
					position = result[i].position and result[i].position ~= '' and json.decode(result[i].position) or vec3(280.03,-584.29,43.29),
					extras = GetExtras(result[i].citizenid)
				}
			end
		end
		return {characters = characters , slots = slots}
	end
end

DeleteCharacter = function(source,slot)
	if Config.framework == 'ESX' then
		local identifier = Config.Prefix..'%:'..ESX.GetIdentifier(source)
		local data = MySQL.query.await('SELECT * FROM users WHERE identifier LIKE ?', {'%'..identifier..'%'})
		for k,v in pairs(data) do
			local id = tonumber(string.sub(v.identifier, #Config.Prefix+1, string.find(v.identifier, ':')-1))
			if id == slot then
				MySQL.query.await('DELETE FROM `users` WHERE `identifier` = ?', {v.identifier})
				break
			end
		end
	else
		local license = QBCore.Functions.GetIdentifier(source, 'license')
		local result = MySQL.query.await('SELECT * FROM players WHERE license = ?', {license})
		for i = 1, (#result), 1 do
			if result[i].citizenid == slot then
				QBCore.Player.DeleteCharacter(source, result[i].citizenid)
    			TriggerClientEvent('QBCore:Notify', source, 'Character Deleted' , "success")
				break
			end
		end
	end
	return true
end

LoadPlayer = function(source)
	local source = source
	local ts = 0
	while not GetPlayerFromId(source) and ts < 1000 do ts += 1 Wait(0) end
	local ply = Player(source).state
	local identifier = GetPlayerFromId(source).identifier
	if identifier then
		ply:set('identifier',GetPlayerFromId(source).identifier,true)
	end
	return true
end

Login = function(source,data,new,qbslot)
	local source = source
	if Config.framework == 'ESX' then
		TriggerEvent('esx:onPlayerJoined', source, Config.Prefix..data, new or nil)
		LoadPlayer(source)
	else
		if new then
			new.cid = data
    		new.charinfo = {
				firstname = new.firstname,
				lastname = new.lastname,
				birthdate = new.birthdate or new.dateofbirth,
				gender = new.sex == 'm' and 0 or 1,
				nationality = new.nationality
			}
		end
		local login = QBCore.Player.Login(source, not new and data or false, new or nil)
		print('^2[qb-core]^7 '..GetPlayerName(source)..' (Citizen ID: '..data..') has succesfully loaded!')
		local ply = Player(source).state
		ply:set('identifier',data,true)
        QBCore.Commands.Refresh(source)
		-- this codes below should be in playerloaded event in server. but here we need this to trigger qb-spawn and to support apartment
		--loadHouseData(source)
		TriggerClientEvent('apartments:client:setupSpawnUI', source, {citizenid = data})
		TriggerEvent("qb-log:server:CreateLog", "joinleave", "Loaded", "green", "**".. GetPlayerName(source) .. "** ("..(QBCore.Functions.GetIdentifier(source, 'discord') or 'undefined') .." |  ||"  ..(QBCore.Functions.GetIdentifier(source, 'ip') or 'undefined') ..  "|| | " ..(QBCore.Functions.GetIdentifier(source, 'license') or 'undefined') .." | " ..data.." | "..source..") loaded..")
	end
	if new then GiveStarterItems(source) end
	return true
end

SaveSkin = function(source,skin) -- only used on fivemappearance character creator
	if Config.framework == 'ESX' then
		local xPlayer = GetPlayerFromId(source)
		MySQL.query.await('UPDATE users SET skin = ? WHERE identifier = ?', {json.encode(skin), xPlayer.identifier})
	else
		local Player = QBCore.Functions.GetPlayer(source)
		if skin.model ~= nil and skin ~= nil then
			-- TODO: Update primary key to be citizenid so this can be an insert on duplicate update query
			MySQL.query('DELETE FROM playerskins WHERE citizenid = ?', { Player.PlayerData.citizenid }, function()
				MySQL.insert('INSERT INTO playerskins (citizenid, model, skin, active) VALUES (?, ?, ?, ?)', {
					Player.PlayerData.citizenid,
					skin.model,
					json.encode(skin),
					1
				})
			end)
		end
	end
	return true
end

GetExtras = function(id,group)
	local status = GlobalState.PlayerStates or {}
	local admin = group ~= nil and group ~= 'user'
	if admin then if not status[id] then status[id] = {} end status[id]['admin'] = true end
	return status[id] or {}
end

UpdateSlot = function(src,id,slot)
	local slots = json.decode(GetResourceKvpString("char_slots") or '[]') or {}
	local license = GetIdentifiers(id)
	if license == nil then return end
	slots[license] = tonumber(slot) or Config.Slots
	SetResourceKvp('char_slots',json.encode(slots))
	return true
end

Command = function(command)
	if Config.framework == 'ESX' then
		ESX.RegisterCommand(command, 'admin', function(xPlayer, args, showError)
			UpdateSlot(xPlayer.source,args[1],args[2])
		end, false)
	else
		QBCore.Commands.Add(command, 'Add Character Slots', {{name='id', help='slots'}, {name='slots', help='Number of Total Sloots, (1, 5 or 7 etc..)'}}, false, function(source, args)
			UpdateSlot(source,args[1],args[2])
		end, 'admin')
	end
end

Command(Config.commandslot)

GlobalState.PlayerStates = json.decode(GetResourceKvpString("char_status") or '[]') or {}

GiveStarterItems = function(source)
	local starter = json.decode(GetResourceKvpString("starteritems") or '[]') or {} -- anti exploit
	Citizen.CreateThreadNow(function()
		local src = source
		if Config.framework == 'QBCORE' then
			local Player = QBCore.Functions.GetPlayer(src)
			if starter[Player.PlayerData.citizenid] then return end
			for _, v in pairs(QBCore.Shared.StarterItems) do
				local info = {}
				if v.item == "id_card" then
					info.citizenid = Player.PlayerData.citizenid
					info.firstname = Player.PlayerData.charinfo.firstname
					info.lastname = Player.PlayerData.charinfo.lastname
					info.birthdate = Player.PlayerData.charinfo.birthdate
					info.gender = Player.PlayerData.charinfo.gender
					info.nationality = Player.PlayerData.charinfo.nationality
				elseif v.item == "driver_license" then
					info.firstname = Player.PlayerData.charinfo.firstname
					info.lastname = Player.PlayerData.charinfo.lastname
					info.birthdate = Player.PlayerData.charinfo.birthdate
					info.type = "Class C Driver License"
				end
				Player.Functions.AddItem(v.item, v.amount, false, info)
			end
			starter[Player.PlayerData.citizenid] = true -- this is something can still be exploit by players as citizenid is random string every register, so put only a real starter pack like phone and etc.

		else
			local xPlayer = ESX.GetPlayerFromId(src)
			if starter[xPlayer.identifier] then return end
			for _, v in pairs(Config.ESXStarterItem) do
				xPlayer.addInventoryItem(v.item,v.amount)
			end
			starter[xPlayer.identifier] = true
		end
		SetResourceKvp('starteritems',json.encode(starter))
	end)
	Wait(2000)
end