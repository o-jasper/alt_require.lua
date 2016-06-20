
local Public = {}
for k,v in pairs(require "alt_require.alt_require") do Public[k] = v end

local function new_state(pkgstr, old_state)
   local new_state = {}
   for k,v in pairs(old_state) do new_state[k] = v end
   new_state.package = pkgstr
   return new_state
end

local function combine_globals(globals, ...)
   local function rg(str)
      return (type(str) == "string" and require("alt_require.glob." .. str)) or str
   end
   local gs = {}
   for k,v in pairs(rg(globals)) do
      gs[k] = v
   end
   for _, g in ipairs{...} do
      for k,v in pairs(rg(g)) do gs[k] = v end
   end
   return gs
end

local raw_require = Public.raw_require

local function alt_require(state, pass_through, globals, ...)
   local state = type(state)=="string" and {package=state} or state

   local globals = combine_globals(globals or "simple", ...)
   local provided_require = globals.require
   local used_require = globals.require or raw_require
   globals.require = function(pkgstr)
      return used_require(new_state(pkgstr, state), pass_through, globals)
   end
   return raw_require(state, pass_through, globals)
end

Public.require = alt_require

return Public
