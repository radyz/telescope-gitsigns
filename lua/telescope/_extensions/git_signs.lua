local pickers = require("pickers")

return require("telescope").register_extension({
    exports = {
        git_signs = pickers.git_signs,
    },
})
