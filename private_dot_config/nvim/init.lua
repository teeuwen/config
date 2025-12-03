-- vim:fileencoding=utf-8:foldmethod=marker

-- Variables --------------------------------------------------------------- {{{

local so = vim.opt
local wo = vim.wo

so.compatible = false

so.rtp:prepend(vim.env.XDG_CONFIG_HOME .. '/nvim')                  -- path: runtime directory
so.backupdir = { vim.env.XDG_CACHE_HOME .. '/nvim/backups', '.' }   -- path: backup file directory (~)
so.directory = { vim.env.XDG_CACHE_HOME .. '/nvim/swap', '.' }      -- path: swap file directory (.swp)
so.viminfo:append('n' .. vim.env.XDG_CACHE_HOME .. '/nvim/history') -- path: history file

vim.g.mapleader = 'g'

-- }}}


-- Packages ---------------------------------------------------------------- {{{

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        'git',
        'clone',
        '--filter=blob:none',
        '--branch=stable',
        'https://github.com/folke/lazy.nvim.git',
        lazypath
    })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
    -- Plugin Frameworks
    {
        'nvim-lua/plenary.nvim',
        events = 'VeryLazy',
    },

    -- Color scheme
    {
        'RRethy/base16-nvim',
        lazy = false,
        priority = 1000,
    },
    --{
    --    'rose-pine/neovim',
    --    name = 'rose-pine',
    --    lazy = false,
    --    priority = 1000,
    --    opts = {
    --        disable_background = true,
    --        dim_nc_background = false,
    --    }
    --},

    -- Treesitter support
    {
        'nvim-treesitter/nvim-treesitter',
        cmd = { 'TSInstall', 'TSBufEnable', 'TSBufDisable', 'TSModuleInfo' },
        event = 'BufRead',
        build = ':TSUpdate',
        opts = {
            ignore_install = { },
            auto_install = true,
            sync_install = false,
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
            },
            indent = {
                enable = false,
            }
        },
        config = function(_, opts)
            require('nvim-treesitter.configs').setup(opts)
        end,
    },

    -- Show function name on top line
    {
        'nvim-treesitter/nvim-treesitter-context',
        event = 'BufRead',
        opts = {
            multiwindow = true,
            max_lines = 1,
            trim_scope = 'inner',
            mode = 'topline',
        },
        config = function(_, opts)
            require('treesitter-context').setup(opts)
        end,
    },

    -- LSP package manager
    {
        'mason-org/mason.nvim',
        opts = {}
    },

    -- LSP package manager helper
    {
        'mason-org/mason-lspconfig.nvim',
        dependencies = {
            { 'neovim/nvim-lspconfig' }  -- Language server configuration
        }
    },

    -- LSP status display
    {
        'j-hui/fidget.nvim',
        event = 'LspAttach',
        opts = {
            progress = {
                ignore = { 'ltex' },
            },
        },
    },

    -- LSP call hierarchy
    {
        'ldelossa/litee.nvim',
        events = 'VeryLazy',
        opts = {
            notify = {
                enabled = false,
            },
            tree = {
                icon_set = 'codicons',
                indent_guides = false,
            },
            panel = {
                orientation = 'bottom',
                panel_size = 10,
            },
        },
        config = function(_, opts)
            require('litee.lib').setup(opts)
        end,
    },
    {
        'ldelossa/litee-calltree.nvim',
        event = 'VeryLazy',
        opts = {
            resolve_symbols = true,
            on_open = 'panel',
            map_resize_keys = false,
            keymaps = {
                collapse = 'h',
                expand = 'l',
            },
        },
        config = function(_, opts)
            require('litee.calltree').setup(opts)
        end,
    },

    -- Autocompletion
    {
        'hrsh7th/nvim-cmp',
        dependencies = {
            { 'hrsh7th/cmp-nvim-lsp' },                -- LSP support
            { 'hrsh7th/cmp-nvim-lsp-signature-help' }, -- Signature while typing
            { 'L3MON4D3/LuaSnip' },                    -- Snippet support
            { 'saadparwaiz1/cmp_luasnip' },            -- Snippet completion
            { 'rafamadriz/friendly-snippets' },        -- Predefined snippets
        }
    },

    -- Buffer tab line
    {
        'romgrk/barbar.nvim',
        event = 'BufEnter',
        init = function() vim.g.barbar_auto_setup = false end,
        opts = {
            animation = false,
            auto_hide = 1,
            insert_at_end = true,
            sidebar_filetypes = { NvimTree = true }
        }
    },

    -- Floating winbar
    {
        'b0o/incline.nvim',
        opts = {
            hide = { cursorline = 'focused_win' },
            window = { margin = { horizontal = 1, vertical = 0 } }
        }
    },

    -- Git in signcolumn
    {
        'lewis6991/gitsigns.nvim',
        opts = {
            signs = {
                add          = { text = '┃' },
                change       = { text = '┃' },
                delete       = { text = '┃' },
                topdelete    = { text = '┳' },
                changedelete = { text = '┃' },
                untracked    = { text = '│' },
            },
        }
    },

    -- Git difftool
    {
        'sindrets/diffview.nvim'
    },

    -- Ctrl-P
    -- Note: Make sure ripgrep is installed!
    {
        'nvim-telescope/telescope.nvim',
        cmd = 'Telescope',
        config = function()
            local actions = require('telescope.actions')

            local function telescope_open_single_or_multi(bufnr)
                local actions_state = require("telescope.actions.state")
                local single_selection = actions_state.get_selected_entry()
                local multi_selection = actions_state.get_current_picker(bufnr):get_multi_selection()
                if not vim.tbl_isempty(multi_selection) then
                    actions.close(bufnr)
                    for _, file in pairs(multi_selection) do
                    if file.path ~= nil then
                        vim.cmd(string.format("edit %s", file.path))
                    end
                    end
                    vim.cmd(string.format("edit %s", single_selection.path))
                else
                    actions.select_default(bufnr)
                end
            end

            require('telescope').setup {
                defaults = {
                    mappings = {
                        i = {
                            ['<esc>'] = require('telescope.actions').close,
                            ['<CR>'] = telescope_open_single_or_multi,
                        },
                    },
                },
            }
        end
    },

    -- Highlight HEX colors
    {
        'NvChad/nvim-colorizer.lua',
        opts = {}
    },

    -- File tree
    {
        'nvim-tree/nvim-tree.lua',
        cmd = { 'NvimTreeToggle', 'NvimTreeFocus' },
        dependencies = {
            -- File tree icons
            { 'kyazdani42/nvim-web-devicons' },
        }
    },

    -- Comment functions
    { 'preservim/nerdcommenter' },

    -- Transparent pasting
    { 'ConradIrwin/vim-bracketed-paste' },

    -- Easy align
    { 'junegunn/vim-easy-align' },

    -- LTeX LSP addons
    { 'barreiroleo/ltex_extra.nvim' },

    -- LaTeX live PDF output
    {
        'lervag/vimtex',
        config = function(_, _)
            vim.g.vimtex_view_method = 'zathura'
        end
    },

    -- Helm file type detection
    {
        'towolf/vim-helm',
        ft = 'helm'
    },
    --{ 'qpkorr/vim-bufkill' },                             -- Don't close window when closing buffer
    --{ 'neoclide/coc.nvim', { branch = 'release' }}        -- Auto completion engine
    --{ 'ap/vim-buftabline' },                              -- Buffer list tabline
    --{ 'ludovicchabant/vim-gutentags' },                   -- Tag file management
    --{ 'kristijanhusak/vim-hybrid-material' },             -- Material color scheme
    --{ 'morhetz/gruvbox' },                                -- Gruvbox color scheme
    --{ 'cocopon/iceberg.vim' },                            -- Iceberg color scheme
    --{ 'xuhdev/vim-latex-live-preview' },                  -- LaTeX live PDF output
    --{ 'christoomey/vim-tmux-navigator' },                 -- tmux Window keymappings
    --{ 'wannesm/wmgraphviz.vim' },                         -- Graphviz dot
})

