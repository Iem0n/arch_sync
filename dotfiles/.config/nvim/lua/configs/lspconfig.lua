require("nvchad.configs.lspconfig").defaults()

local servers = { "clangd" }
vim.lsp.enable(servers)

vim.lsp.config('clangd', {
      root_markers = { '.clang-format', 'compile_commands.json' },
      capabilities = {
        textDocument = {
          completion = {
            completionItem = {
              snippetSupport = true,
            }
          }
        }
      }
    })

-- read :h vim.lsp.config for changing options of lsp servers 
