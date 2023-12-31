# telescope-gitsigns

Provides a picker to view all hunks in the current buffer. Two actions are provided to
either `reset` or `stage` a hunk (`?` to view all available mappings).

![image](https://github.com/radyz/telescope-gitsigns/assets/1755599/89b71ad0-f909-456c-9599-102a792808e6)

## Requirements

- [GitSigns](https://github.com/lewis6991/gitsigns.nvim)
- [Telescope](https://github.com/nvim-telescope/telescope.nvim)

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
require("gitsigns").setup({
  -- This isn't required, but goes to show that selection list signs are being grabbed
  -- from `gitsigns` opts table to get a uniform experience.
  signs = {
    add = { text = "| "}
    ...
  }
})

require("telescope").setup({})

-- To get telescope-gitsigns loaded and working with telescope, you need to call
-- load_extension, somewhere after setup function:
require("telescope").load_extension("git_signs")
```

## Usage

```viml
:Telescope git_signs
```
