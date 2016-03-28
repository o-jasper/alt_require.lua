default:
	echo "Options:" > /dev/null
	grep ':' Makefile
	make run_server

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

# Tests from other projects.
sha2_all: sha2 sha2_more

sha2:
	lua bin/top_in_client.lua "merkle.test.sha2"
sha2_more:
	lua bin/top_in_client.lua "merkle.test.sha2_more"

# TODO more.
