local Remap = require("rivernate.keymap")
local nnoremap = Remap.nnoremap
local vnoremap = Remap.vnoremap
local inoremap = Remap.inoremap

require("codecompanion").setup({
  adapters = {
    openai = function()
      return require("codecompanion.adapters").extend("openai", {
        env = {
          api_key = "cmd:bw get notes 87bbdac0-5d65-4cc4-8b80-b24601355168",
        },
      })
    end,
  },
  display = {
    action_palette = {
      provider = "telescope",
    }
  }
})

nnoremap("<C-a>", "<cmd>CodeCompanionActions<cr>")
vnoremap("<C-a>", "<cmd>CodeCompanionActions<cr>")
nnoremap("<leader>a", "<cmd>CodeCompanionActions<cr>")
vnoremap("<leader>a", "<cmd>CodeCompanionActions<cr>")
vnoremap("ga", "<cmd>CodeCompanionChat Add<cr>")

-- Expand 'cc' into 'CodeCompanion' in the command line
vim.cmd([[cab cc CodeCompanion]])
