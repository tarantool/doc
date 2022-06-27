.. _vshard-pubsub:

Pub/sub system and its events
=============================

Pub/sub is a notification system for Tarantool events.
It is associated with one-time subscriptions.

The system processes the following events:

*   ``box.id``
*   ``box.status``
*   ``box.election``
*   ``box.schema``

In response to each event, the server sends back certain IPROTO fields.

Built-in events for pub/sub
---------------------------

One of the most important purposes of the built-in events is :ref:`master discovery <cfg_basic-master>`.
It is necessary to know the master node in order to send changes to a correct instance
or to read the most recent data.
In addition, there are more built-in events for other mutable properties such as the change of the leader's
state, its election role and term, the change of the schema version,
and the state of the instance.

Built-in events have a special naming schema -- theirs names always start with the ``box`` prefix.
This prefix is reserved for the built-in events. It means that you cannot create new events with it.

Note that built-in events can't be overridden.
It means that the user cannot call
:doc:`box.broadcast('box.id', any_data) <reference/reference_lua/box_watchers/broadcast>`.

Below is a table of all events that includes the name of the event and its description.

..  container:: table

    ..  list-table::
        :widths: 50 50

        *   -   Built-in event
            -   Description

        *   -   box.id
            -   Identification of the instance. Changes are particelarly rare. Some
                values never change or change only once. For example, the UUID of the instance never
                changes after the first :doc:`box.cfg <reference/reference_lua/box_cfg.rst>`.
                However, it is not known before ``box.cfg`` is called.
                The replicaset UUID is unknown until the instance joins a replicaset or
                boots a new one, but events are supposed to start working before then --
                right when the listen launches. The numeric instance ID is known only after
                registration. For anonymous replicas, the value is ``0`` until they are officially registered.

        *   -   box.status
            -   Generic blob about the instance status. There are the most frequently used
                and not frequently changed config options and :doc:`box.info <reference/reference_lua/box_info.rst>`
                fields.

        *   -   box.election
            -   All the required parts of :doc:`box.info.election <doc/reference/reference_lua/box_info/election>`
                needed to find out who is the most recent writable leader.

        *   -   box.schema
            -   Schema-related data. Currently, it contains only the version.

The value for each of the built-in events is written in the following code-block:.

..  code-block:: lua

    -- box.id value
    {
    MP_STR “id”: MP_UINT; box.info.id,
    MP_STR “instance_uuid”: MP_UUID; box.info.uuid,
    MP_STR “replicaset_uuid”: MP_UUID box.info.cluster.uuid,
    }

    -- box.status value
    {
    MP_STR “is_ro”: MP_BOOL box.info.ro,
    MP_STR “is_ro_cfg”: MP_BOOL box.cfg.read_only,
    MP_STR “status”: MP_STR box.info.status,
    }

    -- box.election value
    {
    MP_STR “term”: MP_UINT box.info.election.term,
    MP_STR “role”: MP_STR box.info.election.state,
    MP_STR “is_ro”: MP_BOOL box.info.ro,
    MP_STR “leader”: MP_UINT box.info.election.leader,
    }

    -- box.schema value
    {
    MP_STR “version”: MP_UINT schema_version,
    }

The events are available from the beginning as non-``MP_NIL``.
It is necessary for supported local subscriptions.
Otherwise, there is no way to detect whether an event is supported at all by this Tarantool version.
If the events are broadcast before :doc:`box.cfg{} <reference/reference_lua/box_cfg>`,
then the following values are available:

..  code-block:: lua

    box.id = {}
    box.schema = {}
    box.status = {}
    box.election = {}

This way, users can distinguish if an event being not supported
at all or if ``box.cfg{}`` has not beeen called yet.
Otherwise, they would need to parse the ``_TARANTOOL`` version string locally and the ``peer_version`` in ``net.box``.

Usage example
-------------

..  code-block:: lua

    conn = net.box.connect(URI)
    -- Subscribe to updates of key 'box.id'
    w = conn:watch('box.id', function(key, value)
        assert(key == 'box.id')
        -- do something with value
    end)
    -- or to updates of key 'box.status'
    w = conn:watch('box.status', function(key, value)
        assert(key == 'box.status')
        -- do something with value
    end)
    -- or to updates of key 'box.election'
    w = conn:watch('box.election', function(key, value)
        assert(key == 'box.election')
        -- do something with value
    end)
    -- or to updates of key 'box.schema'
    w = conn:watch('box.schema', function(key, value)
        assert(key == 'box.schema')
        -- do something with value
    end)
    -- Unregister the watcher when it's no longer needed.
    w:unregister()


