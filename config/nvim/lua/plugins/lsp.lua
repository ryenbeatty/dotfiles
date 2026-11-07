-- Servers are installed by mason, not assumed to be on PATH. This list and
-- mason-lspconfig's ensure_installed must stay in sync.
local servers = { "lua_ls", "ts_ls", "html", "cssls", "jsonls", "yamlls", "eslint" }

return {
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    opts = {},
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
    event = { "BufReadPre", "BufNewFile" },
    opts = { ensure_installed = servers, automatic_installation = true },
  },

  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    event = { "BufReadPre", "BufNewFile" },
    opts = { ensure_installed = { "stylua", "prettier", "eslint_d" }, run_on_start = true },
  },

  { "j-hui/fidget.nvim", event = "LspAttach", opts = {} },

  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      -- completion capabilities come from blink.cmp
      vim.lsp.config("*", {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
      })

      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            workspace = {
              checkThirdParty = false,
              library = vim.api.nvim_get_runtime_file("", true),
            },
            diagnostics = { globals = { "vim" } },
            telemetry = { enable = false },
          },
        },
      })

      vim.lsp.enable(servers)

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("dotfiles-lsp", { clear = true }),
        callback = function(args)
          local map = vim.keymap.set
          local function buf(desc, lhs, rhs)
            map("n", lhs, rhs, { buffer = args.buf, desc = desc })
          end
          buf("rename symbol", "<leader>rn", vim.lsp.buf.rename)
          buf("code action", "<leader>ca", vim.lsp.buf.code_action)
          buf("definition", "gd", vim.lsp.buf.definition)
          buf("references", "gr", vim.lsp.buf.references)
          buf("hover", "K", vim.lsp.buf.hover)
          buf("signature help", "<leader>ll", vim.lsp.buf.signature_help)
        end,
      })
    end,
  },
}
