vim.cmd [[packadd packer.nvim]]

vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerCompile
  augroup end
]])

return require("packer").startup(function()
  local use = use
  use "wbthomason/packer.nvim"
  use "nvim-treesitter/nvim-treesitter"
  use "tpope/vim-fugitive" -- Git commands
  use "kyazdani42/nvim-web-devicons"
  use {
    "nvim-telescope/telescope.nvim",
    requires =  { {"nvim-lua/plenary.nvim" } }
  }
  use "gruvbox-community/gruvbox"
  use "prettier/vim-prettier"
  use 'neovim/nvim-lspconfig' -- Configurations for Nvim LSP
end)

