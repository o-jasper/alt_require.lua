
local globals = { require = require }
local receiver = require("alt_require.server.pegasus"):new{
   globals=globals, under_path="alt_require"}

require("pegasus"):new{ port=26019}:start(function(req, rep)
      local method, name, id = receiver:pegasus_respond(req, rep)
      if not method then
         rep:addHeader('Content-Type', 'bin/storebin'):write("No response")
      else
         print(method, name, id)
      end
end)
