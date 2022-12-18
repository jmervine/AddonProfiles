Core = {} -- Class
  Core.DEFAULT_TEMPLATE = "Default"

  -- Current Character
  Core.Character = UnitName("player")

  -- If "true", saves addon state enablement for all characters. Otherwise, only
  -- saves for the current character.
  Core.GlobalAddOnState = false

  -- Store AddOnTemplates once loaded.
  if not AddOnTemplates then
    AddOnTemplates = {}
  end

  Core.Templates = AddOnTemplates

  -- Other useful module globals
  Core.CurrentStateEnablement = 0
  Core.CurrentState = {}

  function Core.Initialize()
    Core.Templates = AddOnTemplates

    Core.SetAddOnState()
    Core.LoadAddOnTemplates()
  end

  function Core.SetAddOnState()
    local state = {}

    for i=1, GetNumAddOns(), 1 do
      local name, title, notes, loadable, reason, security, _ = GetAddOnInfo(i)
      local es = GetAddOnEnableState(nil, name)

      -- TODO. Handle Character vs. Global enabled.
      -- TODO. Is this a number or a boolean? There's conflicting information. The docs
      --    say it should be a number 0=disabled, 1=enabled for some, 2=enabled for all.
      local cse = Core.CurrentStateEnablement
      if (cse == 0 or not cse) and (es == true or es == 1 or es == 2) then
        Core.CurrentStateEnablement = es
      end

      Helpers.Debug("addon. " .. name .. ", enabledState. " .. es)
      state[name] = {
        Index     = i,
        Name      = name,
        Title     = title,
        Notes     = notes,
        Loadable  = loadable,
        Reason    = reason,
        Security  = security,
        Installed = true,
        Enabled   = es
      }
    end

    Core.CurrentState = state
  end

  local function loadTemplates()
    -- If there isn't an existing saved template, create one from the existing
    -- state.
    if not Core.Templates then
      Helpers.Debug("Core.Templates = nil")
      Core.Templates = {}
    end

    -- empty
    if next(Core.Templates) == nil then
      Helpers.Debug("Core.Templates = {}")
      local template = Core.newTemplate()

      -- If all addons are disabled, return an empty template.
      if Core.CurrentStateEnablement == 0 then
        Core.Templates[Core.DEFAULT_TEMPLATE] = {}
        return
      end

      local name

      -- If there are character level addon toggles, then the default template
      -- should include the characters name.
      if Core.CurrentStateEnablement == 1 then
        name = Core.characterDefaultName()
      else
        name = Core.DEFAULT_TEMPLATE
      end

      Core.Templates[name] = template

      return
    end
  end

  local function filterUninstalledAddOns()
    -- This assumes we've found some existing templates. We're going to loop through
    -- them and ensure that all templates are marked "Installed" correctly.
    for tname, template in pairs(Core.Templates) do
      for aname, addon in pairs(template) do
        if not Core.CurrentState[aname] then
          Helpers.Debug("Core.Templates. " .. tname .. " " .. aname .. " IS MISSING")
          Core.Templates[tname][aname].Installed = false
        end
      end
    end
  end

  function Core.LoadAddOnTemplates()
    loadTemplates()
    filterUninstalledAddOns()
  end

  function Core.LoadAddOnsTemplate(tname)
    if not Core.Templates[tname] then
      Helpers.Error(tname .. " template, does not exist.")
      return
    end

    DisableAllAddOns()

    for _, addon in pairs(Core.Templates[tname]) do
      if not addon.Installed then
        Helpers.Warn(addon.Name .. " from " .. tname .. " template, is no longer installed.")
      elseif not addon.Loadable then
        Helpers.Warn(addon.Name .. " from " .. tname .. " template, not loadable (Reason. " .. addon.Reason .. ").")
      else
        EnableAddOn(addon.Name, Core.GlobalAddOnState)
      end
    end
  end

  function Core.SaveAddOnsTemplate(tname)
    local template = Core.Templates[tname]
    if not template then
      Core.Templates[tname] = {}
    end

    for aname, addon in pairs(Core.CurrentState) do
      if addon.Enabled then
        Core.Templates[tname][aname] = addon
      end
    end

    -- Saved to SavedVariables global.
    Core.commit()
  end

  function Core.RemoveAddOnsTemplate(tname)
    local addon = Core.Templates[tname]

    if not addon then
      Helpers.Error(string.format("'%s' was not found to be removed.", tname))
      return
    end

    local t = {}

    for n, v in pairs(Core.Templates) do
      if tname == n then
        Helpers.Print("Found and removing. " .. tname)
      else
        t[n] = v
      end
    end

    Core.Templates = t
    Core.commit()
  end

  -- Locals'ish, but not really
  function Core.commit()
    AddOnTemplates = Core.Templates
  end

  function Core.newTemplate()
    local template = {}

    if not Core.CurrentState then
      return {}
    end

    for _, addon in pairs(Core.CurrentState) do
      if addon.Enabled > 0 then
        template[addon.Name] = addon
      end
    end

    return template
  end


  function Core.characterDefaultName()
    return Core.Character .. "@" .. Core.DEFAULT_TEMPLATE
  end
