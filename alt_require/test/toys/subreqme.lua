print(1 + 2)

-- require "idontexist, so what now"

local ssrm = require "alt_require.test.toys.subsubreqme"

print(unpack(ssrm))

return function(x, y) return x * y end
