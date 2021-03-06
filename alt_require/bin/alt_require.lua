
local globals = { require = require }
local receiver = require("alt_require.server.pegasus"):new{
   globals=globals, under_path="alt_require"}

local prevstr, prevstr_n = "", 0
require("pegasus"):new{ port=tonumber(arg[1]) or 26019 }:start(function(req, rep)
      local method, name, id = receiver:pegasus_respond(req, rep)
      if method then
         local str = string.format("%s\t%s\t%s", method, name, id)
         if str == prevstr then
            prevstr_n = prevstr_n + 1
         else
            prevstr = str
            if prevstr_n == 0 then
               print(str)
            else
               print(str, string.format("%s", prevstr_n))
               prevstr_n = 0
            end
         end
      else
         rep:addHeader('Content-Type', 'bin/storebin'):write("No response")
      end
end)
