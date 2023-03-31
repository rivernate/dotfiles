local Remap = require("rivernate.keymap")
local nnoremap = Remap.nnoremap

-- Search for PRs that need my review
local octoCRSearch = 'is:pr is:open involves:@me review-requested:@me draft:false -label:"on hold"'

nnoremap("<leader>gcr", ":Octo search " .. octoCRSearch .. "<CR>")
