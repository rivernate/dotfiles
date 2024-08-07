-- luacheck: globals vim

local Remap = require("rivernate.keymap")
local nnoremap = Remap.nnoremap
local inoremap = Remap.inoremap

-- mason needs to be stup order is: mason, mason-lspconfig, lspconfig
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
  automatic_installation = false,
})
require("mason-null-ls").setup({
  automatic_installation = false,
  handlers = {}
})
require("null-ls").setup({})

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

local cmp = require("cmp")
local source_mapping = {
  buffer = "[Buffer]",
  nvim_lsp = "[LSP]",
  nvim_lua = "[Lua]",
  path = "[Path]",
}
local lspkind = require("lspkind")

cmp.setup({
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-y'] = cmp.mapping.confirm({ select = true }),
    ["<C-u>"] = cmp.mapping.scroll_docs(-4),
    ["<C-d>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(),
  }),
  formatting = {
    format = function(entry, vim_item)
      vim_item.kind = lspkind.presets.default[vim_item.kind]
      local menu = source_mapping[entry.source.name]
      vim_item.menu = menu
      return vim_item
    end,
  },
  sources = {
    { name = "nvim_lsp" },
    { name = "luasnip" },
    { name = "buffer" },
  },
})

local function config(config_)
  return vim.tbl_deep_extend("force", {
    capabilities = require("cmp_nvim_lsp").default_capabilities(),
    on_attach = function()
      nnoremap("gd", function() vim.lsp.buf.definition() end)
      nnoremap("gD", function() vim.lsp.buf.declaration() end)
      nnoremap("gT", function() vim.lsp.buf.type_definition() end)
      nnoremap("gi", function() vim.lsp.buf.implementation() end)
      nnoremap("K", function() vim.lsp.buf.hover() end)
      nnoremap("<leader>f", function() vim.lsp.buf.format() end)
      nnoremap("<leader>vws", function() vim.lsp.buf.workspace_symbol() end)
      nnoremap("<leader>vd", function() vim.diagnostic.open_float() end)
      nnoremap("<leader>dl", function() require('telescope.builtin').diagnostics() end)
      nnoremap("[d", function() vim.diagnostic.goto_next() end)
      nnoremap("]d", function() vim.diagnostic.goto_prev() end)
      nnoremap("<leader>vca", function() vim.lsp.buf.code_action() end)
      nnoremap("<leader>vco", function()
        vim.lsp.buf.code_action({
          filter = function(code_action)
            if not code_action or not code_action.data then
              return false
            end
            local data = code_action.data.id
            return string.sub(data, #data - 1, #data) == ":0"
          end,
          apply = true
        })
      end)
      nnoremap("<leader>vrr", function() vim.lsp.buf.references() end)
      nnoremap("<leader>vrn", function() vim.lsp.buf.rename() end)
      inoremap("<C-h>", function() vim.lsp.buf.signature_help() end)
    end,
    lsp_flags = {
      debounce_text_changes = 150
    }
  }, config_ or {})
end


local runtime_path = vim.split(package.path, ";")
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")

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

local lspconfig = require("lspconfig")
require("mason-lspconfig").setup_handlers({
  -- The first entry (without a key) will be the default handler
  -- and will be called for each installed server that doesn't have
  -- a dedicated handler.
  function(server_name) -- default handler (optional)
    lspconfig[server_name].setup(config())
  end,
  -- Next, you can provide targeted overrides for specific servers.
  ["gopls"] = function()
    lspconfig.gopls.setup(config({
      settings = {
        gopls = {
          analyses = {
            unusedparams = true,
          },
          staticcheck = true,
          env = gopls_env,
          directoryFilters = {
            "-bazel-bin",
            "-bazel-out",
            "-bazel-testlogs",
            "-bazel-mypkg",
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
            -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
            version = "LuaJIT",
            path = runtime_path,
          },
          diagnostics = {
            -- Get the language server to recognize the `vim` global
            globals = {
              "vim",
              "use",
            }
          },
          workspace = {
            -- Make the server aware of Neovim runtime files
            library = vim.api.nvim_get_runtime_file("", true),
          },
          telemetry = {
            -- Do not send telemetry data containing a randomized but unique identifier
            enable = false,
          },
        }
      },
    }))
  end,
  ["rust_analyzer"] = function()
    lspconfig.rust_analyzer.setup(config({
      settings = {
        ["rust_analyzer"] = {}
      }
    }))
  end,
  ["cssls"] = function()
    lspconfig.cssls.setup(config({
      settings = {
        css = {
          validate = true,
          lint = {
            unknownAtRules = "ignore"
          }
        },
        scss = {
          validate = true,
          lint = {
            unknownAtRules = "ignore"
          }
        },
        less = {
          validate = true,
          lint = {
            unknownAtRules = "ignore"
          }
        },
      },
    })
    )
  end,
  ["jsonls"] = function()
    lspconfig.jsonls.setup(config({
      settings = {
        json = {
          schemas = require('schemastore').json.schemas(),
          validate = { enable = true },
        },
      },
    }))
  end,
  ["yamlls"] = function()
    lspconfig.yamlls.setup(config({
      settings = {
        yaml = {
          keyOrdering = false,
        },
      },
    }))
  end,
})

local snippets_paths = function()
  local plugins = { "friendly-snippets" }
  local paths = {}
  local path
  local root_path = vim.env.HOME .. "/.vim/plugged/"
  for _, plug in ipairs(plugins) do
    path = root_path .. plug
    if vim.fn.isdirectory(path) ~= 0 then
      table.insert(paths, path)
    end
  end
  return paths
end

require("luasnip.loaders.from_vscode").lazy_load({
  paths = snippets_paths(),
  include = nil, -- Load all languages
  exclude = {},
})
