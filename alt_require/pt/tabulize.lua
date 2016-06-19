return function(into_table, how_state, how_el)
   return function(state, el, key, val)
      table.insert(into_table, {state == "whole" and state or state.in_package,
                                how_el == "whole" and el or el.__envname,
                                key, val})
      return val
   end
end
