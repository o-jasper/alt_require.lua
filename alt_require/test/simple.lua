local function r(x)  return require("alt_require" .. x) end
local function pt(x) return r(".pt." .. x) end

local alt_require = r ""

local list, cnts, tree_cnts = {}, {}, {}
local tabulizer = pt("tabulize")(list)
local counter   = pt("keep_count")(cnts)
local tree_counter   = pt("inpackage_counts")(tree_cnts)
local function req(str, pts)
   return alt_require.require({ in_package = str },
      pts, r ".glob.simple",
      { __envname="reqself", require = function(s) return req(s, pts) end })(str)()
end

req("alt_require.test.toys.reqme", {r ".pt.print", tabulizer, counter, tree_counter})

print("----")
for i, el in ipairs(list) do print(i, unpack(el)) end
print("----")
for k, cnt in pairs(cnts) do print(k, cnt) end
print("---")
for pkg, tab in pairs(tree_cnts) do
   for k, cnt in pairs(tab) do print(pkg, k, cnt) end
end

print("---")
req("alt_require.test.toys.reqme", {pt("block_error")(tree_cnts)})

print("--- My files were from:")
for pkg, _ in pairs(tree_cnts) do print(pkg, alt_require.findfile(pkg)) end


math.randomseed(math.floor(os.time() + 100000*os.clock()))
local break_pkg = "alt_require.test.toys." ..
   ({"reqme", "subreqme", "subsubreqme"})[math.random(3)]
print("--- Test breaking", break_pkg)

tree_cnts[break_pkg] = false
local r, err = pcall(function()
      req("alt_require.test.toys.reqme", {pt("block_error")({})})
      return true
end)
assert(r == false)
assert(string.format("/home/jasper/.lualibs/alt_require/pt/block_error.lua:14: nothing in package %s/", break_pkg))
