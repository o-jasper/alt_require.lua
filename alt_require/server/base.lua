local This = { __constant=true }
This.__index = This

function This:new(new)
   new = setmetatable(new or {}, self)
   new:init()
   return new
end

function This:init()
   self.globals = self.globals or {}
   self.server_vals = self.server_vals or {}
   self.client_vals = self.client_vals or {}
end

local _, new_id = unpack(require "alt_require.server.figure_id")

function This:new_id(val)
   return new_id(self.server_vals, val)
end

function This:figure_input(val, tmp_client_vals)
   if type(val) == "table" then
      if val.__server_id then  -- Get the function/table.
         return self.server_vals[val.__server_id]
      elseif val.__client_id then
         return self.client_vals[val.__client_id]
      elseif val.__tmp_client_id then
         return tmp_client_vals[val.__tmp_client_id]
      elseif val.__mem_client_id then
         local id, ret = val.__mem_client_id, {}
         val.__mem_client_id = nil  -- Already know `id`.
         for k,v in pairs(val) do
            ret[k] = self:figure_input(v, tmp_client_vals)
         end
         self.client_vals[id] = ret
         return ret
      elseif val.__mem_tmp_client_id then  -- TODO repetative.
         local id, ret = val.__mem_tmp_client_id, {}
         val.__mem_tmp_client_id = nil
         for k,v in pairs(val) do
            ret[k] = self:figure_input(v, tmp_client_vals)
         end
         tmp_client_vals[id] = ret
         return ret
      else
         local ret = {}
         for k,v in pairs(val) do
            ret[k] = self:figure_input(v, tmp_client_vals)
         end
         return ret
      end
   else
      return val
   end
end

local function astring(inp, fmt)
   local fmt = fmt or "%s not a string; %s"
   for name, str in pairs(inp) do assert(str, string.format(fmt, name, str)) end
end

This.memoize_constant = true  -- TODO sync this over?

function This:respond(method, name, id, input_val)
   astring{method = "method", name=name, id=id}

   local ret = {}
   -- If some object floating in here.
   local in_vals = self:figure_input(input_val, {})

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
   return pass
end

return This
