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
local mason_lspconfig = require("mason-lspconfig")
mason_lspconfig.setup({
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

local gopls_env = {}
local gopackagesdriver_path = './tools/gopackagesdriver.sh'

local function file_exists(path)
  local file = io.open(path, "r")
  if file then
    file:close()
    return true
  else
    return false
  end
end

-- Check if the GOPACKAGESDRIVER file exists
if file_exists(gopackagesdriver_path) then
  gopls_env.GOPACKAGESDRIVER = gopackagesdriver_path
end

-- LSP Servers Configuration
local lspconfig = require("lspconfig")

-- Per-server setup functions:
local handlers = {
  -- gopls: custom settings + env + directoryFilters
  ["gopls"] = function()
    lspconfig.gopls.setup(config({
      settings = {
        gopls = {
          analyses = { unusedparams = true },
          staticcheck = true,
          env = gopls_env,
          directoryFilters = {
            "-bazel-bin",
            "-bazel-out",
            "-bazel-testlogs",
          },
        },
      },
    }))
  end,

  -- lua_ls: runtime, diagnostics, workspace library, telemetry off
  ["lua_ls"] = function()
    lspconfig.lua_ls.setup(config({
      settings = {
        Lua = {
          runtime = {
            version = "LuaJIT",
            path = vim.split(package.path, ";"),
          },
          diagnostics = {
            globals = { "vim", "use" },
          },
          workspace = {
            library = vim.api.nvim_get_runtime_file("", true),
          },
          telemetry = {
            enable = false,
          },
        },
      },
    }))
  end,

  -- rust_analyzer: procMacro ignores for certain macros
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

  -- cssls: validate + lint / unknownAtRules=ignore
  ["cssls"] = function()
    lspconfig.cssls.setup(config({
      settings = {
        css =  { validate = true, lint = { unknownAtRules = "ignore" } },
        scss = { validate = true, lint = { unknownAtRules = "ignore" } },
        less = { validate = true, lint = { unknownAtRules = "ignore" } },
      },
    }))
  end,

  -- jsonls: hook up schemastore + enable validation
  ["jsonls"] = function()
    lspconfig.jsonls.setup(config({
      settings = {
        json = {
          schemas  = require("schemastore").json.schemas(),
          validate = { enable = true },
        },
      },
    }))
  end,

  -- yamlls: turn off key ordering check
  ["yamlls"] = function()
    lspconfig.yamlls.setup(config({
      settings = {
        yaml = { keyOrdering = false },
      },
    }))
  end,
}

-- Default handler: any installed server not in `handlers` falls back here.
local function default_handler(server_name)
  lspconfig[server_name].setup(config())
end

-- Loop over all installed servers and invoke the correct function:
for _, server_name in ipairs(mason_lspconfig.get_installed_servers()) do
  if handlers[server_name] then
    handlers[server_name]()
  else
    default_handler(server_name)
  end
end

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
