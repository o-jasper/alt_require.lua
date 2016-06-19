return function(state, globals, key, val)
   print("**", state.in_package, globals.__envname, key, val)
   return val 
end
