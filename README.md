# Lua Core/Generic Code (`lua-core`)

This repository contains a whole host of different core Lua code.  It is a mixture of different approaches and constructs, largely based on common patterns.

A large amount of this code is based on previous code experience, or patterns observed elsewhere.  Very little of this is new or exciting, and I've avoided anything that taps into other code (reverse-engineered/derived-from-compiled or otherwise).  Attributions to similar code will be given where appropriate; descriptions and pointers to patterns will be provided where available.  (Most of this code has to be heavily edited to extract it from its old code, so this may take some time to fully upload it all, as it takes a fair bit of effort to track down the dangling bits!)

The source code is placed within `source`, and it is treated as the Lua root (or current/present working directory).

I will update this repository, wiki, and the like, with more information on style and so on; the idea is to be accessible so people can adapt from it.

Code should only depend on `Core` (unless it is a test).

## Style

[Style information](https://github.com/ReversingSpace/lua-core/wiki/Style) shall be stored in [the wiki](https://github.com/ReversingSpace/lua-core/wiki/).

Comments should generally be of the form `--[[comment]]` rather than end of line comments `--comment`, as the former allows copying and pasting into interpreters without fear of missing line breaks.  It increases the total size of the file more than somewhat, but it is a cost worth accepting considering the benefits.

## Licence

Apache 2.0 or MIT (your choice); see `COPYRIGHT` for full statement.

This means you are free to use the code in your commercial projects if you so choose.  Contributions are assumed to be made under the above licence; pull requests which deviate from this will typically be rejected (unless they are public domain).

Individual files may contain headers indicating their origin.  See `HEADER` for the default header used here (or more information).