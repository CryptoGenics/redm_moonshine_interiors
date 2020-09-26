-- SHELLS
RequestImap(GetHashKey("MP006_A3SUPP_MOONSHINE01"))
RequestImap(GetHashKey("MP006_A3SUPP_MOONSHINE01_PLUG"))
RequestImap(GetHashKey("MP006_A2SUPP_MOONSHINE02"))
RequestImap(GetHashKey("MP006_A2SUPP_MOONSHINE02_PLUG"))
RequestImap(GetHashKey("MP006_A4SUPP_MOONSHINE03"))
RequestImap(GetHashKey("MP006_A4SUPP_MOONSHINE03_PLUG"))
RequestImap(GetHashKey("MP006_A1SUPP_MOONSHINE04"))
RequestImap(GetHashKey("MP006_A1SUPP_MOONSHINE04_PLUG"))
RequestImap(GetHashKey("MP006_A4SUPP_MOONSHINE05"))
RequestImap(GetHashKey("MP006_A4SUPP_MOONSHINE05_PLUG"))
-- NOT BOARDED UP
RemoveImap(-1696865897) -- Manzanita Post
RemoveImap(-1625703283) -- New Hanover
RemoveImap(-1023331176) -- Lemoyne
RemoveImap(-2071756699) -- New Austin
RemoveImap(-1809571159) -- Grizzlies

local hasAlreadyEnteredMarker, currentZone = false, nil

local PromptGorup = GetRandomIntInRange(0, 0xffffff)
local PromptName = 'Door'

function SetupUseDoorPrompt()
    Citizen.CreateThread(function()
        local str = 'Use'
        UseDoorPrompt = PromptRegisterBegin()
        PromptSetControlAction(UseDoorPrompt, 0xE8342FF2)
        str = CreateVarString(10, 'LITERAL_STRING', str)
        PromptSetText(UseDoorPrompt, str)
        PromptSetEnabled(UseDoorPrompt, true)
        PromptSetVisible(UseDoorPrompt, true)
        PromptSetHoldMode(UseDoorPrompt, true)
        PromptSetGroup(UseDoorPrompt, PromptGorup)
        PromptRegisterEnd(UseDoorPrompt)
    end)
end

Citizen.CreateThread(function()
    SetupUseDoorPrompt()
    while true do
        Citizen.Wait(500)
        local player = PlayerPedId()
        local coords = GetEntityCoords(player)
        local isInMarker, tempZone = false

        for k,v in pairs(Config.Shacks) do
            local dist = #(coords - v.outside)
            local dist2 = #(coords - v.inside)
            if dist < 50 then
                isInMarker = true
                tempZone = k
            elseif dist2 < 50 then
                isInMarker = true
                tempZone = k
            end
        end

		if isInMarker and not hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = true
            currentZone = tempZone
            ZoneLoop(currentZone)
		end

		if not isInMarker and hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = false
            currentZone = nil
        end
    end
end)

function ZoneLoop(zone)
    Citizen.CreateThread(function()
        repeat
            Wait(0)
            local player = PlayerPedId()
            local coords = GetEntityCoords(player)
            for k,v in pairs(Config.Shacks[zone]) do
                if k ~= 'interior' and k ~= 'interior_sets' then
                    local dist = #(coords - v)
                    if dist < 1.8 then
                        local label  = CreateVarString(10, 'LITERAL_STRING', "Door")
                        PromptSetActiveGroupThisFrame(PromptGorup, label)
                        if PromptHasHoldModeCompleted(UseDoorPrompt) then
                            if k == 'outside' then
                                for _,r in pairs(Config.Shacks[zone].interior_sets) do
                                    if not IsInteriorEntitySetActive(Config.Shacks[zone].interior, r) then
                                        ActivateInteriorEntitySet(Config.Shacks[zone].interior, r)
                                    end
                                end
                                DoScreenFadeOut(1000)
                                Wait(1000)
                                SetEntityCoords(player, Config.Shacks[zone].inside)
                                Wait(1000)
                                DoScreenFadeIn(1000)
                                Wait(1000)
                            elseif k == 'inside' then
                                DoScreenFadeOut(1000)
                                Wait(1000)
                                SetEntityCoords(player, Config.Shacks[zone].outside)
                                Wait(1000)
                                DoScreenFadeIn(1000)
                                Wait(1000)
                            end
                        end
                    end
                end
            end
        until currentZone ~= zone
    end)
end