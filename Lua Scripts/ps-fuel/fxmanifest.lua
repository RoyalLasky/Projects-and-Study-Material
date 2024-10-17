fx_version 'cerulean'
game 'gta5'

description 'ps-fuel'
version '1.0'
author 'github.com/Project-Sloth'

escrow_ignore {
	'**',
}

client_scripts {
    '@PolyZone/client.lua',
	'client/client.lua',
	'client/utils.lua'
}

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'server/server.lua'
}

shared_scripts {
	'@qb-core/shared/locale.lua',
	'locales/en.lua',
	-- 'locales/de.lua',
	'shared/config.lua',
}

exports {
	'GetFuel',
	'SetFuel'
}

lua54 'yes'

dependency '/assetpacks'