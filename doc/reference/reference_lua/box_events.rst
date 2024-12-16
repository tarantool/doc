.. _box-watchers:

Event watchers
==============

Since :doc:`2.10.0 </release/2.10.0>`.

The ``box`` module contains some features related to event subscriptions, also known as :term:`watchers <watcher>`.
The subscriptions are used to inform the client about server-side :term:`events <event>`.
Each event subscription is defined by a certain key.

..  glossary::

    Event

        An event is a state change or a system update that triggers the action of other systems.
        To read more about built-in events in Tarantool,
        check the :doc:`system events </reference/reference_lua/box_events/system_events>` section.

    State
        A state is an internally stored key-value pair.
        The key is a string.
        The value is an arbitrary type that can be encoded as MsgPack.
        To update a state, use the ``box.broadcast()`` function.

    Watcher
        A watcher is a :ref:`callback <triggers-box_triggers>` that is invoked when a state change occurs.
        To register a local watcher, use the ``box.watch()`` function.
        To create a remote watcher, use the ``watch()`` function from the ``net.box`` module.
        Note that it is possible to register more than one watcher for the same key.

How a watcher works
-------------------

First, you register a watcher.
After that, the watcher callback is invoked for the first time.
In this case, the callback is triggered whether or not the key has already been broadcast.
All subsequent invocations are triggered with :doc:`box.broadcast() </reference/reference_lua/box_events/broadcast>`
called on the remote host.
If a watcher is subscribed for a key that has not been broadcast yet, the callback is triggered only once,
after the registration of the watcher.

The watcher callback takes two arguments.
The first argument is the name of the key for which it was registered.
The second one contains current key data.
The callback is always invoked in a new fiber. It means that it is allowed to yield in it.
A watcher callback is never executed in parallel with itself.
If the key is updated while the watcher callback is running, the callback will be invoked again with the new
value as soon as it returns.

``box.watch`` and ``box.broadcast`` functions can be used before :doc:`box.cfg </reference/reference_lua/box_cfg>`.

Below is a list of all functions and pages related to watchers or events.

..  container:: table

    ..  rst-class:: left-align-column-1
    ..  rst-class:: left-align-column-2

    ..  list-table::
        :widths: 25 75
        :header-rows: 1

        *   - Name
            - Use

        *  - :ref:`box.watch() <box-watch>`
           - Create a local watcher.

        *  - :ref:`box.watch_once() <box-watch>`
           - Get the current key value.

        *  - :ref:`conn:watch() <conn-watch>`
           - Create a watcher for the remote host.

        *  - :doc:`./box_events/broadcast`
           - Update a state.

        *  - :ref:`Built-in events <system-events>`
           - Predefined events in Tarantool

.. toctree::
    :hidden:

    box_events/watch
    box_events/watch_once
    box_events/broadcast
    box_events/system_events