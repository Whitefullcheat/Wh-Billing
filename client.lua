ESX = exports.es_extended:getSharedObject()

Citizen.CreateThread(function()
	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end
	ESX.PlayerData = ESX.GetPlayerData()
end)
function getPlayerJob()
    local plyData = ESX.GetPlayerData()
        return plyData.job.name
end

local closestPed = nil

RegisterNetEvent('wh-billing:ApriMenuFatture')
AddEventHandler('wh-billing:ApriMenuFatture', function(data)
    local targetId = NetworkGetPlayerIndexFromPed(data.entity)
    local tPed = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))
    local plyJob = getPlayerJob()
    if CanOpenMenu() then
        local reasons = Config.defaultReasons[plyJob]

        local options = {}
        if reasons then
            for _, reason in ipairs(reasons.otherReasons) do
                table.insert(options, { value = reason, label = reason })
            end
        else
            print("Nessuna ragione trovata per il lavoro: " .. plyJob)
        end

        local input = lib.inputDialog('Fattura', {
            { type = 'select', label = 'Motivo', required = true, options = options },
            { type = "input", label = "Importo", required = true },
        })

        if not input then return ESX.ShowNotification('Non hai compilato bene la fattura!', 'error') end
            if tonumber(input[2]) == nil then
                ESX.ShowNotification('Non hai inserito un importo numerico!', 'error')
                return
            end
            if input[1] == nil or input[1] == '' then
                ESX.ShowNotification('Non hai inserito la motivazione!', 'error')
            end
            if string.len(input[1]) > 100 then
                ESX.ShowNotification('La motivazione della fattura non può essere cosi lunga!', 'error')
                return
            end
            if tonumber(input[2]) > 1500000 then
                ESX.ShowNotification('Il massimo importo per fattura è di 1.5MLN!', 'error')
                return
            end
            local aDgn = tonumber(tPed)
            local reason = input[1]
            local hawY = tonumber(input[2])
            local hraY = GetPlayerServerId(PlayerId())
            if CanDoFine() then
                ESX.ShowNotification('Hai emesso correttamente la fattura obbligatoria!', 'success')
                TriggerServerEvent('wh-billing:fatturaobbligatoria', ESX.PlayerData.job.name, aDgn, hawY, hraY)
            elseif CanDoBill() then
                TriggerServerEvent('wh-billing:chiedifattura', aDgn, reason, hawY, hraY)
                ESX.ShowNotification('Hai emesso correttamente la fattura!', 'success')
            end
    else
        ESX.ShowNotification(Config.language['not_enabled'], 'error')
    end
end)

function CanDoFine()
    for k, v in pairs(Fine.CanDoFine) do
        if v == ESX.PlayerData.job.name then
            return true
        end
    end
    return false
end

function CanDoBill()
    for k, v in pairs(Bill.CanDoBill) do
        if v == ESX.PlayerData.job.name then
            return true
        end
    end
    return false
end

function CanOpenMenu()
    for k, v in pairs(Bill.CanOpenMenu) do
        if v == ESX.PlayerData.job.name then
            return true
        end
    end
    return false
end

RegisterNetEvent('wh-billing:ChiediFattura')
AddEventHandler('wh-billing:ChiediFattura', function(reason, amount, beidati)
    local alert = lib.alertDialog({
        header = Config.language["reason"].. ': ' ..reason.. ' ' ..Config.language["amount"].. ': ' ..amount.. '$',
        content = Config.language["want_sign"],
        centered = true,
        cancel = true
    })
    if alert == 'confirm' then
        TriggerServerEvent('wh-billing:rispondifattura', true)
    else
        TriggerServerEvent('wh-billing:rispondifattura', false)
    end
end)

local function notification(text)
    BeginTextCommandThefeedPost('STRING')
	AddTextComponentSubstringPlayerName(text)
	EndTextCommandThefeedPostTicker(true, true)
end

RegisterNetEvent('wh-billing:rispondiFattura')
AddEventHandler('wh-billing:rispondiFattura', function(accepted, id, reason, amount)

    if(not accepted) then
        ESX.ShowNotification(Config.language["invoice_not_accepted"], 'error')
        PlaySound(-1, "Place_Prop_Fail", "DLC_Dmod_Prop_Editor_Sounds", 0, 0, 1)
        return
    end

    TriggerServerEvent('wh-billing:faifattura', id, getPlayerJob(), reason, amount)
    ESX.ShowNotification(Config.language["invoice_accepted"], 'success')
    PlaySound(-1, "Lose_1st", "GTAO_FM_Events_Soundset", 0, 0, 1)
end)

RegisterNetEvent('wh-billing:OpenNUI')
AddEventHandler('wh-billing:OpenNUI', function(data)
    ExecuteCommand("e clipboard")
    lib.registerContext({
        id = 'fattura_singola',
        title = 'Gestisci Fattura',
        options = {
            {
                title = "Quantità: ".. (tostring(data.amount) or "Non Trovato"),
                icon = 'fas fa-dollar-sign',
            },
            {
                title = "Motivo: ".. (data.label or "Non Trovato"),
                icon = 'fas fa-file-lines',
            },
            {
                title = "Dipendente: " .. (data.fatturatore or "Non Trovato"),
                icon = 'fas fa-user-tie',
            },
            {
                title = "Società: " .. (data.azienda or "Non Trovato"),
                icon = 'fas fa-briefcase',
            },
            {
                title = 'Paga',
                icon = 'fas fa-credit-card',
                onSelect = function()
                    local method =  lib.inputDialog('Fattura',{
                        { type = 'select', label = 'Metodo di pagamento', options = {
                            { value = 'money', label = 'Contanti'},
                            { value = 'bank', label = 'Banca' },
                        }}
                    })
    
                    if method and method[1] then
                        TriggerServerEvent('wh-billing:pagafattura', data, method[1])
                        local success = lib.callback.await('wh-billing:pagafattura')
                        if success then
			                ExecuteCommand('me ~g~Ha pagato una fattura di: $' .. data.amount)
                        else
                            ExecuteCommand('me ~r~Non ha pagato la fattura di: $' .. data.amount)
                        end
                        ExecuteCommand('e c')
                    else
                        ESX.ShowNotification('Hai annullato il pagamento della fattura!', 'error')
                        ExecuteCommand('e c')
                    end
                end
            }
        }
    })

    lib.showContext("fattura_singola") 

    while true do 
        Wait(0)
        if not lib.getOpenContextMenu() then
            ExecuteCommand('e c')
            break
        end
    end
end)

-- Citizen.CreateThread(function ()
--     local options = {
--         {
--             name = 'wh-billing:ApriMenuFatture',
--             event = 'wh-billing:ApriMenuFatture',
--             icon = 'fas fa-file-invoice-dollar',
--             label = 'Fattura'
--         },
--     }
--     exports.ox_target:addGlobalPlayer(options)
-- end)
