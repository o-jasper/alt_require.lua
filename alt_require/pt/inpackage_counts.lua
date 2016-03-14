return function(into_table)
   return function(cond, el, key, val)
      local tab = into_table[cond.in_package] or {}
      tab[key] = (tab[key] or 0) + 1
      into_table[cond.in_package] = tab
      return val
   end
end
