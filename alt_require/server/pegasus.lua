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
   self.globals = self.globals or {}
   self.server_vals = self.server_vals or {}
   self.client_vals = self.client_vals or {}
end

local figure_id, new_id = unpack(require "alt_require.server.figure_id")

function This:new_id(val)
   local id = new_id(self.server_vals, val)
--   print("**", id, val)
   return id
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

local function figure_input(val, client_vals, server_vals)
   if type(val) == "table" then
      if val.__server_id then  -- Get the function/table.
         return server_vals[val.__server_id]
      elseif val.__client_id then
         return client_vals[val.__client_id]
      else
         local id, ret = assert(val.__mem_client_id), {}
         if not id then
            for k,v in pairs(val) do print(k, v) end
         end
         val.__mem_client_id = nil
         for k,v in pairs(val) do
            ret[k] = figure_input(v, client_vals, server_vals)
         end
         client_vals[id] = ret
         return ret
      end
   else
      return val
   end
end

function This:figure_input(val)
   return figure_input(val, self.client_vals, self.server_vals)
end

local function astring(inp, fmt)
   local fmt = fmt or "%s not a string; %s"
   for name, str in pairs(inp) do assert(str, string.format(fmt, name, str)) end
end

This.memoize_constant = true  -- TODO sync this over?

function This:respond(method, name, id, input_data)
   astring{method = "method", name=name, id=id, input_data=input_data}

   local ret = {}
   -- If some object floating in here.
   local in_vals = self:figure_input(self.store.decode(input_data))
--   print(method, name, id, #input_data, in_vals and #in_vals, in_vals)
   if id == "global" then  -- A global. (recommended only a handful, or only `require`)
      assert(not in_vals)
      assert(({index=true, newindex=self.allow_set_global})[method])
      assert(method == "index")
      ret = {self.globals[name]}
   elseif method == "gc" then  -- Garbage collection.(hopefully)
      ret = {function() self.server_vals[id] = nil end}
   else
      local cur = self.server_vals[id]
      if method == "call" then
         assert(cur and type(in_vals)=="table",
                string.format("id=%q name=%q cur=%s vals=%s", id, name,
                              cur, in_vals))
         ret = {cur(unpack(in_vals))}
      elseif method == "index" then
         ret = {cur[in_vals or name]}
      elseif method == "newindex" then
         local key, value = unpack(in_vals)
         cur[key] = value
         ret = {value}
      elseif method == "pairs" then
         ret = {pairs(cur)}
      elseif method == "len" then
         ret = {#cur}
      else
         error(string.format("Dont recognize method; %s", method))
      end
   end

   local pass = {}
   for _, r in ipairs(ret) do
      local tp = type(r)
      if tp == "function" then
         table.insert(pass, { tp=tp, id=self:new_id(r) })
      elseif tp == "table" then
         local c
         if self.memoize_constant then
            c = rawget(r, "__constant")
            -- Dynamically figures what is part of class.
            c = (c == nil and r.__constant) or c
         end
         table.insert(pass, { tp=tp, id=self:new_id(r), const=c })
      else  -- Just return it.
         table.insert(pass, { val = r })
      end
   end
   return self.store.encode(pass)
end

return This
