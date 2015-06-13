source plugin/run.vim

call vspec#hint({'scope': 'run#scope()', 'sid': 'run#sid()'})

describe "run"
  describe "s:init()"
    it "sets the correct defaults if none set"
      Expect g:run_mapping == '<leader>w'
      Expect g:run_default_runner == 'silent !{cmd}'
      Expect g:run_tmux_runner == 'call VimuxRunCommand("{cmd}")'
      Expect g:run_commands == {
      \   'cpp,java,make' : 'make run',
      \   'html,markdown' : 'open %',
      \   'js'            : 'node %',
      \   'ruby'          : 'ruby %',
      \   'vim'           : 'source %'
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
end
