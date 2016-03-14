local already_found = {}

-- Wonder why lua doesnt expose something like this already.
local function alt_findfile(str)
   if already_found[str] then return already_found[str] end
   local pos = string.gsub(str, "[.]", "/")
   for at in string.gmatch(package.path, "[^;]+") do
      local cur_file = string.gsub(at, "[?]", pos)
      local open = io.open(cur_file)
      if open then
         io.close(open) 
         already_found[str] = cur_file
         return cur_file
      end
   end
end

local function alt_require_plain(env)
   return function(str)
      return loadfile(assert(alt_findfile(str)), nil, env)
   end
end

local function chain_pt(list)
   return function(el, key, val)
      local ret = val
      for _, fun in ipairs(list) do
         ret = fun(el, key, ret)
      end
      return ret
   end
end

local function globals_index(pass_through, ...)
   local list = {...}
   if type(pass_through) == "table" then
      pass_through = chain_pt(pass_through)
   end
   return function(this, key)
      for _, el in ipairs(list) do
         local val = el[key]
         if val ~= nil then
            this[key] = val
            return pass_through and pass_through(el, key, val) or val
         end
      end
      return pass_through and pass_through({}) or nil
   end
end

-- Accepts sequence of tables with globals in them, if `pass_through`,
--  then it is passed through that for alteration/recording.
local function globals(pass_through, ...)
   for _, el in ipairs{...} do assert(type(el) == "table") end
   return setmetatable({}, {__index=globals_index(pass_through, ...)})
end

-- Produces a function like `require` but finding files itself, and
-- providing its own globals.
-- Including the global `require`, so that can be made to do whatever.
local function alt_require(pass_through, ...)
   return alt_require_plain(globals(pass_through, ...))
end

return { alt_findfile      = alt_findfile,
         alt_require_plain = alt_require_plain,

         globals     = globals,
         alt_require = alt_require,
}
