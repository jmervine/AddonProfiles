-- Build "AddonProfiles" addon.
local AceAddon = LibStub("AceAddon-3.0")

AddonProfiles = AceAddon:NewAddon("AddonProfiles", "AceConsole-3.0", "AceSerializer-3.0")

AddonProfiles.ADDON_NAME = "AddonProfiles"
AddonProfiles.DefaultProfile = string.format("%s@Default", UnitName("player"))

function AddonProfiles:OnInitialize()
  if not AddonProfilesStore or next(AddonProfilesStore) == nil then
    AddonProfilesStore = {
      [self.DefaultProfile] = self:getAddons()
    }
  end

  if self.LibsUI then
    self:InitializeUI()
  end

  self:Print("Welcome! Type '/addonprofiles' to get started.")
end


AddonProfiles.SlashCommands = "addonprofiles"
AddonProfiles.SlashAliases = { "ap", "addons" }

AddonProfiles.HelpMessages = {
  ["help"] = {
    desc = "Show help message.",
    opts = "[SUBCOMMAND]"
  },
  ["addons"] = {
    desc = "List currently enabled Addons.",
    opts = ""
  },
  ["show"] = {
    desc = "Show saved profile or profiles.",
    opts = "[PROFILE]"
  },
  ["load"] = {
    desc = "Load saved 'PROFILE'.",
    opts = "PROFILE"
  },
  ["save"] = {
    desc = "Saved current Addon state as 'PROFILE'.",
    opts = "PROFILE"
  },
  ["import"] = {
    desc = "Open GUI for importing exported profiles string.",
    opts = ""
  },
  ["export"] = {
    desc = "Open GUI for exporting profiles string.",
    opts = ""
  },
  ["delete"] = {
    desc = "Delete saved 'PROFILE'.",
    opts = "PROFILE"
  }
}
table.sort(AddonProfiles.HelpMessages)

AddonProfiles:RegisterChatCommand(AddonProfiles.SlashCommands, "SlashHandler")
for _, c in ipairs(AddonProfiles.SlashAliases) do
  AddonProfiles:RegisterChatCommand(c, "SlashHandler")
end

function AddonProfiles:SlashHandler(input)
  -- handle no input
  if not input or input == "" then
    self:Help()
    return
  end

  -- handle single input
  if input == "help" then
    self:Help()
  elseif input == "show" then
    self:ShowAll()
  elseif input == "addons" then
    self:Addons()
  elseif input == "import" then
    self:Import()
  elseif input == "export" then
    self:Export()
  elseif input == "save" then
    self:Save(self.DefaultProfile)
  elseif input == "load" then
    self:Print("'load' requires a profile argument.")
  elseif input == "delete" then
    self:Print("'delete' requires a profile argument.")
  else

    -- handle multiple input
    local cmd, input = self:GetArgs(input, 2, 1)

    if cmd == "load" then
      self:Load(input)
    elseif cmd == "show" then
      self:ShowOne(input)
    elseif cmd == "save" then
      self:Save(input)
    elseif cmd == "delete" then
      self:Delete(input)
    else
      self:Help()
    end

  end

  return
end

function AddonProfiles:Help()
  self:OpenOptions()
end

function AddonProfiles:Import()
  self:ImportUI()
end

function AddonProfiles:Export()
  self:ExportUI()
end

function AddonProfiles:ShowOne(profile)
  local addons = AddonProfilesStore[profile]

  if addons == nil then
    self:Printf("Profile %s not found.", profile)
    return
  end

  self:Printf("Profile: %s", profile)
  local astr = table.concat(addons, ", ")
  self:Printf(" %s", astr)
end

function AddonProfiles:ShowAll()
  local store = AddonProfilesStore
  self:Print("Profiles:")

  if store == nil or next(store) == nil then
    self:Print("No saved profiles.")
    return
  end

  for pname, _ in pairs(store) do
    self:Printf(" - '%s'", pname)
  end

  return
