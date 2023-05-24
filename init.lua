vim.cmd.colorscheme 'koehler' -- Best built-in colorscheme.
vim.cmd.filetype 'on'
vim.cmd.syntax 'on'
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.netrw_banner = 0
vim.g.netrw_hide = 1
vim.g.netrw_liststyle = 3 -- Start in tree mode.
vim.keymap.set('n', '<c-t>', [[:Lex<cr>:vertical resize 38<cr>]])
vim.keymap.set('n', 'y', [["+y]])
vim.keymap.set('v', 'y', [["+y]])
vim.o.autowrite = true
vim.o.belloff = '' -- vim default.
vim.o.breakindent = true
vim.o.confirm = true -- Have destructive commands y-n prompt instead of fail.
vim.o.encoding = 'utf-8'
vim.o.foldenable = false
vim.o.foldlevelstart = 99
vim.o.foldmethod = 'indent'
vim.o.formatoptions = 'roqlj' -- See fo-table.
vim.o.guicursor = ''
vim.o.hlsearch = true
vim.o.ignorecase = false
vim.o.joinspaces = false -- Single space after a period.
vim.o.laststatus = 1 -- Only show statusbar if there are >1 windows.
vim.o.lazyredraw = true -- No redrawing while executing macros.
vim.o.linebreak = true
vim.o.list = false
vim.o.listchars = 'tab:>  ,lead:-,trail:-,extends:@,precedes:@,nbsp:-'
vim.o.modeline = false
vim.o.mouse = ''
vim.o.nrformats = 'alpha,bin,hex' -- Enable CTRL-A for letters, don't treat leading 0s as a base 8 marker.
vim.o.number = false
vim.o.number = true
vim.o.report = 0 -- Always report number of lines changed, no arbitrary threshhold.
vim.o.secure = true -- Unnecesary but just in case, see trojan-horse.
vim.o.shiftround = true -- Round indent to shiftwidth.
vim.o.shiftwidth = 8
vim.o.shortmess = '' -- Don't shorten any messages.
vim.o.showfulltag = true
vim.o.showmode = true
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.startofline = false
vim.o.textwidth = 80
vim.o.undofile = true
vim.o.virtualedit = 'all' -- Viaje de ida.
vim.o.wrap = false
vim.o.wrapscan = false -- /, * and friends don't wrap around the file. (--search hit BOTTOM, continuing at TOP--)
vim.opt.completeopt = {'menu', 'menuone', 'preview', 'longest', 'noselect'}

-- https://github.com/folke/lazy.nvim - "zzz A modern plugin manager for Neovim"
-- :help lazy.nvim.txt
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
-- if not vim.loop.fs_stat(lazypath) then
--   vim.fn.system {
--     'git', 'clone', '--filter=blob:none', 'https://github.com/folke/lazy.nvim.git', '--branch=stable', -- latest stable release
--     lazypath,
--   }
-- end
if vim.loop.fs_stat(lazypath) then
  vim.opt.rtp:prepend(lazypath)
end

require('lazy').setup({
  { 'https://github.com/airblade/vim-gitgutter', }, -- gitgutter
  { 'https://github.com/editorconfig/editorconfig-vim', }, -- editorconfig
  { 'https://github.com/tpope/vim-sleuth', }, -- sleuth
  { 'https://github.com/tpope/vim-vinegar', lazy = false, }, -- vinegar (netrw)
  { 'https://github.com/ahmedkhalf/project.nvim', }, -- project

  { -- autopairs
    'https://github.com/windwp/nvim-autopairs',
    dependencies = { 'treesitter' },
    config = function()
      require('nvim-autopairs').setup({
        check_ts = true
      })
    end,
  },

  { -- cmp
    'https://github.com/hrsh7th/nvim-cmp',
    name = 'cmp',
    dependencies = { 'luasnip', },
    config = function()
      vim.opt.completeopt = {'menu', 'menuone', 'preview', 'noinsert', 'noselect'}
      local cmp = require('cmp')
      local luasnip = require('luasnip')
      local has_words_before = function()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end
      cmp.setup({
        completion = {
          completeopt = table.concat(vim.opt.completeopt:get(), ","),
        },
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end
        },
        sources = {
          { name = 'buffer', },
          { name = 'emoji', keyword_pattern = ':', },
          { name = 'luasnip', },
          { name = 'nvim_lsp', },
          { name = 'nvim_lsp_signature_help' },
          { name = 'path', keyword_patterh = '/', }, -- Works for ~/, ./, ../.
        },
        formatting = {
          -- fields = {'menu', 'abbr', 'kind'},
          fields = {'abbr', 'kind', 'menu', },
          format = function(entry, item)
            local menu_icon = {
              buffer                   = 'buffer',
              emoji                    = 'emoji',
              luasnip                  = 'luasnip',
              nvim_lsp                 = 'nvim_lsp',
              nvim_lsp_signature_help  = 'nvim_lsp_signature_help',
              path                     = 'path',
            }
            item.menu = menu_icon[entry.source.name]
            return item
          end,
        },
        mapping = {
          ['<CR>'] = cmp.mapping.confirm({
            select = false,
          }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
              -- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable()
              -- they way you will only jump inside the snippet region
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            elseif has_words_before() then
              -- cmp.complete()
              cmp.select_next_item()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        },
      })
    end,
  },

  -- cmp sources
  { 'https://github.com/hrsh7th/cmp-nvim-lsp-signature-help', dependencies = { 'cmp', 'lspconfig', }, },
  { 'https://github.com/hrsh7th/cmp-buffer', dependencies = { 'cmp', }, },
  { 'https://github.com/hrsh7th/cmp-emoji', dependencies = { 'cmp', }, },
  { 'https://github.com/hrsh7th/cmp-nvim-lsp', dependencies = { 'cmp', 'lspconfig', }, },
  { 'https://github.com/hrsh7th/cmp-path', dependencies = { 'cmp', }, },

  { -- comment
    'https://github.com/numToStr/Comment.nvim',
    config = function()
      require('Comment').setup {
        pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
      }
    end,
  },

  { -- fzf
    'https://github.com/junegunn/fzf',
    name = 'fzf',
  },

  { -- fzf.vim
    'https://github.com/junegunn/fzf.vim',
    dependencies = { 'fzf' },
    config = function()
      vim.cmd([[
        nnoremap <C-p> :GFiles!<Cr>
        command! -bang -nargs=* GGrep
          \ call fzf#vim#grep(
          \ 'git grep --line-number -- '.shellescape(<q-args>), 0,
          \ fzf#vim#with_preview({'dir': systemlist('git rev-parse --show-toplevel')[0]}), <bang>0)
        nnoremap <C-g> :GGrep!<Cr>
      ]])
    end,
  },

  { -- lspconfig
    'https://github.com/neovim/nvim-lspconfig',
    name = 'lspconfig',
    lazy = false,
    dependencies = { 'mason-lspconfig', 'neodev', },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        desc = 'LSP actions',
        callback = function()
          -- local bufmap = function(mode, lhs, rhs)
          --   local opts = {buffer = true}
          --   vim.keymap.set(mode, lhs, rhs, opts)
          -- end
          vim.keymap.set('n', '<leader>h', '<cmd>lua vim.lsp.buf.hover()<cr>', { buffer = true, })
          vim.keymap.set('n', '<leader>d', '<cmd>lua vim.lsp.buf.definition()<cr>', { buffer = true, })
            -- bufmap('n', '<leader>D', '<cmd>lua vim.lsp.buf.declaration()<cr>', { buffer = true, })
          vim.keymap.set('n', '<leader>i', '<cmd>lua vim.lsp.buf.implementation()<cr>', { buffer = true, })
          vim.keymap.set('n', '<leader>t', '<cmd>lua vim.lsp.buf.type_definition()<cr>', { buffer = true, })
          vim.keymap.set('n', '<leader>rs', '<cmd>lua vim.lsp.buf.references()<cr>', { buffer = true, })
          vim.keymap.set('n', '<leader>s', '<cmd>lua vim.lsp.buf.signature_help()<cr>', { buffer = true, })
          vim.keymap.set('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<cr>', { buffer = true, })
          vim.keymap.set('n', '<leader>f', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', { buffer = true, })
          vim.keymap.set('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<cr>', { buffer = true, })
          vim.keymap.set('x', '<leader>rca', '<cmd>lua vim.lsp.buf.range_code_action()<cr>', { buffer = true, })
          vim.keymap.set('n', '<leader>of', '<cmd>lua vim.diagnostic.open_float()<cr>', { buffer = true, })
          vim.keymap.set('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<cr>', { buffer = true, })
          vim.keymap.set('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<cr>', { buffer = true, })
        end
      })
      -- Configs:
      -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities.textDocument.completion.completionItem.snippetSupport = true
      local lspconfig = require('lspconfig')
      -- TODO: https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#yamlls
      lspconfig.bashls.setup({})
      lspconfig.docker_compose_language_service.setup({})
      lspconfig.dockerls.setup({})
      lspconfig.gopls.setup({})
      lspconfig.lua_ls.setup({})
      lspconfig.pyright.setup({})
      lspconfig.tailwindcss.setup({})
      lspconfig.terraformls.setup({})
      lspconfig.tsserver.setup({})
      -- vscode-langservers-extracted:
      lspconfig.html.setup({ capabilities = capabilities, })
      lspconfig.cssls.setup({})
      lspconfig.jsonls.setup({ capabilities = capabilities, })
      lspconfig.eslint.setup({
        -- on_attach = function(client, bufnr)
        --   vim.api.nvim_create_autocmd("BufWritePre", {
        --     buffer = bufnr,
        --     command = "EslintFixAll",
        --   })
        -- end,
      })
    end,
  },

  { -- luasnip
    'https://github.com/L3MON4D3/LuaSnip',
    name = 'luasnip',
    version = '1.*',
    -- build = 'make install_jsregexp',
  },

  { -- mason
    'https://github.com/williamboman/mason.nvim',
    name = 'mason',
    build = ':MasonUpdate',
    config = function()
      require('mason').setup()
    end,
  },

  { -- mason-lspconfig
    'https://github.com/williamboman/mason-lspconfig.nvim',
    name = 'mason-lspconfig',
    dependencies = { 'mason', },
    config = function()
      require('mason-lspconfig').setup()
    end,
  },

  { -- neodev
    'https://github.com/folke/neodev.nvim',
    name = 'neodev',
    dependencies = { 'cmp', },
    config = function()
      require('neodev').setup()
    end,
  },

  { -- null_ls
    'https://github.com/jose-elias-alvarez/null-ls.nvim',
    name = 'null_ls',
    dependencies = 'plenary',
    config = function()
      local null_ls = require('null-ls')
      null_ls.setup({
        sources = {
          -- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md
          -- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTIN_CONFIG.md
          -- local sources = { null_ls.builtins.completion.luasnip }
          null_ls.builtins.formatting.astyle,
          null_ls.builtins.code_actions.ts_node_action,
          null_ls.builtins.diagnostics.checkmake,
          null_ls.builtins.formatting.nixfmt,
          null_ls.builtins.formatting.zigfmt,
          null_ls.builtins.code_actions.eslint_d, null_ls.builtins.diagnostics.eslint_d, null_ls.builtins.formatting.eslint_d, -- eslint
          null_ls.builtins.formatting.prettierd,
          null_ls.builtins.formatting.gofumpt, null_ls.builtins.formatting.goimports, -- go
          -- null_ls.builtins.diagnostics.luacheck,
          -- null_ls.builtins.formatting.lua_format,
          null_ls.builtins.code_actions.shellcheck, null_ls.builtins.diagnostics.shellcheck,
          null_ls.builtins.diagnostics.terraform_validate, null_ls.builtins.formatting.terraform_fmt, -- tf
        },
        on_attach = function(client, bufnr) -- https://github.com/jose-elias-alvarez/null-ls.nvim/wiki/Formatting-on-save
          if client.supports_method("textDocument/formatting") then
            vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
            -- vim.api.nvim_create_autocmd("BufWritePre", { -- shouldn't be async
            vim.api.nvim_create_autocmd("BufWritePost", { -- can be async
              group = augroup,
              buffer = bufnr,
              callback = function()
                -- on 0.8, you should use vim.lsp.buf.format({ bufnr = bufnr }) instead
                -- vim.lsp.buf.formatting_sync()
                vim.lsp.buf.format({
                  bufnr = bufnr,
                  timeout_ms = 5000,
                  async = true,
                })
              end,
            })
          end
        end,
      })
    end,
  },

  { -- plenary
    'https://github.com/nvim-lua/plenary.nvim',
    name = 'plenary',
  },

  { -- treesitter
    'https://github.com/nvim-treesitter/nvim-treesitter',
    name = 'treesitter',
    dependencies = { 'ts-context-commentstring', },
    config = function()
      require('nvim-treesitter.configs').setup({
        ensure_installed = { "c", "lua", "vim", "vimdoc", "query" },
          -- "the five listed parsers should always be installed"
          -- https://github.com/nvim-treesitter/nvim-treesitter#modules
        sync_install = false,
        auto_install = true,

        autotag = { enable = true, },
        highlight = { enable = true, },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = '<c-space>',
            node_incremental = '<c-space>',
            scope_incremental = '<c-s>',
            node_decremental = '<M-space>',
          },
        },

        indent = { enable = true, },
        context_commentstring = {
          enable = true,
          enable_autocdm = false,
        },
      })
      vim.cmd([[
        set foldmethod=expr
        set foldexpr=nvim_treesitter#foldexpr()
        set nofoldenable " Disable folding at startup.
      ]])
    end,
  },

  {
    'https://github.com/nvim-treesitter/nvim-treesitter-context',
    dependencies = 'treesitter',
    config = function()
      require('treesitter-context').setup({
        min_window_height = 24,
        mode = 'topline', -- Less jarring than 'cursor'.
      })
    end,
  },

  { -- ts-autotag
    'https://github.com/windwp/nvim-ts-autotag',
    dependencies = { 'treesitter', },
  },

  { -- ts-context-commentstring
    'https://github.com/JoosepAlviste/nvim-ts-context-commentstring',
    name = 'ts-context-commentstring',
  },
})
