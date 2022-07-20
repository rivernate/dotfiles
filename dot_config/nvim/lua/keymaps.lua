vim.g.mapleader = " "

local key_mapper = function(mode, key, result)
  vim.api.nvim_set_keymap(
    mode,
    key,
    result,
    {noremap = true, silent = true}
  )
end

-- Disable Arrow Keys
key_mapper("", "<up>", "<nop>")
key_mapper("", "<down>", "<nop>")
key_mapper("", "<left>", "<nop>")
key_mapper("", "<right>", "<nop>")

-- Setup 'jk' as a shortcut for ESC
key_mapper("i", "jk", "<ESC>")
key_mapper("i", "JK", "<ESC>")
key_mapper("i", "jK", "<ESC>")
key_mapper("v", "jk", "<ESC>")
key_mapper("v", "JK", "<ESC>")
key_mapper("v", "jK", "<ESC>")

-- Telescope keymaps
key_mapper('n', '<C-p>', ':lua require"telescope.builtin".find_files()<CR>')
key_mapper('n', '<leader>fs', ':lua require"telescope.builtin".live_grep()<CR>')
key_mapper('n', '<leader>fh', ':lua require"telescope.builtin".help_tags()<CR>')
key_mapper('n', '<leader>fb', ':lua require"telescope.builtin".buffers()<CR>')

