local already_found = {}

-- Wonder why lua doesnt expose something like this already.
local function findfile(package_str)
   if already_found[package_str] then return already_found[package_str] end
   local pos = string.gsub(package_str, "[.]", "/")
   for at in string.gmatch(package.path, "[^;]+") do
      local cur_file = string.gsub(at, "[?]", pos)
      local open = io.open(cur_file)
      if open then
         io.close(open) 
         already_found[package_str] = cur_file
         return cur_file
      end
   end
   error(string.format("Aint got no file? %s", package_str))
end

-- Chains pass-throughs together, so you can just provide a list.
local function chain_pt(list)
   return function(state, el, key, val)
      local ret = val
      for _, fun in ipairs(list) do
         ret = fun(state, el, key, ret)
      end
      return ret
   end
end

local function globals_index(state, pass_through, globals)
   assert(type(globals) == "table")
   -- Tables are automatically chained together.
   if type(pass_through) == "table" then
      pass_through = chain_pt(pass_through)
   end
   return function(this, key)
      local val = globals[key]
      if val ~= nil then
         -- this[key] = val to memoize... But then control is lost.
         if pass_through then
            return pass_through(state, globals, key, val)
         else
            return val
         end
      end
      return pass_through and pass_through(state, {}) or nil
   end
end

-- Accepts sequence of tables with globals in them, if `pass_through`,
--  then it is passed through that for alteration/recording.
local function globals(state, pass_through, globals)
   return setmetatable({}, {__index=globals_index(state, pass_through, globals)})
end

local function load_pkg(package_str, env)
   local file = assert(findfile(package_str))
   return loadfile(file, nil, env)
end

local function raw_require_fun(package_str, state, pass_through, globals_tab)
   state.in_package = package_str
   return load_pkg(package_str, globals(state, pass_through, globals_tab))
end

return { findfile        = findfile,
         raw_require_fun = raw_require_fun,

         globals_index = globals_index,
         globals = globals,
}
