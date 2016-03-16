## Lua global and package control

"Sandboxing" using `loadfile`, replacing the environment to record, determine,
and/or restrict things. Basically want to distinctions between `lua` and `luajit`.
(it appears to work on both)

# ~~Magic~~ across-server lua
Uses the above and storebin, Pegasus, lua-socket to keep track of
objects on the other side.

Could be useful for:

* Dealing with when something works on `lua` but not `luajit` or vice versa.

* Mandatory Access Control, if it is desired to isolate portions of code.

* Magic moving code between client and server. However, clouds are bad.

(Current)Limitations:

* Unless the function came from the server -as-is-, the client cannot send
  functions to the server.

* Tables that are sent are copied each time.

  Should be possible to clear out these tables and add a metatable as to
  en-server-side them. (Unclear *when* to do this)

* Unknowns..

* It seems a little slow, though i see little reason why it should be.
  (note: perhaps use other data-transmission stuff)

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

## License
I wanted a permissive license, it is under the MIT license accompanied.

## TODO
* Better testing. What do metatables on the server do? Does the
  select-where-to-run portion work nicely?

* Can javascript talk to it?
