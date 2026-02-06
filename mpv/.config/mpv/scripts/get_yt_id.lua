local mp = require 'mp'

local function copy_yt_id()
    local path = mp.get_property("path")
    if not path then return end

    local id = path:match("[?&]v=([%w_-]+)")
    if not id then
        id = path:match("youtu%.be/([%w_-]+)")
    end

    if not id then
        local filename = path:match("([^/\\]+)$") or path
        id = filename:match("%[([%w_-]+)%]")
    end

    local is_shorts = false
    if not id then
        id = path:match("youtube%.com/shorts/([%w_-]+)")
        is_shorts = true
    end

    if not id then
        mp.osd_message("No YouTube ID found")
        return
    end

    if not is_shorts then
        local cmd = "echo -n 'https://youtube.com/watch?v=" .. id .. "' | xclip -selection clipboard"
        os.execute(cmd)
        mp.osd_message("Copied https://youtube.com/watch?v=" .. id)
    else
        local cmd = "echo -n '" .. id .. "' | xclip -selection clipboard"
        os.execute(cmd)
        mp.osd_message("Copied " .. id)
    end
end

mp.add_key_binding(nil, "copy-yt-id", copy_yt_id)

