.. _box-watchers:

--------------------------------------------------------------------------------
Functions for watchers
--------------------------------------------------------------------------------

The ``box`` module contains some functions related to event subscriptions, also known as watchers.
The subscriptions are used to inform a client about server-side events.
To see the list of the built-in events in Tarantool,
check the :doc:`pub/sub </reference/reference_rock/vshard/vshard_pub-sub>` section.

..  glossary::

    Watcher
        A watcher is a :doc:`callback </book/box/triggers>` that is invoked when a state change occurs.
        To create a local watcher, use the ``box.watch()`` function.

    State
        A state is an internally stored key-value pair.
        The key is a string.
        The value is an arbitrary type that can be encoded as MsgPack.
        To update a state, use the ``box.broadcast()`` function.

A watcher callback is passed the key for which it was registered and the current key data.
A watcher callback is always called in a new fiber, so it is okay to yield in it.
A watcher callback is never executed in parallel with itself.
If the key is updated while the callback is running,
the callback will be invoked with the new value as soon as it returns.

The ``watch()`` function returns a watcher handle that can be used to unregister the watcher
when it is no longer needed.

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
             To create a remote watcher, see the :ref:`conn:watch() <conn-watch>` function
             in the ``net.box`` module.

        *  - :doc:`./box_watchers/broadcast`
           - Update a state.

.. toctree::
    :hidden:

    box_watchers/watch
    box_watchers/broadcast