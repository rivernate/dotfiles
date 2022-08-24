local fn = vim.fn
local install_path = fn.stdpath("data").."/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system({"git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path})

  -- Ref: https://github.com/wbthomason/packer.nvim/issues/739#issuecomment-1019280631
  vim.o.runtimepath = vim.fn.stdpath('data') .. '/site/pack/*/start/*,' .. vim.o.runtimepath
end

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
  use {
    "bazelbuild/vim-bazel",
    requires = { {"google/vim-maktaba"} }
  }
  use "nvim-treesitter/nvim-treesitter"
  use "nvim-treesitter/nvim-treesitter-context"
  use "tpope/vim-fugitive" -- Git commands
  use "kyazdani42/nvim-web-devicons"
  use {
    "nvim-telescope/telescope.nvim",
    requires =  { {"nvim-lua/plenary.nvim" } }
  }
  use "gruvbox-community/gruvbox"
  use "prettier/vim-prettier"
  use 'neovim/nvim-lspconfig' -- Configurations for Nvim LSP
  use "williamboman/nvim-lsp-installer"
  use 'mfussenegger/nvim-jdtls'
end)
