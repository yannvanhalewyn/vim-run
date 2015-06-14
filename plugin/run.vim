
let s:plugin_path = expand("<sfile>:p:h:h")

" ===============
" Main EntryPoint
" ===============
function! VimRun()
  let l:cmd = s:getCommandFrom(g:run_commands)
  let l:runner = s:getRunner()
  execute s:getExecution(l:runner, l:cmd)
endfunction

function! VimRunAlternate()
  let l:cmd = s:getCommandFrom(g:run_alternate_commands)
  let l:runner = s:getRunner()
  execute s:getExecution(l:runner, l:cmd)
endfunction

" Returns 1 if current pane is the active tmux pane HACK!!
function! s:InTmux()
  let views = split(system("tmux list-panes"), "\n")
  for view in views
    if match(view, "(active)") != -1
      return matchlist(view, '%[0-9]\+')[0] == $TMUX_PANE
    endif
  endfor
endfunction

" Returns the correct command as specified by g:run_commands dictionary
function! s:getCommandFrom(dictionary)
  let l:ft = &filetype
  for entry in keys(a:dictionary)
    for type in split(entry, ",")
      if type == l:ft
        return a:dictionary[entry]
      endif
    endfor
  endfor
  return ""
endfunction

" Returns the correct runner according to environment
function! s:getRunner()
  if exists("g:run_custom_runners[&filetype]")
    return g:run_custom_runners[&filetype]
  elseif index(g:run_ignore_env, &filetype) != -1
    return g:run_default_runner
  elseif s:InTmux()
    return g:run_tmux_runner
  elseif has("gui_running")
    return g:run_gui_runner
  endif
  return g:run_default_runner
endfunction

" Returns the executable string, replacing {cmd} and other wildcards
" in the given runner
function! s:getExecution(runner, cmd)
  let l:e = substitute(a:runner, "{cmd}", a:cmd, "g")
  let l:e = substitute(l:e, "{%}", expand("%:p"), "g")
  let l:e = substitute(l:e, "{.}", line("."), "g")
  return l:e
endfunction

function! s:init()
  if !exists("g:run_mapping")
    let g:run_mapping = '<leader>r'
  endif
  if !exists("g:run_alternate_mapping")
    let g:run_alternate_mapping = '<leader>R'
  endif
  if !exists("g:run_default_runner")
    let g:run_default_runner = '!{cmd}'
  endif
  if !exists("g:run_tmux_runner")
    let g:run_tmux_runner = 'call VimuxRunCommand("{cmd}")'
  endif
  if !exists("g:run_gui_runner")
    let g:run_gui_runner = 'silent !' . s:plugin_path . "/bin/execute_in_terminal '{cmd}'"
  endif
  if !exists("g:run_ignore_env")
    let g:run_ignore_env = ['vim']
  endif
  if !exists("g:run_custom_runners")
    let g:run_custom_runners = {'vim': "{cmd}"}
  endif
  if !exists("g:run_commands")
    let g:run_commands = {
  \   'cpp,java,make' : 'make run',
  \   'html,markdown' : 'open {%}',
  \   'javascript'    : 'npm start',
  \   'ruby'          : 'ruby {%}',
  \   'vim,conf'      : 'source {%}',
  \   'sh'            : '{%}'
  \ }
  endif
  if !exists("g:run_alternate_commands")
    let g:run_alternate_commands = {
  \   'cpp,java,make' : 'make clean',
  \   'javascript'    : 'node {%}'
  \ }
  endif
  map <Plug>(Run) :call Run()<CR>
  execute 'nnoremap ' . g:run_mapping . ' :call VimRun()<CR>'
  execute 'nnoremap ' . g:run_alternate_mapping . ' :call VimRunAlternate()<CR>'
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
