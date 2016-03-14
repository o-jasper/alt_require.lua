local ar = require "alt_require"

local e = {  -- NOTE: "escaping" stuff probably in here!
   loadstring = loadstring,  -- An escape
   coroutine = coroutine,
   unpack = unpack,
   xpcall = xpcall,
   setmetatable = setmetatable,
   dofile = dofile,
   pcall = pcall,
   load = load,  -- An escape
   rawlen = rawlen,
   rawget = rawget,
   os = os,
   package = package,  -- Recurses, breaks `c.copy_meta`
   getmetatable = getmetatable,
   arg = arg,
   tostring = tostring,
   _G = G,  -- Seems like bad idea.
   bit32 = bit32,
   debug = debug,
   utf8 = utf8,
   io = io,
   string = string,
   tonumber = tonumber,
   math = math,
   select = select,
   assert = assert,
   print = print,
   table = table,
   next = next,
   rawset = rawset,
   require = require,
   pairs = pairs,
   collectgarbage = collectgarbage,
   module = module,
   loadfile = loadfile,
   _VERSION = _VERSION,
   rawequal = rawequal,
   error = error,
   type = type,
   ipairs = ipairs
}

local This = {}
This.__index = This
This.__name = "alt_require.ah.SimpleBase"

function This:new(new)
   new = setmetatable(new or {}, self)
   new:init()
   return new
end

function This:init()
   self.loaded = self.loaded or {}
   self.env = self.env or e
   if self.recurse then
      self.env.require = self:require_fun()
   end
   if self.record_require_file then
      -- Otherwise it will just access the existing one.
      local oldrequire = self.env.require
      self.env.require = function(file)
         self:record_require(file)
         return oldrequire(file)
      end
   end
end

function This:envfun(file) return setmetatable({}, self:meta(file)) end

function This:require_fun(envfun)
   local envfun = envfun or self.envfun
   return function(file)
      local ret = self.loaded[file]
      if not ret then
         local file_path = ar.alt_findfile(file)
         ret = file_path and loadfile(file_path, nil, envfun(self, file))()
         self.loaded[file] = ret
      end   
      return ret
   end
end
function This:require(what) return self:require_fun()(what) end

return This
