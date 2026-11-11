-- Servers are installed by mason, not assumed to be on PATH. This list and
-- mason-lspconfig's ensure_installed must stay in sync.
local servers = { "lua_ls", "ts_ls", "html", "cssls", "jsonls", "yamlls", "eslint" }

return {
  {
    "williamboman/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonUpdate", "MasonLog" },
    build = ":MasonUpdate",
    opts = {},
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
    event = { "BufReadPre", "BufNewFile" },
    opts = { ensure_installed = servers },
  },

  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    event = { "BufReadPre", "BufNewFile" },
    -- One list for everything mason should provide, servers included, so a
    -- single `:MasonToolsInstallSync` (nvim/install.sh) provisions the lot.
    -- Names are mason *package* names, which differ from lspconfig's server
    -- names: html/css/json come from html-lsp / css-lsp / json-lsp, one package
    -- each (the old single "langservers-extracted" bundle is no longer in the
    -- current registry, which is why the three are listed separately).
    opts = {
      ensure_installed = {
        "lua-language-server",
        "typescript-language-server",
        "html-lsp",
        "css-lsp",
        "json-lsp",
        "yaml-language-server",
        "eslint-lsp",
        "stylua",
        "prettier",
        "eslint_d",
      },
      run_on_start = true,
    },
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
