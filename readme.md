## Lua global and package control
"Sandboxing" using `loadfile`, replacing the environment to record, determine,
and/or restrict things. Basically want no distinctions between `lua` and `luajit`.
(it appears to work on both)

To spell it out somewhat, using `loadfile(filename, mode, environment)` it makes an
alternative `require`, that finds the file(`alt_require.findfile`) and makes
an `environment`. The environment can be a table or get things via a metatable,
so arbitrary functions can be applied, like:

* Recording what is being accessed, from where, to an extent.

  Don't think line numbers can be done, unless lua provides that information,
  but from-which-package *is* done in the test.

* Determining what can be accessed or set, and what the result is.
  For instance:
  + Setting global variables can be outlawed.
  + Accessing `os`, `io` etcetera can just return `nil` or cause errors.
    (or return simulacra)
  + `require` can be replaced, infact it *must*, if you want to keep this
    control over sub-entities. However, it can also go to another mode of
    control.

    A particular override of `require` can obviously apply different
    restrictions and changes to different files.
  + If you assume lua "provides no escapes", and there are no bugs here,
    it can essentially be used for Mandatory Access Control. Unclear on
    the certainty of there being no escapes.

* Third one of the above, but worthy of mentioning again, `require` can be
  altered to give different results from different files, so you can change
  them differently in different cases, making programs more modular.

  One question about this is how easy this is on the mind.. Probably better
  to have a differently named function get things of the same concept.

* The below; accessing things actually returns objects that are handles that
  talk to an external server; a "simulacrum based on the entity on the other
  server" to say it fancy.

### API
**TODO**

# ~~Magic~~ across-server lua
Uses [storebin](https://github.com/o-jasper/storebin),
[Pegasus](https://github.com/EvandroLG/pegasus.lua/) and
[lua-socket](https://github.com/diegonehab/luasocket)
for the client side to keep track of lua objects on the server side,

Could be useful for:

* Dealing with when something works on `lua` but not `luajit` or vice versa.

* Mandatory Access Control, if it is desired to isolate portions of code.

* Magic moving code between client and server. However, clouds are bad.

### API
**TODO**

#### (Current)Limitations:

1. Unless the function came from the server -as-is-, the client cannot send
   functions to the server.

2. `getmetatable` of a simulacrum, returns the thing simulating the object,
   so `getmetatable` itself won't be simulated.

   Some implementations of classes, `obj.__index` might effectively do it.

   Client-to-server are not sent with metatables currently. Barring (1)
   it could.

3. Unknowns..

4. It seems a little slow, though i see little reason why it should be.
   (note: perhaps use other data-transmission stuff, note2: storebin might
   be slow, but not nearly slow enough to explain the low speed)
   
   note3: it looks for `__constant` in tables now, tables that are constant
   are memoized on the other side.

In practice things seem to work with what i wrote for it so-far.

Note: to run these tests, have `lua alt_require/test/server.lua` running.

### Dependencies
The non-client server stuff just uses plain lua.(no dependencies)

For the portion with the client-talks-to-lua-on-server, requires
[storebin](https://github.com/o-jasper/storebin),
[Pegasus](https://github.com/EvandroLG/pegasus.lua/) and
[lua-socket](https://github.com/diegonehab/luasocket).

Storebin can be replaced with an object  with `.encode(tree)` &rarr; `data`
`.decode(data)` &rarr; `tree`. Of course the client and server side have to use
the same one.

The pegasus-based thing can probably also be plugged into another server by
calling `:respond` appropriately. Perhaps in the future i'll have an option
to cut pegasus out of the loop.

### Running the tests
If packages are made available to lua, `make` runs the non-server tests.

For the server tests, you need the dependencies above, go to
`alt_require/test/`.(use the `Makefile` to see how some commands work there)

To run the server test, `make run_server` to run a server, and then
`make all_client` runs the client tests using that server.

(server prints out `method, accessname, object_tracking_number`, currently omits
the )

## License
I wanted a permissive license, it is under the MIT license accompanied.

## TODO
* Much better documentation regarding the core part.

* Could be more tests on external projects, and the way server-client is
  split could be varied.

* (really for storebin) Implement a `store` version that ports `json`.
  (`json` can't do full lua tables..)
  + Can javascript talk to it?
  + "pre-prepared `store`", basically with some definitions already transferred.

* There is basically some "table-syncing" code in there.

  This can be separated out, and definitions-for-bandwidth-savings could be
  added.

* Could build-in the top-level format, instead of using `storebin`. i.e.
  `is_server_type` 1byte, `id` 6 bytes, `name`(variable length),
  number-of-arguments, `storebin`-ed each argument.

  *However* depends on other things, *and* should do it using specialized
  `self.store.encode`.(/`..decode`)

* Map projects with recorders, producing graphs with
  [graphviz](http://graphviz.org/).([wp](https://en.wikipedia.org/wiki/Graphviz))

* More limitations can be removed with bidirectional communication.

  Both ends could have simulacra, and instead of the value, the server could
  sometimes return requests with not values, but instead ask more information
  about a server-side simulacrum.

  This can be done with the plain http and pegasus-approach.
  (however, it might make things more-complicated enough to keep a "one-way"
   version around)

* Multithreading sounds hard.. Could have a standard indicating some info about
  how things are used, for instance if a table is constant, if a function does
  not change state of anything.(or even what it changes)
