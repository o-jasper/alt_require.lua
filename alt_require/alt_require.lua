-- Wonder why lua doesnt expose something like this already.
local function alt_findfile(str)
   local pos = string.gsub(str, "[.]", "/")
   for at in string.gmatch(package.path, "[^;]+") do
      local cur_file = string.gsub(at, "[?]", pos)
      local open = io.open(cur_file)
      if open then
         io.close(open) 
         return cur_file
      end
   end
end
-- Overly lazy.
local function alt_require_plain(meta)
   return function(str)
      return loadfile(assert(alt_findfile(str)),
                      nil, setmetatable({}, meta))()
   end
end

return { alt_findfile=alt_findfile, alt_require_plain=alt_require_plain }
