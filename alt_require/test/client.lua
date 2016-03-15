local alt_require = require("alt_require").require

local sender = require("alt_require.client.http"):new{
   under_uri = "http://localhost:26019/",
}

local function req(str, cg)
   return alt_require({in_package=str}, {},
      sender:globals(cg),
      require "alt_require.glob.simple"
      --{ __envname="reqself", require = req }
   )(str)()
end

print("---", "all require on other end")
req("alt_require.test.toys.reqme")

print("---", "just subsubreqme")
req("alt_require.test.toys.reqme", {["alt_require.test.toys.subsubreqme"]=true})


