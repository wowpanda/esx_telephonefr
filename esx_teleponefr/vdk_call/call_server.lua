RegisterServerEvent("player:serviceOn")
RegisterServerEvent("player:serviceOff")
RegisterServerEvent("call:makeCall")
RegisterServerEvent("call:getCall")

local inService = {
    ["police"] = {},
    ["ambulance"] = {},
    ["taxi"] = {},
	["mecano"] = {},
	["banker"] = {},
	["biker"] = {},
	["realestateagent"] = {},
	["tabac"] = {},
	["gouv"] = {},
	["vigne"] = {},
	["grocer"] = {},
	["teamster"] = {},
	["bahama"] = {},
	["karting"] = {},
	["avocat"] = {},
	["unicorn"] = {},
}
local callActive = {
    ["police"] = {taken = false},
    ["ambulance"] = {taken = false},
    ["taxi"] = {taken = false},
	["mecano"] = {taken = false},
	["banker"] = {taken = false},
	["biker"] = {taken = false},
	["realestateagent"] = {taken = false},
	["tabac"] = {taken = false},
	["gouv"] = {taken = false},
	["vigne"] = {taken = false},
	["grocer"] = {taken = false},
	["teamster"] = {taken = false},
	["bahama"] = {taken = false},
	["karting"] = {taken = false},
	["avocat"] = {taken = false},
	["unicorn"] = {taken = false},
}
local timing = 60000

-- Add the player to the inService table
AddEventHandler("player:serviceOn", function(job)
local source = source
print ("aaa")
    table.insert(inService[job], source)	
end)

-- Remove the player to the inService table
AddEventHandler("player:serviceOff", function(job)
local source = source
    if job == nil then
        for _,v in pairs(inService) do
            removeService(v)
        end
    end
    removeService(source, job)
end)

-- Receive call event
AddEventHandler("call:makeCall", function(job, pos, message)
local source = source
	 -- Players can't call simultanously the same service
    if callActive[job].taken then
        TriggerClientEvent("target:call:taken", callActive[job].target, 2)
        CancelEvent()
    end
    -- Save the target of the call
    callActive[job].target = source
    callActive[job].taken = true
    -- Send notif to all players in service
    for _, player in pairs(inService[job]) do
        TriggerClientEvent("call:callIncoming", player, job, pos, message)
    end
    -- Say to the target after 'timing' seconds that nobody will come
    SetTimeout(timing, function()
        if callActive[job].taken then
            TriggerClientEvent("target:call:taken", callActive[job].target, 0)
        end
        callActive[job].taken = false
    end)
end)

AddEventHandler("call:getCall", function(job)
    callActive[job].taken = false
    -- Say to other in service people that the call is taken
    for _, player in pairs(inService[job]) do
        if player ~= source then
            TriggerClientEvent("call:taken", player)
        end
    end
    -- Say to a target that someone come
    if not callActive[job].taken then
        TriggerClientEvent("target:call:taken", callActive[job].target, 1)
    end
end)

function removeService(player, job)
    for i,val in pairs(inService[job]) do
        if val == player then
            table.remove(inService[job], i)
            return
        end
    end
end
