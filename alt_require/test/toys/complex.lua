-- For poking and more complicated stuff gradually.
-- Note: reset the server when you change this,
--   or it will keep using the old version!

local tab = require "alt_require.test.toys.ret_tab"

-- Calling from tables, accessing tables, calling functions.
print(tab.c.d(tab.a(tab.b("1,2"), "3")))

-- Passing received functions back.
print(tab.ff(tab.c.d, "75"))

-- Passing received tables back.
 print(tab.gg(tab.c, "@@"))  -- Bit of a mystery.
