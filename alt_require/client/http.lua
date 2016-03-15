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

function This:init()
   self.constants = {}
   assert(self.under_uri, "Need to specify what server to connect to.")
end

function This:get(method, name, args, id)
   assert(method)

   local const = self.constants[name]
   if const then return const end

   local url_list = {self.under_uri, method, name, id or "0"}

   local encoded_data_sent = self.store.encode(args)

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

   local data = self.store.decode(table.concat(got))  -- TODO not other shit in there?
   local id, ret = data.id, nil
   if data.is_fun then  -- It is a function, that contains the id to track it.
      ret = function(...) return self:get("call", name, {...}, id) end
   elseif data.is_table then  -- Is a table.
      ret = function(_, method)  -- Double meta.
         return function(_, ...)
            return self:get(name, string.match(method, "^__(.+)$"), {...}, id)
         end
      end
      return setmetatable({}, setmetatable({}, {__index=meta_index}))
   elseif data.is_error then -- Shouldnt be touching this.
      error(string.format("Server doesn't allow touching %q", req_args.url))
   elseif data.is_local_get then  -- Mission creep.
      assert(self.logal_get)
      ret = self:local_get(name, args, id, method)
   else
      -- Can still be a tree-shaped table, but in that case it is not
      -- synchronized across.
      ret = data.val
   end
   return ret
end

This.require = require

function This:require_fun(selection)
   local fun = self:get("index", "require", nil, "global")
   return (selection == nil and fun) or
      function(str)
         print("***", str)
         if selection[str] then
            return fun(str)
         else
            return self.require(str)
         end
      end
end
function This:globals(require_selection)
   local ret= { require = self:require_fun(require_selection) }
   print(ret.require)
   return ret
end

return This
