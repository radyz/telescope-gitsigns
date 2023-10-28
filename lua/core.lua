local util = require("gitsigns.util")
local config = require("gitsigns.config").config

-- Gitsigns doesn't expose these functions so right now we are copying and pasting them
local M = {}

--- Taken as is directly from
--- https://github.com/lewis6991/gitsigns.nvim/blob/af0f583cd35286dd6f0e3ed52622728703237e50/lua/gitsigns/popup.lua#L64
--- @class (exact) Gitsigns.HlMark
--- @field hl_group string
--- @field start_row? integer
--- @field start_col? integer
--- @field end_row? integer
--- @field end_col? integer

--- Each element represents a multi-line segment
--- @alias Gitsigns.LineSpec { [1]: string, [2]: Gitsigns.HlMark[]}[][]

--- @param hlmarks Gitsigns.HlMark[]
--- @param row_offset integer
local function offset_hlmarks(hlmarks, row_offset)
    for _, h in ipairs(hlmarks) do
        h.start_row = (h.start_row or 0) + row_offset
        if h.end_row then
            h.end_row = h.end_row + row_offset
        end
    end
end

--- Taken as is directly from
--- https://github.com/lewis6991/gitsigns.nvim/blob/af0f583cd35286dd6f0e3ed52622728703237e50/lua/gitsigns/actions.lua#L634
--- @param hunk Gitsigns.Hunk.Hunk
--- @param fileformat string
--- @return Gitsigns.LineSpec
M.linespec_for_hunk = function(hunk, fileformat)
    local hls = {} --- @type Gitsigns.LineSpec

    local removed, added = hunk.removed.lines, hunk.added.lines

    for _, spec in ipairs({
        { sym = "-", lines = removed, hl = "GitSignsDeletePreview" },
        { sym = "+", lines = added, hl = "GitSignsAddPreview" },
    }) do
        for _, l in ipairs(spec.lines) do
            if fileformat == "dos" then
                l = l:gsub("\r$", "") --[[@as string]]
            end
            hls[#hls + 1] = {
                {
                    spec.sym .. l,
                    {
                        {
                            hl_group = spec.hl,
                            end_row = 1, -- Highlight whole line
                        },
                    },
                },
            }
        end
    end

    if config.diff_opts.internal then
        local removed_regions, added_regions = require("gitsigns.diff_int").run_word_diff(removed, added)

        for _, region in ipairs(removed_regions) do
            local i = region[1]
            table.insert(hls[i][1][2], {
                hl_group = "GitSignsDeleteInline",
                start_col = region[3],
                end_col = region[4],
            })
        end

        for _, region in ipairs(added_regions) do
            local i = hunk.removed.count + region[1]
            table.insert(hls[i][1][2], {
                hl_group = "GitSignsAddInline",
                start_col = region[3],
                end_col = region[4],
            })
        end
    end

    return hls
end

--- Taken as is directly from
--- https://github.com/lewis6991/gitsigns.nvim/blob/af0f583cd35286dd6f0e3ed52622728703237e50/lua/gitsigns/popup.lua#L77
--- Partition the text and Gitsigns.HlMarks from a Gitsigns.LineSpec
--- @param fmt Gitsigns.LineSpec
--- @return string[]
--- @return Gitsigns.HlMark[]
M.partition_linesspec = function(fmt)
    local lines = {} --- @type string[]
    local ret = {} --- @type Gitsigns.HlMark[]

    local row = 0
    for _, section in ipairs(fmt) do
        local section_text = {} --- @type string[]
        local col = 0
        for _, part in ipairs(section) do
            local text, hls = part[1], part[2]

            section_text[#section_text + 1] = text

            local _, no_lines = text:gsub("\n", "")
            local end_row = row + no_lines --- @type integer
            local end_col = no_lines > 0 and 0 or col + #text --- @type integer

            if type(hls) == "string" then
                ret[#ret + 1] = {
                    hl_group = hls,
                    start_row = row,
                    end_row = end_row,
                    start_col = col,
                    end_col = end_col,
                }
            else -- hl is Gitsigns.HlMark[]
                offset_hlmarks(hls, row)
                vim.list_extend(ret, hls)
            end

            row = end_row
            col = end_col
        end

        local section_lines = vim.split(table.concat(section_text), "\n", { plain = true })
        vim.list_extend(lines, section_lines)

        row = row + 1
    end

    return lines, ret
end

return M
