return function(of)
   assert(({table=true, ["function"]=true})[type(of)])
   return string.lower(string.match(tostring(of), "0x([%x]+)"))
end
