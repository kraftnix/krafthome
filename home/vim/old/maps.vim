" onoremap ie :exec "normal! ggVG"<cr>
cnoremap <c-f> <c-f>?
cnoremap <c-k> <c-p>
cnoremap <c-j> <c-n>
nnoremap <C-L> :nohl<CR>

" escape in :term
tnoremap <Esc> <C-\><C-n>
tnoremap <C-\><C-n> <Esc>

" movement
nnoremap <leader>. :<Up><CR>
nnoremap <leader>- <C-^>
nnoremap <leader>j <C-W>j
nnoremap <leader>k <C-W>k
nnoremap <leader>l <C-W>l
nnoremap <leader>h <C-W>h
nnoremap <leader>J <C-W>J
nnoremap <leader>K <C-W>K
nnoremap <leader>L <C-W>L
nnoremap <leader>H <C-W>H

" closing
nnoremap <leader>wq :close<CR>
nnoremap <leader>wQ :close!<CR>
" nnoremap <leader>bd :bd<CR>
" nnoremap <leader>bD :bd!<CR>
" nnoremap <leader>bw :bw<CR>
" nnoremap <leader>bW :bw!<CR>

" quickfix
let g:toggle_list_no_mappings=1
nnoremap <silent> <Leader>qq :call ToggleQuickfixList()<CR>
nnoremap <silent> <Leader>ql :call ToggleLocationList()<CR>

" remaps
cmap <c-k> <c-p>
cmap <c-j> <c-n>
cmap <c-h> <Left>
cmap <c-l> <Right>
nnoremap <Up> <Up><Up><Up><Up><Up>
nnoremap <Down> <Down><Down><Down><Down><Down>
nnoremap <Left> <Left><Left><Left><Left><Left>
nnoremap <Right> <Right><Right><Right><Right><Right>

" expansions
cnoremap <c-s> <c-r>=luaeval('')<Left><Left>
inoremap <c-s> <c-r>=luaeval('')<Left><Left>
cnoremap <c-d> <c-r>=expand('')<Left><Left>
inoremap <c-d> <c-r>=expand('')<Left><Left>

" Ranger
nnoremap <silent> <leader>- :RangerEdit<CR>
nnoremap <silent> <leader>_ :RangerTab<CR>

" compe completion
" inoremap <silent><expr> <C-Space> compe#complete()
" inoremap <silent><expr> <CR>      compe#confirm('<CR>')
" inoremap <silent><expr> <C-e>     compe#close('<C-e>')
" inoremap <silent><expr> <C-f>     compe#scroll({ 'delta': +4 })
" inoremap <silent><expr> <C-d>     compe#scroll({ 'delta': -4 })

" Undo
nnoremap <silent> <leader>u :UndotreeToggle<CR>

" Telescope
nnoremap <silent> <leader>ff :Telescope find_files<CR>
nnoremap <silent> <leader>tt :Telescope<CR>
nnoremap <silent> <leader>tc :Telescope commands<CR>
nnoremap <silent> <leader>th :Telescope command_history<CR>
nnoremap <silent> <leader>ts :Telescope git_status<CR>
nnoremap <silent> <leader>tm :Telescope keymaps<CR>
nnoremap <silent> <leader>tg :Telescope live_grep<CR>
nnoremap <silent> <leader>w :Telescope buffers<CR>
nnoremap <silent> <leader>fF :Files<CR>
nnoremap <silent> <leader>fd :lua require'telescope.builtin'.find_files({ search_dirs={'~/dotfiles'} })<CR>
nnoremap <silent> <leader>f~ :Files ~<CR>
nnoremap <silent> <Leader>f. :Files %:h<CR>
nnoremap <silent> <Leader>f. :lua require'telescope.builtin'.find_files({ search_dirs={"%:h"} })<CR>
" nnoremap <silent> <leader>fw :lua require'telescope.builtin'.find_files({ search_dirs={'~/Dropbox/org'} })<CR>
nnoremap <silent> <leader>fw :lua WikiPicker()<CR>
nnoremap <silent> <leader>of :lua WikiPicker()<CR>
nnoremap <leader>f<Space> :Files<Space>
nnoremap <silent> <Leader>fb :lua require'telescope.builtin'.buffers({sort_lastused = false; ignore_current_buffer = true, show_all_buffers = true, sorter = require'telescope.sorters'.get_substr_matcher()})<CR>
nnoremap <silent> <Leader>fB :Buffers<CR>
nnoremap <silent> <Leader>fq :Telescope quickfix<CR>
nnoremap <silent> <Leader>fh :lua FFHistoryPicker()<CR>
nnoremap <silent> <Leader>fm :Telescope lsp_document_symbols<CR>
nnoremap <silent>  <leader>; :Telescope command_history<CR>
nnoremap <leader>fo :lua SessionPicker()<CR>
nnoremap <leader>fs :lua SshPicker(false)<CR>
nnoremap <leader>fS :lua SshPicker(true)<CR>
nnoremap <leader>fp :lua PsqlPicker()<CR>
nnoremap <leader>fk :lua K8sPods()<CR>
inoremap <expr> <plug>(fzf-complete-path) fzf#vim#complete#path("fd . --color=never")
imap <c-x><c-f> <plug>(fzf-complete-path)
nnoremap <leader>cg :Gcd<CR>
nnoremap <leader>cl :lcd %:h<CR>
nnoremap <leader>cf :Cdz<CR>
nnoremap <leader>ch :cd ~<CR>
nnoremap <leader>c. :Cd .<CR>
nnoremap <leader>c<space> :Cd<space>

