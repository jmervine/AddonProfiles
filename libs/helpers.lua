local Helpers = {} --Class

  Helpers.DEBUG = (os.getenv("DEBUG") == "true")

  -- ADDON_NAME: AddOnTemplates
  Helpers.ADDON_NAME = "AddOnTemplates"

  function Helpers:message(ll, m)
    if m == nil then m = "nil" end

    Helpers:Print("[" .. ll .. "] " .. m)
  end

  function Helpers:Warn(w)
    Helpers:message("WARNING", w)
  end

  function Helpers:Debug(d)
    if Helpers.DEBUG then
      Helpers:message("DEBUG", d)
    end
  end

  function Helpers:Error(e)
    Helpers:message("ERROR", e)
  end

  function Helpers:Print(str)
    print(Helpers.ADDON_NAME .. ": " .. str)
  end

return Helpers
