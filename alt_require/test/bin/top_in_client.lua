local alt_require = require("alt_require").require

local sender = require("alt_require.client.http"):new{
   under_uri  = "http://localhost:26019/alt_require",
}

-- Only the given file is run locally, rest on server side.
local function req(str)
--   local globals = ar.combine_globals(
--                                      require "alt_require.glob.all")
   return alt_require(str, {}, sender:globals(req), "all")
end

req(arg[1])
