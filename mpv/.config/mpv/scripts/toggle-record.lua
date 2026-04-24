local mp = require 'mp'
local utils = require 'mp.utils'

local recording = false
local current_file = nil

local function sanitize_filename(name)
    return name:gsub('[\\/:*?"<>|]', "_")
end

local function get_output_path()
    local title = mp.get_property("media-title") or "recording"
    title = sanitize_filename(title)

    -- local dir = mp.command_native({ "expand-path", "~~home/screencast" })
	local dir = "/home/loaay/screencast/"
	utils.subprocess({
        args = { "mkdir", "-p", dir }
    })

    local timestamp = os.date("%Y-%m-%d_%H-%M-%S")
    return string.format("%s/%s_%s.mkv", dir, title, timestamp)
end

local function toggle_record()
    if not recording then
        current_file = get_output_path()
        mp.set_property("stream-record", current_file)
        recording = true
        mp.osd_message("● Recording started")
    else
        mp.set_property("stream-record", "")
        recording = false
        mp.osd_message("■ Recording stopped")
    end
end

mp.register_script_message("toggle-record", toggle_record)
