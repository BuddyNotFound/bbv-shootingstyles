fx_version 'cerulean'
game 'gta5'

description 'bbv-shootingstyles'
version '1.0.0'

client_scripts {
    'main.lua',
}

lua54 'yes'

ui_page('html/index.html')
      
files {
    'html/index.html',
    'html/app.js',
    'html/style.css',
}

shared_scripts {
    'config.lua',
}
