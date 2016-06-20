**TODO** link to story first, API's first, story after,.

**TODO** improve API.

## Lua global and package control
"Sandboxing" using `loadfile`, replacing the environment to record, determine,
and/or restrict things. Basically want no distinctions between `lua` and `luajit`.
(it appears to work on both)

To spell it out somewhat, using `loadfile(filename, mode, environment)` it makes an
alternative `require`, that finds the file(`alt_require.findfile`) and makes
an `environment`. The environment can be a table or get things via a metatable,
so arbitrary functions can be applied, like.

### API  **TODO** live up to it.
Once installed `local alt_require = require "alt_require"`.

* `.require(state, pass_through, [globals, ...])` 

  + `state` is the state to work with.
  
    `state.package` will indicate what package to read, if `state` is a string,
    it will be as if `{ package=that_string }` is passed.
    

  + `pass_through(state, globals, key,val)` is a function (a list will be composed)
    that get those arguments. Here, `state` is as above,

    The output is the resultant value.

  + `globals, ...` are what globals are at that point. If a list they're rolled
    into one *by changing the first*. If any are string
    `require "alt_require.glob." .. that_string`.

    `globals.require` instead of taking in the package name, it gets
    `state, pass_through, globals`, so information for alternatives is needed.
    
    If no `globals.require` is provided, a default that keeps the sandbox going is
    used.

You'll want to actually do something with it, some `pass_through` are in
`"alt_require.pt."`, they're pretty simple. In there: (`prep="alt_require.pt."`)

* `require(prep.."inpackage_counts")(table)` counts in 
   `table[package_name][key_name]`, i.e. what is accessed from where.
* `require(prep.."keep_count")(table)` counts in `table[key_name]`
  same, but doesn't care about what package it is from.
* `require(prep.."block_error")(table)` produces errors if
   `table[package_name][key_name]` has no entry and is accessed.
   
   Of course, `inpackage_counts` can collect what accesses what, and then
   this one can use the resulting table to enforce it.
 
* `require(prep.."print")(table)` Prints what global is accessed from
  where.

#### Uses:

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
You have to run the server(s) first, `alt_require.bin.alt_require` can be
run as-is. `C = require("alt_require.client.http")` is the class.

* `c = C:new{under_uri = "http://localhost:26019/alt_require"}`
  With just the default site to send the requests.

* `c:globals(local_require, require_selection)`

  The globals with the `c:require_fun(local_require, require_selection)` in it.
  Careful that you don't override `globals.require` afterward.
  
  If `require_selection` not `nil` then if `require_selection[package_name]`
  then it will ask the server, and otherwise it will use `local_require`
  to run it locally.

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

#### More internal API
This does not attempt to put any control inside objects that it returns,
but the globals it produces, like `require` can be modified to do so.

* `.findfile(package_str)`, finds which file `require` would find the
  lua file in question, as lua does not expose that function.

* `.globals_index(state, pass_through, globals)` returns a function for `__index`
  of an environment

  &rarr; `.globals()` Just the above, but the table with it.

* `.raw_require(state, pass_through, globals)`

## License
It is under the MIT license accompanied.

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
