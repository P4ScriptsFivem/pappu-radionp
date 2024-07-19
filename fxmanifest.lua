fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author "Pappu"
description "The Advance Pappu-RadioNp"
version "1.0.1"


shared_scripts {
	'shared/pappu.lua',
    'shared/config.lua'
}

client_scripts {
    'bridge/client/**.lua',
}

server_scripts {
    'bridge/server/**.lua',
}

ui_page 'nui/pappu.html'

files {
    'nui/*',
	'nui/pappu.html',
	'nui/style.css',
	'nui/index.js',
    'nui/files/*.png',
    'nui/files/*.jpg',
    'nui/fonts/*.ttf',
    'nui/fonts/*.otf'
}
