local config = {
  mappings = {
    n = {
      ["<C-s>"] = { ":w!<cr>", desc = "Save File" },
      ["<S-Left>"] = { "<cmd>bp<cr>", desc = "Previous Tab" },
      ["<S-Right>"] = { "<cmd>bn<cr>", desc = "Next Tab" },
    },
    i = {
      ["<C-s>"] = { "<cmd>w!<cr><esc>", desc = "Save File" },
      ["<S-Left>"] = { "<cmd>bp<cr>", desc = "Previous Tab" },
      ["<S-Right>"] = { "<cmd>bn<cr>", desc = "Next Tab" },
    },
  },

  plugins = {
    { "ojroques/nvim-osc52" },
  },
  polish = function()
    vim.keymap.set('n', '<leader>c', require('osc52').copy_operator, { expr = true })
    vim.keymap.set('n', '<leader>cc', '<leader>c_', { remap = true })
    vim.keymap.set('x', '<leader>c', require('osc52').copy_visual)

    vim.cmd([[
        " set tabstop=2 shiftwidth=2
        " autocmd FileType python set shiftwidth=2 tabstop=2 expandtab
        " let g:python_recommended_style = 0
        set whichwrap+=<,>,h,l,[,]
          
        autocmd BufReadPost *
             \ if line("'\"") > 0 && line("'\"") <= line("$") |
             \   exe "normal! g`\"" |
             \ endif
        ]])
    vim.filetype.add {
      filename = {
        ["Makefile.jobs"] = "make",
      },
    }
  end,
}

return config
