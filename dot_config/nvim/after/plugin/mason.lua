require("mason").setup({
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗"
    }
  }
})
require("mason-lspconfig").setup({
  ensure_installed = {
    "bashls", "cssls", "dockerls", "eslint", "gopls", "html", "jsonls",
    "jdtls", "tsserver", "sumneko_lua", "marksman", "pyright", "solargraph",
    "rust_analyzer", "sqlls", "taplo", "terraformls", "lemminx", "yamlls"
  }
})
