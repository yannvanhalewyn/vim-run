
" ===============
" Main EntryPoint
" ===============
function! VimRun()
  let l:cmd = s:getCommand()
  let l:runner = s:getRunner()
  s:execute(l:cmd, l:runner)
endfunction

" Returns the correct command as specified by g:run_commands dictionary
function! s:getCommand()
  for entry in keys(g:run_commands)
    if match(entry, &filetype) != -1
      return g:run_commands[entry]
    endif
  endfor
  return ""
endfunction

" Returns the correct runner according to environment
function! s:getRunner()
  if exists("$TMUX")
    return g:run_tmux_runner
  else
    return g:run_default_runner
  endif
endfunction

function! s:execute(cmd, runner)
  execute substitute(a:runner, "{cmd}", a:cmd, "g")
endfunction

function! s:init()
  if !exists("g:run_mapping")
    let g:run_mapping = '<leader>w'
  endif
  if !exists("g:run_default_runner")
    let g:run_default_runner = 'silent !{cmd}'
  endif
  if !exists("g:run_tmux_runner")
    let g:run_tmux_runner = 'call VimuxRunCommand("{cmd}")'
  endif
  if !exists("g:run_commands")
    let g:run_commands = {
  \   'cpp,java,make' : 'make run',
  \   'html,markdown' : 'open %',
  \   'js'            : 'node %',
  \   'ruby'          : 'ruby %',
  \   'vim'           : 'source %'
  \ }
  endif
  map <Plug>(Run) :call Run()<CR>
  execute 'nnoremap ' . g:run_mapping . ' :call VimRun()'
endfunction

" begin vspec config
function! run#scope()
  return s:
endfunction

function! run#sid()
    return maparg('<SID>', 'n')
endfunction
nnoremap <SID> <SID>
" end vspec config

" =========================
" Initialize plugin on load
" =========================
call s:init()
