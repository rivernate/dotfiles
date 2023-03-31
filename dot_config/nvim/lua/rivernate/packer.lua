local fn = vim.fn
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system({
    "git",
    "clone",
    "--depth",
    "1",
    "https://github.com/wbthomason/packer.nvim",
    install_path,
  })

  -- Ref: https://github.com/wbthomason/packer.nvim/issues/739#issuecomment-1019280631
  vim.o.runtimepath = vim.fn.stdpath("data") .. "/site/pack/*/start/*," .. vim.o.runtimepath
end

vim.cmd([[packadd packer.nvim]])

vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerCompile
  augroup end
]])

return require("packer").startup(function()
  use("wbthomason/packer.nvim")

  -- DAP --
  use("mfussenegger/nvim-dap")
  use({ "leoluz/nvim-dap-go", requires = { { "mfussenegger/nvim-dap" } } })

  -- auto complete
  use("hrsh7th/cmp-nvim-lsp")
  use("hrsh7th/cmp-buffer")
  use("hrsh7th/nvim-cmp")
  use("L3MON4D3/LuaSnip")
  use("saadparwaiz1/cmp_luasnip")
  use("onsails/lspkind-nvim")
  use("simrat39/symbols-outline.nvim")
  use("github/copilot.vim")

  use({ "bazelbuild/vim-bazel", requires = { { "google/vim-maktaba" } } })
  use({
    "williamboman/mason-lspconfig.nvim",
    requires = {
      { "neovim/nvim-lspconfig" }, -- Configurations for Nvim LSP
      { "williamboman/mason.nvim" },
    },
  })
  use("williamboman/mason.nvim")
  use("jose-elias-alvarez/null-ls.nvim")
  use({
    "jay-babu/mason-null-ls.nvim",
    requires = {
      { "williamboman/mason.nvim" },
      { "jose-elias-alvarez/null-ls.nvim" },
    },
  })
  use("nvim-tree/nvim-web-devicons")
  use("nvim-treesitter/nvim-treesitter")
  use("nvim-treesitter/nvim-treesitter-context")
  use({
    "nvim-telescope/telescope.nvim",
    requires = { { "nvim-lua/plenary.nvim" } },
  })
  use("prettier/vim-prettier")
  use("neovim/nvim-lspconfig") -- Configurations for Nvim LSP
  use("mfussenegger/nvim-jdtls")
  use("b0o/schemastore.nvim")

  use({
    "pwntester/octo.nvim",
    requires = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "kyazdani42/nvim-web-devicons",
    },
    config = function()
      require("octo").setup()
    end,
  })

  -- THEMES--
  use("rktjmp/lush.nvim")

  use("gruvbox-community/gruvbox")
  use("Scysta/pink-panic.nvim")
  use("folke/tokyonight.nvim")
  use("haishanh/night-owl.vim")
  -- END THEMES--
end)
