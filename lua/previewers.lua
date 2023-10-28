local utils = require("telescope.previewers.utils")
local buffer_previewer = require("telescope.previewers.buffer_previewer")
local core = require("core")

local M = {}

local ns = vim.api.nvim_create_namespace("telescope_gitsigns")

M.gitsign_previewer = function(opts)
    opts = opts or {}

    return buffer_previewer.new_buffer_previewer({
        title = "Git signs preview",
        get_buffer_by_name = function(_, entry)
            return entry.value
        end,
        define_preview = function(self, entry)
            local hunk = entry.value.hunk

            local diff, highlights = core.partition_linesspec({
                unpack(core.linespec_for_hunk(entry.value.hunk, vim.bo[entry.value.bufnr].fileformat)),
            })

            local diff_line_start = hunk.added.start - 1

            local lines = vim.api.nvim_buf_get_lines(entry.value.bufnr, 0, -1, false)
            vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
            utils.highlighter(self.state.bufnr, vim.bo[entry.value.bufnr].filetype)
            vim.api.nvim_buf_set_lines(self.state.bufnr, diff_line_start, hunk.vend, false, diff)

            for _, hl in ipairs(highlights) do
                local start_row = diff_line_start + hl.start_row
                local end_row = hl.end_row and (diff_line_start + hl.end_row) or nil

                local ok, err =
                    pcall(vim.api.nvim_buf_set_extmark, self.state.bufnr, ns, start_row, hl.start_col or 0, {
                        hl_group = hl.hl_group,
                        end_row = end_row,
                        end_col = hl.end_col,
                        hl_eol = true,
                    })

                if not ok then
                    error(vim.inspect(hl) .. "\n" .. err)
                end
            end

            vim.schedule(function()
                pcall(vim.api.nvim_win_set_cursor, self.state.winid, { diff_line_start, 0 })

                vim.api.nvim_buf_call(self.state.bufnr, function()
                    vim.cmd("norm! zz")
                end)
            end)
        end,
    })
end

return M
