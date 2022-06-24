.. _vshard-pubsub:

Pub/sub system and its events
=============================

Pub/sub is a notification system for Tarantool events.
It is related to one-time subscriptions.

The system processes the following events:

*   ``box.id``
*   ``box.status``
*   ``box.election``
*   ``box.schema``

As a reaction to each event, the server sends back specific IPROTO fields.

Built-in events for pub/sub
---------------------------

First, the important purpose of the built-in events is :ref:`master discovery <cfg_basic-master>`.
It is necessary to know the master node in order to send changes to a correct instance,
or read the most actual data.
Also, there are more built-in events for other mutable properties, like leader
state change, his election role and term, schema version change,
and instance state.

Built-in events have a special naming schema -- theirs name always starts with the ``box`` prefix.
This prefix is reserved for the built-in events. It means that you can't create new events with it.

Keep in mind that built-in events can't be overridden.
It means that the user can't call
:doc:`box.broadcast('box.id', any_data) <reference/reference_lua/box_watchers/broadcast>`.

Below is a table listing all the events, which includes the event name and its description.

..  container:: table

    ..  list-table::
        :widths: 50 50

        *   -   Built-in event
            -   Description

        *   -   box.id
            -   Identification of the instance. Changes are extra rare. Some
                values never change or change only once. For example, instance UUID never
                changes after the first box.cfg. But is not known before box.cfg is called.
                Replicaset UUID is unknown until the instance joins to a replicaset or
                boots a new one, but the events are supposed to start working before that --
                right at listen launch. Instance numeric ID is known only after
                registration. On anonymous replicas is 0 until they are registered officially.

        *   -   box.status
            -   Generic blob about instance status. It is most commonly used
                and not frequently changed config options and box.info fields.

        *   -   box.election
            -   All the needed parts of box.info.election needed to find who is the most recent writable leader.

        *   -   box.schema
            -   Schema-related data. Currently, it contains only version.

The value for each of the built-in events is written in the following code-block:.

-   ..  code-block:: lua

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

The events are available from the very beginning as not ``MP_NIL``.
It is necessary for supported local subscriptions.
Otherwise, there is no way to detect whether an event is even supported at all by this Tarantool version.
If the events are broadcast before :doc:`box.cfg{} <reference/reference_lua/box_cfg>`,
then the following values will be available:

..  code-block:: lua

    box.id = {}
    box.schema = {}
    box.status = {}
    box.election = {}

This way, the users can distinguish an event being not supported
at all from ``box.cfg{}`` being not called yet.
Otherwise, they would need to parse ``_TARANTOOL`` version string locally and ``peer_version`` in ``net.box``.

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


