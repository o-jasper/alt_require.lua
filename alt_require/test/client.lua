local alt_require = require("alt_require").require

local sender = require("alt_require.client.http"):new{
   under_site  = "http://localhost:26019/",
   under_path = "alt_require",
}

local function req(str, cg)
   local globals = sender:globals(cg, function(s) return req(s, cg) end)
   return alt_require({package=str}, {}, globals, require "alt_require.glob.simple")
end

print("---", "all require on other end")
req("alt_require.test.toys.reqme")

print("---", "just subsubreqme")
req("alt_require.test.toys.reqme", {["alt_require.test.toys.subsubreqme"]=true})
