return {
   a = function(x,y) return y .. x .. y end,
   b = function(x) return "(" .. x .. ")" end,
   c = { d = function(x) return "X" .. x .. "X" end },

   ff = function(fun, y)
      return fun(y) .. "Z" .. y
   end
}