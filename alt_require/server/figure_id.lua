local function figure(val)  -- Reads it.
   assert(({table=true, ["function"]=true})[type(val)], val)
   return string.lower(string.match(tostring(val), "0x([%x]+)"))
end

local function new(into, val)
   local id = figure(val)
   into[id] = val
   return id
end

return {figure, new}
