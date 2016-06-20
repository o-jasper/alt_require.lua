local alt_require = require("alt_require").require

local sender = require("alt_require.client.http"):new{
   under_uri  = "http://localhost:26019/alt_require",
}

-- Add the `require` that works via the client, and the the overall one.
local function req(str)
   return alt_require(str, {}, sender:globals(req),"simple")
end

print("---", "all require on other end")
req("alt_require.test.toys.reqme")

print("---", "just subsubreqme")
req("alt_require.test.toys.reqme", {["alt_require.test.toys.subsubreqme"]=true})
