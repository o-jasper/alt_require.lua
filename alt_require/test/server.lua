
local globals = { require = require }
local receiver = require("alt_require.server.pegasus"):new{
   globals=globals, under_path="alt_require"}

require("pegasus"):new{ port=26019}:start(function(req, rep)
      if not receiver:pegasus_respond(req, rep) then
         rep:addHeader('Content-Type', 'bin/storebin'):write("No response")
      end
end)
