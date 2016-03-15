local alt_require = require("alt_require").require

local sender = require("alt_require.client.http"):new{
   under_uri = "http://localhost:26019/",
}

local function req(str)
   return alt_require({in_package=str}, {},
      sender:globals(),
      require "alt_require.glob.simple"
      --{ __envname="reqself", require = req }
   )(str)()
end

req("alt_require.test.toys.reqme")


