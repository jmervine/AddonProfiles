-- AddOnName: AddOnTemplates
AddOnName = "AddOnTemplates"

-- Current Character
Character = UnitName("player")

-- Store AddOnTemplates once loaded.
Templates = {}

-- CurrentState from LoadAddOnState()
CurrentState = {}
CurrentStateEnablement = 0 -- 0=None, 1=Character, 2=Global

-- Fetch state from installed addons.
function LoadAddOnState()
  local state = {}
  for i=1, GetNumAddOns(), 1 do
    local name, title, notes, loadable, reason, security, _ = GetAddOnInfo(i)
    local enabledState = GetAddOnEnabledState(name)

    if CurrentStateEnablement < enabledState then
      CurrentStateEnablement = enabledState
    end

    state[name] = {}
    state[name].Index     = i
    state[name].Name      = name
    state[name].Title     = title
    state[name].Notes     = notes
    state[name].Loadable  = loadable
    state[name].Reason    = reason
    state[name].Security  = security
    state[name].Installed = true
    state[name].Enabled   = enabledState
  end

  CurrentState = state

  return CurrentState
end

-- Actions to take on init.
function OnInit()
  LoadAddOnState()
  LoadSlashCommands()
end


-- --------------------------------------------------------
-- Helper Functions
-- --------------------------------------------------------
function TableKeys(t)
  local keys={}
  for key,_ in pairs(t) do
    table.insert(keys, key)
  end

  return keys
end