-- }}}


-- General ----------------------------------------------------------------- {{{

--filetype indent on

so.showtabline   = 0               -- tabs: hide tabline
so.hidden        = true            -- tabs: allow switching buffers without saving

so.encoding      = 'utf-8'         -- vim:  UTF-8 file encoding
so.fileencoding  = 'utf-8'         -- file: UTF-8 file encoding
so.autoread      = true            -- file: automatically read when file has changed
so.backup        = true            -- file: generate a backup (~) file
so.swapfile      = true            -- file: generate a swap (.swp) file
so.updatetime    = 300             -- file: swap file update frequency
so.undolevels    = 1000            -- file: set number of undos
so.modeline      = true            -- file: enable modeline
so.modelines     = 1               -- file: 1 modeline per file
so.nrformats     : remove('octal') -- misc: don't assume numbers are octal
--so.spell         = true            -- file: check spelling
so.spelllang     = {               -- file: spellcheck languages
    'en_us',
    'nl'
}

--if vim.t_Co >= 256 then
wo.number        = true            -- lines: show line numbers
--wo.numberwidth   = 7               -- lines: line number column width
wo.signcolumn    = 'yes:2'          -- lines: combine line number column and line column

so.termguicolors = true
--end

so.mousescroll   = 'ver:1,hor:0'   -- lines: disable horizontal scrolling
so.scrolloff     = 1               -- lines: set vertical scroll edge
so.sidescrolloff = 5               -- lines: set horizontal scroll edge
so.synmaxcol     = 200             -- lines: speed up syntax highlighting
so.wrap          = false           -- lines: don't wrap
so.whichwrap     : append('<,>,h,l,[,]') -- lines: wrap given movement keys

--so.autoindent  = true            -- indent: automatic
so.expandtab     = true            -- indent: expand tabs
so.shiftround    = true            -- indent: round
so.shiftwidth    = 4               -- indent: shift (<<, >>) width
so.softtabstop   = 4               -- indent: tab width
so.tabstop       = 4               -- indent: visual width

so.laststatus    = 3               -- statusbar: always visible, global
so.showmode      = false           -- statusbar: hide mode
so.showcmd       = false           -- statusbar: hide key presses
so.shortmess     : append({
    a = true,                      -- statusbar: hide generic messages
    c = true,                      -- statusbar: hide completion messages
    o = true,                      -- statusbar: hide writing messages
    s = true,                      -- statusbar: hide search messages
    C = true,                      -- statusbar: hide ins-completion messages
    I = true,                      -- statusbar: hide intro message
    F = true,                      -- statusbar: hide file info
})

so.cmdheight     = 0               -- command: hide commandline by default
so.history       = 1000            -- command: history
--so.path+=**                      -- command: tab-completion recursive file search
--so.wildmenu                      -- command: tab-completion menu
so.wildmode      = 'full'          -- command: tab-completion style
so.completeopt   = 'menuone'       -- command: show menu with only one item
so.pumheight     = 16              -- command: show max 16 entries at once
--so.suffixes      = .aux,.bak,.bbl,.blg,.brf,.cb,.class,.dvi,.idx,.ilg,.ind,.info,.inx,.jpg,.log,.o,.out,.png,.pyc,.swp,.toc,~
--so.wildignore    = *.aux,*.bak,*.bbl,*.blg,*.brf,*.cb,*.class,*.dvi,*.idx,*.ilg,*.ind,*.info,*.inx,*.jpg,*.log,*.o,*.out,*.png,*.pyc,*.swp,*.toc

so.hlsearch      = true            -- search: highlight matches
so.incsearch     = true            -- search: highlight all
so.ignorecase    = true            -- search: ignore case
so.smartcase     = true            -- search: smart ignore case

so.title         = true            -- terminal: enable title
-- TODO
--let &titlestring=$USER . '@' . substitute(hostname(), '\..*$', '', '') . ' - VIM'
so.ttyfast       = true            -- terminal: fast connection
so.ttimeoutlen   = 0               -- terminal: no delay after pressing ESC
so.lazyredraw    = true            -- terminal: faster drawing
so.backspace     = 'indent,eol,start' -- terminal: fix backspace
so.clipboard     = 'unnamedplus'   -- terminal: copy to global clipboard
so.fillchars     = {
    fold      = ' ',
    foldsep   = ' ',
    foldopen  = '',
    foldclose = '',
    eob       = ' ',               -- terminal: empty lines at end of buffer
    stl       = ' ',               -- terminal: active window indicator
    stlnc     = ' ',               -- terminal: non-active window indicator
    diff      = '╱',               -- diffview.nvim: deleted lines
}
so.listchars = {
    eol   = '↲',                   -- terminal: end of line indicator
    tab   = '»―',                  -- terminal: tab indicator
    space = '⋅',                   -- terminal: space indicator
    nbsp  = '␣',                   -- terminal: non-breaking space indicator
}
so.winborder = 'shadow'

-- TODO: https://www.reddit.com/r/neovim/comments/1djjc6q/statuscolumn_a_beginers_guide/
--so.statuscolumn = "%=%l%s%C"
--so.foldcolumn = '1'

so.sessionoptions = {              -- session: configure what to save
    blank    = true,
    buffers  = true,
    curdir   = true,
    folds    = true,
    help     = true,
    tabpages = true,
    terminal = true
}

--opt.guicursor = n-v-c-sm:block,i-ci-ve:ver25-Cursor,r-cr-o:hor20
--let &t_SI='\e[6 q'
--let &t_SR='\e[4 q'
--let &t_EI='\e[2 q'


-- Enable mouse support in Normal mode
vim.api.nvim_create_autocmd({ 'BufEnter' }, {
  pattern = { '*' },
  command = 'set mouse=n'
})

-- Remove How to disable mouse from right click menu
vim.cmd [[aunmenu PopUp.How-to\ disable\ mouse]]
vim.cmd [[aunmenu PopUp.-1-]]

-- Highlight characters over 120 columns
--au BufWinEnter * let w:m2=matchadd('ErrorMsg', '\%>120v.\+', -1)

-- Restore cursor to previous position when file is reloaded
--augroup resCur
--    autocmd!
--    autocmd BufReadPost * call setpos('.', getpos(''\"'))
--augroup END

-- }}}


-- LSP --------------------------------------------------------------------- {{{

local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())
local lsp_servers = {
    clangd = {},
    cmake = {},
    --dartls = {},
    gopls = {},
    helm_ls = {
        ['helm-ls'] = {
            yamlls = {
                path = "yaml-language-server",
            }
        }
    },
    ltex = {
        language = 'auto',
        checkFrequency = 'manual'
    },
    lua_ls = {
        Lua = {
            runtime = { version = 'LuaJIT' },
            diagnostics = { globals = { 'vim', 'require' } },
            workspace = {
                library = vim.api.nvim_get_runtime_file('', true),
                checkThirdParty = false
            },
            telemetry = { enable = false }
        }
    },
    pyrefly = {
        displayTypeErrors = 'force-on',
    },
    texlab = {},
    typos_lsp = {},
    yamlls = {
        yaml = {
            customTags = {
                '!reference sequence'
            },
            schemas = (function()
                local fname = vim.api.nvim_buf_get_name(0)
                local root = vim.fs.root(fname, { '.git' })

                if root == nil then
                    return {}
                end

                local path = root .. '/.schemas.lua'
                if vim.fn.filereadable(path) == 0 then
                    return {}
                end

                -- FIXME: unsafe, use a yaml parser instead
                dofile(path)

                if schemas == nil then
                    return {}
                end

                return schemas
            end)()
        }
    }
}

require('mason-lspconfig').setup {
    ensure_installed = vim.tbl_keys(lsp_servers),
    automatic_enable = false
}

for server_name, config in pairs(lsp_servers) do
    vim.lsp.config(server_name, {
        capabilities = lsp_capabilities,
        settings = config
    })
    vim.lsp.enable(server_name)
end

vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
        virtual_text = false,
        signs = true,
        update_in_insert = false,
        underline = true
    }
)

vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(ev)
        local opts = { buffer = ev.buf }

        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if not client then
            return
        end

        if client.name == 'ltex' then
            require('ltex_extra').setup {}
        end

        if client.name == 'helm' then
            require('telescope').load_extension('yaml_schema')
        end
        if client.name == 'yamlls' then
            require('telescope').load_extension('yaml_schema')
        end

        -- Default mappings (created by NeoVim automatically)
        vim.keymap.set('n', '<leader>ra', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', '<leader>ri', vim.lsp.buf.implementation, opts)
        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
        vim.keymap.set('n', '<leader>rr', vim.lsp.buf.references, opts)
        vim.keymap.set('n', '<leader>rt', vim.lsp.buf.type_definition, opts)
        vim.keymap.set('n', '<leader>O', vim.lsp.buf.document_symbol, opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)

        -- Shortcut for <Ctrl + ]> (Use <Ctrl + T> to go back)
        vim.keymap.set('n', '<leader>d', vim.lsp.buf.definition, opts)
        --vim.keymap.set('n', '<leader>D', vim.lsp.buf.definition_back, opts)

        vim.keymap.set('n', '<leader>rd', vim.lsp.buf.declaration, opts)
        vim.keymap.set('n', '<leader>c', vim.lsp.buf.incoming_calls, opts)
        vim.keymap.set('n', '<leader>f', vim.lsp.buf.format, opts)
        vim.keymap.set('v', '<leader>f', vim.lsp.buf.format, opts)
        vim.keymap.set('n', '<leader>w', require('telescope.builtin').grep_string)
        vim.keymap.set('n', 'S', vim.diagnostic.open_float, opts)
    end,
})

