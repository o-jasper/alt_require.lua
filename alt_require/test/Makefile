# Needed to run any server tests.
run_server:
	lua server.lua

### Non-server tests.
all_non_server: lua_non_server luajit_non_server

lua_non_server: lua_simple

lua_simple:
	lua simple.lua

luajit_non_server: luajit_simple

luajit_simple:
	luajit simple.lua

### Server.

all_client: complex client

client:
	lua client.lua

# Looks like this works
complex:
	lua bin/top_in_client.lua "alt_require.test.toys.complex"

### (server) below do not yet work.

sha2_all: sha2 sha2_more

# Doesn't crash, but likely _not_ working and just spinning its wheels.
sha2:
	lua bin/top_in_client.lua "merkle.test.sha2"

#(idem)
sha2_more:
	lua bin/top_in_client.lua "merkle.test.sha2_more"
