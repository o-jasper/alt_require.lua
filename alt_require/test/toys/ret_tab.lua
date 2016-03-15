local function a(x,y) return y .. x .. y end

return {
   a = a,
   b = function(x) return "(" .. x .. ")" end,
   c = { d = function(x) return "X" .. x .. "X" end },

   ff = function(fun, y)
      return fun(y) .. "Z" .. y
   end,

   gg = function(tab, x)
      return a(tab.d(x), x)
   end,
}