-- Set gutter symbols
local signs = { Error = ' ', Warn = ' ⚠', Hint = ' !', Info = ' ℹ' }
for type, icon in pairs(signs) do
    local hl = 'DiagnosticSign' .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

local luasnip = require('luasnip')
require('luasnip.loaders.from_vscode').lazy_load()
luasnip.config.setup { }

local cmp_icons = {
    Class           = ' ',
    Color           = ' ',
    Constant        = ' ',
    Constructor     = ' ',
    Enum            = ' ',
    EnumMember      = ' ',
    Event           = ' ',
    Field           = ' ',
    File            = ' ',
    Folder          = ' ',
    Function        = '󰅩 ',
    Interface       = ' ',
    Keyword         = ' ',
    Method          = ' ',
    Module          = ' ',
    Operator        = ' ',
    Property        = ' ',
    Reference       = ' ',
    Snippet         = ' ',
    Struct          = ' ',
    Text            = ' ',
    TypeParameter   = ' ',
    Unit            = ' ',
    Value           = '󰎠 ',
    Variable        = '󰫧 ',
}

local cmp = require('cmp')
cmp.setup {
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },
    formatting = {
        fields = {
            cmp.ItemField.Kind,
            cmp.ItemField.Abbr,
            cmp.ItemField.Menu,
        },
        format = function(entry, vim_item)
            vim_item.kind = cmp_icons[vim_item.kind] or ''

            vim_item.menu = ({
                buffer = '[Buffer]',
                nvim_lsp = '',
                luasnip = '',
                nvim_lua = '[Lua]',
                latex_symbols = '[LaTeX]',
            })[entry.source.name]

            return vim_item
        end
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-u>'] = cmp.mapping.scroll_docs(-4),
        ['<C-d>'] = cmp.mapping.scroll_docs(4),
        ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            else
                fallback()
            end
        end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { 'i', 's' }),
        --['<F15>'] = cmp.mapping(function(fallback)
        --    if cmp.visible() then
        --        cmp.select_next_item()
        --    elseif luasnip.expand_or_jumpable() then
        --        luasnip.expand_or_jump()
        --    else
        --        fallback()
        --    end
        --end, { 'i', 's' }),
        --['<F16>'] = cmp.mapping(function(fallback)
        --    if cmp.visible() then
        --        cmp.select_prev_item()
        --    elseif luasnip.jumpable(-1) then
        --        luasnip.jump(-1)
        --    else
        --        fallback()
        --    end
        --end, { 'i', 's' }),
        --['<F17>'] = cmp.mapping.complete(),
        -- Return --
        ['<CR>'] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Replace,
            select = false,
        },
    }),
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
        { name = 'nvim_lsp_signature_help' }
    })
}

