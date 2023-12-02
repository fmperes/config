require("plugins")

-- Basic configs & Remaps
vim.g.mapleader = " "

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.enc = "utf-8"
vim.opt.fenc = "utf-8"
vim.opt.termencoding = "utf-8"
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.autoindent = true

vim.api.nvim_create_autocmd("FileType", {
    pattern = "tex",
    command = "setlocal shiftwidth=2 tabstop=2"
})

vim.opt.wrap = false
vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.config/nvim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.signcolumn = "no"

vim.opt.scrolloff = 8
vim.opt.updatetime = 50

vim.api.nvim_set_option("clipboard","unnamedplus")
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
vim.keymap.set({ 'n', 'v' }, '<C-c>', '"+y', { silent = true })
vim.keymap.set("n", "<leader>ex", vim.cmd.Ex)


vim.api.nvim_set_keymap("", "<C-b>", ":cex system('./build.sh') | copen<CR>", {expr = false, noremap = true})
--vim.api.nvim_set_keymap("", "<C-b>", ":make! | copen<CR>", {expr = false, noremap = true})

-- Compiler error detection
vim.api.nvim_create_autocmd("FileType", {
    pattern = "odin",
    command = "set errorformat=%f(%l:%c)\\ %m"
})
vim.api.nvim_create_autocmd({'BufNewfile', 'BufRead'}, {
    pattern = "*.glinc",
    command = "set filetype=glsl"
})


--TODO(FP): Figure out how to ignore NOTE highlighting

--
-- Plugins configuration
--

-- Telescope
require('telescope').setup({
    defaults = {
        sorting_strategy = "ascending",
        layout_config = {
            prompt_position = 'top';
        }
    }
})

local telescopeBLTN = require('telescope.builtin')
vim.keymap.set('n', '<leader>?', telescopeBLTN.oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader>fb', telescopeBLTN.buffers, { desc = '[F]ind in existing [B]uffers' })
vim.keymap.set('n', '<leader>fg', telescopeBLTN.git_files, { desc = '[F]ind in [G]it files' })
vim.keymap.set('n', '<leader>ff', "<cmd>Telescope find_files no_ignore=true<CR>", { desc = '[F]ind in all [Files]' })
vim.keymap.set('n', '<leader>fr', telescopeBLTN.live_grep, { desc = '[F]ind [R]eferences in files' })
vim.keymap.set('n', '<leader>fc', telescopeBLTN.resume,    { desc = '[F]ind [C]ontinue ' })
vim.keymap.set('n', '<leader>fp', function()
	telescopeBLTN.grep_string({ search = vim.fn.input("Grep > ") })
end)

-- Treesitter
require('nvim-treesitter.configs').setup {
	ensure_installed = { "c", "cpp", "javascript", "odin", "lua", "vim", "vimdoc" },
	sync_install = false,
	auto_install = false,


	highlight = {
        	enable = false,
        	additional_vim_regex_highlighting = false
    	},
    	indent = { enable = false },
}

-- Vim fugitive
vim.keymap.set("n", "<leader>gs", vim.cmd.Git)

-- Language Server Protocol

local lsp = require('lsp-zero')
lsp.preset('recommended')

lsp.ensure_installed({
  'ols',
})

local cmp = require('cmp')
local cmp_select = {behavior = cmp.SelectBehavior.Select}
local cmp_mappings = lsp.defaults.cmp_mappings({
  ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
  ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
  ['<C-y>'] = cmp.mapping.confirm({ select = true }),
  ['<C-Space>'] = cmp.mapping.complete(),
})


lsp.nvim_workspace()

lsp.setup_nvim_cmp({
  mapping = cmp_mappings
})

local lsp = require('lsp-zero')
lsp.setup()

local on_attach = function(_, bufnr)
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

  nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
  nmap('gr', require('telescopeBLTN').lsp_references, '[G]oto [R]eferences')
  nmap('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
  nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')

  -- See `:help K` for why this keymap
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

  -- Lesser used LSP functionality
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })
end

require('lspconfig').ols.setup({autostart = true})

-- Vim-airline
vim.g["airline_powerline_fonts"] = 1
vim.g["airline#extensions#tabline#enabled"] = 1
vim.g["airline_theme"] = "bubblegum"
vim.keymap.set('n', '<leader>bp', "<cmd>bprevious<CR>", {})
vim.keymap.set('n', '<leader>bn', "<cmd>bnext<CR>", {})
vim.keymap.set('n', '<leader>bd', "<cmd>bp|bd #<CR>", {})

-- Vimtex
vim.g["vimtex_view_general_viewer"] = "zathura"
vim.g["vimtex_view_method"] = "zathura"
vim.g["tex_flavor"] = "latex"
vim.g["vimtex_quickfix_open_on_warning"] = 0
vim.g["vimtex_quickfix_mode"] = 2
