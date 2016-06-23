local alt_require = require("alt_require").require

-- Two servers.
local sender_1 = require("alt_require.client.http"):new{
   under_uri  = "http://localhost:26019/alt_require",
}
local sender_2 = require("alt_require.client.http"):new{
   under_uri  = "http://localhost:26020/alt_require",
}

local require_1,require_2 = sender_1:require_fun(), sender_2:require_fun()

local p1,p2 = 0.3,0.3

-- Randomly decides to run things, randomly, between the two servers, or still-on-client.
local function req(str)
   local function myreq(state, ...)  -- Re
      local r = math.random()
      if r < p1 then  -- First server.
         return require_1(state, ...)
      elseif r < p1 + p2 then
         return require_2(state, ...)
      else
         return req(state.package)  -- Keep going in client.
      end
   end

   return alt_require(str, {}, { require=myreq}, "all")
end

req(arg[1])
