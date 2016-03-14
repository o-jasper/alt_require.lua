local function r(x) return require("alt_require" .. x) end

local list, cnts, tree_cnts = {}, {}, {}
local tabulizer = r(".pt.tabulize")(list)
local counter   = r(".pt.keep_count")(cnts)
local tree_counter   = r(".pt.keep_tree_count")(tree_cnts)
local function req(str)
   return r("").alt_require({ in_package = str },
      {r ".pt.print", tabulizer, counter, tree_counter}, r ".glob.simple",
      { __envname="reqself", require = req })(str)()
end

req("alt_require.test.toys.reqme")

print("----")
for i, el in ipairs(list) do print(i, unpack(el)) end
print("----")
for k, cnt in pairs(cnts) do print(k, cnt) end
print("---")
for pkg, tab in pairs(tree_cnts) do
   for k, cnt in pairs(tab) do print(pkg, k, cnt) end
end