-- }}}


-- Colors ------------------------------------------------------------------ {{{

local colors_light = {
    -- Gutter
    --LineNr                = { bg = '#F3F3F3', fg = '#888888' },
    --SignColumn            = { bg = '#F3F3F3', fg = '#888888' },
    --DiagnosticSignError   = { bg = '#F3F3F3', fg = '#FF0000', bold = true },
    --DiagnosticSignWarn    = { bg = '#F3F3F3', fg = '#FFA500', bold = true },
    --DiagnosticSignHint    = { bg = '#F3F3F3', fg = '#90EE90', bold = true },
    --DiagnosticSignInfo    = { bg = '#F3F3F3', fg = '#ADD8E6', bold = true },

    -- Statusline
    --MsgArea               = { bg = '#485760', fg = '#FAFAFA' },
    --StatusLine            = { bg = '#485760', fg = '#FAFAFA' },
    --CommandColor          = { bg = '#485760' },
    --NormalColor           = { bg = '#485760' },

    -- NvimTree
    BufferOffset          = { bg = '#F3F3F3' },
    NvimTreeNormal        = { bg = '#F3F3F3', fg = '#888888' },
    NvimTreeWinSeparator  = { bg = 'NONE',    fg = '#FFFFFF' },
    NvimTreeCursorLine    = { bg = '#F6CD76', fg = '#0A0D13' },

    -- Diff
    DiffAdd               = { bg = '#98C379', fg = '#16161D' },
    DiffChange            = { bg = '#E5C07B', fg = '#16161D' },
    DiffDelete            = { bg = '#E06C75', fg = '#16161D' },

    -- Windows
    NormalFloat           = { bg = '#E8E8E8', fg = '#666666' },
    --FloatBorder           = { bg = '#F8F8F8', fg = '#666666' },
}

local colors_dark = {
    -- Gutter
    --LineNr                = { bg = '#000000', fg = '#666666' },
    --SignColumn            = { bg = '#000000', fg = '#666666' },
    --DiagnosticSignError   = { bg = '#000000', fg = '#FF0000', bold = true },
    --DiagnosticSignWarn    = { bg = '#000000', fg = '#FFA500', bold = true },
    --DiagnosticSignHint    = { bg = '#000000', fg = '#90EE90', bold = true },
    --DiagnosticSignInfo    = { bg = '#000000', fg = '#ADD8E6', bold = true },

    -- NvimTree
    BufferOffset          = { bg = '#222222' },
    NvimTreeNormal        = { bg = '#222222', fg = '#EEEEEE' },
    NvimTreeWinSeparator  = { bg = 'NONE',    fg = '#0F0D13' },
    NvimTreeCursorLine    = { bg = '#F6CD76', fg = '#0A0D13' },

    -- Statusline
    --MsgArea               = { bg = '#000000', fg = '#FFFFFF' },
    --StatusLine            = { bg = '#000000', fg = '#FFFFFF' },
    --CommandColor          = { bg = '#000000' },
    --NormalColor           = { bg = '#000000' },

    -- Windows
    NormalFloat           = { bg = '#000000', fg = '#EEEEEE' },
    --FloatBorder           = { bg = '#000000', fg = '#EEEEEE' },
}

local colors_generic = {
    Normal                = { bg = 'NONE' },
    NormalNC              = { bg = 'NONE' },
    LineNr                = { bg = 'NONE',    fg = '#666666' },
    SignColumn            = { bg = 'NONE',    fg = '#666666' },
    GitSignsAdd           = { bg = 'NONE',    fg = '#088F8F' },
    GitSignsUntracked     = { bg = 'NONE',    fg = '#088F8F' },
    GitSignsChange        = { bg = 'NONE',    fg = '#FFA836' },
    GitSignsChangeDelete  = { bg = 'NONE',    fg = '#3D85C6' },
    GitSignsDelete        = { bg = 'NONE',    fg = '#A52A2A' },
    GitSignsTopDelete     = { bg = 'NONE',    fg = '#A52A2A' },
    DiagnosticSignError   = { bg = 'NONE',    fg = '#FF0000', bold = true },
    DiagnosticSignWarn    = { bg = 'NONE',    fg = '#FFA500', bold = true },
    DiagnosticSignHint    = { bg = 'NONE',    fg = '#90EE90', bold = true },
    DiagnosticSignInfo    = { bg = 'NONE',    fg = '#ADD8E6', bold = true },

    -- BarBar
    BufferTabPageFill     = { bg = '#485760' },
    BufferCurrent         = { bg = '#FFFFFF', fg = '#000000' },
    BufferCurrentMod      = { bg = '#FFFFFF', fg = '#000000' },
    BufferCurrentSign     = { bg = '#FFFFFF', fg = '#FFFFFF' },
    BufferVisible         = { bg = '#3C454B', fg = '#FFFFFF' },
    BufferVisibleMod      = { bg = '#3C454B', fg = '#FFFFFF' },
    BufferVisibleSign     = { bg = '#3C454B', fg = '#FFFFFF' },
    BufferInactive        = { bg = '#485760', fg = '#FFFFFF' },
    BufferInactiveMod     = { bg = '#485760', fg = '#FFFFFF' },
    BufferInactiveSign    = { bg = '#485760', fg = '#FFFFFF' },

    -- Statusline
    MsgArea               = { bg = '#385760', fg = '#FAFAFA' },
    StatusLine            = { bg = '#485760', fg = '#FAFAFA' },
    CommandColor          = { bg = '#485760' },
    NormalColor           = { bg = '#485760' },
    InsertColor           = { bg = '#81ABDC', fg = '#000000' },
    ReplaceColor          = { bg = '#FFCCCB', fg = '#000000' },
    VisualColor           = { bg = '#FFFF9F', fg = '#000000' },
    SelectColor           = { bg = 'Magenta', fg = '#000000' },

    -- Line numbers and linting colors
    GitColor              = { bg = 'NONE',    fg = '#00FF00' },
    SpellColor            = { bg = 'NONE',    fg = '#FF0000' },

    TrailingWhitespace    = { bg = '#FF0000' },
    LspSignatureActiveParameter = { bg = '#000000', fg = '#FFFFFF' },
}

function UpdateColorscheme()
    --if mode == 'dark' then
    --    so.background = 'dark'
    --elseif mode == 'light' then
    --    so.background = 'light'
    --else
    --    -- FIXME get from file in .config
    --    local handle = io.popen('defaults read -g AppleInterfaceStyle 2>&1')
    --    if handle == nil then
    --        return
    --    end

    --    local result = handle:read('*a')
    --    handle:close()

    --    if result:find'^Dark' ~= nil then
    --        mode = 'dark'
    --        so.background = 'dark'
    --    else
    --        mode = 'light'
    --        so.background = 'light'
    --    end
    --end

    local theme = vim.fn.readfile(vim.env.XDG_CONFIG_HOME .. '/current-theme')[1]
    local mode = vim.fn.readfile(vim.env.XDG_CONFIG_HOME .. '/current-theme')[2]

    vim.cmd('colorscheme ' .. theme)
    so.background = mode

    if mode == 'dark' then
        for group,colors in pairs(colors_dark) do
            vim.api.nvim_set_hl(0, group, colors)
        end
    else
        for group,colors in pairs(colors_light) do
            vim.api.nvim_set_hl(0, group, colors)
        end
    end

    -- General colors
    for group,colors in pairs(colors_generic) do
        vim.api.nvim_set_hl(0, group, colors)
    end

    vim.cmd('redraw!')
end

-- Update color scheme when Neovim is (re)started or when SIGUSR1 is received
vim.api.nvim_create_autocmd({ 'FileType', 'Signal', 'VimResume' }, {
    pattern = { '*' },
    callback = UpdateColorscheme
})

-- Highlight trailing whitespaces in normal mode
vim.api.nvim_create_autocmd({ 'InsertEnter' }, {
    pattern = { '*' },
    command = 'match TrailingWhitespace /\\s\\+\\%#\\@<!$/'
})
vim.api.nvim_create_autocmd({ 'InsertLeave' }, {
    pattern = { '*' },
    command = 'match TrailingWhitespace /\\s\\+$/'
})

-- }}}


