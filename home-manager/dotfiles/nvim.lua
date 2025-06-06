vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.opt.laststatus=2
vim.opt.tabstop=4
vim.opt.shiftwidth=4
vim.opt.softtabstop=4
vim.opt.expandtab=true
vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.spell = true
vim.opt.filetype = "on"
vim.opt.syntax = "on"
vim.opt.relativenumber = true
vim.opt.ruler = true
vim.opt.undofile = true
vim.opt.scrolloff = 8
vim.opt.hidden = true
vim.opt.colorcolumn="120"
vim.opt.swapfile = false

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    spec = {
        {
          "folke/tokyonight.nvim",
          opts = {
            transparent = true,
            styles = {
              sidebars = "transparent",
              floats = "transparent",
            },
          },
        },
        "shaunsingh/nord.nvim",
        "nvim-lua/plenary.nvim",
        "neovim/nvim-lspconfig",
        "tpope/vim-fugitive",
        "tpope/vim-obsession",
        "voldikss/vim-floaterm",
        "jremmen/vim-ripgrep",
        "kyazdani42/nvim-web-devicons",
        "kyazdani42/nvim-tree.lua",
        "nvim-treesitter/nvim-treesitter",
        "hrsh7th/nvim-cmp",
        "nvim-telescope/telescope.nvim",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/vim-vsnip",
        "hrsh7th/cmp-vsnip",
        "hrsh7th/cmp-buffer",
        "nvim-lualine/lualine.nvim",
        {
          "MeanderingProgrammer/render-markdown.nvim",
          ft = { "markdown", "codecompanion" }
        }
    }
})

require'nvim-tree'.setup {
}

require'nvim-treesitter.configs'.setup {
  ensure_installed = { "rust", "markdown", "python", "c", "lua", "nix" },
  sync_install = false,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
}

vim.cmd[[colorscheme tokyonight-night]]

vim.api.nvim_set_keymap('n', '<leader>o', ':NvimTreeToggle<cr>', {noremap=true})

vim.api.nvim_set_keymap('n', '<leader>tc', ':FloatermNew<cr>', {noremap=true})
vim.api.nvim_set_keymap('n', '<leader>tt', '<C-\\><c-n>:FloatermToggle<cr>', {noremap=true})

vim.api.nvim_set_keymap('n', '<leader>ff', ':Telescope find_files<cr>', {noremap=true})
vim.api.nvim_set_keymap('n', '<leader>fg', ':Telescope live_grep<cr>', {noremap=true})
vim.api.nvim_set_keymap('n', '<leader>fgr', [[:lua require'telescope.builtin'.lsp_references()<cr>]], {noremap=true})
vim.api.nvim_set_keymap('n', '<leader>fb', ':Telescope buffers<cr>', {noremap=true})
vim.api.nvim_set_keymap('n', '<leader>fh', ':Telescope help_tags<cr>', {noremap=true})
vim.api.nvim_set_keymap('n', '<leader>fe', [[:lua require'telescope.builtin'.diagnostics()<cr>]], {noremap=true})
vim.api.nvim_set_keymap('n', '<leader>fw', [[:lua require'telescope.builtin'.grep_string()<cr>]], {noremap=true})
vim.api.nvim_set_keymap('n', '<leader>ft', [[:lua require'telescope.builtin'.git_files()<cr>]], {noremap=true})
vim.api.nvim_set_keymap('n', '<leader>fgs', [[:lua require'telescope.builtin'.git_status()<cr>]], {noremap=true})
vim.api.nvim_set_keymap('n', '<leader>fgc', [[:lua require'telescope.builtin'.git_commits()<cr>]], {noremap=true})

