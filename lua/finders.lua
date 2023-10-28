local finders = require("telescope.finders")
local entry_display = require("telescope.pickers.entry_display")
local gitsign_cache = require("gitsigns.cache").cache
local gitsign_config = require("gitsigns.config").config

local M = {}

local entry_maker = function(entry)
    local hunk = entry.hunk
    local text = string.format("Lines %d-%d", hunk.added.start, hunk.vend)

    local displayer = entry_display.create({
        separator = "",
        items = {
            { width = 2 },
            { remaining = true },
        },
    })

    local make_display = function()
        local sign = gitsign_config.signs[hunk.type]

        return displayer({
            {
                sign.text,
                sign.hl,
            },
            text,
        })
    end

    return {
        value = entry,
        ordinal = text,
        display = make_display,
        lnum = hunk.added.start,
        filename = entry.filename,
    }
end

M.generate_buffer_finder = function(opts)
    opts = opts or {}
    local current_buf = opts.bufnr or vim.api.nvim_get_current_buf()
    local results = {}

    local bcache = gitsign_cache[current_buf]

    if bcache then
        local hunks = bcache.hunks

        for _, hunk in ipairs(hunks) do
            table.insert(results, {
                bufnr = current_buf,
                hunk = hunk,
            })
        end
    end

    if not vim.tbl_isempty(results) then
        return finders.new_table({
            results = results,
            entry_maker = entry_maker,
        })
    end
end

return M
