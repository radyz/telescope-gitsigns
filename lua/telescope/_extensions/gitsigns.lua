local pickers = require("pickers")

return require("telescope").register_extension({
    exports = {
        gitsigns = pickers.gitsigns,
    },
})
