require("Libs.LUAUnit.WowStubs.SavedVariables")

SlashCmdList = {}

wowAddonsStub = {
  [1] = {
    _enabled = true, -- non-Bliz public state, using for testing.
    name     = "TestAddon_One",
    title    = "Test Addon Sub #1",
    notes    = "Test Addon Sub #1 Note",
    loadable = 1,
    reason   = nil,
    security = "INSECURE", -- default for all non Bliz addons
    dependencies = {} -- no dependencies
  },
  [2] = {
    _enabled = false, -- non-Bliz public state, using for testing.
    name     = "TestAddon_Two",
    title    = "Test Addon Sub #2",
    notes    = "Test Addon Sub #2 Note",
    loadable = 1,
    reason   = nil,
    security = "INSECURE", -- default for all non Bliz addons
    dependencies = { "TestAddon_One" } -- depends on TestAddon_One
  },
  [3] = {
    _enabled = false, -- non-Bliz public state, using for testing.
    name     = "TestAddon_Three",
    title    = "Test Addon Sub #3",
    notes    = "Test Addon Sub #3 Note",
    loadable = nil,
    reason   = "MISSING",
    security = "INSECURE", -- default for all non Bliz addons
    dependencies = {}
  },
  [4] = {
    _enabled = true, -- non-Bliz public state, using for testing.
    name     = "TestAddon_OutOfDate",
    title    = "Test Addon Out of Date",
    notes    = "Test Addon that is out of date",
    loadable = false,
    reason   = "INTERFACE_VERSION",
    security = "INSECURE", -- default for all non Bliz addons
    dependencies = {}
  }
}

wowAddonProfiles = {
  ["Default"] = { "TestAddon_One" },
  ["TestCharacter@Raiding"] = {
    "TestAddon_One", "TestAddon_One"
  }
}

-- WoW: Global functions
-- ref: https://wowwiki-archive.fandom.com/wiki/API_UnitName
function UnitName(_)
  return "TestCharacter"
end

-- ref: https://wowpedia.fandom.com/wiki/API_GetRealmName
function GetRealmName()
  return "TestRealm"
end

-- ref: https://wowpedia.fandom.com/wiki/API_UnitClass
function UnitClass(unit)
  return "Warrior", "WARRIOR"
end

-- ref: https://wowpedia.fandom.com/wiki/API_UnitRace
function UnitRace(unit)
  return "Human", "Human"
end

-- ref: https://wowpedia.fandom.com/wiki/API_UnitFactionGroup
function UnitFactionGroup(unit)
  return "Alliance", "Alliance"
end

-- ref: https://wowpedia.fandom.com/wiki/API_GetLocale
function GetLocale()
  return "enUS"
end

-- ref: https://wowpedia.fandom.com/wiki/API_GetCurrentRegion
function GetCurrentRegion()
  return 1 -- US region
end

-- ref: https://wowpedia.fandom.com/wiki/API_GetCVar
function GetCVar(cvar)
  return nil
end

-- ref: https://wowpedia.fandom.com/wiki/API_GetBuildInfo
function GetBuildInfo()
  return "1.15.7", "12345", "Oct 10 2024", 11507
end

-- ref: https://wowpedia.fandom.com/wiki/API_GetAddOnInfo
function GetAddOnInfo(a)
  -- check to see if it's a number
  n = tonumber(a)
  if n == nil then -- NaN
    for _, addon in ipairs(wowAddonsStub) do
      if addon.name == a then
        return addon.name, addon.title, addon.notes, addon.loadable, addon.reason, addon.security, nil
      end
    end
  end

  addon = wowAddonsStub[n]
  if not addon then
    return nil, nil, nil, nil, nil, nil, nil
  end

  return addon.name, addon.title, addon.notes, addon.loadable, addon.reason, addon.security, nil
end

-- ref: https://wowpedia.fandom.com/wiki/API_GetAddOnEnableState
function GetAddOnEnableState(_, a)
  for i, addon in pairs(wowAddonsStub) do
    if (addon.name == a or i == a) and (addon._enabled or addon.loadable) then
      return 2
    end
  end

  return 0
end

-- ref: https://wowpedia.fandom.com/wiki/API_GetNumAddons
function GetNumAddOns()
  if not wowAddonsStub then
    return 0
  end

  len = 0
  for _ in pairs(wowAddonsStub) do
    len = len + 1
  end

  return len
end

-- ref: https://wowpedia.fandom.com/wiki/API_EnableAddOn
function EnableAddOn(aname, _)
  for i, addon in pairs(wowAddonsStub) do
    if addon.name == aname or i == aname then
      wowAddonsStub[i]._enabled = true
      wowAddonsStub[i].loadable = 1
    end
  end
end

-- ref: https://wowpedia.fandom.com/wiki/API_DisableAddOn
function DisableAddOn(aname, _)
  for i, addon in pairs(wowAddonsStub) do
    if addon.name == aname or i == aname then
      wowAddonsStub[i]._enabled = false
      wowAddonsStub[i].loadable = false
    end
  end
end

-- ref: https://wowpedia.fandom.com/wiki/API_DisableAllAddOns
function DisableAllAddOns()
  for i, _ in pairs(wowAddonsStub) do
    wowAddonsStub[i]._enabled = false
  end
end

-- ref: https://wowpedia.fandom.com/wiki/API_GetAddOnDependencies
function GetAddOnDependencies(index)
  local addon = wowAddonsStub[index]
  if not addon or not addon.dependencies or #addon.dependencies == 0 then
    return -- Return nothing if no dependencies
  end
  
  -- Use table.unpack for Lua 5.2+ or unpack for Lua 5.1
  local unpack_func = table.unpack or unpack
  return unpack_func(addon.dependencies)
end

-- ref: https://wowpedia.fandom.com/wiki/API_IsAddOnLoadOnDemand
function IsAddOnLoadOnDemand(index)
  local addon = wowAddonsStub[index]
  if not addon then return false end
  -- For testing, return false (not load on demand)
  return false
end

-- ref: https://wowpedia.fandom.com/wiki/API_IsAddOnLoaded
function IsAddOnLoaded(index)
  local addon = wowAddonsStub[index]
  if not addon then return false end
  -- For testing, return true if addon is enabled
  return addon._enabled == true
end

-- Stub for C_Timer (used in Core.lua)
C_Timer = C_Timer or {}
function C_Timer.After(delay, callback)
  -- In tests, execute immediately
  if callback then
    callback()
  end
end

-- Stub for ReloadUI
function ReloadUI()
  -- In tests, do nothing
  print("ReloadUI() called (stub)")
end

-- Stub for time()
function time()
  return os.time()
end

-- support ace
local Frame = {}
function Frame:RegisterEvent(...)
  return {}
end

function Frame:SetScript(...)
  return {}
end

function Frame:AddMessage(...)
  return {}
end

DEFAULT_CHAT_FRAME = Frame

function CreateFrame(...)
  return Frame
end