-- Statusline -------------------------------------------------------------- {{{

local function createstatusline()
    local statusline = '%#StatusLine#'
        .. '%#CommandColor#%{(mode()==#"c") ? "        " : ""}' -- Command
        .. '%#NormalColor#%{(mode()==#"n")  ? "        " : ""}' -- Normal
        .. '%#InsertColor#%{(mode()==#"i")  ? "    I   " : ""}' -- Insert
        .. '%#ReplaceColor#%{(mode()==#"R") ? "    R   " : ""}' -- Replace
        .. '%#VisualColor#%{(mode()==#"v")  ? "    V   " : ""}' -- Visual
        .. '%#VisualColor#%{(mode()==#"V")  ? "   V·L  " : ""}' -- Visual Line
        .. '%#VisualColor#%{(mode()==#"") ? "   V·B  " : ""}' -- Visual Block
        .. '%#SelectColor#%{(mode()==#"s")  ? "    S   " : ""}' -- Select
        .. '%#SelectColor#%{(mode()==#"S")  ? "   S·L  " : ""}' -- Select Line
        .. '%#VisualColor#%{(mode()==#"") ? "   S·B  " : ""}' -- Select Block
        .. '%#NormalColor#%{(mode()==#"t")  ? "    T   " : ""}' -- Terminal
        .. '%#StatusLine# %f '                                  -- File name
        .. '%{&ro ? "⨯ " : ""}'                                 -- Read Only
        .. '%{&mod ? "⊙ " : ""}'                                -- Modified
        .. '%#StatusLine#%='                                    -- Spacer
        --.. '%3*%#SpellColor#%{&spell ? &spl : ""}%#StatusLine# '-- Spell check
        .. '%{&ff} '                                            -- File format
        .. '%{&fenc} '                                          -- Encoding
        .. '%{&ft!="" ? " ".&ft." " : ""} '                     -- File type
        .. '꠵  %3p%% '                                          -- Percentage
        .. '%3l:%-3c'                                           -- Line, Column

    -- TODO display lsp messages - lsp-status.nvim?

    return statusline
end

--so.statusline = '%!v:lua.create_statusline()'
so.statusline = createstatusline()

-- }}}


