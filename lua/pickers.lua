local telescope_utils = require("telescope.utils")
local pickers = require("telescope.pickers")
local telescope_config = require("telescope.config").values

local actions = require("actions")
local previewers = require("previewers")
local finders = require("finders")

local M = {}

M.git_signs = function(opts)
    opts = opts or {}

    local finder = finders.generate_buffer_finder(opts)

    if not finder then
        telescope_utils.notify("git_signs", {
            msg = "No git hunks found",
            level = "INFO",
        })
        return
    end

    pickers
        .new(opts, {
            prompt_title = "Git Hunks",
            finder = finder,
            sorter = telescope_config.generic_sorter(opts),
            previewer = previewers.gitsign_previewer(opts),
            attach_mappings = function(_, map)
                map("i", "<C-d", actions.git_reset)
                map("n", "dd", actions.git_reset)
                map("n", "cc", actions.git_stage)

                return true
            end,
        })
        :find()
end

return M
