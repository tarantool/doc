.. _compat-option-fiber-channel:

Fiber channel close mode
========================

Before the change, there was an unexpected behavior when using channel:close() as it closed the channel entirely and discarded all unread events.

Old and new behavior
--------------------

compat lets you chose between channel force and graceful close, the latter being the new behavior.
You can select new/old behavior in compat, it will affect all channels existing and future.

..  code-block:: lua

    tarantool> compat = require('compat')
    ---
    ...

    tarantool> compat
    ---
    - - yaml_pretty_multiline: default (old)
      - json_escape_forward_slash: default (old)
      - fiber_channel_close_mode: default (old)
    ...

    tarantool> fiber = require('fiber')
    ---
    ...

    tarantool> ch = fiber.channel(10)
    ---
    ...

    tarantool> ch:put('one')
    ---
    - true
    ...

    tarantool> ch:put('two')
    ---
    - true
    ...

    tarantool> ch:get()
    ---
    - one
    ...

    tarantool> ch:close()
    ---
    ...

    tarantool> ch:get()
    ---
    - null
    ...

    tarantool> compat.fiber_channel_close_mode = 'new'
    ---
    ...

    tarantool> ch = fiber.channel(10)
    ---
    ...

    tarantool> ch:put('one')
    ---
    - true
    ...

    tarantool> ch:put('two')
    ---
    - true
    ...

    tarantool> ch:get()
    ---
    - one
    ...

    tarantool> ch:close()
    ---
    ...

    tarantool> ch:get()
    ---
    - two
    ...

    tarantool> ch:get()
    ---
    - null
    ...

Known compatibility issues
--------------------------

At this point we do not know any incompatible modules.

Detecting issues in you codebase
--------------------------------

The new behavior is mostly backward compatible, the only known problem that could appear is when code relies on channel being entrirely closed after ch:close() and ch:get() returning nil.
