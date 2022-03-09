local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPserver = Tunnel.getInterface("vRP")

-----------------------------------------------------------------------------------------------------------------------------------------
-- CONEXÃO
-----------------------------------------------------------------------------------------------------------------------------------------
src = {}
Tunnel.bindInterface("vrp_tattoo", src)
Proxy.addInterface("vrp_tattoo", src)
cx = Tunnel.getInterface("vrp_tattoo")


-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIAVEIS
-----------------------------------------------------------------------------------------------------------------------------------------
local tattooShops = {}
local oldTattoo = nil
local atualTattoo = {}
atualShop = {}
local oldCustom = {}

local totalPrice = 0
local cam = nil

-----------------------------------------------------------------------------------------------------------------------------------------
-- FUNCTIONS
-----------------------------------------------------------------------------------------------------------------------------------------
function src.setTattoos(data)
    atualTattoo = data
end

function src.payment(r)    
    SetNuiFocus(false, false)   
    if r then 

    else 
        resetTattoo()
    end
    oldTattoo = nil
    closeGuiLojaTattoo()
end

function openTattooShop(id)
    local ped = PlayerPedId()
    SetNuiFocus(true, true)
    SetCameraCoords()
    if GetEntityModel(ped) == GetHashKey("mp_m_freemode_01") then
        atualShop = tattooShops[id]['partsM']
        SendNUIMessage({
            openNui = true,
            shop = atualShop,
            tattoo = oldTattoo
        })
    elseif GetEntityModel(ped) == GetHashKey("mp_f_freemode_01") then 
        atualShop = tattooShops[id]['partsF']    
        SendNUIMessage({
            openNui = true,
            shop = atualShop,
            tattoo = oldTattoo
        })    
    end
end

function closeGuiLojaTattoo()
    local ped = PlayerPedId()
    vRP.setCustomization(oldCustom)
    src.applyTatto()
    cx.AplicarSkin()
    SetNuiFocus(false, false)
    FreezeEntityPosition(ped, false)
    SetEntityInvincible(ped, false)
    in_loja = false
    oldTattoo = nil
    totalPrice = 0
    DeleteCam()
    TriggerServerEvent('vrp_barber:setPedClient')
end

function resetTattoo()
    atualTattoo = oldTattoo
    if oldTattoo then
		ClearPedDecorations(PlayerPedId())
		for k,v in pairs(oldTattoo) do
			AddPedDecorationFromHashes(PlayerPedId(),GetHashKey(v[1]),GetHashKey(k))
        end
    else 
        ClearPedDecorations(PlayerPedId())
	end
end

function atualizarTattoo()
    ClearPedDecorations(PlayerPedId())
    for k,v in pairs(atualTattoo) do
        AddPedDecorationFromHashes(PlayerPedId(),GetHashKey(v[1]),GetHashKey(k))
    end
    SendNUIMessage({
        atualizaPrice = true, 
        price = totalPrice
    })
end

function src.applyTatto()
    ClearPedDecorations(PlayerPedId())
    for k,v in pairs(atualTattoo) do
        AddPedDecorationFromHashes(PlayerPedId(),GetHashKey(v[1]),GetHashKey(k))
    end
end

function setNewCustom()
    local roupaPelado = {
        [1885233650] = {                                      
			[1] = { -1,0 },
			[3] = { 15,0 },
			[4] = { 21,0 },
			[5] = { -1,0 },
			[6] = { 34,0 },
			[7] = { -1,0 },
			[8] = { 15,0 },
			[10] = { -1,0 },
			[11] = { 15,0 }
		},
		[-1667301416] = {
			[1] = { -1,0 },
			[3] = { 15,0 },
			[4] = { 15,0 },
			[5] = { -1,0 },
			[6] = { 35,0 },
			[7] = { -1,0 },
			[8] = { 6,0 },
			[9] = { -1,0 },
			[10] = { -1,0 },
			[11] = { 15,0 }
        }
    }

    local modelHash = oldCustom.modelhash
    local idleCopy = {}
    for l,w in pairs(roupaPelado[modelHash]) do
        idleCopy[l] = w
    end

    vRP.setCustomization(idleCopy)
end


function SetCameraCoords()
    local ped = PlayerPedId()
	RenderScriptCams(false, false, 0, 1, 0)
    DestroyCam(cam, false)
    
	if not DoesCamExist(cam) then
        cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
		SetCamActive(cam, true)
        RenderScriptCams(true, true, 500, true, true)

        pos = GetEntityCoords(PlayerPedId())
        camPos = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 2.0, 0.0)
        SetCamCoord(cam, camPos.x, camPos.y, camPos.z+0.75)
        PointCamAtCoord(cam, pos.x, pos.y, pos.z+0.15)
    end
end

function DeleteCam()
	SetCamActive(cam, false)
	RenderScriptCams(false, true, 0, true, true)
	cam = nil
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADS
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
    SetNuiFocus(false, false)
    tattooShops = cx.getTattooShops()    
    cx.getTattoo()
