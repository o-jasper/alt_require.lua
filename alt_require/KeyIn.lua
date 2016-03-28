-- A kind of which entries are/in/out for a set of keys.
-- Used to indicate what entries may be changed.

local This = { __constant=true }
This.__index = This
This.__newindex = function() error("bad idea") end

function This:new(new)
   new = setmetatable(new or {}, This)
   new:init()
   return new
end

function This:init() end

-- Specific keys not if `true` otherwise, that type specifically not for that key
This.n = {}
This.y = {}      -- idem, but yes.
This.nms = {}    -- Patterns, a list, if matched, no.
This.ms = {}     -- idem, yes
This.stm = {}    -- Table keys are matches, values table then recurse, otherwise like yes.
This.ntp = {}    -- Types not allowed.
This.ytp = {}    -- Types allowed.
This.yd  = false -- Default if all else doesn't trigger.

local find = string.find

local function true_or_type(got, value)
   return (got == true) or (got == type(value))
end

function This:inside(key, value)
   if true_or_type(self.n[key], value) then
      assert(not self.y[key])
      return false
   elseif true_or_type(self.n[key], value) then
      return true
   elseif self.nm and find(key, self.nm) then
      return false
   end
   -- Pattern matchers.
   for _, m1 in ipairs(self.nms) do
      if find(key, m1) then return false end
   end
   if self.m and find(key, self.m) then return true end
   for _, m1 in ipairs(self.ms) do
      if find(key, m1) then return true end
   end

   -- Sub-tree and type matchers.
   for m1, st in pairs(self.stm) do
      if find(key, m1) then
         if type(st) == "table" then
            return (st.inside and st or This:new(st)):inside(key, value)
         else  -- Demand a type.
            return true_or_type(st, value)
         end
      end
   end
   -- Type based.
   if self.ntp[type(value) or "nil"] then
      return false
   elseif self.ytp[type(value) or "nil"] then
      return true
   end
   -- Final default.
   return self.yd
end

return This
