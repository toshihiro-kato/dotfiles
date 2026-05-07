-- Treesitter configuration
return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    version = false,
    build = function()
      local TS = require("nvim-treesitter")
      if not TS.get_installed then
        vim.notify("Please restart Neovim and run `:TSUpdate` to use the `nvim-treesitter` **main** branch.", vim.log.levels.ERROR)
        return
      end
      TS.update(nil, { summary = true })
    end,
    lazy = vim.fn.argc(-1) == 0,
    cmd = { "TSUpdate", "TSInstall", "TSLog", "TSUninstall" },
    opts_extend = { "ensure_installed" },
    opts = {
      indent = { enable = true },
      highlight = { enable = true },
      folds = { enable = true },
      ensure_installed = {
        "bash",
        "c",
        "diff",
        "html",
        "javascript",
        "jsdoc",
        "json",
        "jsonc",
        "lua",
        "luadoc",
        "luap",
        "markdown",
        "markdown_inline",
        "printf",
        "python",
        "query",
        "regex",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "xml",
        "yaml",
      },
    },
    config = function(_, opts)
      local TS = require("nvim-treesitter")

      -- sanity checks
      if not TS.get_installed then
        vim.notify("Please use `:Lazy` and update `nvim-treesitter`", vim.log.levels.ERROR)
        return
      elseif type(opts.ensure_installed) ~= "table" then
        vim.notify("`nvim-treesitter` opts.ensure_installed must be a table", vim.log.levels.ERROR)
        return
      end

      -- setup treesitter
      TS.setup(opts)

      -- install missing parsers
      local installed = TS.get_installed()
      local install = vim.tbl_filter(function(lang)
        return not installed[lang]
      end, opts.ensure_installed or {})
      if #install > 0 then
        TS.install(install, { summary = true })
      end

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("custom_treesitter", { clear = true }),
        callback = function(ev)
          local ft = ev.match
          if not TS.get_installed()[ft] then
            return
          end

          -- highlighting
          if opts.highlight and opts.highlight.enable ~= false then
            pcall(vim.treesitter.start)
          end

          -- indents
          if opts.indent and opts.indent.enable ~= false then
            vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end

          -- folds
          if opts.folds and opts.folds.enable ~= false then
            vim.wo[0].foldmethod = "expr"
            vim.wo[0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
          end
        end,
      })
    end,
  }
}
