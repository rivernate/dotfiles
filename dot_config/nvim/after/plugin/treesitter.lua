require 'nvim-treesitter.configs'.setup {
  ensure_installed = { "bash", "c", "c_sharp", "clojure", "commonlisp", "cpp",
    "css", "dockerfile", "gitignore", "go", "haskell",  "html", "java",
    "javascript", "json", "lua", "make", "markdown", "proto", "python", "ruby",
    "rust", "scala", "toml", "tsx", "typescript", "vim", "vimdoc", "yaml"
  },
  sync_install = false,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
}
