-- Blocks and raises an error if not `allowed[package][symbol]`

return function(allowed)
   return function(cond, el, key, val)
      local pkg = cond.in_package
      local pkg_cond = allowed[pkg]
      if pkg_cond then
         if pkg_cond[key] then
            return val
         else
            error(string.format("May not access %s inside package %s", key, pkg))
         end
      else  -- Note: doesnt block the package, just everything in it.
         error(string.format("nothing in package %s.", cond.in_package))
      end
   end
end
