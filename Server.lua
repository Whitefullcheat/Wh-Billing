local ESX = exports.es_extended:getSharedObject()
local webhook = ''

RegisterNetEvent('wh-billing:fatturaobbligatoria')
AddEventHandler('wh-billing:fatturaobbligatoria', function(job, id, amount, target)
    if target == -1 then
        return
    end
    if id == -1 then
        return
    end
    local xTarget = ESX.GetPlayerFromId(id)
    local xPlayer = ESX.GetPlayerFromId(target)
    TriggerEvent('esx_addonaccount:getSharedAccount', 'society_' ..job, function(account)
        xTarget.removeAccountMoney(Config.Account.remove, amount)
        account.addMoney(amount)
        xTarget.showNotification('Hai subito una multa dalla società ' ..job.. ' per un totale di: ' ..amount, 'success')
        local message = 'Il giocatore **' ..GetPlayerName(target).. ' [' ..xPlayer.identifier.. ']** ha inviato una multa per la società **' ..job.. '** al giocatore **' ..GetPlayerName(xTarget.source).. ' [' ..xTarget.identifier.. ']**\n**Totale:** ' ..amount
        ESX.Log(webhook, message)
    end)
end)

RegisterNetEvent('wh-billing:chiedifattura')
AddEventHandler('wh-billing:chiedifattura', function(target, reason, amount, fatturatore)
    targetval = target
    fatturatoreval = fatturatore
    reasonval = reason
    amountval = amount
    TriggerClientEvent('wh-billing:ChiediFattura', target, reason, amount)
end)

RegisterNetEvent('wh-billing:rispondifattura')
AddEventHandler('wh-billing:rispondifattura', function(bool)
    TriggerClientEvent('wh-billing:rispondiFattura', fatturatoreval, bool, targetval, reasonval, amountval)
end)

RegisterNetEvent('wh-billing:faifattura')
AddEventHandler('wh-billing:faifattura', function(id, job, reason, amount)
    local xTarget = ESX.GetPlayerFromId(id)
    local xFatturatore = ESX.GetPlayerFromId(fatturatoreval)
    metadata = {}
    metadata.fatturatore = xFatturatore.getName()
    metadata.azienda = job
    metadata.label = reason
    metadata.amount = amount
    exports.ox_inventory:AddItem(xTarget.source, Config.Item.name, 1, metadata)
    local message = 'Il giocatore **' ..GetPlayerName(fatturatoreval).. ' [' ..xFatturatore.identifier.. ']** ha inviato una fattura al giocatore **' ..GetPlayerName(id).. ' [' ..xTarget.identifier.. ']**\n**Motivo:** ' ..metadata.label.. '\n**Prezzo:** ' ..metadata.amount
    ESX.Log(webhook, message)
end)

RegisterNetEvent('wh-billing:pagafattura')
AddEventHandler('wh-billing:pagafattura', function(table, method)
    local money = tonumber(table.amount)
    local azienda = table.azienda
    local xPlayer = ESX.GetPlayerFromId(source)
    TriggerEvent('esx_addonaccount:getSharedAccount', 'society_' ..azienda, function(account)
    if method == 'money' then
        if xPlayer.getMoney() >= money then
            account.addMoney(money)
            xPlayer.removeMoney(money)
            xPlayer.showNotification('Hai pagato la fattura per un totale di ' ..money.. '$ con i contanti!', 'success')
            exports.ox_inventory:RemoveItem(xPlayer.source, Config.Item.name, 1, metadata)
            paid = true
            local message = 'Il giocatore **' ..GetPlayerName(source).. ' [' ..xPlayer.identifier.. ']** ha pagato una fattura per la società **' ..azienda.. '**\n**Metodo di pagamento:** Contanti\n**Totale:** ' ..money
            ESX.Log(webhook, message)
            Wait(500)
            paid = false
        else
            paid = false
            xPlayer.showNotification(Config.language["not_enough_money"], 'error')
        end
    elseif method == 'bank' then
        if xPlayer.getAccount(Config.Account.bank).money >= money then
            account.addMoney(money)
            xPlayer.removeAccountMoney(Config.Account.bank, money)
            xPlayer.showNotification('Hai pagato la fattura per un totale di ' ..money.. '$ con la carta di credito!', 'success')
            exports.ox_inventory:RemoveItem(xPlayer.source, Config.Item.name, 1, metadata)
            paid = true
            local message = 'Il giocatore **' ..GetPlayerName(source).. ' [' ..xPlayer.identifier.. ']** ha pagato una fattura per la società **' ..azienda.. '**\n**Metodo di pagamento:** Banca\n**Totale:** ' ..money
            ESX.Log(webhook, message)
            Wait(500)
            paid = false
        else
            paid = false
            xPlayer.showNotification(Config.language["not_enough_money"], 'error')
        end
    end
    end)
if paid then
    local xPlayers = ESX.GetPlayers()
    for i=1, #xPlayers, 1 do
        local dipendenti = ESX.GetPlayerFromId(xPlayers[i])
        if dipendenti.job.name == azienda then
            dipendenti.showNotification('Una fattura per un totale di ' ..money.. ' è stata pagata da ' ..xPlayer.getName(), 'success')
        end
    end
end
end)

lib.callback.register('wh-billing:pagafattura', function()
    return paid
end)

ESX.RegisterUsableItem(Config.Item.name, function(source, null, data)
	local xPlayer = ESX.GetPlayerFromId(source)
    if data.metadata ~= nil then
        TriggerClientEvent('wh-billing:OpenNUI', source, data.metadata)
    else
        xPlayer.showNotification('Fattura Vuota', 'error')
    end
end)
