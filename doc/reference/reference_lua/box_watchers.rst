.. _box-watchers:

--------------------------------------------------------------------------------
Functions for watchers
--------------------------------------------------------------------------------

The ``box`` module contains some functions related to event subscriptions, also known as watchers.
The subscriptions are used to inform a client about server-side events.
To see the list of the built-in events in Tarantool,
check the :doc:`pub/sub </reference/reference_lua/pub-sub>` section.

..  glossary::

    Watcher
        A watcher is a :doc:`callback </book/box/triggers>` that is invoked when a state change occurs.
        To register a local watcher, use the ``box.watch()`` function.
        To create a remote watcher, user the ``conn:watch()`` function.

    State
        A state is an internally stored key-value pair.
        The key is a string.
        The value is an arbitrary type that can be encoded as MsgPack.
        To update a state, use the ``box.broadcast()`` function.

First, a watcher callback is invoked unconditionally after the watcher registration.
Note that it is possible to register more than one watcher for the same key.
After that, :doc:`box.broadcast() </reference/reference_lua/box_watchers/broadcast>`  called on the remote host
triggers all subsequent invocations.

A watcher callback is passed the name of the key for which it was registered and the current key data.
A watcher callback is always invoked in a new fiber. It means that is is okay to yield in it.
A watcher callback is never executed in parallel with itself.
If the key is updated while the watcher callback is running, the callback will be invoked again with the new
value as soon as it returns.

``box.watch`` and ``box.broadcast`` functions can be used before :doc:`box.cfg </reference/reference_lua/box_cfg>`.

..  note::

    Keep in mind that garbage collection of a watcher handle doesn't lead to the watcher's destruction.
    In this case, the watcher remains registered.
    It is okay to discard the result of ``watch`` function if the watcher will never be unregistered.

Below is a list of all functions related to watchers.

..  container:: table

    ..  rst-class:: left-align-column-1
    ..  rst-class:: left-align-column-2

    ..  list-table::
        :widths: 25 75
        :header-rows: 1

        *   - Name
            - Use

        *  - :doc:`./box_watchers/watch`
           - Create a local watcher.

        *  - :ref:`conn:watch() <conn-watch>`
           - Create a watcher for the remote host.

        *  - :doc:`./box_watchers/broadcast`
           - Update a state.

.. toctree::
    :hidden:

    box_watchers/watch
    box_watchers/broadcast