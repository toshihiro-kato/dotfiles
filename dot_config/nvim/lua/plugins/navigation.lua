-- Navigation and search plugins
return {
  -- Hop
  {
    "phaazon/hop.nvim",
    branch = "v2",
    config = function()
      require('hop').setup({
        multi_windows = true
      })
    end,
  },

  -- Lightspeed
  "ggandor/lightspeed.nvim",

  -- Matchup
  {
    "andymass/vim-matchup",
    init = function()
      vim.g.matchup_matchparen_offscreen = { method = "popup" }
    end,
  },

  -- Columnskip
  "tyru/columnskip.vim",

  -- Move
  "matze/vim-move",

  -- CamelCaseMotion
  "bkad/CamelCaseMotion",

  -- Wilder
  {
    "gelguy/wilder.nvim",
    config = function()
      -- config goes here
    end,
  },

  -- Asterisk
  "haya14busa/vim-asterisk",

  -- Visualstar
  "thinca/vim-visualstar",

  -- Quick-scope
  "unblevable/quick-scope",

  -- Ripgrep
  "jremmen/vim-ripgrep",
}
