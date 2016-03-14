
local tab = require("alt_require.ah.Table"):new()
assert(tab.loaded, tab.__name)
tab:require("alt_require.test.toys.reqme")

-- Fancily display what is going on in these things..
local function str_tab(tab, prep)
   local ret, prep = "", prep or "  "
   for k, v in pairs(tab) do
      if type(v) == "table" then
         ret = ret .. prep .. tostring(k) .. ":\n" .. str_tab(v, "  " .. prep)
      else 
         ret = ret .. prep .. string.format("%s: %s\n", k, v)
      end
   end
   return ret
end

-- Print the result.
print(str_tab(tab.cnts))
print(str_tab(tab.vals))

-- Okey now try enforce limitation to the recorded behavior.
tab.mode = "enforce"
tab:require("alt_require.test.toys.reqme")

-- TODO Tests ... well not even a test showing it actually blocks.
