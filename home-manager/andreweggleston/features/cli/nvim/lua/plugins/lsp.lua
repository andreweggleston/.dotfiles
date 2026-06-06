return { -- LSP keymaps
  {
    "neovim/nvim-lspconfig",
    ---@param opts PluginLspOpts
    opts = function(_, opts)
      -- options for vim.diagnostic.config()
      opts.diagnostics = vim.tbl_deep_extend("force", opts.diagnostics or {}, {
        underline = true,
        update_in_insert = false,
        virtual_text = false,
        severity_sort = true,
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = LazyVim.config.icons.diagnostics.Error,
            [vim.diagnostic.severity.WARN] = LazyVim.config.icons.diagnostics.Warn,
            [vim.diagnostic.severity.HINT] = LazyVim.config.icons.diagnostics.Hint,
            [vim.diagnostic.severity.INFO] = LazyVim.config.icons.diagnostics.Info,
          },
        },
      })

      -- Enable this to enable the builtin LSP inlay hints on Neovim >= 0.10.0
      -- Be aware that you also will need to properly configure your LSP server to
      -- provide the inlay hints.
      opts.inlay_hints = {
        enabled = false,
        exclude = { "vue" }, -- filetypes for which you don't want to enable inlay hints
      }

      -- Enable this to enable the builtin LSP code lenses on Neovim >= 0.10.0
      -- Be aware that you also will need to properly configure your LSP server to
      -- provide the code lenses.
      opts.codelens = {
        enabled = false,
      }

      -- Enable lsp cursor word highlighting
      opts.document_highlight = {
        enabled = true,
      }

      -- LSP Server Settings
      opts.servers = vim.tbl_deep_extend("force", opts.servers or {}, {
        ["*"] = {
          -- add any global capabilities here
          capabilities = {
            workspace = {
              fileOperations = {
                didRename = true,
                willRename = true,
              },
            },
          },
          {
            "gd",
            "<cmd>FzfLua lsp_definitions jump_to_single_result=true ignore_current_line=true<cr>",
            desc = "Goto Definition",
            has = "definition",
          },
          { "<leader>ca", false },
          { "<leader>cc", false },
          { "<leader>cC", false },
          { "<leader>cR", false },
          { "<leader>cr", false },
          { "<leader>cA", false },
          { "<leader>cl", false },
          { "<leader>Ca", vim.lsp.buf.code_action, desc = "Code Action", mode = { "n", "v" }, has = "codeAction" },
          { "<leader>Cc", vim.lsp.codelens.run, desc = "Run Codelens", mode = { "n", "v" }, has = "codeLens" },
          {
            "<leader>CC",
            vim.lsp.codelens.refresh,
            desc = "Refresh & Display Codelens",
            mode = { "n" },
            has = "codeLens",
          },
          {
            "<leader>CR",
            Snacks.rename.rename_file,
            desc = "Rename File",
            mode = { "n" },
            has = { "workspace/didRenameFiles", "workspace/willRenameFiles" },
          },
          { "<leader>Cr", vim.lsp.buf.rename, desc = "Rename", has = "rename" },
          { "<leader>CA", LazyVim.lsp.action.source, desc = "Source Action", has = "codeAction" },
          { "<leader>Cl", LazyVim.lsp.action.source, desc = "Source Action", has = "codeAction" },
        },
        basedpyright = {},
        ruff = {},
        clangd = {},
        nixd = {},
        lua_ls = {
          -- mason = false, -- set to false if you don't want this server to be installed with mason
          -- Use this to add any additional keymaps
          -- for specific lsp servers
          -- ---@type LazyKeysSpec[]
          -- keys = {},
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
      })
    end,
  },
}
