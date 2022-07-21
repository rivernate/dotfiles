--from https://github.com/ThePrimeagen/.dotfiles/blob/a7e38d8febcba62d4b0f8dae637ce61d470c251f/nvim-lua-config/.config/nvim/lua/theprimeagen/keymap.lua
local M = {}

function bind(op, outer_opts)
    outer_opts = outer_opts or {noremap = true}
    return function(lhs, rhs, opts)
        opts = vim.tbl_extend("force",
            outer_opts,
            opts or {}
        )
        vim.keymap.set(op, lhs, rhs, opts)
    end
end

M.nmap = bind("n", {noremap = false})
M.nnoremap = bind("n")
M.vnoremap = bind("v")
M.xnoremap = bind("x")
M.inoremap = bind("i")

return M