end)

-- Deixar comentado depois da ultima att do Fivem as tatuagens pararam de piscar! Caso ocorra, descomentar esta funçao
-- CreateThread(function()
--     while true do 
--         Wait(300)
--         if not in_loja then 
--             ClearPedDecorations(PlayerPedId())
--             for k,v in pairs(atualTattoo) do
--                  AddPedDecorationFromHashes(PlayerPedId(),GetHashKey(v[1]),GetHashKey(k))
--             end
--         end      
--     end
-- end)

CreateThread(function()
    while true do 
        local nyoSleep = 500
        local ped = PlayerPedId()
        local x,y,z = table.unpack(GetEntityCoords(ped))
        if not in_loja then 
            for k,v in pairs(tattooShops) do 
                for k2, v2 in pairs(v['coord']) do 
                    local distance = GetDistanceBetweenCoords(x,y,z,v2[1], v2[2], v2[3], true)
                    if distance < 10 then 
                        nyoSleep = 4
                        DrawMarker(27,v2[1],v2[2],v2[3]-0.95,0,0,0,0,180.0,130.0,1.0,1.0,1.0,255,0,0,75,0,0,0,1)
                        if distance <=1 then 
                            if IsControlJustPressed(0, 38) then 
                                in_loja = true
                                oldTattoo = atualTattoo
                                oldCustom = vRP.getCustomization()
                                setNewCustom()
                                openTattooShop(k)


                                TaskGoToCoordAnyMeans(ped, v2[1],v2[2],v2[3], 1.0, 0, 0, 786603, 0xbf800000)
                            end
                        end
                    end
                end                
            end
        end        
        Wait(nyoSleep)
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CALLBACK
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("reset", function(data, cb)
    resetTattoo()
    ClearPedTasks(PlayerPedId())
    closeGuiLojaTattoo()
end)

RegisterNUICallback("changeTattoo", function(data, cb)
    local pId = data.id + 1
    local pType = data.type
    local tattooData = atualShop[pType]['tattoo'][pId]
        if atualTattoo[tattooData['name']] ~= nil then 
            local newAtualTattoo = {}
            for k,v in pairs(atualTattoo) do 
                if k ~= tattooData['name'] then 
                    newAtualTattoo[k] = v
                end
            end
            atualTattoo = newAtualTattoo

                if oldTattoo[tattooData['name']] == nil then 
                    totalPrice = totalPrice - tattooData['price']
                end
            atualizarTattoo()
        else 
            local newAtualTattoo = {}
            for k,v in pairs(atualTattoo) do 
                if k ~= tattooData['name'] then 
                    newAtualTattoo[k] = v
                end
            end
            newAtualTattoo[tattooData['name']] = {tattooData['part']}
            atualTattoo = newAtualTattoo
            if oldTattoo[tattooData['name']] == nil then 
                totalPrice = totalPrice + tattooData['price']
            end
            atualizarTattoo()
        end    
end)

RegisterNUICallback("limpaTattoo", function(data, cb)
    atualTattoo = {}
    atualizarTattoo()
end)



RegisterNUICallback("payament", function(data, cb)
    cx.payment(data.price, totalPrice, atualTattoo)
end)

RegisterNUICallback("leftHeading", function(data, cb)
    local currentHeading = GetEntityHeading(PlayerPedId())
    heading = currentHeading-tonumber(data.value)
    SetEntityHeading(PlayerPedId(), heading)
end)

RegisterNUICallback("handsUp", function(data, cb)
    local dict = "missminuteman_1ig_2"
    
	RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
		Citizen.Wait(100)
    end
    
    if not handsup then
        TaskPlayAnim(PlayerPedId(), dict, "handsup_enter", 8.0, 8.0, -1, 50, 0, false, false, false)
        handsup = true
    else
        handsup = false
        ClearPedTasks(PlayerPedId())
    end
end)

RegisterNUICallback("rightHeading", function(data, cb)
    local currentHeading = GetEntityHeading(PlayerPedId())
    heading = currentHeading+tonumber(data.value)
    SetEntityHeading(PlayerPedId(), heading)
end)

RegisterNetEvent('reloadtattos')
AddEventHandler('reloadtattos',function()
	if atualTattoo then
		ClearPedDecorations(PlayerPedId())
		for k,v in pairs(atualTattoo) do
			AddPedDecorationFromHashes(PlayerPedId(),GetHashKey(v[1]),GetHashKey(k))
		end
	end
end)
 

RegisterNUICallback("updateRotate", function(data, cb)
    if data then
        SetEntityHeading(PlayerPedId(), moreValue(data.valor))
    end
end)

function moreValue(n)
	n = n + 0.00000
	return n
end

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        cx.AplicarSkin()
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        closeGuiLojaTattoo()
    end
end)