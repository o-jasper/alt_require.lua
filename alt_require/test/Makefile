
vbins/%:
	make tic/"`echo -n$@ | cut -f 2 -d/`"
	make ris/"`echo -n$@ | cut -f 2 -d/`"

tic/%:
	lua bin/top_in_client.lua "`echo -n$@ | cut -f 2 -d/`"

ris/%:
	lua bin/randomly_in_server.lua "`echo -n$@ | cut -f 2 -d/`"

default:
	echo "Options:" > /dev/null
	grep ':' Makefile
	make run_server

# Needed to run any server tests.
run_server:
	lua ../bin/alt_require.lua

run_server_2:
	lua ../bin/alt_require.lua 26020

### Non-server tests.
all_non_server: simple.lua simple.luajit

%.lua: /tmp/
	lua "$@"

%.luajit:
	lua "`echo -n $@ | head -c-3`"

### Server.

all_client: client.lua client.luajit

# Looks like this works
complex: vbins/alt_require.test.toys.complex

# Top-layer-on-client tests from other projects. (TODO need to go deeper, obviously)
lib_test: sha2 storebin merkle page_html/util #Searcher

sha2/ris: ris/merkle.test.sha2  ris/merkle.test.sha2_more
sha2/tic: tic/merkle.test.sha2  tic/merkle.test.sha2_more
sha2: sha2/tic sha2/ris
# Storebin, merkle, Search violates assumptions i still need, apparently.
storebin/ris: ris/storebin.test.test ris/storebin.test.try
storebin/tic: tic/storebin.test.pkg tic/storebin.test.test tic/storebin.test.try
storebin: storebin/tic

merkle/ris: ris/merkle.Merkle.test.merkle
merkle/tic: tic/merkle.Merkle.test.merkle
merkle: merkle/tic

# Searcher just broke atm.
Searcher/ris: ris/Searcher.test.sql ris/Searcher.test.try_Formulator
Searcher/tic: tic/Searcher.test.sql tic/Searcher.test.try_Formulator
Searcher: Searcher/tic

# Don't really use string_split now.
page_html/util_meh: tic/page_html.util.test.string_split tic/page_html.util.test.try
# Markdown and "escapeless"
#  latter might move to Searcher later, as it is intended to keep strings from
#  getting into your Sql thing.
page_html/util/tic: tic/page_html.util.fmt.test.fmts
page_html/util/ris: ris/page_html.util.fmt.test.fmts

page_html/util: page_html/util/tic page_html/util/ris