-- NvimTree ---------------------------------------------------------------- {{{

local nvimtree = { api = require('nvim-tree.api') }

local function nvim_tree_on_attach(bufnr)
    nvimtree.api.config.mappings.default_on_attach(bufnr)

    local function opts(desc)
        return {
            desc    = 'nvim-tree: ' .. desc,
            buffer  = bufnr,
            noremap = true,
            silent  = true,
            nowait  = true
        }
    end

    vim.keymap.set('n', '<Space>', nvimtree.api.node.open.edit, opts('Open'))
    vim.keymap.set('n', 'o', nvimtree.api.node.open.edit, opts('Open'))
    vim.keymap.set('n', '<LeftRelease>', nvimtree.api.node.open.edit, opts('Open'))
end

require('nvim-tree').setup {
    disable_netrw       = true,
    hijack_netrw        = true,
    open_on_tab         = false,
    hijack_cursor       = false,
    update_cwd          = false,

    actions = {
        open_file = {
            resize_window = false
        }
    },

    diagnostics = {
        enable = false,
    },

    filters = {
        dotfiles = false,
        custom   = {}
    },

    git = {
        enable  = true,
        ignore  = true,
        timeout = 500,
    },

    hijack_directories = {
        enable    = true,
        auto_open = true,
    },

    system_open = {
        cmd  = nil,
        args = {}
    },

    update_focused_file = {
        enable      = false,
        update_cwd  = false,
        ignore_list = {}
    },

    renderer = {
        root_folder_label = false,
        add_trailing      = true,
        highlight_git     = true,
        indent_markers    = {
            enable = true
        },
        icons = {
            show = {
                git          = false,
                folder       = true,
                file         = true,
                folder_arrow = false
            }
        },
        special_files      = {}
    },

    view = {
        cursorline     = false,
        width          = 30,
        side           = 'left',
        number         = false,
        relativenumber = false,
        signcolumn     = 'yes'
    },

    on_attach = nvim_tree_on_attach,

    trash = {
        cmd             = 'trash',
        require_confirm = true
    }
}

-- Blank statusline when NvimTree is focused
nvimtree.api.events.subscribe(nvimtree.api.events.Event.TreeOpen, function()
    wo.statusline = '%#StatusLine#'
end)

-- Hide cursor in NvimTree
vim.api.nvim_create_autocmd({ 'WinEnter', 'BufWinEnter' }, {
  pattern = 'NvimTree*',
  callback = function()
    local def = vim.api.nvim_get_hl_by_name('Cursor', true)
    vim.api.nvim_set_hl(0, 'Cursor', vim.tbl_extend('force', def, { blend = 100 }))
    so.guicursor:append('a:Cursor/lCursor')
  end,
})
vim.api.nvim_create_autocmd({ 'BufLeave', 'WinClosed' }, {
  pattern = 'NvimTree*',
  callback = function()
    local def = vim.api.nvim_get_hl_by_name('Cursor', true)
    vim.api.nvim_set_hl(0, 'Cursor', vim.tbl_extend('force', def, { blend = 0 }))
    so.guicursor = 'n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20'
  end,
})

-- }}}


-- Keybindings ------------------------------------------------------------- {{{

local function nnoremap(keys, cmd)
    vim.keymap.set('n', keys, cmd, { silent = true, noremap = true })
end

-- [Esc] + [Esc]: Unhighlight searches
nnoremap('<esc><esc>', ':silent! nohls<CR>')

-- ([Shift] +) [Tab]: Switch buffers
nnoremap('<Tab>', ':BufferNext<CR>')
nnoremap('<S-Tab>', ':BufferPrev<CR>')

-- Leader + [q]: Close buffer
nnoremap('<leader>q', ':BufferClose<CR>')

nnoremap('<C-p>', require('telescope.builtin').find_files)
nnoremap('<C-=>', require('telescope.builtin').live_grep)

-- Leader + [k]: Toggle invisible characters
nnoremap('<leader>k', ':setl list!<CR>')

-- Leader + [s]: Toggle spelling check
nnoremap('<leader>s', ':setl invspell<CR>')

-- Leader + [t]: NvimTree: Open
nnoremap('<leader>t', nvimtree.api.tree.toggle)

-- Leader + [/]: NvimTree: Find files
--nnoremap('<leader>/', nvimtree.api.tree.find_file)

-- }}}
