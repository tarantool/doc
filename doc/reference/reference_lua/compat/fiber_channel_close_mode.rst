.. _compat-option-fiber-channel:

Fiber channel close mode
========================

Before the change, there was an unexpected behavior when using ``channel:close()`` because it closed the channel entirely and discarded all unread events.

Old and new behavior
--------------------

The ``compat`` module allows you chose between the channel force and graceful closing. The latter is a new behavior.

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

You can select new/old behavior in ``compat``. It will affect all existing channels and the future ones.

Known compatibility issues
--------------------------

At this point, no incompatible modules are known.

Detecting issues in your codebase
---------------------------------

The new behavior is mostly backward compatible.
The only known problem that can appear is when the code relies on channel being entirely closed after ``ch:close()`` and ``ch:get()`` returning ``nil``.
