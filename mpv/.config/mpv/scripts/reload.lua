local msg = require 'mp.msg'

local function reload_resume()
    local pos = mp.get_property_number("time-pos")
    local path = mp.get_property("path")

    if not path or not pos then
        msg.warn("No path or position available")
        return
    end

    msg.info(string.format("Reloading stream, will seek to %.2f", pos))
    mp.commandv("loadfile", path, "replace")

    local function seek_on_load()
        mp.unregister_event("file-loaded", seek_on_load)
        mp.commandv("seek", tostring(pos), "absolute")
        mp.set_property("pause", "no")
    end

    mp.register_event("file-loaded", seek_on_load)
end

mp.add_key_binding(nil, "reload-resume", reload_resume)

