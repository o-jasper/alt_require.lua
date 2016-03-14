return function(into_table)
   return function(el, key, val)
      table.insert(into_table, {el, key, val})
      return val
   end
end
