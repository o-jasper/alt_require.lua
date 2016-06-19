-- Blocks and raises an error if not `allowed[package][symbol]`

return function(allowed)
   return function(state, el, key, val)
      local pkg = state.in_package
      local pkg_state = allowed[pkg]
      if pkg_state then
         if pkg_state[key] then
            return val
         else
            error(string.format("May not access %s inside package %s", key, pkg))
         end
      else  -- Note: doesnt block the package, just everything in it.
         error(string.format("nothing in package %s.", state.in_package))
      end
   end
end
