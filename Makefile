
test: lua_test luajit_test

lua_test: lua_plain lua_simples

lua_plain:
	lua alt_require/test/init.lua
lua_simples:
	lua alt_require/test/simples.lua

luajit_test: luajit_plain luajit_simples

luajit_plain:
	luajit alt_require/test/init.lua
luajit_simples:
	luajit alt_require/test/simples.lua
