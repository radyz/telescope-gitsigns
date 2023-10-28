local from_entry = require("telescope.from_entry")
local conf = require("telescope.config").values
local buffer_previewer = require("telescope.previewers.buffer_previewer")
local core = require("core")

local M = {}

local ns = vim.api.nvim_create_namespace("telescope_gitsigns")

local function inject_diff(bufnr, entry)
    local hunk = entry.value.hunk
    local diff_line_start = hunk.added.start - 1

    local diff, highlights = core.partition_linesspec({
        unpack(core.linespec_for_hunk(entry.value.hunk, vim.bo[entry.value.bufnr].fileformat)),
    })

    vim.api.nvim_buf_set_lines(bufnr, diff_line_start, hunk.vend, false, diff)

    for _, hl in ipairs(highlights) do
        local start_row = diff_line_start + hl.start_row
        local end_row = hl.end_row and (diff_line_start + hl.end_row) or nil

        local ok, err = pcall(vim.api.nvim_buf_set_extmark, bufnr, ns, start_row, hl.start_col or 0, {
            hl_group = hl.hl_group,
            end_row = end_row,
            end_col = hl.end_col,
            hl_eol = true,
        })

        if not ok then
            error(vim.inspect(hl) .. "\n" .. err)
        end
    end
end

local function jump_to_line(bufnr, winid, entry)
    vim.schedule(function()
        pcall(vim.api.nvim_win_set_cursor, winid, { entry.value.hunk.added.start, 0 })

        vim.api.nvim_buf_call(bufnr, function()
            vim.cmd("norm! zz")
        end)
    end)
end

M.gitsign_previewer = function(opts)
    opts = opts or {}

    return buffer_previewer.new_buffer_previewer({
        title = "Git signs preview",
        get_buffer_by_name = function(_, entry)
            return entry.value
        end,
        define_preview = function(self, entry)
            local p = from_entry.path(entry, true)
            if p == nil or p == "" then
                return
            end

            conf.buffer_previewer_maker(p, self.state.bufnr, {
                bufname = self.state.bufname,
                winid = self.state.winid,
                preview = opts.preview,
                callback = function(bufnr)
                    inject_diff(bufnr, entry)
                    jump_to_line(bufnr, self.state.winid, entry)
                end,
                file_encoding = opts.file_encoding,
            })
        end,
    })
end

return M
