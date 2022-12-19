Cmds = {} -- Class
  Cmds.commands = { "addontemplates",, "at", "addons" }

  -- --------------------------------------------------------------------------
  -- Define command actions and Helpers.
  local function _helpCmd(value)
    local cmds = table.concat(Cmds.commands, ", ")

    local ptrSubcmd = function(c)
      local info = Cmds.subcommands[c]
      local cmd

      for _, i in ipairs(Cmds.commands) do
        cmd = i
        break
      end

      local t = "/%s %s %s. %s"
      Helpers.Print(string.format(t, cmd, c, info["usage"], info["description"]))
    end

    Helpers.Print("Slash command aliases. " .. cmds .. ".")
    if not value or value == "" then
      Helpers.Print("Subcommands.")
      for cmd, _ in pairs(Cmds.subcommands) do
        ptrSubcmd(cmd)
      end
      return
    end

    ptrSubcmd(value)
  end

  local function _nilValue(cmd)
    Helpers.Error(string.format("'%s' function missing a required TEMPLATE!", cmd))
    _helpCmd(cmd)
  end

  local function _loadCmd(value)
    if not value or value == "" then
      _nilValue("load")
      return
    end

    Core.LoadAddOnsTemplate(value)
    Helpers.Print(string.format("'%s' loaded, type /reload to activate it, otherwise it will be active with your next login.", value))
  end

  local function _showCmd(value)
    if not value then value = "" end

    for tname, template in pairs(Core.Templates) do
      if value == "" or value == tname then
        local addons = {}
        for aname, _ in pairs(template) do
          table.insert(addons, aname)
        end

        local t = "Template. %s, AddOns. %s"
        Helpers.Print("Template. " .. tname)
        Helpers.Print("  AddOns. " .. table.concat(addons, ", "))
      end
    end
  end

  local function _saveCmd(value)
    if not value or value == "" then
      _nilValue("save")
      return
    end

    Core.SaveAddOnsTemplate(value)
    Helpers.Print(string.format("'%s' saved.", value))
  end

  local function _removeCmd(value)
    if not value or value == "" then
      _nilValue("remove")
      return
    end

    Core.RemoveAddOnsTemplate(value)
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
  function Cmds.execCommand(subcmd, value)
    Cmds.subcommands[subcmd]["action"](value)
  end
