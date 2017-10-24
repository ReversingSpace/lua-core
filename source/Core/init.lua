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
This is a trivial hack that replaces another hack, which is used to load the
library into scope from the core initialisation.

Think of this as a springboard.  It occupies the global `Core`.
---------------------------------------------------------------------------]]--

--[[ If this already exists we don't want to clobber it; if it doesn't, we
were beaten and should bow out. ]]
if type(Core) == "table" then
    return
end

Core = {}

require("Core/VM/Util")