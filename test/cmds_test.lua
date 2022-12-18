TestCmds = {} -- class
  local function runSlashCmd(action, value)
    Helpers.Debug(action)
    SlashCmdList["at"](action, value)
  end

  function TestCmds:setUp()
    Cmds.Initialize()
  end

  function TestCmds:test_no_command()
    local called = false

    Cmds.subcommands["help"]["action"] = function()
      called = true
    end

    runSlashCmd()
    lu.assertTrue(called)
  end

  function TestCmds:test_help()
    local called = false

    Cmds.subcommands["help"]["action"] = function()
      called = true
    end

    runSlashCmd("help", "")
    lu.assertTrue(called)
  end
