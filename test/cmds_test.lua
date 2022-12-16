#!/usr/bin/env lua
local helpers = require('libs.helpers')
local cmds    = require('cmds.cmds')

TestCmds = {} -- class
  local function runSlashCmd(action, value)
    helpers:Debug(action)
    SlashCmdList["at"](action, value)
  end

  function TestCmds:setUp()
    cmds:Initialize()
  end

  function TestCmds:test_no_command()
    local called = false

    cmds.subcommands["help"]["action"] = function()
      called = true
    end

    runSlashCmd()
    lu.assertTrue(called)
  end

  function TestCmds:test_help()
    local called = false

    cmds.subcommands["help"]["action"] = function()
      called = true
    end

    runSlashCmd("help", "")
    lu.assertTrue(called)
  end
