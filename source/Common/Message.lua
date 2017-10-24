--[[---------------------------------------------------------------------------
Copyright (c) 2011-2017 A.W. Stanley.

See the COPYRIGHT file at the top-level directory of this distribution and in
the repository: https://github.com/ReversingSpace/lua-core

Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
<LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
option. This file may not be copied, modified, or distributed
except according to those terms.
-------------------------------------------------------------------------------
This code comes from my long private collection, which involves both modding
related code and complex embedded systems code; Lua is ideal for configuration
files on embedded systems, so while this is not the optimised copy of the
Message passing file it is one that is widely compatible and good for testing
or rapid prototyping.

Original header information below.
-------------------------------------------------------------------------------
Message passing like that which is used in message queues (MQs).  Similar to
the kind found in the Tropico games, though this is actually derived from a
trivial pattern in C.  Wrapped in metatables to make it super-pretty, and
spawned as a factory-based system.

Uses Core/VM detection systems to build on compatibility of a given platform
or version.

This can be better/faster written in C++ if you need raw speed; C variants are
also probably better, though more annoying to write.
---------------------------------------------------------------------------]]--

--[[ Include Core if it's missing. ]]
if type(Core) ~= "table" then
    require("Core/init")
end

--[[ Include Core/VM/Util if it's missing. ]]
if type(_VERSION) ~= "table" then
    require("Core/VM/Util")
end

--[[ If Message is defined as a table then either someone beat us to it, or
we already installed.  This is a cheap test which should prevent some minor
breakage. ]]
if type(Message) == "table" then
    return
end


--[[---------------------------------------------------------------------------
The factory-based system is divided into three parts:
 - `message` (the namespace and factory);
 - `message_factory_metatable` (metatable for `message`);
 - `message_metatable` (metatable for created message queues).

The real magic is in the message_metatable.

Per the pattern the basic idea is to have a message queue object (a Lua table),
allow registration of listeners on the message queue, and firing on the queue.

To do this we enable variadic queue storage (which is how I do this in C++),
which is less painful in this than it is in C++.

To create a queue:

    local queue = Message:Create()
    -- or (for Lua 5.1+)
    local queue = Message()


To queue messages for a given name we abuse __index:

    queue["MsgName"] = function(...) [code goes here] end
    queue["MsgName"] = function(...) [more code goes here] end


To reset the queue you can use Clear, or set it to nil:

    queue["MsgName"] = nil -- cleared
    queue:Clear("MsgName") -- cleared


To call the message use `:Fire` (or __call from 5.1+):

    queue:Fire("MsgName", args, go, here)
    queue("MsgName", args, go, here)


To remove a specific function use `:Forget`:

    queue:Forget("MsgName", fn)

To create a one-use function:

    -- We assume 'queue' is stored here.

    local function fn()
        -- Do magic here

        -- Then forget me
        queue:Forget("MsgName", fn)
    end
    queue("MsgName", fn)


Notes:

    queue:Forget("MsgName", nil) -- will clear the queue

-------------------------------------------------------------------------------
The first code block is declarations.
---------------------------------------------------------------------------]]--



--[[ We re-use this a lot, so we might as well write it once so people can
update it later if they want. ]]
local message_storage_table_name = "message"

--[[ Create a local table to build into. ]]
local message = {}

--[[ Metatable on the factory. ]]
local message_factory_metatable = {}

--[[ The metatable which does the real/complex/hard work. ]]
local message_metatable = {}

--[[---------------------------------------------------------------------------
`message`
Defines the factory.
---------------------------------------------------------------------------]]--

--[[ Create a new queue and bind it to the metatable. ]]
local function create()
    local t = {}
    t[message_storage_table_name] = {}
    setmetatable(t, message_metatable)
    return t
end


--[[---------------------------------------------------------------------------
`message_factory_metatable`
Defines the factory metatable.
---------------------------------------------------------------------------]]--

--[[ For Lua versions 5.1+, we bind the __call function to the metatable. ]]
if _VERSION(5.1) then
    message_factory_metatable.__call = create
end

--[[ Block access to the metatable. ]]
message_factory_metatable.__metatable = "Access denied"

--[[ Restrict access in general ]]
message_factory_metatable.__index = function(t,k)
    if k == "Create" then
        return create
    end
    return nil
end

--[[ Block modifications. ]]
message_factory_metatable.__newindex = function(t,k,v)
    return nil
end

setmetatable(message, message_factory_metatable)


--[[---------------------------------------------------------------------------
`message_metatable`
Defines the metatable for message queues.
---------------------------------------------------------------------------]]--

--[[ Block access to the metatable. ]]
message_metatable.__metatable = "Access denied"

--[[ Fire function is Dispatch (remember we pay for each byte in names).

First argument is the table (`t`), which is converted to `self` when used
like so: `Msg:Fire(...)`.

Second argument is the message (`m`), which may take whatever form it is
stored in the table as.

Third argument is variadic, which we just pass on as-is. ]]
local dispatch = function(t, m, ...)
    --[[ Get the storage folder. ]]
    local messages = rawget(t, message_storage_table_name)

    --[[ Check if it's valid, scanning for how we should approach it. ]]
    if m ~= nil then
        if type(messages[m]) == "table" then
            --[[ Pass to each, one by one, but only if valid. ]]
            for _,v in ipairs(messages[m]) do
                --[[ Commented out checked version is here; we don't need
                this as we can't install unless it is a function!
                if type(v) == "function" then
                    v(...)
                end
                ]]
                v(...)
            end
        end
    end
end

--[[ For Lua versions 5.1+, we bind the __call function to the metatable. ]]
if _VERSION(5.1) then
    message_metatable.__call = dispatch
end

--[[ Rewrite the __newindex so it can be used to storage messages. ]]
message_metatable.__newindex = function(t,k,v)
    local messages = rawget(t, message_storage_table_name)
    if v == nil then
        --[[ Clear semantics ]]
        messages[k] = {}
    else
        --[[ Queue semantics
        Only install if it is a function, creating the missing
        subtable to store it in if it's missing.]]
        if type(v) == "function" then
            
            if not messages[k] then
                messages[k] = {}
            end
            table.insert(messages[k], v)
        end
    end
end

--[[ Forget functionality ]]
local forget = function(t, k, fn)
    --[[ Get storage. ]]
    local messages = rawget(t, message_storage_table_name)

    --[[ If it's nil, do a reset, as we forget all this way. ]]
    if fn == nil then
        messages[k] = {}
    else
        --[[ Check if it's a valid storage table, then search
        for it.  This is where closures can bite you. ]]
        if type(messages[k]) == "table" then
            for i,v in ipairs(messages[k]) do
                if v == fn then
                    table.remove(messages[k], i)
                end
            end
        end
    end
end


--[[ We don't need to enable lookups, as we're using a factory based build.
For other builds you could do insane things like function scanning on the
subtable or something.  I don't recommend it as the cost is way higher
than just writing a sensible API. ]]
message_metatable.__index = function(t,k)
    --[[ Only allow strings, and only certain strings at that. ]]
    if type(k) == "string" then
        if k == "Fire" then
            return dispatch
        end

        if k == "Forget" then
            return forget
        end
    end
    return nil
end

--[[ Lua 5.3+ features: just add the __name for type identification in
crash related moments. ]]
if _VERSION(5.3) then
    message_metatable.__name = "MessageQueue"
end

--[[ We use a global value because that's just how this was designed;
if you move to a modular variant just do the return below. ]]
Message = message
return message