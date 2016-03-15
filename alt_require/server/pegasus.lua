local This = {}
This.__index = This

This.store = require "storebin"

function This:new(new)
   new = setmetatable(new or {}, self)
   new:init()
   return new
end

function This:init()
   assert(self.our_path_portion)

   self.prev_id = 0
   self.globals = self.globals or {}
   self.ongoing = self.ongoing or {}
end

function This:new_id(to)
   self.prev_id = self.prev_id + 1
   self.ongoing[tostring(self.prev_id)] = to
   return tostring(self.prev_id)
end

-- Can prepend things and change the server-end correspondingly, of course.
This.our_path_portion = "^/?([^/]+)/?([^/]+)/?([^/]+)$"

function This:pegasus_respond(req, rep)
   local method, name, id = string.match(req:path() or "", self.our_path_portion)
   if name then
      -- Currently at least, pegasus needs headers out first.
      for k,v in pairs(req:headers()) do print("h", k,v) end
      local input_data = req:receiveBody()
      print("IN", input_data)
      local str = self:respond(method, name, id, input_data)
      -- TODO header depends on `self.store`.
      rep:addHeader("Content-Type", "bin/storebin"):write(str)
      return true
   end
end

function This:respond(method, name, id, input_data)
   print(method, name, id, input_data)
   local ret = nil

   -- If some object floating in here.
   local in_vals = input_data and #input_data > 0 and self.store.decode(input_data)
   if id == "global" then  -- A global. (recommended only a handful, or only `require`)
      assert(not in_vals)
      assert(({index=true, newindex=self.allow_set_global})[method])
      assert(method == "index")
      ret = self.globals[name]
   elseif method == "call" then
      ret = self.ongoing[id](unpack(in_vals))
   elseif method == "index" then
      ret = self.ongoing[id][in_vals[1]]
   elseif method == "newindex" then
      local key, value = unpack(in_vals)
      self.ongoing[id][key] = value
      ret = value
   elseif method == "gc" then  -- Garbage collection.(hopefully)
      ret = function() self.ongoing[id] = nil end
   end

   local pass = {}
   if type(ret) == "function" then
      pass = { is_fun=true,   id=self:new_id(ret) }
   elseif type(ret) == "table" then
      pass = { is_table=true, id=self:new_id(ret) }
   else  -- Just return it.
      pass = { val = ret }
   end

   return self.store.encode(pass)
end

return This
