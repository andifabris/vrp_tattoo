client_script "@vrp/lib/lib.lua" --Para remover esta pendencia de todos scripts, execute no console o comando "uninstall"

fx_version 'adamant'
game 'gta5'

dependencies 'vrp'

ui_page 'nui/index.html'
files {
    'nui/*',
    'nui/**/*',
    'nui/**/*/*',
    'addons/*/*',
    -- 'streams/*'
}
 
server_scripts{
    "@vrp/lib/utils.lua",
    "config.lua",
    "server.lua"
}

client_script {
    "@vrp/lib/utils.lua",
    "client.lua"
}

data_file 'TATTOO_SHOP_DLC_FILE' 'addons/mpheist3/shop_tattoo.meta'
data_file 'PED_OVERLAY_FILE' 'addons/mpheist3/mpheist3_overlays.xml'
data_file 'TATTOO_SHOP_DLC_FILE' 'addons/mpvinewood/shop_tattoo.meta'
data_file 'PED_OVERLAY_FILE' 'addons/mpvinewood/mpvinewood_overlays.xml'
data_file 'TATTOO_SHOP_DLC_FILE' 'addons/mpheist4/shop_tattoo.meta'
data_file 'PED_OVERLAY_FILE' 'addons/mpheist4/mpheist4_overlays.xml'
              