vim.api.nvim_set_keymap('n', '<leader>cb', ':! cargo build<CR>', {noremap=true})
vim.api.nvim_set_keymap('n', '<leader>cc', ':! cargo check<CR>', {noremap=true})
vim.api.nvim_set_keymap('n', '<leader>ct', ':! cargo test<CR>', {noremap=true})
vim.api.nvim_set_keymap('n', '<leader>cl', ':! cargo clippy<CR>', {noremap=true})
vim.api.nvim_set_keymap('n', '<leader>cf', ':! cargo fmt<CR>', {noremap=true})
vim.api.nvim_set_keymap('n', '<leader>cd', ':! cargo doc --open<CR>', {noremap=true})

vim.api.nvim_set_keymap('n', '<leader>ve', ':e ~/.config/nvim/init.lua<cr>', {noremap=true})
vim.api.nvim_set_keymap('n', '<leader>vs', ':source ~/.config/nvim/init.lua<cr>', {noremap=true})
vim.api.nvim_set_keymap('n', '<leader>vz', ':e ~/.zshrc<cr>', {noremap=true})

local nvim_lsp = require('lspconfig')

local servers = { 'gopls', 'ccls', 'rust_analyzer' }
for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup {
    on_attach = on_attach,
    flags = {
      debounce_text_changes = 150,
    }
  }
end

vim.lsp.inlay_hint.enable(true)

vim.api.nvim_set_keymap('n', '<leader>gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', {noremap=true})
vim.api.nvim_set_keymap('n', '<leader>gd', '<cmd>lua vim.lsp.buf.type_definition()<CR>', {noremap=true})
vim.api.nvim_set_keymap('n', '<leader>K', '<cmd>lua vim.lsp.buf.hover()<CR>', {noremap=true})
vim.api.nvim_set_keymap('n', '<leader>gq', '<cmd>lua vim.lsp.buf.implementation()<CR>', {noremap=true})
vim.api.nvim_set_keymap('n', '<leader><C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', {noremap=true})
vim.api.nvim_set_keymap('n', '<leader>wa', '<cmd>lua vim.buf.add_workspace_folder()<CR>', {noremap=true})
vim.api.nvim_set_keymap('n', '<leader>wr', '<cmd>lua vim.buf.remove_workspace_folder()<CR>', {noremap=true})
vim.api.nvim_set_keymap('n', '<leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', {noremap=true})
vim.api.nvim_set_keymap('n', '<leader>D', '<cmd>lua vim.buf.type_definition()<CR>', {noremap=true})
vim.api.nvim_set_keymap('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', {noremap=true})
vim.api.nvim_set_keymap('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', {noremap=true})
vim.api.nvim_set_keymap('n', '<leader>gr', '<cmd>lua vim.lsp.buf.references()<CR>', {noremap=true})
vim.api.nvim_set_keymap('n', '<leader>e', '<cmd>lua vim.diagnostic.open_float()<CR>', {noremap=true})
vim.api.nvim_set_keymap('n', '<leader>[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', {noremap=true})
vim.api.nvim_set_keymap('n', '<leader>]d', '<cmd>lua vim.diagnostic.goto_next()<CR>', {noremap=true})
vim.api.nvim_set_keymap('n', '<leader>q', '<cmd>lua vim.diagnostic.set_loclist()<CR>', {noremap=true})
vim.api.nvim_set_keymap('n', '<leader>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', {noremap=true})

vim.o.completeopt = 'menuone,noselect'

local cmp = require 'cmp'
cmp.setup {
  mapping = {
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end,
    ['<S-Tab>'] = function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end,
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'path' },
    { name = 'buffer' },
  },
}

require'lualine'.setup {
  options = {
    icons_enabled = true,
    theme = 'dracula',
    component_separators = { left = '', right = ''},
    section_separators = { left = '', right = ''},
    disabled_filetypes = {},
    always_divide_middle = true,
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff',
                  {'diagnostics', sources={'nvim_lsp', 'coc'}}},
    lualine_c = { 
        { 'filename', file_status=true, path = 2}
    },
    lualine_x = {'encoding', 'fileformat', 'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'filename'},
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  extensions = {}
}

require'nvim-web-devicons'.setup {
 default = true;
}
