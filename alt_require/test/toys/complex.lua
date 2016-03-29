-- For poking and more complicated stuff gradually.
-- Note: reset the server when you change this,
--   or it will keep using the old version!

local tab = require "alt_require.test.toys.ret_tab"

-- Zero arguments is okey.
print(tab.no_args())

-- Testing if `pairs` can work.
for k,v in pairs(tab) do print(k,v) end

-- Calling from tables, accessing tables, calling functions.
print(tab.c.d(tab.a(tab.b("1,2"), "3")))

-- Passing received functions back.
print(tab.ff(tab.c.d, "75"))

-- Passing received tables back.
print(tab.gg(tab.c, "@@"))

-- 
local x = require "alt_require.test.toys.ret_list"
print(x[1], x[2], x[3], x[4])
print(unpack(x))
