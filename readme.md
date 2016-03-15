## Lua global and package control

Experimentation with using `load` to record, determine, and/or restrict things.
Use `load` alone! Basically want to distinctions between `lua` and `luajit`.
(it appears to work on both)

Basically, it could be a mandatory access control tool, a tool to analyse.

# Magic across-server lua

Uses the above and storebin, Pegasus, lua-socket to keep track of
objects on the other side.

Could be useful for:

* Dealing with when something works on `lua` but not `luajit` or vice versa.

* Mandatory Access Control, if it is desired to isolate portions of code.

* Magic moving code between client and server. However, clouds are bad.

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
* Better testing. What do metatables on the server do?

* Apply it to something..
