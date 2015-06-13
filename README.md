" Map <leader>r to run files with some extensions
au FileType ruby       nnoremap <leader>r :!ruby %<CR>
au FileType {cpp,make} nnoremap <leader>r :!make run<CR>
au FileType html       nnoremap <leader>r :!open %<CR>
au FileType vim        nnoremap <leader>r :source %<CR>
if exists('$TMUX')
  au FileType javascript nnoremap <Leader>r :call VimuxRunCommand('node <c-r>%')<cr>
  au FileType {cpp,make} nnoremap <leader>r :call VimuxRunCommand('make run')<CR>
else
  au FileType javascript nnoremap <Leader>r :!node <c-r>%<cr>
  au FileType {cpp,make} nnoremap <leader>r :!make run<CR>
endif

au FileType javascript vnoremap <Leader>be d?describe<CR>o<CR>beforeEach(function() {<CR>});<esc>P<esc>
au FileType cpp        nnoremap <Leader>l :SyntasticCheck<CR>
au FileType cpp        set      softtabstop=4
au FileType cpp        set      shiftwidth=4
