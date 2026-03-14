return {
  -- disable leap and flash
  { "ggandor/leap.nvim", enabled = false },
  {
    "folke/flash.nvim",
    keys = function()
      return {}
    end,
  },
  -- persistence
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {},
    -- stylua: ignore
    keys = function () return
      {
        { "<leader>rs", function() require("persistence").load() end, desc = "Restore Session" },
        { "<leader>rl", function() require("persistence").load({ last = true }) end, desc = "Restore Last Session" },
        { "<leader>rd", function() require("persistence").stop() end, desc = "Don't Save Current Session" },
      }
    end,
  },
  -- neotree
  {
    "nvim-neo-tree/neo-tree.nvim",
    keys = function()
      return {
        {
          "<leader>e",
          function()
            require("neo-tree.command").execute({ toggle = true, dir = LazyVim.root() })
          end,
          desc = "Explorer NeoTree (Root Dir)",
          remap = true,
        },
        {
          "<leader>E",
          function()
            require("neo-tree.command").execute({ toggle = true, dir = vim.uv.cwd() })
          end,
          desc = "Explorer NeoTree (cwd)",
          remap = true,
        },
        {
          "<leader>ge",
          function()
            require("neo-tree.command").execute({ source = "git_status", toggle = true })
          end,
          desc = "Git Explorer",
        },
        {
          "<leader>be",
          function()
            require("neo-tree.command").execute({ source = "buffers", toggle = true })
          end,
          desc = "Buffer Explorer",
        },
      }
    end,
    opts = {
      window = {
        mappings = {
          ["<cr>"] = "open_with_window_picker",
        },
      },
    },
  },
  -- todo-comments
  {
    "folke/todo-comments.nvim",
    cmd = { "TodoTrouble", "TodoTelescope" },
    event = "LazyFile",
    opts = {},
    keys = function()
      return {
        {
          "]t",
          function()
            require("todo-comments").jump_next()
          end,
          desc = "Next Todo Comment",
        },
        {
          "[t",
          function()
            require("todo-comments").jump_prev()
          end,
          desc = "Previous Todo Comment",
        },
        { "<leader>xt", "<cmd>Trouble todo toggle<cr>", desc = "Todo (Trouble)" },
        {
          "<leader>xT",
          "<cmd>Trouble todo toggle filter = {tag = {TODO,FIX,FIXME}}<cr>",
          desc = "Todo/Fix/Fixme (Trouble)",
        },
        { "<leader>sT", "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>", desc = "Todo/Fix/Fixme" },
      }
    end,
  },
  -- window-picker
  {
    "s1n7ax/nvim-window-picker",
    name = "window-picker",
    event = "VeryLazy",
    version = "2.*",
    config = function()
      require("window-picker").setup({
        hint = "floating-big-letter",
      })
    end,
  },
  -- mini.comment
  {
    "nvim-mini/mini.comment",
    opts = {
      mappings = {
        comment_line = "<leader>/",
        comment_visual = "<leader>/",
      },
    },
  },
  -- lsplines
  {
    "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    config = function()
      require("lsp_lines").setup()
    end,
  },
  -- remove stinky binds
  {
    "stevearc/conform.nvim",
    keys = function()
      return {
        {
          "<leader>CF",
          function()
            require("conform").format({ formatters = { "injected" }, timeout_ms = 3000 })
          end,
          mode = { "n", "v" },
          desc = "Format Injected Langs",
        },
      }
    end,
  },
  {
    "mason-org/mason.nvim",
    keys = function()
      return {
        { "<leader>Cm", "<cmd>Mason<cr>", desc = "Mason" },
      }
    end,
  },
  {
    "folke/trouble.nvim",
    keys = {
      { "<leader>Cs", "<cmd>Trouble symbols toggle<cr>", desc = "Symbols (Trouble)" },
      { "<leader>CS", "<cmd>Trouble lsp toggle<cr>", desc = "LSP references/definitions/... (Trouble)" },
      { "<leader>cs", false },
      { "<leader>cS", false },
    },
  },
  {
    "snacks.nvim",
    opts = {
      scroll = { enabled = false },
    },
  },
}
