-- Requesting end of a harness.
-- TODO sending end, so i actually have something.

local http  = require "socket.http"
local ltn12 = require "ltn12"

local This = {}
This.__index = This

This.store = require "storebin"

function This:new(new)
   new = setmetatable(new or {}, self)
   new:init()
   return new
end

This.under_path = ""

function This:init()
   self.constants = {}
   assert(self.under_site, "Need to specify what server to connect to.")
   self.under_uri = self.under_uri or self.under_site .. "/" .. self.under_path

   self.table_meta = {}
   for _, method in ipairs{"newindex", "call", "pairs"} do
      self.table_meta["__" .. method] = function(this, ...)
         return self:get(method, this.__name, {...}, this.__id)
      end
   end
   self.table_meta.__index = function(this, key)
      return self:get("index", key, nil, this.__id)
   end

   -- TODO rest off limits..
   self.fun_meta = { __call = self.table_meta.__call }
end

local function prep_for_send(tab)
   local ret = {}
   for k,v in pairs(tab) do
      if type(v) == "table" then
         if v.__is_server_type then
            print("fix", v.__name)
            -- Otherwise `storebin` may use `__pairs` and stuff,
            --  and then end up sending stuff that way.
            ret[k] = {__is_server_type = v.__is_server_type,
                      __id = v.__id,
                      __name = v.__name }
         else
            ret[k] = prep_for_send(tab)
         end
      else
         ret[k] = v
      end
   end
   return ret
end

function This:get(method, name, args, id)
   print(method, name, id, unpack(args or {}))
   assert(method)

   local const = self.constants[name]
   if const then return const end

   local url_list = {self.under_uri, method, name, id or "0"}

   -- TODO abstract this portion so you can switch it for something else than http.
   local encoded_data_sent = self.store.encode(args and prep_for_send(args) or nil)

   local got = {}
   local req_args = {
      url     = table.concat(url_list, "/"),
      sink    = ltn12.sink.table(got),
      method  = "PUT",
      -- TODO header depends on `self.store`.
      headers = { 
         ["Content-Length"] = #encoded_data_sent,
         ["Content-Type"] = "bin/storebin"
      },
   }
   if args then
      assert(type(args) == "table")
      req_args.source = function()
         local ret = encoded_data_sent
         encoded_data_sent = nil
         return ret
      end
   end

   local c, code, headers = http.request(req_args)
   -- TODO try again.
   assert(code == 200, string.format("I am really bad with hickups! %q (%s)", code, c))

   local ret_list = {}  -- List of values.
   local data_list = self.store.decode(table.concat(got)) or {}
    -- TODO not other shit in there?
   for _, data in ipairs(data_list) do
      local id, ret = data.id, nil
      if data.tp == "function" then  -- It is a function, that contains the id to track it.
         assert(not data.val)
         if self.funs_as_funs then  -- Note then you cannot send the function back.
            ret = function(...) return self:get("call", name, {...}, id) end
         else
            ret = setmetatable({ __is_server_type="function", __id=id, __name=name},
               self.fun_meta)
         end
      elseif data.tp == "table" then  -- Is a table.
         assert(not data.val)
         ret = setmetatable({ __is_server_type="table", __id=id, __name=name },
            self.table_meta)
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
