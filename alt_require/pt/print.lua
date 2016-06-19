return function(state, globals, key, val)
   print("**", state.package, globals.__envname, key, val)
   return val 
end
