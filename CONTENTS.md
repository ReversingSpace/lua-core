# Common

## Message

A simple message passing queue.  It has been adapted based in part on exposure, but is largely just what you'd find in C.  The metatable system creates a factory, which just covers a table in a fairly neat/trivial way.

Useful for learning about message passing queues, but not a lot else.

Similar to what is found in the Tropico 3/4/5 series of games.  Original inspiration was a Python pickle-based message pump (for cross-threading), though 'Dispatch' has been changed to 'Fire' to reduce cost.


# Core

At this time all of this code is from A.W. Stanley.  It is a stripped down version of some utilities which have been decoupled.

## VM

Virtual Machine related updates/hacks/tweaks.  Very stripped back (only handles `_VERSION` right now).