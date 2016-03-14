return function(into_table, how_cond, how_el)
   return function(cond, el, key, val)
      table.insert(into_table, {cond == "whole" and cond or cond.in_package,
                                how_el == "whole" and el or el.__envname,
                                key, val})
      return val
   end
end
