-- For poking and more complicated stuff gradually.

local tab = require "alt_require.test.toys.ret_tab"

-- Calling from tables, accessing tables, calling functions.
print(tab.c.d(tab.a(tab.b("1,2"), "3")))

-- Passing received functions back.
print(tab.ff(tab.c.d, "75"))
