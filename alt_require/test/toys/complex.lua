-- For poking and more complicated stuff gradually.

local tab = require "alt_require.test.toys.ret_tab"

print(tab.c.d(tab.a(tab.b("1,2"), "3")))
