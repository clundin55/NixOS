vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.opt.laststatus = 2
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.spell = true
vim.opt.relativenumber = true
vim.opt.undofile = true
vim.opt.scrolloff = 8
vim.opt.colorcolumn = "120"
vim.opt.swapfile = false
vim.opt.completeopt = 'menuone,noselect'

local gh = function(x) return 'https://github.com/' .. x end

vim.pack.add({
  gh('folke/tokyonight.nvim'),
  gh('nvim-lua/plenary.nvim'),
  gh('tpope/vim-fugitive'),
  gh('tpope/vim-obsession'),
  gh('voldikss/vim-floaterm'),
  gh('nvim-tree/nvim-web-devicons'),
  gh('nvim-tree/nvim-tree.lua'),
  gh('nvim-treesitter/nvim-treesitter'),
  gh('hrsh7th/nvim-cmp'),
  gh('nvim-telescope/telescope.nvim'),
  gh('hrsh7th/cmp-nvim-lsp'),
  gh('hrsh7th/vim-vsnip'),
  gh('hrsh7th/cmp-vsnip'),
  gh('hrsh7th/cmp-buffer'),
  gh('nvim-lualine/lualine.nvim'),
  { src = gh('MeanderingProgrammer/render-markdown.nvim'), load = false },
})

-- Lazy-load render-markdown only for relevant filetypes
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "codecompanion" },
  once = true,
  callback = function() vim.cmd.packadd('render-markdown.nvim') end,
})

require'nvim-tree'.setup {}

require'nvim-treesitter'.install { 'rust', 'markdown', 'python', 'c', 'lua', 'nix' }

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'rust', 'markdown', 'python', 'c', 'lua', 'nix' },
  callback = function()
    vim.treesitter.start()
  end,
})

vim.cmd[[colorscheme tokyonight]]
require'tokyonight'.setup {
  transparent = true,
  styles = {
    sidebars = "transparent",
    floats = "transparent",
  },
}

local map = function(key, cmd, opts)
  vim.keymap.set('n', key, cmd, vim.tbl_extend('force', { noremap = true }, opts or {}))
end

map('<leader>o', ':NvimTreeToggle<cr>')
map('<leader>tc', ':FloatermNew<cr>')
map('<leader>tt', '<C-\\><c-n>:FloatermToggle<cr>')
map('<leader>ff', ':Telescope find_files<cr>')
map('<leader>fg', ':Telescope live_grep<cr>')
map('<leader>fgr', function() require'telescope.builtin'.lsp_references() end)
map('<leader>fb', ':Telescope buffers<cr>')
map('<leader>fh', ':Telescope help_tags<cr>')
map('<leader>fe', function() require'telescope.builtin'.diagnostics() end)
map('<leader>fw', function() require'telescope.builtin'.grep_string() end)
map('<leader>ft', function() require'telescope.builtin'.git_files() end)
map('<leader>fgs', function() require'telescope.builtin'.git_status() end)
map('<leader>fgc', function() require'telescope.builtin'.git_commits() end)

map('<leader>cb', ':! cargo build<CR>')
map('<leader>cc', ':! cargo check<CR>')
map('<leader>ct', ':! cargo test<CR>')
map('<leader>cl', ':! cargo clippy<CR>')
map('<leader>cf', ':! cargo fmt<CR>')
map('<leader>cd', ':! cargo doc --open<CR>')

map('<leader>ve', ':e ~/.config/nvim/init.lua<cr>')
map('<leader>vs', ':source ~/.config/nvim/init.lua<cr>')
map('<leader>vz', ':e ~/.zshrc<cr>')

-- Diagnostic keymaps (global, not LSP-specific)
-- <leader>e   open diagnostic float
-- <leader>[d  previous diagnostic
-- <leader>]d  next diagnostic
-- <leader>q   diagnostics to loclist
map('<leader>e', vim.diagnostic.open_float)
map('<leader>[d', vim.diagnostic.goto_prev)
map('<leader>]d', vim.diagnostic.goto_next)
map('<leader>q', vim.diagnostic.setloclist)

-- LSP keymaps, buffer-local on attach
--
-- Neovim built-in (global, always available):
--   grn        rename
--   gra        code action (normal + visual)
--   grr        references
--   gri        implementation
--   grt        type definition
--   grx        codelens run
--   gO         document symbols
--   K          hover
--   CTRL-S     signature help (insert mode)
--
-- Custom (set on LspAttach):
--   <leader>gD  declaration
--   <leader>C-k signature help (normal mode)
--   <leader>wa  add workspace folder
--   <leader>wr  remove workspace folder
--   <leader>wl  list workspace folders
--   <leader>f   format buffer
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local lmap = function(key, cmd, opts)
      vim.keymap.set('n', key, cmd, vim.tbl_extend('force', { noremap = true, buffer = ev.buf }, opts or {}))
    end
    lmap('<leader>gD', vim.lsp.buf.declaration)
    lmap('<leader><C-k>', vim.lsp.buf.signature_help)
    lmap('<leader>wa', vim.lsp.buf.add_workspace_folder)
    lmap('<leader>wr', vim.lsp.buf.remove_workspace_folder)
    lmap('<leader>wl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end)
    lmap('<leader>f', function() vim.lsp.buf.format() end)
  end,
})

vim.lsp.config('rust_analyzer', {
  cmd = { 'rust-analyzer' },
  filetypes = { 'rust' },
  root_markers = { 'Cargo.toml', 'Cargo.lock', '.git' },
})
vim.lsp.enable('rust_analyzer')

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
    component_separators = { left = '', right = ''},
    section_separators = { left = '', right = ''},
    disabled_filetypes = {},
    always_divide_middle = true,
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff',
                  {'diagnostics', sources={'nvim_lsp'}}},
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
  default = true,
}
