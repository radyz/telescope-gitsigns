local action_state = require("telescope.actions.state")
local actions = require("gitsigns.actions")

local finders = require("finders")

local M = {}

M.git_reset = function(prompt_bufnr)
    local current_picker = action_state.get_current_picker(prompt_bufnr)

    current_picker:delete_selection(function(selection)
        local hunk = selection.value.hunk

        vim.api.nvim_buf_call(selection.value.bufnr, function()
            actions.reset_hunk({ hunk.added.start, hunk.vend })
        end)

        -- Note. Haven't found any other way to get up to date results from the buffer
        -- cache after resetting a hunk other than setting a timeout for cache to get
        -- refreshed.
        vim.defer_fn(function()
            current_picker:refresh(
                finders.generate_buffer_finder({ bufnr = selection.value.bufnr }),
                { reset_prompt = true }
            )
        end, 300)
    end)
end

M.git_stage = function(prompt_bufnr)
    local current_picker = action_state.get_current_picker(prompt_bufnr)

    current_picker:delete_selection(function(selection)
        local hunk = selection.value.hunk

        vim.api.nvim_buf_call(selection.value.bufnr, function()
            actions.stage_hunk({ hunk.added.start, hunk.vend })
        end)
    end)
end

return M
