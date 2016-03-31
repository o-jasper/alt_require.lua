tic/%:
	lua bin/top_in_client.lua "`echo -n$@ | cut -f 2 -d/`"

default:
	echo "Options:" > /dev/null
	grep ':' Makefile
	make run_server

# Needed to run any server tests.
run_server:
	lua server.lua

### Non-server tests.
all_non_server: simple.lua simple.luajit

%.lua: /tmp/
	lua "$@"

%.luajit:
	lua "`echo -n $@ | head -c-3`"

### Server.

all_client: client.lua client.luajit

# Looks like this works
complex: tic/alt_require.test.toys.complex

# Top-layer-on-client tests from other projects. (TODO need to go deeper, obviously)
top_layer_test: sha2 storebin merkle

sha2: tic/merkle.test.sha2  tic/merkle.test.sha2_more
storebin: tic/storebin.test.pkg tic/storebin.test.test tic/storebin.test.try
merkle: tic/merkle.Merkle.test.merkle

