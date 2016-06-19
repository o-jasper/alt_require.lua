return function(into_table)
   return function(state, el, key, val)
      local tab = into_table[state.in_package] or {}
      tab[key] = (tab[key] or 0) + 1
      into_table[state.in_package] = tab
      return val
   end
end
