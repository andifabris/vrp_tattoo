local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP","vrp_tattoo")
vRPloja = Tunnel.getInterface("vrp_tattoo")
nyo = Proxy.getInterface("nyo")

-----------------------------------------------------------------------------------------------------------------------------------------
-- CONEXÃO
-----------------------------------------------------------------------------------------------------------------------------------------
local tattooStart = true 

cx = {}
Tunnel.bindInterface("vrp_tattoo",cx)
src = Tunnel.getInterface("vrp_tattoo")

-----------------------------------------------------------------------------------------------------------------------------------------
-- Functions
-----------------------------------------------------------------------------------------------------------------------------------------
function SendWebhookMessage(webhook,message)
    if webhook ~= nil and webhook ~= "" then
        PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({content = message}), { ['Content-Type'] = 'application/json' })
    end
end

function cx.getTattooShops()
    if tattooStart then 
        return tattooShop
    else 
        return {}
    end
end

function cx.AplicarSkin()
    local source = source
    local user_id = vRP.getUserId(source)
    TriggerEvent("vrp_barber:setPedServer",user_id)
end

function cx.getTattoo()
    local source = source
    local user_id = vRP.getUserId(source)
    local custom = {}
    local data = vRP.getUData(user_id,"vRP:tattoos")
     if data ~= '' then
        custom = json.decode(data)  
        src.setTattoos(source,custom)
        Wait(100)
        src.applyTatto(source)
     else         
        src.setTattoos(source,custom)
        Wait(100)
        src.applyTatto(source)
     end
end

function cx.payment(price, totalPrice, newTatto)
    local source = source 
    local user_id = vRP.getUserId(source)
    if parseInt(price) == parseInt(totalPrice) then 
        if vRP.tryPayment(user_id,parseInt(totalPrice)) then
            TriggerClientEvent("Notify",source,"sucesso","Você pagou <b>$"..totalPrice.." dólares</b> em suas tatuagens.",5000)
            vRP.setUData(user_id,"vRP:tattoos",json.encode(newTatto))
            src.payment(source, true)
            TriggerEvent("vrp_barber:setPedServer",user_id)
        else 
            TriggerClientEvent("Notify",source,"negado","Você não tem dinheiro suficiente",5000)
            src.payment(source, false)
            TriggerEvent("vrp_barber:setPedServer",user_id)
        end 
    else 
        TriggerClientEvent("Notify",source,"negado","Ocorreu um erro na sua compra! Tente novamente!",5000)
        src.payment(source, false)
        TriggerEvent("vrp_barber:setPedServer",user_id)
    end
end

AddEventHandler("vRP:playerSpawn",function(user_id,source,first_spawn)
    local source = source
    if first_spawn and tattooStart then
        local custom = {}
        local data = vRP.getUData(user_id,"vRP:tattoos")

        if data ~= '' then
            custom = json.decode(data)
            src.setTattoos(source,custom)
            Wait(100)
            src.applyTatto(source)
        else 
            src.setTattoos(source,custom)
            Wait(100)
            src.applyTatto(source)
        end 
    end
end)