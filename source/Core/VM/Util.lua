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
This file is extracted from my own personal libraries of core code,
and it is being released here so people may make good use of it.

Original header comments are in the next section of this comment block.
Capitalisation is tied to the original purpose (closed and limited sharing).

Only partial code is made available at this time (as a lot of it is for
mods which I don't want broken and a lot of the code is tied to bits and
pieces in VMs that you don't need to know/care about).

Some modifications were made to keep in style with my updated code.

USAGE:
This file is useful for unknown targets, and general purpose testing and/or
prototyping.  It has been adapted to remove reliance on the _AWS global
namespace/table construct, and the VM modifications which backfed into it.

NOTES:
This file has been modified to remove global variable checks, and so must do
a pre-install check on each modified function or variable.  Typically you
would only do these checks if you needed them in production, but you should
generally find your way around that.    
-------------------------------------------------------------------------------
UNKNOWN/PRE-RELEASE CODE BLOCK. USE THIS IN PROTOTYPES WITH UNKNOWN
LUA CODE OR IN MOD CODE WITH UNCERTAIN BASES.

Tested for official Lua, versions 5.0.3 through 5.3.1.
---------------------------------------------------------------------------]]--

--[[ Check to see if we haven't already been here. ]]
if type(_VERSION) == "string" then
    --[[ Making global version splits.
    This can be *vastly* improved by moving MT to a single table, or 
    implementing it in the C API (pre-allocate tables for cost reduction).

    The structure here, i.e. `(function() ... end)()`, is a Lua closure. ]]
    _VERSION = (function()
        --[[ Extract components. ]]
        local major,minor = _VERSION:match("Lua (%d).(%d)")

        --[[ Pull the full version. ]]
        local full_version = _VERSION:match("Lua (%g+)")

        --[[ Cross version hack.  Works in modded copies too.
        Remember that all numbers are actually strings too.
        
        Important because this is how we actually detect it!
        
        Note: we can use `major = major + 0` if tonumber is
        broken or missing, but we use tonumber as it's an
        old function that's safe. ]]
        major = tonumber(major)
        minor = tonumber(minor)
        full_version = tonumber(full_version)

        --[[ Throw an error message if it isn't supported (non-official). ]]
        if major == nil then
            error([[
    Invalid or unsupported Lua version (or crippled VM).
    Use hardened tools.
    ]])
        end

        --[[ Copy the global version to a local copy so we can return it. ]]
        local version = _VERSION
        
        --[[ The table itself, which is actually empty. ]]
        local t = {}

        --[[ Returns the parts, Python style. ]]
        local parts = { 
            full_version,
            major,
            minor
        }

        --[[ Metatable, so we can build it bit by bit. ]]
        local mt = {}

        --[[ Sets the error type in standard installs; sets it to typeof()
        checks in my modified VMs; does not impact type() in Lua, but does
        allow for `luaT_objtypename` checks in the C API for Lua 5.3+ ]]
        mt.__name = "Core/Util:(Lua Version)"

        --[[ Block modification without rawset. ]]
        mt.__newindex = function(t,k,v)
            return
        end

        --[[ Block fetch without rawget.]]
        mt.__index = function(t,k)
            if type(k) == "string" then
                local k_lowered = k:lower()
                if k_lowered == "major" then
                    return major
                end

                if k_lowered == "minor" then
                    return minor
                end
            end
            return nil
        end
        
        --[[ Returns a set like Python does; or provides a test if the
        version_minimum is specified. ]]
        mt.__call = function(self, version_minimum)
            if version_minimum ~= nil then
                return full_version >= version_minimum
            end
            return parts
        end

        --[[ Return the string representation to prevent weird issues if
        people use it in other ways; typically a non-issue, as most games
        don't need to test their Lua install/build. ]]
        mt.__tostring = function()
            return version
        end

        --[[ Bind the return value to the metatable. ]]
        setmetatable(t, mt)

        --[[ Return it (but only once). ]]
        return t
    end)()
end