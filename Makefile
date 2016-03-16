
# Not all tests.
test: lua_test luajit_test

lua_test: lua_simple

lua_simple:
	lua alt_require/test/simple.lua

luajit_test: luajit_simple

luajit_simple:
	luajit alt_require/test/simple.lua
