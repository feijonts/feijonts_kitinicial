-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
feijonts = {}
Tunnel.bindInterface("feijonts_kitinicial",feijonts)
feijontsC = Tunnel.getInterface("feijonts_kitinicial")

function SendWebhookMessage(webhook,message)
	if webhook ~= nil and webhook ~= "" then
		PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({content = message}), { ['Content-Type'] = 'application/json' })
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PREPARES
-----------------------------------------------------------------------------------------------------------------------------------------
vRP._prepare('feijonts/selectkit','SELECT * FROM feijonts_kitinicial WHERE user_id = @user_id')
vRP._prepare('feijonts/insertkit','INSERT IGNORE INTO feijonts_kitinicial(user_id,collected) VALUES(@user_id,@collected)')
vRP._prepare('feijonts/updatekit','UPDATE feijonts_kitinicial SET collected = @collected WHERE user_id = @user_id')
vRP._prepare('feijonts/selectvehicle','SELECT * FROM vrp_user_vehicles WHERE user_id = @user_id AND vehicle = @vehicle')
vRP._prepare("feijonts/insertvehicle","INSERT IGNORE INTO vrp_user_vehicles(user_id,vehicle,ipva) VALUES(@user_id,@vehicle,@ipva)")
-----------------------------------------------------------------------------------------------------------------------------------------
-- COMMAND
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('kit', function(source,args)
    local user_id = vRP.getUserId(source)
    local query = vRP.query('feijonts/selectkit', { user_id = user_id })
    if not query[1] then
        vRP.execute('feijonts/insertkit', { user_id = user_id, collected = true })
        if not config['creative'] then
            if config['items'] ~= nil and #config['items'] > 0 then
                for k,v in pairs(config['items']) do
                    vRP.giveInventoryItem(user_id,v[1],parseInt(v[2]))
                end
            end
        else
            if config['items'] ~= nil and #config['items'] > 0 then
                for k,v in pairs(config['items']) do
                    vRP.generateItem(user_id,v[1],parseInt(v[2]),true)
                end
            end
        end
        if config['weapons'] ~= nil and #config['weapons'] > 0 then
            for k,v in pairs(config['weapons']) do
                vRPclient.giveWeapons(source,{[v] = { ammo = 250 }},false)
            end
        end
        if config['vehicles'] ~= nil and #config['vehicles'] > 0 then
            for k,v in pairs(config['vehicles']) do
                local query = vRP.query('feijonts/selectvehicle', { user_id = user_id, vehicle = v })
                if not query[1] then
                    vRP.execute("feijonts/insertvehicle",{ user_id = user_id, vehicle = v, ipva = parseInt(os.time()) }) 
                end
                Wait(100)
            end
        end
        TriggerClientEvent('Notify', source, 'sucesso', 'Kit inicial resgatado com sucesso!')
        SendWebhookMessage(config['webhook'],"```prolog\n[ID]: "..user_id.."\n[RESGATOU O KIT INICIAL]"..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").." \r```") 
    else
        if query[1].collected ~= 1 then
            vRP.execute('feijonts/updatekit', { user_id = user_id, collected = true })
            if not config['creative'] then
                for k,v in pairs(config['items']) do
                    vRP.giveInventoryItem(user_id,v[1],parseInt(v[2]))
                end
            else
                for k,v in pairs(config['items']) do
                    vRP.generateItem(user_id,v[1],parseInt(v[2]),true)
                end
            end
            for k,v in pairs(config['weapons']) do
                vRPclient.giveWeapons(source,{[v] = { ammo = 250 }},false)
            end
            for k,v in pairs(config['vehicles']) do
                vRP.execute("feijonts/insertvehicle",{ user_id = user_id, vehicle = v, ipva = parseInt(os.time()) }) 
            end
            TriggerClientEvent('Notify', source, 'sucesso', 'Kit inicial resgatado com sucesso!')
            SendWebhookMessage(config['webhook'],"```prolog\n[ID]: "..user_id.."\n[RESGATOU O KIT INICIAL]"..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").." \r```") 
        else
            TriggerClientEvent('Notify',source,'negado','Você ja coletou o kit inicial')
        end
    end
end)