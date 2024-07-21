fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name "wh-billing"
description "Billing System with ox lib menu"
author "Whitefullcheat"
version "1.0"

shared_scripts {
  'config.lua',
	'@es_extended/imports.lua',
	'@ox_lib/init.lua',
}

client_scripts {
	'@es_extended/locale.lua',
	'client/*.lua'
}

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'@es_extended/locale.lua',
	'server/*.lua'
}
