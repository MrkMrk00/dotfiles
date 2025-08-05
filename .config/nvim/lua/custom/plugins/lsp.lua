local js_filetypes = {
  'javascript',
  'javascriptreact',
  'typescript',
  'typescriptreact',
  'vue',
}

return {
  {
    'MrkMrk00/typescript-tools.nvim',
    dependencies = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' },
    ft = js_filetypes,
    config = function()
      local mason_path = vim.fn.stdpath 'data' .. '/mason/packages/'

      require('typescript-tools').setup {
        filetypes = js_filetypes,
        settings = {
          expose_as_code_action = 'all',
          tsserver_plugins = {
            {
              name = '@vue/typescript-plugin',
              path = mason_path .. 'vue-language-server/node_modules/@vue/language-server/bin/vue-language-server.js',
            },
          },
          jsx_close_tag = {
            enable = false,
          },
        },
      }
    end,
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'williamboman/mason.nvim', config = true }, -- NOTE: Must be loaded before dependants

      -- v2 breaks autolaunching of LSP servers :/
      { 'williamboman/mason-lspconfig.nvim', branch = 'v1.x' },
      { 'WhoIsSethDaniel/mason-tool-installer.nvim', commit = '09caa3380a0e8532043bc417c04d1d6d31b6683b' },

      -- `neodev` configures Lua LSP for your Neovim config, runtime and plugins
      -- used for completion, annotations and signatures of Neovim apis
      { 'folke/lazydev.nvim', opts = {
        library = { 'nvim-dap-ui' },
      }, ft = { 'lua' } },
    },

    config = function()
      --  This function gets run when an LSP attaches to a particular buffer.
      --    That is to say, every time a new file is opened that is associated with
      --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
      --    function will be executed to configure the current buffer
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          -- NOTE: Remember that Lua is a real programming language, and as such it is possible
          -- to define small helper and utility functions so you don't have to repeat yourself.
          --
          -- In this case, we create a function that lets us more easily define mappings specific
          -- for LSP related items. It sets the mode, buffer and description for us each time.
          local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
          map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
          map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
          map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
          map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
          map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
          map('K', vim.lsp.buf.hover, 'Hover Documentation')
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.server_capabilities.documentHighlightProvider then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          -- The following autocommand is used to enable inlay hints in your
          -- code, if the language server you are using supports them
          --
          -- This may be unwanted, since they displace some of your code
          if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      -- LSP servers and clients are able to communicate to each other what features they support.
      --  By default, Neovim doesn't support everything that is in the LSP specification.
      --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
      --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      local servers = {
        stylua = {},
        clangd = {},
        ruff = {},
        pyright = {
          settings = {
            pyright = {
              -- Using Ruff's import organizer
              disableOrganizeImports = true,
            },
            python = {
              analysis = {
                -- Ignore all files for analysis to exclusively use Ruff for linting
                ignore = { '*' },
              },
            },
          },
        },
        rust_analyzer = {},
        phpactor = {},

        prettierd = {},
        eslint = {},
        volar = { 'vue' },
        cssls = {},
        unocss = {},
        tailwindcss = {},

        lua_ls = {
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
            },
          },
        },
        gopls = {},
      }

      local function has_eslintrc(path)
        local found_files = vim.fs.find({ '.eslintrc', '.eslintrc.json', '.eslintrc.js', '.eslintrc.cjs', '.eslintrc.mjs' }, {
          path = path,
          upward = true,
          limit = 2,
          type = 'file',
        })

        return #found_files > 0
      end

      require('mason').setup()
      require('mason-tool-installer').setup {
        ensure_installed = vim.tbl_keys(servers or {}),
      }

      require('mason-lspconfig').setup {
        automatic_installation = false,
        ensure_installed = {},
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            -- This handles overriding only values explicitly passed
            -- by the server configuration above. Useful when disabling
            -- certain features of an LSP (for example, turning off formatting for tsserver)
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})

            if server_name == 'eslint' and has_eslintrc(vim.fn.getcwd()) then
              server = vim.tbl_deep_extend('keep', server, {
                cmd_env = {
                  ESLINT_USE_FLAT_CONFIG = '0',
                },
                settings = {
                  useFlatConfig = false,
                  experimental = {
                    useFlatConfig = false,
                  },
                },
              })
            end

            require('lspconfig')[server_name].setup(server)
          end,
        },
      }
    end,
  },

  {
    'stevearc/conform.nvim',
    lazy = true,
    keys = {
      {
        '<leader>f',
        function()
          require('conform').format({ async = true, lsp_fallback = true }, function(_, _)
            local bufnr = vim.api.nvim_get_current_buf()
            local clients = vim.lsp.get_clients { bufnr = bufnr }

            for _, client in ipairs(clients) do
              if client.name == 'typescript-tools' then
                vim.cmd [[
                  TSToolsFixAll
                  TSToolsOrganizeImports
                ]]
                break
              end
            end
          end)
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    config = function()
      local formatters = {
        {
          ft = js_filetypes,
          formatters = {
            'prettierd',
            'eslint',
          },
        },
        {
          ft = { 'lua' },
          formatters = { 'stylua' },
        },
      }

      local formatters_by_ft = {}
      for _, formatter_type in ipairs(formatters) do
        for _, file_type in ipairs(formatter_type.ft) do
          formatters_by_ft[file_type] = formatter_type.formatters
        end
      end

      require('conform').setup {
        notify_on_error = false,
        formatters_by_ft = formatters_by_ft,
      }
    end,
  },
}
