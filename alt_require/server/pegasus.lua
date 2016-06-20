local This = {}
for k,v in pairs(require "alt_require.server.base") do This[k] = v end
This.__index = This

This.store = require "storebin"

-- Can prepend things and change the server-end correspondingly, of course.
This.matcher = "^/?([^/]+)/?([^/]+)/?([^/]+)$"
This.under_path = ""

function This:pegasus_respond(req, rep)
   local path = req:path() or ""
   if string.sub(path, 2, #self.under_path + 1) == self.under_path then
      local method, name, id =
         string.match(string.sub(path, #self.under_path + 2),  self.matcher)
      if name then
         -- Currently at least, pegasus needs headers out first.
         req:headers()
         local input_data = req:receiveBody()
         local str = self.store.encode(self:respond(method, name, id,
                                                    self.store.decode(input_data)))
         -- TODO header depends on `self.store`.
         rep:addHeader("Content-Type", "bin/storebin"):write(str)
         return method, name, id
      end
   end
end

return This
