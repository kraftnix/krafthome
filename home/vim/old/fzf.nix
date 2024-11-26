{ pkgs, ... }:
{
  plugin = pkgs.vimPlugins.fzf-vim;
  config = ''
    set rtp+=${pkgs.fzf}/bin/fzf

    " 'bg' changed from Normal to ErrorMsg so not overrode by transparent conf
    let g:fzf_colors =
    \ { 'fg':      ['fg', 'Normal'],
      \ 'bg':      ['bg', 'ErrorMsg'],
      \ 'hl':      ['fg', 'Comment'],
      \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
      \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
      \ 'hl+':     ['fg', 'Statement'],
      \ 'info':    ['fg', 'PreProc'],
      \ 'border':  ['fg', 'Ignore'],
      \ 'prompt':  ['fg', 'Conditional'],
      \ 'pointer': ['fg', 'Exception'],
      \ 'marker':  ['fg', 'Keyword'],
      \ 'spinner': ['fg', 'Label'],
      \ 'header':  ['fg', 'Comment'] }


    " allows cycling back through history (ctrl-p)
    let g:fzf_history_dir = '~/.local/share/fzf-history'

    " remap up/down in fzf window
    cnoremap <c-k> <c-p>
    cnoremap <c-j> <c-n>

    " f -> find (fzf)
    inoremap <expr> <plug>(fzf-complete-path) fzf#vim#complete#path("fd . --color=never")
    inoremap <expr> <plug>(fzf-complete-file)  fzf#vim#complete#path("fd --type f . --color=never")
    imap <c-f> <plug>(fzf-complete-path)
    nmap <leaer><tab> <plug>(fzf-maps-n)
    xmap <leader><tab> <plug>(fzf-maps-x)
    omap <leader><tab> <plug>(fzf-maps-o)
    nnoremap <leader>; :History:<CR>
    nnoremap <leader>/ :FzfPreviewLines<CR>
    nnoremap <leader>? :Lines<CR>
    nnoremap <leader>fa :FzfPreviewMru<CR>
    " nnoremap <leader>ff :Files .<CR>
    " nnoremap <leader>fF :Files
    nnoremap <leader>f~ :Files ~<CR>
    nnoremap <leader>f/ :Files /<CR>
    nnoremap <leader>fs :<C-u>FzfPreviewGitStatus -processors=g:fzf_preview_fugitive_processors<CR>
    nnoremap <leader>fS :FzfPreviewChanges<CR>
    nnoremap <leader>fq :FzfPreviewQuickFix<CR>
    nnoremap <leader>fj :FzfPreviewJumps<CR>
    nnoremap <leader>fn :Maps<CR>
    nnoremap <leader>fg :Rg<CR>
    nnoremap <leader>fG :Rg
    nnoremap <leader>fc :GCheckout<CR>
    " nnoremap <silent> <Leader>fb :FzfPreviewBuffers<CR>
    nnoremap <silent> <Leader>fb :Buffers<CR>


    " fzf git checkout via GCheckout
    function! s:open_branch_fzf(line)
      let l:parser = split(a:line)
      let l:branch = l:parser[0]
      if l:branch ==? '*'
        let l:branch = l:parser[1]
      endif
      execute '!git checkout ' . l:branch
    endfunction

    command! -bang -nargs=0 GCheckout
      \ call fzf#vim#grep(
      \   'git branch -v', 0,
      \   {
      \     'sink': function('s:open_branch_fzf')
      \   },
      \   <bang>0
      \ )
  '';
}