end

function AddonProfiles:Load(input)
  local current = self:getAddons()

  local store = AddonProfilesStore
  if store == nil or next(store) == nil then
    self:Print("No saved profiles.")
    return
  end

  local requested = store[input]
  if not requested then
    self:Print("ERROR Unknown profile.")
    self:Print(" ")
    self:ShowAll()
  end

  if current == requested then
    self:Print("Requested profile is the same as current state.")
    return
  end

  self:Print("DisableAllAddons()")
  DisableAllAddons()
  for _, addon in ipairs(requested) do
    EnableAddon(addon)
  end

  self:Printf("Loaded: '%s': %s", input, table.concat(requested, ", "))
  self:ReloadUI()

  return
end

function AddonProfiles:getAddons()
  local addons = {}

  for i=1, GetNumAddOns(), 1 do
    local name, _, _, loadable, _, _, _ = GetAddOnInfo(i)
    local state = GetAddOnEnableState(nil, name)
    if state > 0 or loadable then
      table.insert(addons, name)
    end
  end

  return addons
end

function AddonProfiles:Addons()
  self:Print("Enabled Addons:")
  for _, addon in ipairs(self:getAddons()) do
    self:Printf(" - %s", addon)
  end

  self:Print(" ")
  self:Print("Go to Game Menu > Addons to enable additional Addons.")
end

function AddonProfiles:saveAddonProfile(profile, addons)
  if not AddonProfilesStore then
    AddonProfilesStore = { [profile] = addons }
  else
    AddonProfilesStore[profile] = addons
  end

  return
end

function AddonProfiles:Save(input)
  self:saveAddonProfile(input, self:getAddons())

  self:Printf("Saved \"%s\": %s", input, table.concat(AddonProfilesStore[input], ", "))

  return
end

function AddonProfiles:deleteProfile(input)
  local store = AddonProfilesStore
  AddonProfilesStore = nil
  local removed = false
  for profile, addons in pairs(store) do
    if profile == input then
      removed = true
      self:Printf("Removed profile \"%s\"", input)
    else
      self:saveAddonProfile(profile, addons)
    end
  end

  return removed
end

function AddonProfiles:Delete(input)
  local requested = AddonProfilesStore[input]
  if not requested then
    self:Print("ERROR Unknown profile.")
    self:Print(" ")
    self:ShowAll()
  end

  local removed = self:deleteProfile(input)

  self:Print(" ")
  if removed then
    self:ShowAll()
  else
    self:Printf("No profiles were removed.")
  end

  return
end

function AddonProfiles:serializeStore()
  if not AddonProfilesStore or next(AddonProfilesStore) == nil then
    return nil
  end

  local s = self:Serialize(AddonProfilesStore)
  if not s or s == "" then
    return nil
  end

  return Base64.encode(s)
end

function AddonProfiles:deserializeString(str)
  local de = Base64.decode(str)
  local ds = self:Deserialize(de)

  return ds
end

-- exports all saved configuration
function AddonProfiles:ExportProfiles()
  if not AddonProfilesStore or next(AddonProfilesStore) == nil then
    return false, "Nothing to export."
  end

  local s = self:Serialize(AddonProfilesStore)
  if not s or s == "" then
    return false, "ERROR: A serialization error occurred."
  end

  return true, Base64.encode(s)
end

function AddonProfiles:ImportProfiles(str)
  local de = Base64.decode(str)
  local ok, new = self:Deserialize(de)
  if not ok then
    err = ( (err and type(err) == "string") or "An unknown error occurred" )
    return false, string.format("Import error: %s", err)
  end

  local ok, err = self:validateImport(new)
  if not ok then
    return false, string.format("Import error: %s", err)
  end

  AddonProfilesStore = new
  return true, new
end

function AddonProfiles:validateImport(profiles)
  if not profiles or next(profiles) == nil then
    return false, "Imported profiles are nil or empty."
  end

  return true, ""
end
