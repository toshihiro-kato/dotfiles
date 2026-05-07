return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "mason.nvim",
    { "mason-org/mason-lspconfig.nvim", config = function() end },
  },
  opts = function()
    local icons = { Error = " ", Warn = " ", Hint = " ", Info = " " }

    local ret = {
      diagnostics = {
        underline = true,
        update_in_insert = false,
        virtual_text = {
          spacing = 4,
          source = "if_many",
          prefix = "●",
        },
        severity_sort = true,
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = icons.Error,
            [vim.diagnostic.severity.WARN] = icons.Warn,
            [vim.diagnostic.severity.HINT] = icons.Hint,
            [vim.diagnostic.severity.INFO] = icons.Info,
          },
        },
      },
      inlay_hints = {
        enabled = true,
        exclude = { "vue" },
      },
      codelens = {
        enabled = false,
      },
      folds = {
        enabled = true,
      },
      capabilities = {
        workspace = {
          fileOperations = {
            didRename = true,
            willRename = true,
          },
        },
      },
      format = {
        formatting_options = nil,
        timeout_ms = nil,
      },
      servers = {
        stylua = { enabled = false },
        lua_ls = {
          settings = {
            Lua = {
              workspace = {
                checkThirdParty = false,
              },
              codeLens = {
                enable = true,
              },
              completion = {
                callSnippet = "Replace",
              },
              doc = {
                privateName = { "^_" },
              },
              hint = {
                enable = true,
                setType = false,
                paramType = true,
                paramName = "Disable",
                semicolon = "Disable",
                arrayIndex = "Disable",
              },
            },
          },
        },
      },
      setup = {},
    }
    return ret
  end,
  config = vim.schedule_wrap(function(_, opts)
    -- LSP keymaps on attach
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("custom_lsp_attach", { clear = true }),
      callback = function(ev)
        local buffer = ev.buf
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if not client then return end

        local map = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = buffer, desc = desc, silent = true })
        end

        map("n", "gd", vim.lsp.buf.definition, "Go to Definition")
        map("n", "gD", vim.lsp.buf.declaration, "Go to Declaration")
        map("n", "gr", vim.lsp.buf.references, "References")
        map("n", "gI", vim.lsp.buf.implementation, "Go to Implementation")
        map("n", "gy", vim.lsp.buf.type_definition, "Go to Type Definition")
        map("n", "K", vim.lsp.buf.hover, "Hover")
        map("n", "gK", vim.lsp.buf.signature_help, "Signature Help")
        map("i", "<C-k>", vim.lsp.buf.signature_help, "Signature Help")
        map("n", "<leader>ca", vim.lsp.buf.code_action, "Code Action")
        map("n", "<leader>cr", vim.lsp.buf.rename, "Rename")

        -- inlay hints
        if opts.inlay_hints.enabled and client.supports_method("textDocument/inlayHint") then
          if vim.api.nvim_buf_is_valid(buffer) and vim.bo[buffer].buftype == ""
            and not vim.tbl_contains(opts.inlay_hints.exclude, vim.bo[buffer].filetype) then
            vim.lsp.inlay_hint.enable(true, { bufnr = buffer })
          end
        end

        -- folds
        if opts.folds.enabled and client.supports_method("textDocument/foldingRange") then
          vim.wo[0].foldmethod = "expr"
          vim.wo[0].foldexpr = "v:lua.vim.lsp.foldexpr()"
        end

        -- code lens
        if opts.codelens.enabled and vim.lsp.codelens and client.supports_method("textDocument/codeLens") then
          vim.lsp.codelens.refresh()
          vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
            buffer = buffer,
            callback = vim.lsp.codelens.refresh,
          })
        end
      end,
    })

    -- diagnostics
    vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

    if opts.capabilities then
      vim.lsp.config("*", { capabilities = opts.capabilities })
    end

    -- get all the servers that are available through mason-lspconfig
    local have_mason, mason_mappings = pcall(require, "mason-lspconfig.mappings")
    local mason_all = have_mason
        and vim.tbl_keys(mason_mappings.get_mason_map().lspconfig_to_package)
      or {}
    local mason_exclude = {}

    local function configure(server)
      local sopts = opts.servers[server]
      sopts = sopts == true and {} or (not sopts) and { enabled = false } or sopts

      if sopts.enabled == false then
        mason_exclude[#mason_exclude + 1] = server
        return
      end

      local use_mason = sopts.mason ~= false and vim.tbl_contains(mason_all, server)
      local setup = opts.setup[server] or opts.setup["*"]
      if setup and setup(server, sopts) then
        mason_exclude[#mason_exclude + 1] = server
      else
        vim.lsp.config(server, sopts)
        if not use_mason then
          vim.lsp.enable(server)
        end
      end
      return use_mason
    end

    local install = vim.tbl_filter(configure, vim.tbl_keys(opts.servers))
    if have_mason then
      require("mason-lspconfig").setup({
        ensure_installed = install,
        automatic_enable = { exclude = mason_exclude },
      })
    end
  end),
}
