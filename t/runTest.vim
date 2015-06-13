source plugin/run.vim

call vspec#hint({'scope': 'run#scope()', 'sid': 'run#sid()'})

describe "run"
  describe "s:init()"
    it "sets the correct defaults if none set"
      Expect g:run_mapping == '<leader>r'
      Expect g:run_default_runner == 'silent !{cmd}'
      Expect g:run_tmux_runner == 'call VimuxRunCommand("{cmd}")'
      Expect g:run_commands == {
      \   'cpp,java,make' : 'make run',
      \   'html,markdown' : 'open {%}',
      \   'javascript'    : 'node {%}',
      \   'ruby'          : 'ruby {%}',
      \   'vim'           : 'source {%}'
      \ }
    end

    it "doesn't override user mappings"
      let g:run_mapping = "<leader>k"
      call Call("s:init")
      Expect g:run_mapping == "<leader>k"
    end
  end

  describe "s:getCommand()"
    it "returns the correct mapping if exists (single)"
      let g:run_commands={'ruby': 'ruby %'}
      set ft=ruby
      Expect Call("s:getCommand") == "ruby %"
    end

    it "returns the correct mapping if exists (multi)"
      let g:run_commands={'html,markdown,txt': 'open %'}
      set ft=markdown
      Expect Call("s:getCommand") == "open %"
    end

    it "returns an empty string if no cmd exists"
      set ft=invalidFT
      Expect Call("s:getCommand") == ""
    end

  end

  describe "s:getRunner()"
    it "returns the correct command (run this in and out of tmux, can't stub)"
      if exists("$TMUX")
        let g:run_tmux_runner = "TMUX command {cmd}"
        Expect Call("s:getRunner") == "TMUX command {cmd}"
      else
        let g:run_default_runner = "DEFAULT command {cmd}"
        Expect Call("s:getRunner") == "DEFAULT command {cmd}"
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
      Expect Call("s:getExecution",  "silent !{cmd}",  "open {%}") ==
          \ "silent !open tmp.js"
    end

    it "replaces a {.} wildcard"
      normal yyppp " Add three lines (aka 4 total)
      Expect Call("s:getExecution",  "silent !{cmd}",  "echo {.}") ==
          \ "silent !echo 4"
    end
  end
end
