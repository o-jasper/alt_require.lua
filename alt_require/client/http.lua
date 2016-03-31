-- Requesting end of a harness.
-- TODO sending end, so i actually have something.

local http  = require "socket.http"
local ltn12 = require "ltn12"

local This = {
   __constant=true,
   __which_not_constant = { under_path=true, memoize_constant=true, require=true, },
}
This.__index = This

This.store = require "storebin"

function This:new(new)
   new = setmetatable(new or {}, self)
   new:init()
   return new
end

This.under_path = ""

This.memoize_constant = true

function This:init()
   assert(self.under_site, "Need to specify what server to connect to.")
   self.under_uri = self.under_uri or self.under_site .. "/" .. self.under_path

   self.table_meta = {}
   for _, method in ipairs{"newindex", "call", "pairs", "len"} do
      self.table_meta["__" .. method] = function(this, ...)
         return self:get(method, this.__name, {...}, this.__server_id)
      end
   end

   self.server_vals = {}
   self.client_vals = {}  -- Allows sending loops.

   if self.memoize_constant then
      self.table_meta.__index = function(this, key)  -- _server_-side table, that is.
         -- Don't have it yet in any case.
         local got = self:get("index", key, key, this.__server_id)
         -- See if constant.
         local c = rawget(this, "__constant")
         if (c == true) or c and c:inside(key, got) then
            rawset(this, key, got)
         end
         return got
      end
   else
      self.table_meta.__index = function(this, key)
         return self:get("index", key, key, this.__id)
      end
   end

   -- TODO rest off limits..
   self.fun_meta = { __call = self.table_meta.__call }
end

local figure_id = unpack(require "alt_require.server.figure_id")

-- TODO synchronizing tables might be something that can be separated out.
--   including allowing for loops and optimizations by synchronizing accross
--   definitions.(but then, that might not be aware of constancy?)
function This:prep_for_send(val, tmp_client)
   if type(val) == "table" then
      if val.__server_id then  -- Came from the server before.
         -- Otherwise `storebin` may use `__pairs` and stuff,
         --  and then end up sending stuff that way.
         return {__server_id = val.__server_id,
                 __name = val.__name }  -- A point to it?
      else
         local id = figure_id(val)
           -- Already sent it at some point, just refer to it.
         if self.client_vals[id] then
            return {__client_id = id }
         elseif tmp_client[id] then
            return { __tmp_client_id = id }
         else
            local ret = {}
            if val.__constant then
               ret.__mem_client_id = id
               self.client_vals[id] = true
            else
               ret.__mem_tmp_client_id = id
               tmp_client[id] = true
            end
            for k,v in pairs(val) do
               ret[k] = self:prep_for_send(v, tmp_client)
            end
            return ret
         end
      end
   elseif type(val) == "function" then
      error("can't send functions")
      -- return { __client_id = figure_id(id) }
   else
      return val
   end
end

function This:send_n_receive(url, data)
--   if method == "index" and name == data then data = nil end

--type(args)=="table" and self:prep_for_send(args) or
--      ( and args) or nil
   local encoded_data_sent = self.store.encode(data)  -- Need the bloody length.

   local got = {}
   local req_args = {
      url     = url,
      sink    = ltn12.sink.table(got),
      method  = "PUT",
      -- TODO header depends on `self.store`.
      headers = { 
         ["Content-Length"] = #encoded_data_sent,
         ["Content-Type"] = "bin/storebin"
      },
   }
   req_args.source = function()
      local ret = encoded_data_sent
      encoded_data_sent = nil
      return ret
   end

   local c, code, headers = http.request(req_args)
   -- TODO try again.
   assert(code == 200, string.format("I am really bad with hickups! %q (%s)", code, c))
   return self.store.decode(table.concat(got)) or {}
end

local KeyIn = require "alt_require.KeyIn"

function This:get(method, name, args, id)
   assert(type(method) == "string")
   assert(type(id) == "string")
   assert(method ~= "call" or type(args) == "table")
   local name = tostring(name)

   local url = table.concat({self.under_uri, method, name, id}, "/")
   local data_list, ret_list =
      self:send_n_receive(url, self:prep_for_send(args, {})), {}

   -- TODO not other shit in there?
   for _, data in ipairs(data_list) do
      local id, ret = data.id, nil
      if data.tp == "function" then  -- It is a function, that contains the id to track it.
         assert(not data.val)
         ret = self.server_vals[id]
         if not ret then
            if self.funs_as_funs then  -- Note then you cannot send the function back.
               ret = function(...) return self:get("call", name, {...}, id) end
            else
               ret = setmetatable({ __server_id=id, __name=name},
                  self.fun_meta)
            end
            self.server_vals[id] = ret
         end
      elseif data.tp == "table" then  -- Is a table.
         assert(not data.val)
         ret = self.server_vals[id] or self.client_vals[id]
         if not ret then
            local const = data.const
            local const = (type(const) == "table" and KeyIn:new(const)) or const
            ret = setmetatable({ __server_id=id, __name=name,
                                 __constant = const },
               self.table_meta)
            self.server_vals[id] = ret
         end
      elseif data.tp == "error" then -- Shouldnt be touching this.
         error(string.format("Server doesn't allow touching %q", req_args.url))
      elseif data.tp == "local_get" then  -- Mission creep.
         assert(self.local_get)
         ret = self:local_get(name, args, id, method)
      else
         -- Can still be a tree-shaped table, but in that case it is not
         -- synchronized across.
         ret = data.val
      end
      table.insert(ret_list, ret)
   end
  -- Note logic that require that type could have issues..
   -- can be fir
   assert(type(ret) ~= "function")

   return unpack(ret_list)
end

This.require = require

function This:require_fun(selection, local_require)
   local fun = self:get("index", "require", nil, "global")
   return (selection == nil and fun) or
      function(str)
         if selection[str] then
            return fun(str)
         else
            return (local_require or self.require)(str)
         end
      end
end
function This:globals(require_selection, local_require)
   return { __envname="http-client",
            require = self:require_fun(require_selection, local_require) }
end

return This
