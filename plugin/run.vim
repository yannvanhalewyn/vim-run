
let s:plugin_path = expand("<sfile>:p:h:h")

" Restik <unique> here
nnoremap <silent> <Plug>Vimrun  :<C-U>call <SID>VimRun(g:vimrun_actions)<CR>
noremap  <silent> <Plug>VimrunAlternate :<C-U>call <SID>VimRun(g:vimrun_alternate_actions)<CR>

" ===============
" Main EntryPoint
" ===============
function! s:VimRun(actionset)
  let l:action = s:getActionFrom(a:actionset)
  let l:runner = s:getRunner()
  execute s:getExecution(l:runner, l:action)
endfunction

" Returns 1 if current pane is the active tmux pane HACK!!
function! s:InTmux()
  if !exists("$TMUX")
    return 0
  endif
  let views = split(system("tmux list-panes"), "\n")
  for view in views
    if match(view, "(active)") != -1
      return matchlist(view, '%[0-9]\+')[0] == $TMUX_PANE
    endif
  endfor
endfunction

" Returns the correct action as specified by g:vimrun_actions dictionary
function! s:getActionFrom(actionset)
  let l:ft = &filetype
  for entry in keys(a:actionset)
    for type in split(entry, ",")
      if type == l:ft
        return a:actionset[entry]
      endif
    endfor
  endfor
  return ""
endfunction

" Returns the correct runner according to environment
function! s:getRunner()
  if exists("g:vimrun_custom_runners[&filetype]")
    return g:vimrun_custom_runners[&filetype]
  elseif index(g:vimrun_ignore_env, &filetype) != -1
    return g:vimrun_default_runner
  elseif s:InTmux()
    return g:vimrun_tmux_runner
  elseif has("gui") && has("gui_running")
    return g:vimrun_gui_runner
  endif
  return g:vimrun_default_runner
endfunction

" Returns the executable string, replacing {cmd} and other wildcards
" in the given runner
function! s:getExecution(runner, action)
  let l:e = substitute(a:runner, "{cmd}", a:action, "g")
  let l:e = substitute(l:e, "{%}", expand("%:p"), "g")
  let l:e = substitute(l:e, "{d}", expand("%:p:h"), "g")
  let l:e = substitute(l:e, "{\\.}", line("."), "g")
  return l:e
endfunction

function! s:init()
  if !exists("g:vimrun_mapping")
    let g:vimrun_mapping = '<leader>r'
  endif
  if !exists("g:vimrun_alternate_mapping")
    let g:vimrun_alternate_mapping = '<leader>R'
  endif
  if !exists("g:vimrun_default_runner")
    let g:vimrun_default_runner = '!{cmd}'
  endif
  if !exists("g:vimrun_tmux_runner")
    let g:vimrun_tmux_runner = 'call VimuxRunCommand("{cmd}")'
  endif
  if !exists("g:vimrun_gui_runner")
    let g:vimrun_gui_runner = 'silent !' . s:plugin_path . "/bin/execute_in_terminal '{cmd}'"
  endif
  if !exists("g:vimrun_ignore_env")
    let g:vimrun_ignore_env = ['vim']
  endif
  if !exists("g:vimrun_custom_runners")
    let g:vimrun_custom_runners = {'vim': "{cmd}"}
  endif
  if !exists("g:vimrun_actions")
    let g:vimrun_actions = {
  \   'cpp,java,make' : 'make run',
  \   'html,markdown' : 'open {%}',
  \   'javascript'    : 'npm start',
  \   'ruby'          : 'ruby {%}',
  \   'vim,conf'      : 'source {%}',
  \   'sh'            : '{%}'
  \ }
  endif
  if !exists("g:vimrun_alternate_actions")
    let g:vimrun_alternate_actions = {
  \   'cpp,java,make' : 'make clean',
  \   'javascript'    : 'node {%}',
  \   'ruby'          : 'rake'
  \ }
  endif
  map <Plug>(Run) :call Run()<CR>
  execute 'nmap ' . g:vimrun_mapping . ' <Plug>Vimrun'
  execute 'nmap ' . g:vimrun_alternate_mapping . ' <Plug>VimrunAlternate'
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
