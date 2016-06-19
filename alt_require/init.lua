
local Public = {}
for k,v in pairs(require "alt_require.alt_require") do Public[k] = v end

local raw_require_fun = Public.raw_require_fun

local function new_state(pkgstr, old_state)
   local new_state = {}
   for k,v in pairs(old_state) do new_state[k] = v end
   new_state.package = pkgstr
   return new_state
end

-- `pt` stands for pass_through and `globs` for globals.
local function handle_require(got, pkgstr, full_pkgstr, state, pt,globs)
   if type(got) == "function" then  -- Verbatim.
      return got(full_pkgstr)
   elseif type(got) == "table" then  -- However table thinks it should.
      if got[1] == "function" then  -- user-defined based on info available.
         return got[1](full_pkgstr, state,pt,globs)
      end

      local pre, post = string.match(pkgstr, "([^.]+)[.](,+)?")
      if not pre then
         return handle_require(tab.default, pkgstr, full_pkgstr)
      else
         return handle_require(tab[pre], post, full_pkgstr)
      end
   elseif not got then  -- Recursively.
      --return state.recurse(full_pkgstr)
      return raw_require_fun(new_state(full_pkgstr, state), pt,globs)()
   else
      error([[Require may only be a function, `false`/`nil` indicating,
or a table containing those]])
   end
end

local function require_fun_1(state, pt,globs)
   local got = globs.require
   if type(got) ~= "function" then
      globs.require = function(pkgstr)
         return handle_require(got, pkgstr, pkgstr, state, pt,globs)
      end
   end
   -- Tells how to recurse. (so you can.)
   state.recurse = function(pkgstr)
      return raw_require_fun(new_state(pkgstr, state), pt,globs)()
   end
   return raw_require_fun(state, pt,globs)
end

local function combine_globals(globals, list)
   local gs = {}
   for k,v in pairs(globals) do
      gs[k] = v
   end
   for _, g in ipairs(list) do
      for k,v in pairs(g) do gs[k] = v end
   end
   return gs
end

local function require_fun(state, pass_through, globals, first, ...)
   local globals = first and combine_globals(globals, {first, ...}) or globals or "simple"
   if type(globals) == "string" then
      globals = require("alt_require.glob." .. globals)
   end
   return require_fun_1(state, pass_through, globals)
end

Public.require_fun = require_fun
Public.require = function(...)
   return require_fun(...)()
end

return Public
