local mp = require 'mp'

local function copy_title()
    local title = mp.get_property("media-title")
    if not title then return end

    local cmd = "echo -n '" .. title:gsub("'", "'\\''") .. "' | xclip -selection clipboard"
    os.execute(cmd)

    mp.osd_message("Copied: " .. title)
end

mp.add_key_binding(nil, "copy-title", copy_title)

