## Lua global and package control

Experimentation with using `load` to record, determine, and/or restrict things.
Use `load` alone! Basically want to distinctions between `lua` and `luajit`.
(it appears to work on both)

Basically, it could be a mandatory access control tool, a tool to analyse.

But *also*, in principle, it might be possible to take some arbitrary lua file
and say "you run on this other computer, using http(s) to talk".
(or Tox, or whatever) Indicating just how MAC it could be. If they use
`io.open` or `os.`, different files may see a different
operating system, unless you pass that along aswel.

There is some code here, but not tested yet.

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
calling `:respond` appropriately.

## License
I wanted a permissive license, it is under the MIT license accompanied.
