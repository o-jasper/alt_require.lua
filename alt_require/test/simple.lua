-- Conveniences, requiring  in this repo and getting pass-through functions.
local function r(x)  return require("alt_require" .. x) end
local function pt(x) return r(".pt." .. x) end  -- (pt) stands for pass-through.

local alt_require = r ""
local req = alt_require.require  -- happen to not need globals, so can do this..

-- Differnt pass-throughs and objects they record into.
local list, cnts, tree_cnts = {}, {}, {}
local tabulizer = pt("tabulize")(list)
local counter   = pt("keep_count")(cnts)
local tree_counter   = pt("inpackage_counts")(tree_cnts)

-- Run using pass-throughs; different ways of recording;
--  printing, tabularizing into flatly into `list`(with values), flatly with counts of use,
--  and tree-form which counts how often something accessed -from-a-package.
req("alt_require.test.toys.reqme", {r ".pt.print", tabulizer, counter, tree_counter})

-- Prints out the cases.
print("----")
for i, el in ipairs(list) do print(i, unpack(el)) end
print("----")
for k, cnt in pairs(cnts) do print(k, cnt) end
print("---")
for pkg, tab in pairs(tree_cnts) do
   for k, cnt in pairs(tab) do print(pkg, k, cnt) end
end

-- Uses the tree counts to block if not counted, it passes because all connections
--  already counted.
print("---")
req("alt_require.test.toys.reqme", {pt("block_error")(tree_cnts)})

-- Go through the tree-thing and print the files.
print("--- My files were from:")
for pkg, _ in pairs(tree_cnts) do print(pkg, alt_require.findfile(pkg)) end

math.randomseed(math.floor(os.time() + 100000*os.clock()))
local break_pkg = "alt_require.test.toys." ..
   ({"reqme", "subreqme", "subsubreqme"})[math.random(3)]
print("--- Test breaking", break_pkg)

-- Turn this one off, but it'll be needed, we expect an error.
-- (_a_ test against false-positives)
tree_cnts[break_pkg] = false
local r, err = pcall(function()
      req("alt_require.test.toys.reqme", {pt("block_error")({})})
      return true
end)
assert(r == false)
