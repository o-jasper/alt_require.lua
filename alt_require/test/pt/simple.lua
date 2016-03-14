local function r(x) return require("alt_require" .. x) end

local list, cnts = {}, {}
local tabulizer = r(".pt.tabulize")(list)
local counter   = r(".pt.keep_count")(cnts)
local function req(str)
   return r("").alt_require({r ".pt.print", tabulizer, counter}, r ".glob.simple",
                            { __envname="reqself", require = req })(str)()
end

req("alt_require.test.toys.reqme")

print("----")
for i, el in ipairs(list) do print(i, unpack(el)) end
print("----")
for k, cnt in pairs(cnts) do print(k, cnt) end
