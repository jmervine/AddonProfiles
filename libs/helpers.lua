Helpers = {} --Class
  Helpers.DEBUG = true 

  -- ADDON_NAME. AddOnTemplates
  Helpers.ADDON_NAME = "AddOnTemplates"

  function Helpers.message(ll, m)
    if m == nil then m = "nil" end

    Helpers.Print("[" .. ll .. "] " .. m)
  end

  function Helpers.Warn(w)
    Helpers.message("WARNING", w)
  end

  function Helpers.Debug(d)
    if Helpers.DEBUG then
      Helpers.message("DEBUG", d)
    end
  end

  function Helpers.Error(e)
    Helpers.message("ERROR", e)
  end

  function Helpers.Print(str)
    DEFAULT_CHAT_FRAME:AddMessage("[" .. Helpers.ADDON_NAME .. "] " .. str)
  end

  function Helpers.SplitString(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
      table.insert(result, match);
    end
    return result;
  end

  function Helpers.TableLen(t)
    local l = 0
    for _ in pairs(t) do
      l = l + 1
    end
    return l
  end
