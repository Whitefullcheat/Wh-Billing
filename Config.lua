Config = {}

Config.defaultReasons = {

    --[[
        [JobName] = {default = 'Guida pericolosa', otherReasons = {'Eccesso limite di velocità', 'Rapina in banca', 'Omicidio'}}, -- FDO
        [JobName] = {default = "Cibo e bevande", otherReasons = {'Cibo e bevande', 'Cibo', 'Bevande'}}, -- Bars/Restaurant
        [JobName] = {default = "Vendita Auto", otherReasons = {'Vendita Moto'}, {'Vendita Auto'}}, --Car Dealer
        [JobName] = {default = 'Rimozione veicolo', otherReasons = {}}, -- Impound
        [JobName] = {default = 'Soccorso stradale', otherReasons = {'Cure mediche', 'Bende', 'Visita medica'}}, -- EMS
        [JobName] = {default = "Kit Cibo", otherReasons = {'Kit Drink', 'Tessuto', 'Pezzo Arma'}}, --Import
        [JobName] = {default = "Tasse", otherReasons = {'Tasse', 'Attività'}}, --IRS
        [JobName] = {default = "Modifiche e Riparazione", otherReasons = {'Modifiche e Riparazione', 'Modifiche', 'Riparazione'}}, --Bennys
        [JobName] = {default = 'Vendita Sigarette', otherReasons = {}}, -- smoke shop
        [JobName] = {default = 'Vendita Pistola 9mm', otherReasons = {}}, -- Ammunation
        [JobName] = {default = 'Vendita Casa', otherReasons = {}}, --estate agency
    ]]
    ['galaxy'] = {default = "Cibo e bevande", otherReasons = {'Cibo e bevande', 'Cibo', 'Bevande'}}, -- Bars/Restaurant
}

Config.Item = {
    name = 'fattura' -- name of the bill item
}

Config.Account = {
    bank = 'bank',
    money = 'money',
    remove = 'bank' -- can be a custom value, thats the where the money get removed when the player receives a fine.
}

Fine = {
    CanDoFine = { -- jobs that can send an automatic bill (money get removed from the player when the bill is sent)
        'police',
        'ambulance',
    }
}

Bill = {
    CanDoBill = { -- jobs that can send bill
        'galaxy'
    },

    CanOpenMenu = { -- jobs that can open the billing menu
        'galaxy'
    }
}

Config.language = {

    ['customer_id'] = "Numero del cliente",
    ['player_server_id'] = "(ID del giocatore)",
    ['include_jobname'] = "Aggingi il nome della società nella fattura",
    ['invoice'] = "Fattura",
    ['amount'] = "Importo",
    ['reason'] = "Motivo",
    ['invoice_amount'] = "Importo fattura",
    ['invoice_reason'] = "Motivo della fattura",
    ['premade'] = "Frequenti",
    ['create_invoice'] = "Invia fattura",
    ['invoice_accepted'] = "La fattura è stata firmata",
    ['invoice_not_accepted'] = "La fattura è stata strappata",
    ['not_enabled'] = "Non sei abilitato a fare fatture!",
    ['want_sign'] = "Vuoi firmare la fattura?",
    ['not_enough_money'] = "Non hai abbastanza soldi!",
    ['lib_menu_title'] = "Billing Menu",
    ['lib_menu_bill'] = "Bill",
}
