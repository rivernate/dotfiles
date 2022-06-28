require("plugins")

vim.opt.termguicolors = true
vim.opt.syntax = "on"
vim.opt.errorbells = false
vim.opt.smartcase = true
vim.opt.showmode = false
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = vim.fn.stdpath("config") .. "/undodir"
vim.opt.undofile = true
vim.opt.incsearch = true
vim.opt.hidden = true
vim.opt.scrolloff = 8
vim.opt.hlsearch = false
vim.opt.completeopt="menuone,noinsert,noselect"
vim.opt.colorcolumn = "80"

vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.expandtab = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"
vim.opt.wrap = false

vim.g.mapleader = " "

vim.cmd [[colorscheme gruvbox]]

local key_mapper = function(mode, key, result)
  vim.api.nvim_set_keymap(
    mode,
    key,
    result,
    {noremap = true, silent = true}
  )
end

key_mapper("", "<up>", "<nop>")
key_mapper("", "<down>", "<nop>")
key_mapper("", "<left>", "<nop>")
key_mapper("", "<right>", "<nop>")
key_mapper("i", "jk", "<ESC>")
key_mapper("i", "JK", "<ESC>")
key_mapper("i", "jK", "<ESC>")
key_mapper("v", "jk", "<ESC>")
key_mapper("v", "JK", "<ESC>")
key_mapper("v", "jK", "<ESC>")

key_mapper('n', '<C-p>', ':lua require"telescope.builtin".find_files()<CR>')
key_mapper('n', '<leader>fs', ':lua require"telescope.builtin".live_grep()<CR>')
key_mapper('n', '<leader>fh', ':lua require"telescope.builtin".help_tags()<CR>')
key_mapper('n', '<leader>fb', ':lua require"telescope.builtin".buffers()<CR>')
