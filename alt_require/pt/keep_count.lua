return function(into_table)
   return function(el, key, val)
      into_table[key] = (into_table[key] or 0) + 1
      return val
   end
end
