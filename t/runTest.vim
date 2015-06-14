source plugin/run.vim

call vspec#hint({'scope': 'run#scope()', 'sid': 'run#sid()'})


describe "run"
  describe "s:init()"
    it "sets the correct defaults if none set"
      Expect g:run_mapping == '<leader>r'
      Expect g:run_alternate_mapping == '<leader>R'
      Expect g:run_default_runner == '!{cmd}'
      Expect g:run_tmux_runner == 'call VimuxRunCommand("{cmd}")'
      Expect g:run_gui_runner == 'silent !' . expand("%:p:h") . "/bin/execute_in_terminal '{cmd}'"
      Expect g:run_ignore_env == ['vim']
      Expect g:run_custom_runners == {"vim": "{cmd}"}
      Expect g:run_commands == {
      \   'cpp,java,make' : 'make run',
      \   'html,markdown' : 'open {%}',
      \   'javascript'    : 'npm start',
      \   'ruby'          : 'ruby {%}',
      \   'vim,conf'      : 'source {%}',
      \   'sh'            : '{%}'
      \ }
      Expect g:run_alternate_commands == {
      \   'cpp,java,make' : 'make clean',
      \   'javascript'    : 'node {%}'
      \ }
    end

    it "doesn't override user mappings"
      let g:run_mapping = "<leader>k"
      call Call("s:init")
      Expect g:run_mapping == "<leader>k"
    end
  end

  describe "s:getCommandFrom()"
    it "returns the correct mapping if exists (single)"
      let l:commands={'ruby': 'ruby %'}
      set ft=ruby
      Expect Call("s:getCommandFrom", l:commands) == "ruby %"
    end

    it "returns the correct mapping if exists (multi)"
      let l:commands={'html,markdown,txt': 'open %'}
      set ft=markdown
      Expect Call("s:getCommandFrom", l:commands) == "open %"
    end

    it "returns an empty string if no cmd exists"
      set ft=invalidFT
      Expect Call("s:getCommandFrom", g:run_commands) == ""
    end

    it "returns an empty string if no filetype"
      set ft=
      Expect Call("s:getCommandFrom", g:run_commands) == ""
    end
  end

  describe "s:getRunner()"
    " If anyone has an idea on how to stub has("gui") and exists("$TMUX"),
    " please let me know!
    it "returns the correct command (run this in and out of tmux, can't stub)"
      if Call("s:InTmux")
        let g:run_tmux_runner = "TMUX command {cmd}"
        Expect Call("s:getRunner") == "TMUX command {cmd}"
      else
        let g:run_default_runner = "DEFAULT command {cmd}"
        Expect Call("s:getRunner") == "DEFAULT command {cmd}"
      endif
    end

    it "uses default runner if ft is specified in g:run_ignore_env"
      set ft=cpp
      let g:run_default_runner = "DEFAULT command {cmd}"
      let g:run_ignore_env = ['cpp']
      Expect Call("s:getRunner") == "DEFAULT command {cmd}"
    end

    it "uses custom runner if any"
      set ft=vim
      let g:run_custom_runners = {"vim": "{cmd}"}
      Expect Call("s:getRunner") == "{cmd}"
    end

    it "returns the guivim runner if guivim"
      set ft=Any
      if !exists("$TMUX")
        let g:run_gui_runner = "GUI command {cmd}"
        Expect Call("s:getRunner") == "GUI command {cmd}"
      endif
    end
  end

  describe "s:getExecution()"
    it "replaces {cmd} in the runner"
      Expect Call("s:getExecution",  "silent !{cmd}",  "open someFile") ==
            \ "silent !open someFile"
    end

    it "replaces a {%} wildcard"
      edit tmp.js " set buffername
      let l:path = expand("%:p")
      Expect Call("s:getExecution",  "silent !{cmd}",  "open {%}") ==
          \ "silent !open " . l:path
    end

    it "replaces a {.} wildcard"
      normal yyppp " Add three lines (aka 4 total)
      Expect Call("s:getExecution",  "silent !{cmd}",  "echo {.}") ==
          \ "silent !echo 4"
    end
  end
end
