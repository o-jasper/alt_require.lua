local alt_require = require("alt_require").require

local sender = require("alt_require.client.http"):new{
   under_site  = "http://localhost:26019/",
   under_path = "alt_require",
}

-- Only the given file is run locally, rest on server side.
local function req(str)
   return alt_require({in_package=str}, {},
      sender:globals(nil, req),
      require "alt_require.glob.all"
      --{ __envname="reqself", require = req }
   )(str)()
end

req(arg[1])
