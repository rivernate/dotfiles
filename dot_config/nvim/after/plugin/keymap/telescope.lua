local Remap = require("rivernate.keymap")
local nnoremap = Remap.nnoremap

nnoremap("<C-p>", ":Telescope")
nnoremap("<leader>ps", ":lua require('telescope.builtin').live_grep()<CR>")
nnoremap("<C-p>", ":lua require('telescope.builtin').git_files()<CR>")
nnoremap("<Leader>pf", ":lua require('telescope.builtin').find_files()<CR>")

nnoremap("<leader>pw", ":lua require('telescope.builtin').grep_string { search = vim.fn.expand(\"<cword>\") }<CR>")
nnoremap("<leader>pb", ":lua require('telescope.builtin').buffers()<CR>")
nnoremap("<leader>vh", ":lua require('telescope.builtin').help_tags()<CR>")
