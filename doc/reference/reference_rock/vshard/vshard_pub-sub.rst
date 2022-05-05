.. _vshard-pubsub:

Pub/sub system and its events
=============================

Pub/sub is a notification system for Tarantool events.
It is related to one-time subscriptions.

Events that the system will process:

box.id
box.status
box.election
box.schema

As a reaction to each event, the server sends back specific IPROTO fields.

Built-in events for pub/sub
---------------------------

The important purpose of the built-in events is to learn who is the
master, unless it is defined in an application specific way. Knowing who
is the master is necessary to send changes to a correct instance, and
probably make reads of the most actual data if it is important. Also
defined more built-in events for other mutable properties like leader
state change, his election role and election term, schema version change
and instance state.

Built-in events have a special naming schema --ё their name always starts
with box.. The prefix is reserved for built-in events. Creating new events
with this prefix is banned. Below is a list of all the events + their names
and values:

..  container:: table

    ..  list-table::
        :widths: 20 40 40

        *   -   Built-in event
            -   Description
            -   Value

        *   -   box.id
            -   Identification of the instance. Changes are extra rare. Some
                values never change or change only once. For example, instance UUID never
                changes after the first box.cfg. But is not known before box.cfg is called.
                Replicaset UUID is unknown until the instance joins to a replicaset or
                bootsa new one, but the events are supposed to start working before that -
                right at listen launch. Instance numeric ID is known only after
                registration. On anonymous replicas is 0 until they are registered officially.
            -   ..  code-block:: lua

                    {
                    MP_STR “id”: MP_UINT; box.info.id,
                    MP_STR “instance_uuid”: MP_UUID; box.info.uuid,
                    MP_STR “replicaset_uuid”: MP_UUID box.info.cluster.uuid,
                    }

        *   -   box.status
            -   Generic blob about instance status. It is most commonly used
                and not frequently changed config options and box.info fields.]
            -   ..  code-block:: lua

                    {
                    MP_STR “is_ro”: MP_BOOL box.info.ro,
                    MP_STR “is_ro_cfg”: MP_BOOL box.cfg.read_only,
                    MP_STR “status”: MP_STR box.info.status,
                    }

        *   -   box.election
            -   All the needed parts of box.info.election needed to find who is the most recent writable leader.
            -   ..  code-block:: lua

                    {
                    MP_STR “term”: MP_UINT box.info.election.term,
                    MP_STR “role”: MP_STR box.info.election.state,
                    MP_STR “is_ro”: MP_BOOL box.info.ro,
                    MP_STR “leader”: MP_UINT box.info.election.leader,
                    }

        *   -   box.schema
            -   Schema-related data. Currently it is only version.
            -   ..  code-block:: lua

                    {
                    MP_STR “version”: MP_UINT schema_version,
                    }

Built-in events can't be override. Meaning, users can't be able to call
box.broadcast(‘box.id’, any_data) etc.

The events are available from the very beginning as not MP_NIL. It's
necessary for supported local subscriptions. Otherwise, there is no way to detect
whether an event is even supported at all by this Tarantool version. If
events are broadcast before box.cfg{}, then the following values will
available:
box.id = {}
box.schema = {}
box.status = {}
box.election = {}

This way, the users will be able to distinguish an event being not supported
at all from ``box.cfg{}`` being not called yet. Otherwise they would need to
parse ``_TARANTOOL`` version string locally and peer_version in net.box.

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


