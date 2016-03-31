local function a(x,y) return y .. x .. y end

local loop = {}
loop.self = loop

return {
   no_args = function() return "no arguments works" end,
   a = a,
   b = function(x) return "(" .. x .. ")" end,
   c = { d = function(x) return "X" .. x .. "X" end },

   ff = function(fun, y)
      return fun(y) .. "Z" .. y
   end,

   gg = function(tab, x)
      return a(tab.d(x), x)
   end,

   loop = loop,
}
