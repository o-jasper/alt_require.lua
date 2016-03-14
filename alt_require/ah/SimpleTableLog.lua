-- Record into tables.
-- (here just for example.)

local SimplePrintLog = require "alt_require.ah.SimplePrintLog"
local This = {}

for k,v in pairs(SimplePrintLog) do This[k] = v end
This.__name = "alt_require.ah.TableLog"
This.__index = This

function This:init()
   SimplePrintLog.init(self)
   self.recorded = {}
   self.recorded_require = {}
end

function This:record_require(str)
   self.recorded_require[str] = (self.recorded_require[str] or 0) + 1
end
function This:record(where, key)
   local now = self.recorded[where]
   now[key] = (now[key] or 0) + 1
end

function This:meta(where)
   self.recorded[where] = self.recorded[where] or {}
   return SimplePrintLog.meta(self, where)
end

return This
