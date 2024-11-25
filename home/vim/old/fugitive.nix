{pkgs, ...}: {
  plugin = pkgs.vimPlugins.vim-fugitive;
  config = ''
    " g -> git (fugitive)
    nnoremap <leader>gg :Git<Space>
    nnoremap <leader>gs :Git<CR>
    nnoremap <leader>ga :GitGutterStageHunk<CR>
    nnoremap <leader>gu :GitGutterUndoHunk<CR>
    nnoremap <leader>gw :Gwrite<CR><CR>
    nnoremap <leader>gc :Gcommit -v -q<CR>
    nnoremap <leader>gC :Gcommit -v -q --amend<CR>
    nnoremap <leader>gd :Gdiff<CR>
    nnoremap <leader>gD :Git diff<CR>
    nnoremap <leader>gr :Grebase --interactive<Space>
    nnoremap <leader>gR :Grebase<Space>
    nnoremap <leader>gb :Gblame<CR>
    nnoremap <leader>go :Git checkout<Space>
    nnoremap <leader>gO :Git branch<Space>
    nnoremap <leader>gl :Commits<CR>
    nnoremap <leader>gL :BCommits<CR>
    nnoremap <leader>gpp :Git push<CR>
    nnoremap <leader>gpP :Git pull<CR>
    nnoremap <leader>gj :GitGutterNextHunk<CR>
    nnoremap <leader>gk :GitGutterPrevHunk<CR>
    nnoremap <leader>gB :.Gbrowse<CR>
    vnoremap <leader>gB :Gbrowse<CR>
  '';
}
