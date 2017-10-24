--[[ Simple test file for `Message.lua`. 

Expected output (without the indent):

    'Test' - 1
    fn_once!
    'Test' - 2
    fn_always!
    'Test' - 3
    'Test' - 4
    fn_always!
    fn_always!
]]
package.path = './../?.lua;' .. package.path
require("Common/Message")

local queue = Message:Create()

local function fn_once(...)
    print("fn_once!")
    queue:Forget("Test", fn_once)
end

local function fn_always()
    print("fn_always!")
end

queue["Test"] = fn_once
queue["Test"] = fn_always

print("'Test' - 1")
queue("Test")

print("'Test' - 2")
queue:Fire("Test")

queue["Test"] = nil

print("'Test' - 3")
queue("Test")

queue["Test"] = fn_always
queue["Test"] = fn_always

print("'Test' - 4")
queue("Test")