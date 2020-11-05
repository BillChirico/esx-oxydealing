resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

description 'Oxy Dealing'

version '1.0.0-beta'

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'@es_extended/locale.lua',
	'config.lua',
	'server/main.lua'
}

client_scripts {
	'@es_extended/locale.lua',
	'config.lua',
	'client/main.lua',
	'client/functions.lua'
}

dependencies {
	'es_extended'
}
