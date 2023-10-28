# telescope-gitsigns

Provides a picker to view all hunks in the current buffer. Two actions are provided to
either `reset` or `stage` a hunk (`?` to view all available mappings).

![image](https://github.com/radyz/telescope-gitsigns/assets/1755599/2532ce66-a46f-4127-8e69-28b9e4465d17)

## Installation

The extension may be installed manually or with a plugin manager of choice.

An example using [Lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
require("lazy").setup({
    "radyz/telescope-gitsigns",
    dependencies = {
        "lewis6991/gitsigns.nvim",
        "nvim-telescope/telescope.nvim",
    }
})
```

## Telescope Setup and Configuration:

```lua
-- This is your opts table
require("telescope").setup({})
-- To get telescope-gitsigns loaded and working with telescope, you need to call
-- load_extension, somewhere after setup function:
require("telescope").load_extension("git_signs")
```

## Usage

```viml
:Telescope git_signs
```
