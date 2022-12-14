local Core = {} -- Class

Core.DEBUG = false

-- ADDON_NAME: AddOnTemplates
Core.ADDON_NAME       = "AddOnTemplates"
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

function Core:SetAddOnState()
  local state = {}
  for i=1, GetNumAddOns(), 1 do
    local name, title, notes, loadable, reason, security, _ = GetAddOnInfo(i)
    local enabledState = GetAddOnEnableState(nil, name)

    -- TODO: Handle Character vs. Global enabled.
    -- TODO: Is this a number or a boolean? There's conflicting information. The docs
    --    say it should be a number 0=disabled, 1=enabled for some, 2=enabled for all.
    if Core.CurrentStateEnablement == (enabledState == true  or enabledState == 1 or enabledState == 2) then
      Core.CurrentStateEnablement = enabledState
    end

    Core:debug("state: " .. name .. ", enabledState: " .. enabledState)
    state[name] = {
      Index     = i,
      Name      = name,
      Title     = title,
      Notes     = notes,
      Loadable  = loadable,
      Reason    = reason,
      Security  = security,
      Installed = true,
      Enabled   = enabledState
    }
  end

  Core.CurrentState = state
end

function Core:LoadAddOnTemplates()
  Core.Templates = AddOnTemplates

  -- If there isn't an existing saved template, create one from the existing
  -- state.
  if not Core.Templates then
    Core:debug("Core.Templates = nil")
    Core.Templates = {}
  end

  if Core.Templates == {} then
    Core:debug("Core.Templates = {}")
    local template = Core:newTemplate()

    -- If all addons are disabled, return an empty template.
    if Core.CurrentStateEnablement == 0 then
      Core.Templates[Core.DEFAULT_TEMPLATE] = {}
      return
    end

    local name

    -- If there are character level addon toggles, then the default template
    -- should include the characters name.
    if Core.CurrentStateEnablement == 1 then
      name = Core:serverDefaultName()
    else
      name = Core.DEFAULT_TEMPLATE
    end

    Core.Templates[name] = template

    return
  end

  -- This assumes we've found some existing templates. We're going to loop through
  -- them and ensure that all templates are marked "Installed" correctly.
  for tname, template in pairs(Core.Templates) do
    Core:debug("Core.Templates: " .. tname)
    for aname, addon in pairs(template) do
      Core:debug("Core.Templates: " .. tname .. " " .. aname)
      if not Core.CurrentState[aname] then
        Core.Templates[tname][aname].Installed = false
        Core:debug("Core.Templates: " .. tname .. " " .. aname .. " IS MISSING")
      else
        for k, v in pairs(Core.CurrentState[aname]) do
          Core:debug("Core.Templates:" .. tname .. " " .. aname .. " " .. k .. " " .. tostring(v))
        end
      end
    end
  end
end

function Core:LoadAddOnsTemplate(tname)
  if not tname then
    tname = Core.DEFAULT_TEMPLATE
    if not Core.Templates[tname] then
      tname = Core:serverDefaultName()
    end
  end

  if not Core.Templates[tname] then
    err(tname .. " template, does not exist.")
    return
  end

  DisableAllAddOns()

  for _, addon in Core.Templates[tname] do
    if not addon.Installed then
      Core.warn(addon.Name .. " from " .. tname .. " template, is no longer installed.")
    elseif not addon.Loadable then
      Core.warn(addon.Name .. " from " .. tname .. " template, not loadable (Reason: " .. addon.Reason .. ").")
    else
      EnableAddOn(addon.Name, Core.GlobalAddOnState)
    end
  end
end

function Core:SaveAddOnsTemplate(tname)
  if not tname then
    if Core.CurrentState == 1 then
      tname = Core.Character .. "@Default"
    else
      tname = "Default"
    end
  end
end

-- Locals'ish, but not really
function Core:newTemplate()
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

function Core:warn(str)
  Core:msg("WARNING", str)
end

function Core:debug(str)
  if Core.DEBUG then
    Core:msg("DEBUG", str)
  end
end

function Core:err(str)
  Core:msg("ERROR", str)
end

function Core:msg(t, str)
  print(Core.ADDON_NAME .. ": [" .. t .. "] " .. str)
end

function Core:serverDefaultName()
  return Core.Character .. "@" .. Core.DEFAULT_TEMPLATE
end

return Core
