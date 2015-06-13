VIM-RUN
=======

Vim-run is born because I needed something to manage all my 'running' commands.  When working with many different filetypes, I need many different commands to run those files. And sometimes, when using Tmux, I need even more rules to define those commands. Does this sound familiar?

    au FileType ruby nnoremap <leader>r :!ruby %<CR>
    if exists('$TMUX')
      au FileType ruby nnoremap <leader>r :call VimuxRunCommand('ruby <c-r>%')<C-R>
    endif
    au FileType {cpp,make} nnoremap <leader>r :!make run<CR>
    if exists('$TMUX')
      au FileType {cpp,make} nnoremap <leader>r :call VimuxRunCommand('make run')<C-R>
    endif
    au FileType html nnoremap <leader>r :!open %<CR>
    au FileType vim nnoremap <leader>r :source %<CR>
    au FileType javascript nnoremap <Leader>r :!node <c-r>%<cr>
    if exists('$TMUX')
      au FileType javascript nnoremap <Leader>r :call VimuxRunCommand('node <c-r>%')<cr>
    endif

Needless to say, it's messy, and mildly annoying if you change your mind about one of the commands.

Vim-run abstracts you from all those autocommands, and executes the correct one at runtime. This makes is easier to add, edit or remove any needs you have in this area.

Usage
-----

**NOTE** Check the defaults below. It works right out of the box, you might not need any configuration.

### Defining the raw commands

set the `g:run_commands` dictionnary to map any filetype to it's run-command:

    let g:run_commands = {'cpp': 'make', 'ft': 'command'}

You can set multiple filetypes to the same command:

    let g:run_commands = {'cpp,make,java', 'make'}

**note**: You can modify this dictionary while vim is running.

#### Wildcards

Use wildcards to insert current filepath `{%}` or the current linenumber `{.}`

    let g:run_commands = {'ruby': 'ruby {%}', 'sh': './{%}'}

### Defining the runners

There are three runners (for now). A default runner, a gvim (or MacVim) runner and a runner for the Tmux environment. The `{cmd}` will be replaced by the command corresponding to the filetype.

    let g:run_default_runner = '!{cmd}'
    let g:run_gvim_runner = 'silent !run_in_terminal {cmd}'
    let g:run_tmux_runner = 'call VimuxRunCommand("{cmd}")'

You can also specify custom runners for a specific filetype. For example, all is well to run silent !{cmd} on most filetypes, but when sourcing .vim files, this doesn't work. The custom runner takes precedence over any other runners.

    let g:run_custom_runners = {'vim': '{cmd}'}

### Define the keystroke

Vim-run defaults to `<leader>r` (for "run"). If you dislike this mapping, you can override it:

    let g:run_mapping = 'yourMapping'

### Ignoring the Tmux runner for some filetypes

Sometimes you want a certain command to always be ran with the default runner. A .vim file is a good example of this. Running source *.vim in the shell is not very useful. `g:run_ignore_tmux` is an array of filetypes for which the tmux runner will be ignored and the default runner will be used.

    let g:run_ignore_tmux = ["vim"]

Defaults
--------

These are currently the defaults. They fit me well, please let me know if you dissagree. If this is what you need, no extra configuration is needed to make vim-run work:

    let g:run_mapping = '<leader>r'
    let g:run_default_runner = '!{cmd}'
    let g:run_tmux_runner = 'call VimuxRunCommand("{cmd}")'
    let g:run_ignore_tmux = ['vim']
    let g:run_custom_runners = {"vim": "{cmd}"}
    let g:run_commands = {
    \   'cpp,java,make' : 'make run',
    \   'html,markdown' : 'open {%}',
    \   'javascript'    : 'npm start',
    \   'ruby'          : 'ruby {%}',
    \   'vim,conf'      : 'source {%}',
    \   'sh'            : './{%}',
    \ }


Installation
------------

Using any package manager. Example for vim-plug:

    Plug 'yannvanhalewyn/vim-run'

Running tests
-------------

Tests are written using vim-vspec and run with vim-flavor.

Install the vim-flavor gem, install the dependencies and run the tests:

    gem install vim-flavor
    vim-flavor install
    rake

Note
----

I made this primarily for myself, and have only tried this on my machine, in terminal vim. Please let me know of any issues, and I'll try to fix'em. Pull requests are welcome!
