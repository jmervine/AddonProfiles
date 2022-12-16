local helpers = require('libs.helpers')
local core    = require('core.core')

local Cmds    = {} -- Class
  Cmds.commands = {
    "addontemplates",
    "at",
    "addons"
  }

  -- --------------------------------------------------------------------------
  -- Define command actions and helpers.
  local function _helpCmd(value)
    local cmds = table.concat(Cmds.commands, ", ")

    local ptrSubcmd = function(c)
      local info = Cmds.subcommands[c]
      local cmd

      for _, i in ipairs(Cmds.commands) do
        cmd = i
        break
      end

      local t = "/%s %s %s: %s"
      helpers:Print(string.format(t, cmd, c, info["usage"], info["description"]))
    end

    helpers:Print("Slash command aliases: " .. cmds .. ":")
    if not value or value == "" then
      helpers:Print("Subcommands:")
      for cmd, _ in pairs(Cmds.subcommands) do
        ptrSubcmd(cmd)
      end
      return
    end

    ptrSubcmd(value)
  end

  local function _nilValue(cmd)
    helpers:Error(string.format("'%s' function missing a required TEMPLATE!", cmd))
    _helpCmd(cmd)
  end

  local function _loadCmd(value)
    if not value or value == "" then
      _nilValue("load")
      return
    end

    core:LoadAddOnsTemplate(value)
    helpers:Print(string.format("'%s' loaded, type /reload to activate it, otherwise it will be active with your next login.", value))
  end

  local function _showCmd(value)
    if not value then value = "" end

    for tname, template in pairs(core.Templates) do
      if value == "" or value == tname then
        local addons = {}
        for aname, _ in pairs(template) do
          table.insert(addons, aname)
        end

        local t = "Template: %s, AddOns: %s"
        helpers:Print("Template: " .. tname)
        helpers:Print("  AddOns: " .. table.concat(addons, ", "))
      end
    end
  end

  local function _saveCmd(value)
    if not value or value == "" then
      _nilValue("save")
      return
    end

    core:SaveAddOnsTemplate(value)
    helpers:Print(string.format("'%s' saved.", value))
  end

  local function _removeCmd(value)
    if not value or value == "" then
      _nilValue("remove")
      return
    end

    core:RemoveAddOnsTemplate(value)
  end

  -- --------------------------------------------------------------------------
  -- Define command UX
  Cmds.subcommands = {
    [ "help" ] = {
      [ "description" ] = "Display slash command help message.",
      [ "usage"       ] = "[COMMAND]",
      [ "action"      ] = _helpCmd
    },
    [ "load" ] = {
      [ "description" ] = "Load AddOns from specified template.",
      [ "usage"       ] = "TEMPLATE_NAME",
      [ "action"      ] = _loadCmd
    },
    [ "show" ] = {
      [ "description" ] = "Show AddOns Templates, or contents of specified template.",
      [ "usage"       ] = "[TEMPLATE_NAME]",
      [ "action"      ] = _showCmd
    },
    [ "save" ] = {
      [ "description" ] = "Save current AddOn state as the named template.",
      [ "usage"       ] = "TEMPLATE_NAME",
      [ "action"      ] = _saveCmd
    },
    [ "remove" ] = {
      [ "description" ] = "Remove the saved template.",
      [ "usage"       ] = "TEMPLATE_NAME",
      [ "action"      ] = _removeCmd
    },
  }

  -- --------------------------------------------------------------------------
  -- Class Functions
  function Cmds:Initialize()
    for _, command in ipairs(Cmds.commands) do
      initCommand(command)
    end
  end

  function initCommand(command)
    helpers:Debug("Initialize command: " .. command)

    SlashCmdList[command] = exec
  end

  function exec(subcmd, value)
    if subcmd == nil then
      execCommand("help", "")
      return
    end

    execCommand(subcmd, value)
  end

  function execCommand(subcmd, value)
    if subcmd == nil then subcmd = "help" end
    if value == nil  then value = ""      end

    helpers:Debug("subcmd: '" .. subcmd .. "', value: '" .. value .. "'")
    Cmds.subcommands[subcmd]["action"](value)
  end

return Cmds
