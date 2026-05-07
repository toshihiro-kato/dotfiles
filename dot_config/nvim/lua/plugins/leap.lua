return {
  "ggandor/leap.nvim",
  dependencies = { "tpope/vim-repeat" },
  config = function()
    require("leap").setup({})
  end,
}
