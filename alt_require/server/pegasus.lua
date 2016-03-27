local This = { __constant=true }
This.__index = This

This.store = require "storebin"

function This:new(new)
   new = setmetatable(new or {}, self)
   new:init()
   return new
end

-- Can prepend things and change the server-end correspondingly, of course.
This.matcher = "^/?([^/]+)/?([^/]+)/?([^/]+)$"
This.under_path = ""

function This:init()
   self.prev_id = 0
   self.globals = self.globals or {}
   self.ongoing = self.ongoing or {}
end

function This:new_id(to)
   self.prev_id = self.prev_id + 1
   self.ongoing[tostring(self.prev_id)] = to
   return tostring(self.prev_id)
end

function This:pegasus_respond(req, rep)
   local path = req:path() or ""
   if string.sub(path, 2, #self.under_path + 1) == self.under_path then
      local method, name, id =
         string.match(string.sub(path, #self.under_path + 2),  self.matcher)
      if name then
         -- Currently at least, pegasus needs headers out first.
         local input_data = req:receiveBody()
         local str = self:respond(method, name, id, input_data)
         -- TODO header depends on `self.store`.
         rep:addHeader("Content-Type", "bin/storebin"):write(str)
         return method, name, id
      end
   end
end

local function turn_tables(ongoing, tab)
   local ret = {}
   for k,v in pairs(tab) do
      if type(v) == "table" then
         if v.__is_server_type then  -- Get the function/table.
            ret[k] = ongoing[v.__id]
         else
            ret[k] = turn_tables(ongoing, v)
         end
      else
         ret[k] = v
      end
   end
   return ret
end

local function astring(inp, fmt)
   local fmt = fmt or "%s not a string; %s"
   for name, str in pairs(inp) do assert(str, string.format(fmt, name, str)) end
end

function This:respond(method, name, id, input_data)
   astring{method = "method", name=name, id=id, input_data=input_data}

   local ret = {}
   -- If some object floating in here.
   local in_vals = #input_data > 0 and self.store.decode(input_data)
--   print(method, name, id, #input_data, in_vals and #in_vals, in_vals)
   if id == "global" then  -- A global. (recommended only a handful, or only `require`)
      assert(not in_vals)
      assert(({index=true, newindex=self.allow_set_global})[method])
      assert(method == "index")
      ret = {self.globals[name]}
   elseif method == "gc" then  -- Garbage collection.(hopefully)
      ret = {function() self.ongoing[id] = nil end}
   else
      local cur = self.ongoing[id]
      if method == "call" then
         assert(type(in_vals) == "table")
         ret = {cur(unpack(turn_tables(self.ongoing, in_vals)))}
      elseif method == "is_constant" then
         -- Separate otherwise classes where `__index` is self cannot make
         -- themselves constant without making all instances constant.
         local c = rawget(cur, "__constant")
         if c == nil and cur.__constant then  -- Some metatable stuff is constant.
            if not cur.__which_constant then
               local index = getmetatable(cur).__index
               local wc, wnc = {}, index.__which_not_constant or {}
               index.__which_constant     = wc
               index.__which_not_constant = wnc  -- Indicate changables here.
               for k in pairs(index) do
                  wc[k] = not wnc[k] or nil
               end
            end
            ret = {cur.__which_constant}
         else
            ret = {c}
         end
      elseif method == "index" then
         assert(not in_vals)
         ret = {cur[name]}
      elseif method == "newindex" then
         local key, value = unpack(in_vals)
         cur[key] = value
         ret = {value}
      elseif method == "pairs" then
         ret = {pairs(cur)}
      end
   end

   local pass = {}
   for _, r in ipairs(ret) do
      if ({["function"]=true, ["table"]=true})[type(r)] then
         table.insert(pass, { tp=type(r), id=self:new_id(r) })
      else  -- Just return it.
         table.insert(pass, { val = r })
      end
   end
   return self.store.encode(pass)
end

return This
