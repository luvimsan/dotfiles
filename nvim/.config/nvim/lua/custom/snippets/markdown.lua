local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local f = ls.function_node
local i = ls.insert_node

local function get_date_info()
    local now = os.time()
    local one_day = 24 * 60 * 60
    local daily_dir = "6 - Journals/Daily/"

    return {
        week = os.date("%G-W%V"),
        yesterday_path = daily_dir .. os.date("%Y-%m-%d", now - one_day),
        yesterday_name = os.date("%A", now - one_day),
        tomorrow_path = daily_dir .. os.date("%Y-%m-%d", now + one_day),
        tomorrow_name = os.date("%A", now + one_day),
    }
end

ls.add_snippets("markdown", {

    s("d", {
        t({"---", "Week:", "  - "}),
        f(function() return get_date_info().week end),
        i(1),
        t({"", "📖Quran: false", "🌅Azkar_Sabah: false", "💻Coding: false", "💪PushUps: ", "📿Azkar_Masaa: false", "🕌Qyam_Ellyl: false", "🔁Consistency: false", "💤Sleep: ", "---"}),
        t({"", "## 🕌  Prayers", "", ""}),
        t({"| Prayer     | 👥 With Group | 👤Alone | ⏰ Late | 🌌 Nafila |", "| ---------- | ------------- | ------- | ------- | --------- |"}),
        t({"", "| 🌄 Fajr    |               |         |         |           |"}),
        t({"", "| ☀️ Dhuhr   |               |         |         |           |"}),
        t({"", "| 🌤 Asr     |               |         |         | ⬛        |"}),
        t({"", "| 🌇 Maghrib |               |         |         |           |"}),
        t({"", "| 🌙 Isha    |               |         |         |           |", ""}),

        t({"", "### Tasks", "", "- [ ] ", "", "---", "### Notes", "", "", "", "", "", ""}),

        t("### References"),
        f(function()
            local d = get_date_info()
            return { "", "[[" .. d.yesterday_path .. "|" .. d.yesterday_name .. "]]" }
        end),
        f(function()
            local d = get_date_info()
            return { "", "", "[[" .. d.tomorrow_path .. "|" .. d.tomorrow_name .. "]]" }
        end),
    }),

    s("m", {
        f(function()
            return os.date("%Y-%m-%d %H:%M")
        end),
        t({"", "Tags:", "", "# "}),
        f(function()
            return vim.fn.expand("%:t:r")
        end),
        t({"", "", ""}),
        i(1),
        t({"", "", "", "## References", "", ""}),
    })
})
