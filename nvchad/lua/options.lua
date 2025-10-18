require "nvchad.options"

local o = vim.o
local opt = vim.opt

o.autoindent = true
o.autoread = true
opt.backspace = {
  "indent",
  "eol",
  "start",
}
o.backup = false

opt.breakindent = true
opt.breakindentopt = { "sbr" }
o.showbreak = "↪"

o.cdhome = true
o.cmdheight = 1
opt.completeopt = {
  "fuzzy",
  "menuone",
  "noselect",
  "popup",
}
opt.concealcursor = { ["v"] = true }
o.confirm = true
o.cursorline = true
opt.cursorlineopt = { "number", "screenline" }
opt.diffopt = {
  "algorithm:minimal",
  "closeoff",
  "context:20",
  "followwrap",
  "internal",
  "linematch:40",
}
o.errorbells = true
o.expandtab = true
o.exrc = true
o.foldcolumn = "auto"
o.fsync = true
o.gdefault = false
opt.helplang = {
  "zh",
  "en",
}
o.history = 10000
o.hlsearch = true

o.ignorecase = true
o.smartcase = true

o.inccommand = "split"
o.list = true
opt.listchars = {
  tab = "--→",
  trail = "·",
  multispace = " ",
  nbsp = "⍽",
  space = "·",
}
o.magic = true
o.more = true
o.mouse = "a"

o.number = true
o.numberwidth = 4
o.relativenumber = true

o.scrollback = 100000
o.scrolloff = 5
o.shiftround = true
o.shiftwidth = 2
o.showmode = false
o.signcolumn = "yes"
o.smoothscroll = true
o.splitbelow = true
o.splitright = true
o.startofline = true
o.swapfile = false
opt.tabclose = {
  "uselast",
}
o.tabstop = 2
o.termguicolors = true
o.undofile = true
o.undolevels = 100000
opt.virtualedit = {
  "block",
  "onemore",
}
opt.whichwrap = { b = true, s = true, ["<"] = true, [">"] = true }
o.wildmenu = true
opt.wildmode = { "full" }
opt.wildoptions = {
  "fuzzy",
  "pum",
}
o.winborder = "solid"
o.wrap = true