" lsp
nnoremap <leader>id :lua vim.lsp.buf.definition()<CR>
nnoremap <leader>iD :lua vim.lsp.buf.type_definition()<CR>
nnoremap <silent> [d :lua vim.lsp.diagnostic.goto_prev()<CR>
nnoremap <silent> ]d :lua vim.lsp.diagnostic.goto_next()<CR>
nnoremap <leader>ir :Telescope lsp_references<CR>
nnoremap <leader>iR :Telescope lsp_implemenations<CR>
nnoremap <Leader>ie :Telescope lsp_document_diagnostics<CR>
nnoremap <leader>im :WorkspaceSymbols<CR>
nnoremap <leader>iM :DocumentSymbols<CR>
nnoremap <leader>in :lua vim.lsp.buf.rename()<CR>
nnoremap <leader>if :lua vim.lsp.buf.formatting()<CR>
vnoremap <leader>if :lua vim.lsp.buf.range_formatting()<CR>
nnoremap <leader>ii :lua vim.lsp.buf.code_action()<CR>
nnoremap <leader>is :SymbolsOutline<CR>
nnoremap <silent> K :lua require('lspsaga.hover').render_hover_doc()<CR>
nnoremap <silent> KK :lua require('lspsaga.hover').render_hover_doc()<CR>
nnoremap <silent> KS :lua require('lspsaga.signaturehelp').signature_help()<CR>
nnoremap <silent> KD :lua require'lspsaga.provider'.preview_definition()<CR>
nnoremap <silent> KE :lua require'lspsaga.diagnostic'.show_line_diagnostics()<CR>
nmap KG <Plug>(git-messenger)

" vsnip
imap <expr> <Tab>   vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : '<Tab>'
smap <expr> <Tab>   vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : '<Tab>'
imap <expr> <S-Tab> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'
smap <expr> <S-Tab> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'
imap <expr> <A-l>   vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : '<Tab>'
smap <expr> <A-l>   vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : '<Tab>'
imap <expr> <A-h>   vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)'      : '<C-h>'
smap <expr> <A-h>   vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)'      : '<C-h>'



" yoink shortcuts
" nmap <c-n> <plug>(YoinkPostPasteSwapBack)
" nmap <c-p> <plug>(YoinkPostPasteSwapForward)
" nmap p <plug>(YoinkPaste_p)
" nmap P <plug>(YoinkPaste_P)

" Subversive shortcuts
" nmap s <plug>(SubversiveSubstitute)
" nmap ss <plug>(SubversiveSubstituteLine)
" nmap S <plug>(SubversiveSubstituteToEndOfLine)
" inoremap <expr> <C-j> pumvisible() ? "\<C-N>" : "\<C-j>"
" inoremap <expr> <C-k> pumvisible() ? "\<C-P>" : "\<C-k>"

" nnoremap <leader>dd :Bdelete<CR>
" nnoremap <leader>dD :bufdo bwipeout<CR>
" nnoremap <leader>m :TableModeToggle<CR>
" nnoremap <leader>z :tabe %<CR>
" nnoremap <leader>u :UndotreeToggle<CR>
" xnoremap <leader>n :normal <CR>
" nnoremap <leader>o :Obsess  ~/.local/share/nvim/sessions/
" nnoremap <leader>O :Obsess!<CR>


" t -> Tests
" nnoremap <leader>tn :TestNearest<CR>
" nnoremap <leader>tf :TestFile<CR>
" nnoremap <leader>ts :TestSuite<CR>
" nnoremap <leader>tl :TestLast<CR>

