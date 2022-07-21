local Remap = require("rivernate.keymap")
local nnoremap = Remap.nnoremap
local vnoremap = Remap.vnoremap
local inoremap = Remap.inoremap
local xnoremap = Remap.xnoremap
local nmap = Remap.nmap

-- Disable Arrow Keys
nnoremap("<up>", "<nop>")
nnoremap("<down>", "<nop>")
nnoremap("<left>", "<nop>")
nnoremap("<right>", "<nop>")

inoremap("jk", "<ESC>")
inoremap("Jk", "<ESC>")
inoremap("jK", "<ESC>")
inoremap("JK", "<ESC>")
vnoremap("jk", "<ESC>")
vnoremap("JK", "<ESC>")
vnoremap("jK", "<ESC>")
vnoremap("JK", "<ESC>")
