-- luacheck: globals vim

-- Key mappings
local Remap = require("rivernate.keymap")
local nnoremap = Remap.nnoremap
local inoremap = Remap.inoremap

-- Mason Setup
-- The order of setup is: mason, mason-lspconfig, lspconfig
require("mason").setup({
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗",
    },
  },
})
require("mason-lspconfig").setup({
  automatic_installation = false,
})
require("mason-null-ls").setup({
  automatic_installation = false,
  handlers = {},
})
require("null-ls").setup({})

-- LSP Capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

-- Completion (nvim-cmp) Setup
local cmp = require("cmp")
local lspkind = require("lspkind")
local source_mapping = {
  buffer = "[Buffer]",
  nvim_lsp = "[LSP]",
  nvim_lua = "[Lua]",
  path = "[Path]",
}

cmp.setup({
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-y>"] = cmp.mapping.confirm({ select = true }),
    ["<C-u>"] = cmp.mapping.scroll_docs(-4),
    ["<C-d>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(),
  }),
  formatting = {
    format = function(entry, vim_item)
      vim_item.kind = lspkind.presets.default[vim_item.kind]
      vim_item.menu = source_mapping[entry.source.name]
      return vim_item
    end,
  },
  sources = {
    { name = "nvim_lsp" },
    { name = "luasnip" },
    { name = "buffer" },
  },
})

-- LSP Configuration Helper
local function config(config_)
  return vim.tbl_deep_extend("force", {
    capabilities = require("cmp_nvim_lsp").default_capabilities(),
    on_attach = function()
      -- Key mappings for LSP
      nnoremap("gd", vim.lsp.buf.definition)
      nnoremap("gD", vim.lsp.buf.declaration)
      nnoremap("gT", vim.lsp.buf.type_definition)
      nnoremap("gi", vim.lsp.buf.implementation)
      nnoremap("K", vim.lsp.buf.hover)
      nnoremap("<leader>f", vim.lsp.buf.format)
      nnoremap("<leader>vws", vim.lsp.buf.workspace_symbol)
      nnoremap("<leader>vd", vim.diagnostic.open_float)
      nnoremap("<leader>dl", require("telescope.builtin").diagnostics)
      nnoremap("[d", vim.diagnostic.goto_next)
      nnoremap("]d", vim.diagnostic.goto_prev)
      nnoremap("<leader>vca", vim.lsp.buf.code_action)
      nnoremap("<leader>vrr", vim.lsp.buf.references)
      nnoremap("<leader>vrn", vim.lsp.buf.rename)
      inoremap("<C-h>", vim.lsp.buf.signature_help)
    end,
    lsp_flags = {
      debounce_text_changes = 150,
    },
  }, config_ or {})
end

-- LSP Servers Configuration
local lspconfig = require("lspconfig")
require("mason-lspconfig").setup_handlers({
  function(server_name) -- Default handler
    lspconfig[server_name].setup(config())
  end,
  ["gopls"] = function()
    lspconfig.gopls.setup(config({
      settings = {
        gopls = {
          analyses = { unusedparams = true },
          staticcheck = true,
          env = {
            GOPACKAGESDRIVER = './tools/gopackagesdriver.sh',
          },
          directoryFilters = {
            "-bazel-bin",
            "-bazel-out",
            "-bazel-testlogs",
          },
        },
      },
    }))
  end,
  ["lua_ls"] = function()
    lspconfig.lua_ls.setup(config({
      settings = {
        Lua = {
          runtime = {
            version = "LuaJIT",
            path = vim.split(package.path, ";"),
          },
          diagnostics = { globals = { "vim", "use" } },
          workspace = {
            library = vim.api.nvim_get_runtime_file("", true),
          },
          telemetry = { enable = false },
        },
      },
    }))
  end,
  ["rust_analyzer"] = function()
    lspconfig.rust_analyzer.setup(config({
      settings = {
        ["rust_analyzer"] = {
          procMacro = {
            ignored = {
              leptos_macro = { "component", "server" },
            },
          },
        },
      },
    }))
  end,
  ["cssls"] = function()
    lspconfig.cssls.setup(config({
      settings = {
        css = { validate = true, lint = { unknownAtRules = "ignore" } },
        scss = { validate = true, lint = { unknownAtRules = "ignore" } },
        less = { validate = true, lint = { unknownAtRules = "ignore" } },
      },
    }))
  end,
  ["jsonls"] = function()
    lspconfig.jsonls.setup(config({
      settings = {
        json = {
          schemas = require("schemastore").json.schemas(),
          validate = { enable = true },
        },
      },
    }))
  end,
  ["yamlls"] = function()
    lspconfig.yamlls.setup(config({
      settings = {
        yaml = { keyOrdering = false },
      },
    }))
  end,
})

-- Snippet Loader
local function snippets_paths()
  local plugins = { "friendly-snippets" }
  local paths = {}
  for _, plug in ipairs(plugins) do
    local path = vim.env.HOME .. "/.vim/plugged/" .. plug
    if vim.fn.isdirectory(path) ~= 0 then
      table.insert(paths, path)
    end
  end
  return paths
end

require("luasnip.loaders.from_vscode").lazy_load({
  paths = snippets_paths(),
})
